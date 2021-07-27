part of vcl;


const int MaxListSize = 0x7ffffff;

class EInvalidGridOperation extends TException
{
  EInvalidGridOperation(String msg) : super(msg);
}

  

class TGridAxisDrawInfo
{
  int EffectiveLineWidth = 0;
  int FixedBoundary = 0;
  int GridBoundary = 0;
  int GridExtent = 0;
  int LastVisibleCell = 0; // new
  int LastFullVisibleCell = 0;
  int FullVisBoundary = 0;
  int FixedCellCount = 0;
  int FirstGridCell = 0;
  int GridCellCount = 0;

  var GetExtent = null;
}

class TGridDrawInfo
{
  final TGridAxisDrawInfo Horz = TGridAxisDrawInfo();
  final TGridAxisDrawInfo Vert = TGridAxisDrawInfo();
}

enum TGridState {Normal, Selecting, RowSizing, ColSizing, RowMoving, ColMoving}

enum GridOptions {FixedVertLine, FixedHorzLine, VertLine, HorzLine,
  RangeSelect, DrawFocusSelected, RowSizing, ColSizing, RowMoving,
  ColMoving, Editing, Tabs, RowSelect,
  AlwaysShowEditor, ThumbTracking}

typedef TGridOptions = Set<GridOptions>;





enum TGridDrawStates { Selected, Focused, Fixed }

typedef TGridDrawState = Set<TGridDrawStates>;


class TGridSizing
{
  final TCustomGrid grid;

  TGridSizing(this.grid);

  TGridState State = TGridState.Normal;


  int Index = 0;
  int Pos = 0;
  int Ofs = 0;
  int MoveIndex = 0;
  int MovePos = 0;

  Element? _elem;
  void Invalidate()
  {
    if(State == TGridState.Normal)
    {
      if(_elem != null)
      {
        _elem!.remove();
        _elem = null;
      }
      return;
    }

    if(_elem==null)
    {
      _elem = DivElement();
      _elem!.owner = grid.Handle;

      _elem!.style.position='relative';
      _elem!.style.background = 'linear-gradient(to right, #8080ff40, #8080ffC0, #8080ff40)';

      _elem!.setParent(grid.Handle.handle);
    }

    _elem!.style.left='${Pos-1}px';
    _elem!.style.top='${1}px';
    _elem!.style.width='${3}px';

    _elem!.style.height='${grid.ClientHeight+2}px';

  }

  void DrawMove()
  {

  }
}

class TGridExtent
{
  List<int>? Extents;

  TGridExtent()
  {

  }

  void Update(int NewSize,  int Default)
  {
    int OldSize = 0;
    if(Extents != null)
      OldSize = Extents!.length;
    Modify(OldSize, NewSize - OldSize, Default);
  }

  void Modify(int Index, int Amount, int Default)
  {
    if(Amount == 0)
      return;
    int OldSize = Extents == null? 0 : Extents!.length;
    if((Index < 0) || (OldSize < Index))
      InvalidOp(Consts.SIndexOutOfRange);
    int NewSize = OldSize + Amount;
    if(NewSize < 0)
      InvalidOp(Consts.STooManyDeleted);
    else
    if(NewSize >= MaxListSize)
      InvalidOp(Consts.SGridTooLarge);

    if(Extents == null)
      Extents = <int>[];
    Extents!.resize(NewSize, Default);




    for(int i = Index; i<NewSize; i++)
      Extents![i] = Default;
  }

  bool Allocated()
  {
    return Extents != null;
  }

  int operator [](int index) => Extents![index];
  void operator []=(int index, int value) => Extents![index] = value;

}

class TGridCell // new
{
   final TableCellElement Handle;
   final int Col;
   final int Row;
   final TGridDrawState State;

   TGridCell(this.Handle, this.Col, this.Row, this.State)
   {
   }

   bool IsActive()
   {
     return State==TGridDrawStates.Focused || State==TGridDrawStates.Selected;
   }

   TAlignment? _alignment;
   TAlignment
     get Alignment => _alignment ?? TAlignment.LeftJustify;
     set Alignment(TAlignment val)
     {
       if(_alignment==val)
         return;
       _alignment=val;
       ValidateAlignment();
     }

   void ValidateAlignment()
   {
     var p = Handle.childNodes[0] as ParagraphElement;
     switch(Alignment)
     {
       case TAlignment.LeftJustify:
         p.style.textAlign='left';
         break;
       case TAlignment.RightJustify:
         p.style.textAlign='right';
         break;
       case TAlignment.Center:
         p.style.textAlign='center';
         break;
     }
   }

   void ChangeClassState(String name, bool state)
   {
     ParagraphElement p = Handle.childNodes[0] as ParagraphElement;
     if(state)
       p.classes.add(name);
     else
       p.classes.remove(name);
   }

   String? _value;
   String?
     get Value => _value;
     set Value(String? val)
     {
       if(_value==val)
         return;
       _value=val;
       ValidateValue();
     }

   void ValidateValue()
   {
     Handle.childNodes[0].text = Value;
   }

   TColor? _brushColor;
   TColor
     get BrushColor
     {
       if(_brushColor!=null)
         return _brushColor!;

       return TColor.parse(Handle.getComputedStyle().backgroundColor);
     }

     set BrushColor(TColor val)
     {
       if(_brushColor==val)
         return;
       _brushColor=val;
       Style.background = _brushColor==null? null : BrushColor.html;
     }

   TColor? _fontColor;
   TColor?
     get FontColor => _fontColor;
     set FontColor(TColor? val)
     {
       if(_fontColor==val)
         return;
       _fontColor=val;
       Style.color = FontColor==null? null : FontColor!.html;
     }

   CssStyleDeclaration get Style => Handle.style;
}



class TGridCoord
{
  int X;
  int Y;

  TGridCoord( [this.X=0, this.Y=0] );

  TGridCoord Copy() => TGridCoord(X, Y);

  void Assign(TGridCoord pt)
  {
    X = pt.X;
    Y = pt.Y;
  }

  String toString()
  {
    return 'TGridCoord($X, $Y)';
  }
}

class TGridRect
{
  int Left;
  int Top;
  int Right;
  int Bottom;

  TGridCoord TopLeft() => TGridCoord(Left, Top);
  TGridCoord BottomRight() => TGridCoord(Right, Bottom);

  TGridRect Copy() => TGridRect(Left, Top, Right, Bottom);
  TRect ToRect() => TRect(Left, Top, Right, Bottom);

  TGridRect( [this.Left=0, this.Top=0, this.Right=0, this.Bottom=0] );

}


void InvalidOp(String id)
{
  throw EInvalidGridOperation(id);
}

TGridRect GridRect(TGridCoord Coord1, TGridCoord Coord2)
{
  return TGridRect
    (
      Coord1.X < Coord2.X? Coord1.X : Coord2.X,
      Coord1.Y < Coord2.Y? Coord1.Y : Coord2.Y,
      Coord1.X < Coord2.X? Coord2.X : Coord1.X,
      Coord1.Y < Coord2.Y? Coord2.Y : Coord1.Y
    );
}



class TInplaceEdit  extends TCustomMaskEdit
{


  TInplaceEdit(TComponent AOwner) : super(AOwner)
  {

    TabStop = false;

  }


  void Deselect()
  {

  }


}


class TCustomGrid extends TCustomControl
{

  final _anchor = TGridCoord();

  int _colCount = 5;
  int
    get ColCount => _colCount;
    set ColCount(int Value)
    {
      if(_colCount == Value)
        return;
      if(Value < 1)
        Value = 1;
      if(Value <= FixedCols)
        FixedCols = Value - 1;
      ChangeSize(Value, RowCount);
      if(Options.contains(GridOptions.RowSelect))
      {
        _anchor.X = ColCount - 1;
        Invalidate();
      }
    }

  TGridExtent _colWidths = TGridExtent();
  late final TItems<int> ColWidths;

  TGridExtent _tabStops = TGridExtent();
  late final TItems<bool> TabStops;

  final _current = TGridCoord();

  int
    get Col => _current.X;
    set Col(int Value)
    {
      if(Col != Value)
        FocusCell(Value, Row, true);
    }

  int
    get Row => _current.Y;
    set Row(int Value)
    {
      if(Row != Value)
        FocusCell(Col, Value, true);
    }

  int _defaultColWidth = 64;
  int
    get DefaultColWidth => _defaultColWidth;
    set DefaultColWidth(int Value)
    {
      if(_colWidths.Allocated())
        _colWidths.Update(0, 0);
      _defaultColWidth = Value;
      ColWidthsChanged();
      InvalidateGrid();
    }

  int _defaultRowHeight = SysMetric.CellCy;
  int
    get DefaultRowHeight => _defaultRowHeight;
    set DefaultRowHeight(int Value)
    {
      if(_rowHeights.Allocated())
        _rowHeights.Update(0, 0);
      _defaultRowHeight = Value;
      RowHeightsChanged();
      InvalidateGrid();
    }

  int _fixedCols = 1;
  int
    get FixedCols => _fixedCols;
    set FixedCols(int Value)
    {
      if(_fixedCols == Value)
        return;
      if(Value < 0)
        InvalidOp(Consts.SIndexOutOfRange);
      if(Value >= ColCount)
        InvalidOp(Consts.SFixedColTooBig);
      _fixedCols = Value;
      Initialize();
      InvalidateGrid();
    }

  int _fixedRows = 1;
  int
    get FixedRows => _fixedRows;
    set FixedRows(int Value)
    {
      if(_fixedRows == Value)
        return;
      if(Value < 0)
        InvalidOp(Consts.SIndexOutOfRange);
      if(Value >= RowCount)
        InvalidOp(Consts.SFixedRowTooBig);
      _fixedRows = Value;
      Initialize();
      InvalidateGrid();
    }


  int _gridLineWidth = 1;
  int
    get GridLineWidth => _gridLineWidth;
    set GridLineWidth(int Value)
    {
      if(_gridLineWidth == Value)
        return;
      _gridLineWidth = Value;
      InvalidateGrid();
    }


  final TGridOptions _options = TGridOptions.from( {
    GridOptions.FixedVertLine, GridOptions.FixedHorzLine,
    GridOptions.VertLine, GridOptions.HorzLine, GridOptions.RangeSelect} );

  TGridOptions
    get Options => _options;
    set Options(TGridOptions Value)
    {
      if(_options.isEqual(Value))
        return;
      if(Value.contains(GridOptions.RowSelect))
        Value>>GridOptions.AlwaysShowEditor;
      _options.assign(Value);
      if(!_editorMode)
      {
        if(Value.contains(GridOptions.AlwaysShowEditor))
          ShowEditor();
        else
          HideEditor();
      }
      if(Value.contains(GridOptions.RowSelect))
        MoveCurrent(Col, Row,  true, false);
      InvalidateGrid();
    }


  int _rowCount = 5;
  int
    get RowCount => _rowCount;
    set RowCount(int Value)
    {
      if(_rowCount == Value)
        return;
      if(Value < 1)
        Value = 1;
      if(Value <= FixedRows)
        FixedRows = Value - 1;
      ChangeSize(ColCount, Value);
    }

  final _rowHeights = TGridExtent();
  late final TItems<int> RowHeights;


  TScrollStyle _scrollBars = TScrollStyle.Both;
  TScrollStyle
    get ScrollBars => _scrollBars;
    set ScrollBars(TScrollStyle Value)
    {
      if(_scrollBars == Value)
        return;
      _scrollBars = Value;
      if(HandleAllocated())
      {
        _grid!.updateScrollBars(_scrollBars); 
        ConstrainGrid();
      }
      
    }

  TGridCoord _topLeft = TGridCoord();

  int
    get LeftCol => _topLeft.X;
    set LeftCol(int Value)
    {
      if(_topLeft.X != Value)
        MoveTopLeft(Value, TopRow);
    }

  int
    get TopRow => _topLeft.Y;
    set TopRow(int Value)
    {
      if(_topLeft.Y != Value)
        MoveTopLeft(LeftCol, Value);
    }


  TInplaceEdit? _inplaceEdit;
  TInplaceEdit? get InplaceEditor => _inplaceEdit;

  int _inplaceCol = -1;
  int _inplaceRow = -1;
  int _colOffset = 0;


  bool _editorMode = false;
  bool
    get EditorMode => _editorMode;
    set EditorMode(bool Value)
    {
      if(Value)
      {
        ShowEditor();
        _inplaceEdit?.Deselect();
      }
      else
        HideEditor();
    }

  late final TGridSizing _gridSizing;

  final DesignOptionsBoost = TGridOptions.from( { GridOptions.ColSizing, GridOptions.RowSizing } );
  bool _virtualView = false;


    TGridRect
      get Selection => GridRect(_current, _anchor);
      set Selection(TGridRect Value)
      {
        TGridRect OldSel = Selection;
        _anchor.Assign( Value.TopLeft() );
        _current.Assign( Value.BottomRight() );
        SelectionMoved(OldSel);
      }
    
  TCustomGrid(TComponent AOwner) : super(AOwner)
  {
    ControlStyle.assign( [ ControlStyles.CaptureMouse, ControlStyles.Opaque, ControlStyles.DoubleClicks] );


    ColWidths = TItems<int>(
        (ndx) => GetColWidths(ndx),
        ()    => throw UnimplementedError(),
        (ndx, value) => SetColWidths(ndx, value));

    RowHeights = TItems<int>(
        (ndx) => GetRowHeights(ndx),
        ()    => throw UnimplementedError(),
        (ndx, value) => SetRowHeights(ndx, value));

    TabStops = TItems<bool>(
        (ndx) => GetTabStops(ndx),
        ()    => throw UnimplementedError(),
        (ndx, value) => SetTabStops(ndx, value));

    _gridSizing = TGridSizing(this);

    TabStop = true;
    SetBounds(Left, Top, _colCount * _defaultColWidth, _rowCount * _defaultRowHeight);
    Initialize();
  }

  void Destroy()
  {

    super.Destroy();
  }

  HGrid? _grid;

  void CreateWindowHandle(TCreateParams Params)
  {
    _grid = HGrid();
    _grid!.updateScrollBars(ScrollBars); 
    WindowHandle = _grid;

  }

  void CreateWnd()
  {
    super.CreateWnd();
    ConstrainGrid();
  }

  TScroll GetScrollArea() => _grid!.scroll;

  void ConstrainGrid()
  { 
    if(_grid == null)
      return;
    TableSectionElement body = _grid!.body;

    int dch = SysMetric.CellCy;
    while(body.rows.length > RowCount)
      body.deleteRow(body.rows.length-1);
    while(body.rows.length<RowCount)
      body.addRow();

    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);

    List<int> cols = <int>[];
    for(int i=0; i<DrawInfo.Horz.FixedCellCount; i++)
      cols.add(i);
    for(int i=DrawInfo.Horz.FirstGridCell; i<=DrawInfo.Horz.LastVisibleCell; i++)
      cols.add(i);

    for(int i = 0; i < RowCount; i++)
    {
      TableRowElement row = body.rows[i];
      row.style.height = '${dch}px';
      while(row.cells.length>cols.length)
        row.deleteCell(row.cells.length-1);

      while(row.cells.length<cols.length)
      {
        TableCellElement cell = row.addCell();
        Element p = Element.p();
        p.className='cell_p';
        cell.append(p);
      }
      for(int j=0; j<cols.length; j++)
      {
        Element? p=row.cells[j].childNodes[0] as Element?;
        p?.style.width = '${ GetColWidths(cols[j]) }px';
      }
    }

    Invalidate();
  }





  TRect BoxRect(int ALeft, int ATop, int ARight, int ABottom)

  {
    TRect GridRect = TRect(ALeft, ATop, ARight, ABottom);
    return GridRectToScreenRect(GridRect, false);
  }


  TRect CellRect(int ACol, int ARow)
  {
    return BoxRect(ACol, ARow, ACol, ARow);
  }

  bool CanEditAcceptKey(int Key)
  {
    return true;
  }

  bool CanGridAcceptKey(TKeyCode Key, TShiftState Shift)
  {
    return true;
  }



  bool IsActiveControl()
  {
    return true;

  }



  String GetEditText(int ACol, int ARow)
  {
    return "";
  }

  void SetEditText(int ACol, int ARow, final String Value)
  {

  }



  void HideEditor()
  {
    _editorMode = false;
    HideEdit();
  }

  void ShowEditor()
  {
    _editorMode = true;
    
  }



  void InvalidateEditor()
  {
    _inplaceCol = -1;
    _inplaceRow = -1;
    UpdateEdit();
  }



  void MoveColumn(int FromIndex, int ToIndex)
  {

  }

  void ColumnMoved(int FromIndex, int ToIndex)
  {

  }

  void MoveRow(int FromIndex, int ToIndex)
  {

  }

  void RowMoved(int FromIndex, int ToIndex)
  {

  }

  TGridCoord MouseCoord(int X, int Y)
  {
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    TGridCoord Result = CalcCoordFromPoint(X, Y, DrawInfo);
    if(Result.X < 0)
      Result.Y = -1;
    else
    if(Result.Y < 0)
      Result.X = -1;
    return Result;
  }

  void MoveColRow(int ACol, int ARow, bool MoveAnchor, bool Show)
  {
    MoveCurrent(ACol, ARow, MoveAnchor, Show);
  }

  bool SelectCell(int ACol, int ARow)
  {
    return true;
  }

  void SizeChanged(int OldColCount, int OldRowCount)
  {

  }

  bool Sizing(int X, int Y)
  {
    if(_gridSizing.State != TGridState.Normal)
      return true;

    TGridSizing gs = TGridSizing(this);
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    CalcSizingState(X, Y, gs, DrawInfo);
    return gs.State != TGridState.Normal;
  }

  void TopLeftChanged()
  {

  }



  void Paint()
  {

    _gridSizing.Invalidate();
    TGridDrawInfo DrawInfo = TGridDrawInfo();


    TGridCell CreateGridCell(TableCellElement Handle, int Col, int Row, TGridDrawState State)
    {
      return TGridCell(Handle, Col, Row, State);
    }

    void DrawCells(int ACol, int ARow, int StartX, int StartY, int StopX, int StopY, TGridDrawState IncludeDrawState)
    {
      TableSectionElement body = _grid!.body;

      bool Focused = IsActiveControl();
      TRect Where = TRect();

      int CurRow = ARow;
      Where.top = StartY;
      while((Where.top < StopY) && (CurRow < RowCount))
      {
        int CurCol = ACol;
        Where.left = StartX;
        Where.bottom = Where.top + GetRowHeights(CurRow);
        while((Where.left < StopX) && (CurCol < ColCount))
        {
          Where.right = Where.left + GetColWidths(CurCol);
          if((Where.right > Where.left)/* && RectVisible(Canvas.Handle, Where)*/)
          {
            TGridDrawState DrawState = TGridDrawState();
            DrawState.assign(IncludeDrawState);
            if(Focused && (CurRow == Row) && (Options.contains(GridOptions.RowSelect)? true : CurCol == Col))
              DrawState << TGridDrawStates.Focused;



              int ci = CurCol;
              if(ci>=DrawInfo.Horz.FixedCellCount)
                ci-=DrawInfo.Horz.FirstGridCell-1;
              if(CurRow<body.rows.length)
              {
                TableRowElement row = body.rows[CurRow];
                if(ci<row.cells.length)
                  DrawCell(CreateGridCell(row.cells[ci], CurCol, CurRow, DrawState));
              }

          }
          Where.left = Where.right + DrawInfo.Horz.EffectiveLineWidth;
          CurCol++;
        }
        Where.top = Where.bottom + DrawInfo.Vert.EffectiveLineWidth;
        CurRow++;
      }
    }

    
    CalcDrawInfo(DrawInfo);


    DrawCells(0, 0, 0, 0, DrawInfo.Horz.FixedBoundary, DrawInfo.Vert.FixedBoundary, TGridDrawState.from({ TGridDrawStates.Fixed }));
    DrawCells(LeftCol, 0, DrawInfo.Horz.FixedBoundary - _colOffset, 0, DrawInfo.Horz.GridBoundary, DrawInfo.Vert.FixedBoundary, TGridDrawState.from({ TGridDrawStates.Fixed }));
    DrawCells(0, TopRow, 0, DrawInfo.Vert.FixedBoundary, DrawInfo.Horz.FixedBoundary, DrawInfo.Vert.GridBoundary, TGridDrawState.from( { TGridDrawStates.Fixed }));
    DrawCells(LeftCol, TopRow, DrawInfo.Horz.FixedBoundary - _colOffset, DrawInfo.Vert.FixedBoundary, DrawInfo.Horz.GridBoundary, DrawInfo.Vert.GridBoundary, TGridDrawState());


  }

  void DrawCell(TGridCell Cell)
  {

    if(Cell.Col<FixedCols || Cell.Row<FixedRows)
      Cell.Handle.className='fixed_cell';
    else
    {
      Cell.Handle.className = 'cell';
      if(Cell.State.contains(TGridDrawStates.Focused))
      {
        Cell.Style.background = Focused()? clActiveRecord.html : clInactiveRecord.html;
        
        Cell.Style.color = clWhite.html;
      }
      else
      {
        Cell.Style.background=clWhite.html;
        Cell.Style.color = clBlack.html;
      }
    }
  }



  TGridCoord CalcCoordFromPoint(int X, int Y, TGridDrawInfo DrawInfo)
  {
    int DoCalc(final TGridAxisDrawInfo AxisInfo, int N)
    {
      int Start, Stop, Line;
      if(N < AxisInfo.FixedBoundary)
      {
        Start = 0;

        Stop =  AxisInfo.FixedCellCount - 1;
        Line = 0;
      }
      else
      {
        Start = AxisInfo.FirstGridCell;

        Stop = AxisInfo.GridCellCount - 1;
        Line = AxisInfo.FixedBoundary;
      }
      for(int i = Start; i<=Stop; i++)
      {
        Line+=(AxisInfo.GetExtent(i) as int) + AxisInfo.EffectiveLineWidth;
        if(N < Line)
          return i;
      }
      return -1;
    }

    int DoCalcRightToLeft(final TGridAxisDrawInfo AxisInfo, int N)
    {
      throw UnimplementedError();
  
    }

    if(!UseRightToLeftAlignment())
      return TGridCoord(DoCalc(DrawInfo.Horz, X), DoCalc(DrawInfo.Vert, Y));

    return TGridCoord(DoCalcRightToLeft(DrawInfo.Horz, X), DoCalc(DrawInfo.Vert, Y));
  }

  TRect GetClientRect()
  {
    if(HandleAllocated())
    {
      if(_handle!.handle.offsetParent==null)
      {
        TRect rect = super.GetClientRect();
        rect.right-=2;
        rect.bottom-=2;
        return rect;
      }
      return TRect(0, 0, _grid!.clientWidth - 2, _grid!.clientHeight - 2);
    }
    return super.GetClientRect();
  }

  void CalcDrawInfo(TGridDrawInfo DrawInfo)
  {

    TRect rect=GetClientRect();
    CalcDrawInfoXY(DrawInfo, rect.width, rect.height);

  }

  void CalcDrawInfoXY(TGridDrawInfo DrawInfo, int UseWidth, int UseHeight)
  {

    void CalcAxis(TGridAxisDrawInfo AxisInfo, int UseExtent)
    {
      AxisInfo.GridExtent = UseExtent;
      AxisInfo.GridBoundary = AxisInfo.FixedBoundary;
      AxisInfo.FullVisBoundary = AxisInfo.FixedBoundary;
      AxisInfo.LastFullVisibleCell = AxisInfo.FirstGridCell;

      for (int i = AxisInfo.FirstGridCell; i < AxisInfo.GridCellCount; i++)
      {
        AxisInfo.GridBoundary +=(AxisInfo.GetExtent(i) as int) + AxisInfo.EffectiveLineWidth;
        if (AxisInfo.GridBoundary > AxisInfo.GridExtent + AxisInfo.EffectiveLineWidth)
        {
          AxisInfo.GridBoundary = AxisInfo.GridExtent;
          AxisInfo.LastVisibleCell = i;

          break;
        }
        AxisInfo.LastFullVisibleCell = i;
        AxisInfo.LastVisibleCell = i;
        AxisInfo.FullVisBoundary = AxisInfo.GridBoundary;
      }
    }

    CalcFixedInfo(DrawInfo);
    CalcAxis(DrawInfo.Horz, UseWidth);
    CalcAxis(DrawInfo.Vert, UseHeight);
  }

  void CalcFixedInfo(TGridDrawInfo DrawInfo)
  {

    void CalcFixedAxis(TGridAxisDrawInfo Axis, TGridOptions LineOptions,
        int FixedCount, int FirstCell, int CellCount, Function GetExtentFunc)
    {


      Axis.EffectiveLineWidth = GridLineWidth;

      Axis.FixedBoundary = 0;
      for (int i = 0; i < FixedCount; i++)
        Axis.FixedBoundary += (GetExtentFunc(i) as int) + Axis.EffectiveLineWidth;

      Axis.FixedCellCount = FixedCount;
      Axis.FirstGridCell = FirstCell;
      Axis.GridCellCount = CellCount;
      Axis.GetExtent = GetExtentFunc;
    }

    CalcFixedAxis(DrawInfo.Horz,
        TGridOptions.from( { GridOptions.FixedVertLine, GridOptions.VertLine } ), FixedCols, LeftCol, ColCount, GetColWidths);
    CalcFixedAxis(DrawInfo.Vert,
        TGridOptions.from( { GridOptions.FixedHorzLine, GridOptions.HorzLine } ), FixedRows, TopRow, RowCount, GetRowHeights);
  }

  // Calculates the TopLeft that will put the given Coord in view
  TGridCoord CalcMaxTopLeft(TGridCoord Coord, TGridDrawInfo DrawInfo)
  {
    int CalcMaxCell(TGridAxisDrawInfo Axis, int Start)
    {
      int Result = Start;
      int Line = Axis.GridExtent + Axis.EffectiveLineWidth;
      for(int i = Start;  i >= Axis.FixedCellCount; i--)
      {
        int Extent = Axis.GetExtent(i);
        if(Extent > 0)
        {
          Line-=Extent;
          Line-=Axis.EffectiveLineWidth;
          if(Line < Axis.FixedBoundary)
          {
            if((Result == Start) && (Axis.GetExtent(Start) <= 0))
              Result = i;
            break;
          }
          Result = i;
        }
      }
      return Result;
    }

    return TGridCoord(
        CalcMaxCell(DrawInfo.Horz, Coord.X),
        CalcMaxCell(DrawInfo.Vert, Coord.Y) );
  }


  void CalcSizingState(int X, int Y, TGridSizing Info, TGridDrawInfo FixedInfo)
  {

    void CalcAxisState(final TGridAxisDrawInfo AxisInfo, int Pos, TGridState NewState)
    {

      if((NewState == TGridState.ColSizing) && UseRightToLeftAlignment())
        Pos = ClientWidth - Pos;

      int Line =  AxisInfo.FixedBoundary;
      int Range = AxisInfo.EffectiveLineWidth;
      int Back = 0;
      if(Range < 7)
      {
        Range = 7;
        Back = (Range - AxisInfo.EffectiveLineWidth) >> 1;
      }
      for(int I = AxisInfo.FirstGridCell; I<AxisInfo.GridCellCount; I++)
      {
        Line+=(AxisInfo.GetExtent(I) as int);
        if(Line > AxisInfo.GridBoundary)
          break;
        if((Pos >= Line - Back) && (Pos <= Line - Back + Range))
        {
          Info.State = NewState;
          Info.Pos = Line;
          Info.Ofs = Line - Pos;
          Info.Index = I;
          return;
        }
        Line+=AxisInfo.EffectiveLineWidth;
      }
      if((AxisInfo.GridBoundary == AxisInfo.GridExtent) && (Pos >= AxisInfo.GridExtent - Back)
          && (Pos <= AxisInfo.GridExtent))
      {
        Info.State = NewState;
        Info.Pos = AxisInfo.GridExtent;
        Info.Ofs = AxisInfo.GridExtent - Pos;
        Info.Index = AxisInfo.LastFullVisibleCell + 1;
      }
    }

    bool XOutsideHorzFixedBoundary()
    {
      if(!UseRightToLeftAlignment())
        return X > FixedInfo.Horz.FixedBoundary;
      return X < ClientWidth - FixedInfo.Horz.FixedBoundary;
    }

    bool XOutsideOrEqualHorzFixedBoundary()
    {
      if(!UseRightToLeftAlignment())
        return X >= FixedInfo.Horz.FixedBoundary;
      return X <= ClientWidth - FixedInfo.Horz.FixedBoundary;
    }


    Info.State = TGridState.Normal;
    Info.Index = -1;
    TGridOptions EffectiveOptions = TGridOptions();
    EffectiveOptions.assign(Options);
    if(ComponentState.contains(ComponentStates.Designing))
      EffectiveOptions.assign(DesignOptionsBoost);

    if(Options.contains(GridOptions.ColSizing) || Options.contains(GridOptions.RowSizing))
    {
      
      FixedInfo.Vert.GridExtent = ClientHeight;
      FixedInfo.Horz.GridExtent = ClientWidth;
      if(XOutsideHorzFixedBoundary() && Options.contains(GridOptions.ColSizing))
      {
        if(Y >= FixedInfo.Vert.FixedBoundary)
          return;
        CalcAxisState(FixedInfo.Horz, X, TGridState.ColSizing);
      }
      else
      if((Y > FixedInfo.Vert.FixedBoundary) &&  Options.contains(GridOptions.RowSizing))
      {
        if(XOutsideOrEqualHorzFixedBoundary())
          return;
        CalcAxisState(FixedInfo.Vert, Y, TGridState.RowSizing);
      }
    }
  }



  void ChangeSize(int NewColCount, int NewRowCount)
  {
    TGridDrawInfo OldDrawInfo = TGridDrawInfo();
    int OldColCount = -1;
    int OldRowCount = -1;

    void MinRedraw(final TGridAxisDrawInfo OldInfo, TGridAxisDrawInfo NewInfo, int Axis)
    {

    }

    void DoChange()
    {
      if(_colWidths.Allocated())
        _colWidths.Update(ColCount, DefaultColWidth);
      if(_tabStops.Allocated())
        _tabStops.Update(ColCount, 1);
      if(_rowHeights.Allocated())
        _rowHeights.Update(RowCount, DefaultRowHeight);
      TGridCoord Coord = _current.Copy();
      if(Row >= RowCount)
        Coord.Y = RowCount - 1;
      if(Col >= ColCount)
        Coord.X = ColCount - 1;
      if((_current.X != Coord.X) || (_current.Y != Coord.Y))
        MoveCurrent(Coord.X, Coord.Y, true, true);
      if((_anchor.X != Coord.X) || (_anchor.Y != Coord.Y))
        MoveAnchor(Coord);

      if(_virtualView ||
          (LeftCol != OldDrawInfo.Horz.FirstGridCell) ||
          (TopRow != OldDrawInfo.Vert.FirstGridCell))
          InvalidateGrid();
      else
      if(HandleAllocated())
      {
        TGridDrawInfo NewDrawInfo = TGridDrawInfo();
        CalcDrawInfo(NewDrawInfo);
        MinRedraw(OldDrawInfo.Horz, NewDrawInfo.Horz, 0);
        MinRedraw(OldDrawInfo.Vert, NewDrawInfo.Vert, -1);
      }
      UpdateScrollRange();
      SizeChanged(OldColCount, OldRowCount);
    }


    if(HandleAllocated())
      CalcDrawInfo(OldDrawInfo);
    OldColCount = _colCount;
    OldRowCount = _rowCount;
    _colCount = NewColCount;
    _rowCount = NewRowCount;
    if(FixedCols > NewColCount)
      _fixedCols = NewColCount - 1;
    if(FixedRows > NewRowCount)
      _fixedRows = NewRowCount - 1;
    try
    {
      DoChange();
    }
    catch(E)
    {
      // Could not change size so try to clean up by setting the size back
      _colCount = OldColCount;
      _rowCount = OldRowCount;
      DoChange();
      InvalidateGrid();
      throw E;
    }

  
  }

  // Will move TopLeft so that Coord is in view
  void ClampInView(TGridCoord Coord)
  {
    if(!HandleAllocated())
      return;
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);

    if((Coord.X > DrawInfo.Horz.LastFullVisibleCell) ||
        (Coord.Y > DrawInfo.Vert.LastFullVisibleCell) || (Coord.X < LeftCol) || (Coord.Y < TopRow))
    {
      TGridCoord OldTopLeft = _topLeft.Copy();
      TGridCoord MaxTopLeft = CalcMaxTopLeft(Coord, DrawInfo);
      Update();
      if(Coord.X < LeftCol)
        _topLeft.X = Coord.X;
      else
      if(Coord.X > DrawInfo.Horz.LastFullVisibleCell)
        _topLeft.X = MaxTopLeft.X;
      if(Coord.Y < TopRow)
        _topLeft.Y = Coord.Y;
      else
      if(Coord.Y > DrawInfo.Vert.LastFullVisibleCell)
        _topLeft.Y = MaxTopLeft.Y;
      TopLeftMoved(OldTopLeft.X, OldTopLeft.Y);
    }
  }

  void DrawSizingLine(TGridDrawInfo DrawInfo)
  {
    _gridSizing.Invalidate();

  }

  void DrawMove()
  {

  }

  void FocusCell(int ACol, int ARow, bool MoveAnchor)
  {
    MoveCurrent(ACol, ARow, MoveAnchor, true);
    UpdateEdit();
    Click();
  }

  TRect GridRectToScreenRect(TRect GridRect, bool IncludeLine)
  {
    int LinePos(TGridAxisDrawInfo AxisInfo, int Line)
    {
      int Result = 0;
      int Start;
      if(Line < AxisInfo.FixedCellCount)
        Start = 0;
      else
      {
        if(Line >= AxisInfo.FirstGridCell)
          Result = AxisInfo.FixedBoundary;
        Start = AxisInfo.FirstGridCell;
      }
      for(int i = Start; i<Line; i++)
      {
        Result+=(AxisInfo.GetExtent(i) as int) + AxisInfo.EffectiveLineWidth;
        if(Result > AxisInfo.GridExtent)
          return 0;
      }
      return Result;
    }

    bool CalcAxis(TGridAxisDrawInfo AxisInfo, int GridRectMin, int GridRectMax, TPoint ScreenPt)
    {
      if((GridRectMin >= AxisInfo.FixedCellCount) && (GridRectMin < AxisInfo.FirstGridCell))
        if(GridRectMax < AxisInfo.FirstGridCell)
        {

          return false;
        }
        else
          GridRectMin = AxisInfo.FirstGridCell;
      if(GridRectMax > AxisInfo.LastFullVisibleCell)
      {
        GridRectMax = AxisInfo.LastFullVisibleCell;
        if(GridRectMax < AxisInfo.GridCellCount - 1)
          GridRectMax++;
        if(LinePos(AxisInfo, GridRectMax) == 0)
          GridRectMax--;
      }

      ScreenPt.x = LinePos(AxisInfo, GridRectMin);
      ScreenPt.y = LinePos(AxisInfo, GridRectMax);
      if(ScreenPt.y == 0)
        ScreenPt.y = ScreenPt.x + (AxisInfo.GetExtent(GridRectMin) as int);
      else
        ScreenPt.y+=(AxisInfo.GetExtent(GridRectMax) as int);
      if(ScreenPt.y > AxisInfo.GridExtent)
        ScreenPt.y = AxisInfo.GridExtent;
      if(IncludeLine)
        ScreenPt.y+=AxisInfo.EffectiveLineWidth;
      return true;
    }


    if((GridRect.left > GridRect.right) || (GridRect.top > GridRect.bottom))
      return TRect();
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);

    if(GridRect.left > DrawInfo.Horz.LastFullVisibleCell + 1)
      return TRect();
    if(GridRect.top > DrawInfo.Vert.LastFullVisibleCell + 1)
      return TRect();

    TPoint lr = TPoint();
    TPoint tb = TPoint();
    if(CalcAxis(DrawInfo.Horz, GridRect.left, GridRect.right, lr) &&
        CalcAxis(DrawInfo.Vert, GridRect.top, GridRect.bottom, tb))
      return TRect(lr.x, lr.y, tb.x, tb.y);
    return TRect();


  }

  void Initialize()
  {
    _topLeft.X = FixedCols;
    _topLeft.Y = FixedRows;
    _current.Assign(_topLeft);
    _anchor.Assign(_current);
    if(Options.contains(GridOptions.RowSelect))
      _anchor.X = ColCount - 1;
  }

  void InvalidateCell(int ACol, int ARow)
  {
    InvalidateRect(TGridRect(ACol, ARow, ACol, ARow));
  }

  void InvalidateCol(int ACol)
  {
    InvalidateRect(TGridRect(ACol, 0, VisibleRowCount + 1, ACol));
  }

  void InvalidateRow(int ARow)
  {
    InvalidateRect(TGridRect(0, ARow, VisibleRowCount + 1, ARow));
  }

  void InvalidateGrid()
  {
    Invalidate();
  }

  void InvalidateRect(TGridRect ARect)
  {
    if(!HandleAllocated())
      return;
    TRect InvalidRect =  GridRectToScreenRect(ARect.ToRect(), true);
    Windows.InvalidateRect(Handle, InvalidRect, false);
  }

  void ModifyScrollBar(int ScrollBar, int ScrollCode, int Pos, bool UseRightToLeft)
  {
    TGridCoord MaxTopLeft = TGridCoord();
    int RTLFactor = 0;
    TGridDrawInfo DrawInfo = TGridDrawInfo();

    int Min()
    {
      return ScrollBar == Windows.SB_HORZ? FixedCols : FixedRows;
    }

    int Max()
    {
      return ScrollBar == Windows.SB_HORZ? MaxTopLeft.X : MaxTopLeft.Y;
    }

    int PageUp()
    {
      int Result;
      TGridCoord MaxTopLeft = CalcMaxTopLeft(_topLeft, DrawInfo);
      if(ScrollBar == Windows.SB_HORZ)
        Result = _topLeft.X - MaxTopLeft.X;
      else
        Result = _topLeft.Y - MaxTopLeft.Y;
      if(Result < 1)
        return 1;
      return Result;
    }

    int PageDown()
    {
      TGridDrawInfo DrawInfo = TGridDrawInfo();
      CalcDrawInfo(DrawInfo);
      int Result;
      if(ScrollBar == Windows.SB_HORZ)
        Result = DrawInfo.Horz.LastFullVisibleCell - _topLeft.X;
      else
        Result = DrawInfo.Vert.LastFullVisibleCell - _topLeft.Y;
      if(Result < 1)
        return 1;
      return Result;
    }

    int CalcScrollBar(int Value, int ARTLFactor)
    {
      int Result = Value;
      switch(ScrollCode)
      {
        case Windows.SB_LINEUP:   Result-=ARTLFactor; break;
        case Windows.SB_LINEDOWN: Result+=ARTLFactor; break;
        case Windows.SB_PAGEUP:   Result-=PageUp() * ARTLFactor; break;
        case Windows.SB_PAGEDOWN: Result+=PageDown() * ARTLFactor; break;
        case Windows.SB_BOTTOM:   Result = Max(); break;
        case Windows.SB_TOP:      Result = Min(); break;
        case Windows.SB_THUMBPOSITION:
        case Windows.SB_THUMBTRACK:
          if(Options.contains(GridOptions.ThumbTracking) || ScrollCode == Windows.SB_THUMBPOSITION)
          {
            if(!UseRightToLeftAlignment() || ARTLFactor == 1)
              Result = Min() + MulDiv(Pos, Max() - Min(), SysUtils.MAXSHORT);
            else
              Result = Max() - MulDiv(Pos, Max() - Min(), SysUtils.MAXSHORT);
          }
          break;
      }
      return Result;
    }

    void ModifyPixelScrollBar(int Code, int Pos)
    {
      int NewOffset = _colOffset;
      int ColWidth = ColWidths[DrawInfo.Horz.FirstGridCell];
      int GridSpace = ClientWidth - DrawInfo.Horz.FixedBoundary;
      switch(Code)
      {
        case Windows.SB_LINEUP:   NewOffset-=20*RTLFactor; break; //, Canvas.TextWidth('0') * RTLFactor);
        case Windows.SB_LINEDOWN: NewOffset+=20*RTLFactor; break; //, Canvas.TextWidth('0') * RTLFactor);
        case Windows.SB_PAGEUP:   NewOffset-=GridSpace * RTLFactor; break;
        case Windows.SB_PAGEDOWN: NewOffset+=GridSpace * RTLFactor; break;
        case Windows.SB_BOTTOM:   NewOffset = 0; break;
        case Windows.SB_TOP:      NewOffset = ColWidth - GridSpace; break;
        case Windows.SB_THUMBPOSITION:
        case Windows.SB_THUMBTRACK:
          if(Options.contains(GridOptions.ThumbTracking) || Code == Windows.SB_THUMBPOSITION)
          {
            if(!UseRightToLeftAlignment())
              NewOffset = Pos;
            else
              NewOffset = Max() - Pos;
          }
          break;
      }
      if(NewOffset < 0)
        NewOffset = 0;
      else
      if(NewOffset >= ColWidth - GridSpace)
        NewOffset = ColWidth - GridSpace;
      if(NewOffset != _colOffset)
      {
        int OldOffset = _colOffset;
        _colOffset = NewOffset;
        ScrollData(OldOffset - NewOffset, 0);

        Invalidate();
        Update();
        UpdateScrollPos();
      }
    }

    if(!UseRightToLeftAlignment() || !UseRightToLeft)
      RTLFactor = 1;
    else
      RTLFactor = -1;
    if(Visible && CanFocus() && TabStop && !ComponentState.contains(ComponentStates.Designing))
      SetFocus();
    CalcDrawInfo(DrawInfo);
    if(ScrollBar == Windows.SB_HORZ && ColCount == 1)
    {
      ModifyPixelScrollBar(ScrollCode, Pos);
      return;
    }
    MaxTopLeft.X = ColCount - 1;
    MaxTopLeft.Y = RowCount - 1;
    MaxTopLeft = CalcMaxTopLeft(MaxTopLeft, DrawInfo);
    TGridCoord NewTopLeft = _topLeft.Copy();

    int Temp;
    if(ScrollBar == Windows.SB_HORZ)
    {
      do
      {
        Temp = NewTopLeft.X;
        NewTopLeft.X = CalcScrollBar(NewTopLeft.X, RTLFactor);
      } while(!((NewTopLeft.X <= FixedCols) || (NewTopLeft.X >= MaxTopLeft.X)
        || (ColWidths[NewTopLeft.X] > 0) || (Temp == NewTopLeft.X)));
    }
    else
    {
      do
      {
        Temp = NewTopLeft.Y;
        NewTopLeft.Y = CalcScrollBar(NewTopLeft.Y, 1);
      } while(!((NewTopLeft.Y <= FixedRows) || (NewTopLeft.Y >= MaxTopLeft.Y)
        || (RowHeights[NewTopLeft.Y] > 0) || (Temp == NewTopLeft.Y)));
    }
    NewTopLeft.X = max(FixedCols, min(MaxTopLeft.X, NewTopLeft.X));
    NewTopLeft.Y = max(FixedRows, min(MaxTopLeft.Y, NewTopLeft.Y));
    if((NewTopLeft.X != _topLeft.X) || (NewTopLeft.Y != _topLeft.Y))
      MoveTopLeft(NewTopLeft.X, NewTopLeft.Y);
  }



  void MoveAnchor(final TGridCoord NewAnchor)
  {

    MoveCurrent(NewAnchor.X, NewAnchor.Y, true, true);
  }

  void MoveCurrent(int ACol, int ARow, bool MoveAnchor, bool Show)
  {
    if((ACol < 0) || (ARow < 0) || (ACol >= ColCount) || (ARow >= RowCount))
      InvalidOp(Consts.SIndexOutOfRange);
    if(SelectCell(ACol, ARow))
    {
      TGridRect  OldSel = Selection;
      TGridCoord OldCurrent = _current.Copy();
      _current.X = ACol;
      _current.Y = ARow;
      if(!Options.contains(GridOptions.AlwaysShowEditor))
        HideEditor();
      if(MoveAnchor || !Options.contains(GridOptions.RangeSelect))
      {
        _anchor.Assign(_current);
        if(Options.contains(GridOptions.RowSelect))
          _anchor.X = ColCount - 1;
      }
      if(Options.contains(GridOptions.RowSelect))
        _current.X = FixedCols;
      if(Show)
        ClampInView(_current);
      SelectionMoved(OldSel);
      InvalidateCell(OldCurrent.X, OldCurrent.Y);
      InvalidateCell(ACol, ARow);
    }
  }



  void MoveTopLeft(int ALeft, int ATop)
  {
    if((ALeft == _topLeft.X) && (ATop == _topLeft.Y))
      return;
    Update();
    int OldTopLeftX = _topLeft.X;
    int OldTopLeftY = _topLeft.Y;
    _topLeft.X = ALeft;
    _topLeft.Y = ATop;
    TopLeftMoved(OldTopLeftX, OldTopLeftY);
  }

  void ResizeCol(int Index, int OldSize, int NewSize)
  {
    InvalidateGrid();
  }

  void ResizeRow(int Index, int OldSize, int NewSize)
  {
    InvalidateGrid();
  }

  void SelectionMoved(final TGridRect OldSel)
  {
    ConstrainGrid(); // new

  }


  void ScrollDataInfo(int DX, int DY, TGridDrawInfo DrawInfo)
  {

    TRect ScrollArea;
    // Scroll the area
    if(DY == 0)
    {
      // Scroll both the column titles and data area at the same time
      if(!UseRightToLeftAlignment())
        ScrollArea = TRect(DrawInfo.Horz.FixedBoundary, 0, DrawInfo.Horz.GridExtent, DrawInfo.Vert.GridExtent);
      else
      {
        ScrollArea = TRect(ClientWidth - DrawInfo.Horz.GridExtent, 0, ClientWidth - DrawInfo.Horz.FixedBoundary, DrawInfo.Vert.GridExtent);
        DX = -DX;
      }
      ConstrainGrid(); // new
      // ScrollWindowEx(Handle, DX, 0, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
    }
    else
    if(DX == 0)
    {
      // Scroll both the row titles and data area at the same time
      ScrollArea = TRect(0, DrawInfo.Vert.FixedBoundary, DrawInfo.Horz.GridExtent, DrawInfo.Vert.GridExtent);
      // ScrollWindowEx(Handle, 0, DY, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
    }
    else
    {
      // Scroll titles and data area separately
      // Column titles
      ScrollArea = TRect(DrawInfo.Horz.FixedBoundary, 0, DrawInfo.Horz.GridExtent, DrawInfo.Vert.FixedBoundary);
      // ScrollWindowEx(Handle, DX, 0, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
      // Row titles
      ScrollArea = TRect(0, DrawInfo.Vert.FixedBoundary, DrawInfo.Horz.FixedBoundary, DrawInfo.Vert.GridExtent);
      // ScrollWindowEx(Handle, 0, DY, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
      // Data area
      ScrollArea = TRect(DrawInfo.Horz.FixedBoundary, DrawInfo.Vert.FixedBoundary, DrawInfo.Horz.GridExtent, DrawInfo.Vert.GridExtent);
      //ScrollWindowEx(Handle, DX, DY, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
    }

    if(Options.contains(GridOptions.RowSelect))
      InvalidateRect(Selection);
  }

  void ScrollData(int DX, int DY)

  {
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    ScrollDataInfo(DX, DY, DrawInfo);
  }

  void TopLeftMoved(int OldTopLeftX, int OldTopLeftY)
  {
    int CalcScroll(TGridAxisDrawInfo AxisInfo, int OldPos, int CurrentPos)
    {
      int Start = OldPos < CurrentPos? OldPos : CurrentPos;
      int Stop =  OldPos < CurrentPos? CurrentPos : OldPos;
      int Amount = 0;
      for(int i = Start; i<Stop; i++)
      {
        Amount+=(AxisInfo.GetExtent(i) as int) + AxisInfo.EffectiveLineWidth;
        if(Amount > (AxisInfo.GridBoundary - AxisInfo.FixedBoundary))
        { // Scroll amount too big, redraw the whole thing
          InvalidateGrid();
          return 0;
        }
      }
      if(OldPos < CurrentPos)
        Amount = -Amount;
      return Amount;
    }

    TGridDrawInfo DrawInfo =TGridDrawInfo();
    UpdateScrollPos();
    CalcDrawInfo(DrawInfo);
    int dx = CalcScroll(DrawInfo.Horz, OldTopLeftX, _topLeft.X);
    int dy = CalcScroll(DrawInfo.Vert, OldTopLeftY, _topLeft.Y);
    ScrollDataInfo(dx, dy, DrawInfo);
    TopLeftChanged();
  }

  void UpdateScrollPos()
  {
    int ColWidth = 0;
    int GridSpace = 0;

    void SetScroll(int Code, int Value)
    {
      if(UseRightToLeftAlignment() && (Code == Windows.SB_HORZ))
        if(ColCount != 1)
          Value = SysUtils.MAXSHORT - Value;
        else
          Value = (ColWidth - GridSpace) - Value;
      ScrollArea.SetPos(Code, Value);
    }

    if(!HandleAllocated() || ScrollBars == TScrollStyle.None)
      return;

    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    TGridCoord MaxTopLeft=TGridCoord(ColCount - 1, RowCount - 1);

    MaxTopLeft = CalcMaxTopLeft(MaxTopLeft, DrawInfo);
    if([TScrollStyle.Horizontal, TScrollStyle.Both].contains(ScrollBars))
    {
      if(ColCount == 1)
      {
        ColWidth = ColWidths[DrawInfo.Horz.FirstGridCell];
        GridSpace = ClientWidth - DrawInfo.Horz.FixedBoundary;
        if((_colOffset > 0) && (GridSpace > (ColWidth - _colOffset)))
          ModifyScrollBar(Windows.SB_HORZ, Windows.SB_THUMBPOSITION, ColWidth - GridSpace, true);
        else
          SetScroll(Windows.SB_HORZ, _colOffset);
      }
      else
        SetScroll(Windows.SB_HORZ, MulDiv(_topLeft.X - FixedCols, SysUtils.MAXSHORT, MaxTopLeft.X - FixedCols));
    }
    if([TScrollStyle.Vertical, TScrollStyle.Both].contains(ScrollBars))
      SetScroll(Windows.SB_VERT, MulDiv(_topLeft.Y - FixedRows, SysUtils.MAXSHORT, MaxTopLeft.Y - FixedRows));
  }

  void UpdateScrollRange()
  {
    TGridCoord OldTopLeft = TGridCoord();
    TGridCoord MaxTopLeft = TGridCoord();
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    TScrollStyle OldScrollBars = TScrollStyle.None;

    bool Updated = false;

    void DoUpdate()
    {
      if(!Updated)
      {
        Update();
        Updated = true;
      }
    }

    bool ScrollBarVisible(int Code)
    {
      if((ScrollBars == TScrollStyle.Both) ||
        ((Code == Windows.SB_HORZ) && (ScrollBars == TScrollStyle.Horizontal)) ||
        ((Code == Windows.SB_VERT) && (ScrollBars == TScrollStyle.Vertical)))
        return ScrollArea.IsVisible(Code);
      return false;
    }

    void CalcSizeInfo()
    {
      CalcDrawInfoXY(DrawInfo, DrawInfo.Horz.GridExtent, DrawInfo.Vert.GridExtent);
      MaxTopLeft.X = ColCount - 1;
      MaxTopLeft.Y = RowCount - 1;
      MaxTopLeft=CalcMaxTopLeft(MaxTopLeft, DrawInfo);
    }

    int SetAxisRange(int Current, int Code, int Fixeds)
    {
      CalcSizeInfo();

      int Max = Code==Windows.SB_HORZ? MaxTopLeft.X : MaxTopLeft.Y;
      int Old = Code==Windows.SB_HORZ? OldTopLeft.X : OldTopLeft.Y;

      if(Fixeds < Max)
        ScrollArea.SetRange(Code, 0, SysUtils.MAXSHORT);
      else
        ScrollArea.SetRange(Code, 0, 0);

      if(Old > Max)
      {
        DoUpdate();
        Current = Max;
      }
      return Current;
    }

    void SetHorzRange()
    {
      if([TScrollStyle.Horizontal, TScrollStyle.Both].contains(OldScrollBars))
      {
        if(ColCount == 1)
        {
          int Range = GetColWidths(0) - ClientWidth;
          if(Range < 0)
            Range = 0;
          ScrollArea.SetRange(Windows.SB_HORZ, 0, Range);
        }
        else
          _topLeft.X=SetAxisRange(_topLeft.X, Windows.SB_HORZ, FixedCols);
      }
    }

    void SetVertRange()
    {
      if([TScrollStyle.Vertical, TScrollStyle.Both].contains(OldScrollBars))
        _topLeft.Y=SetAxisRange(_topLeft.Y, Windows.SB_VERT, FixedRows);
    }

    if((ScrollBars == TScrollStyle.None) || !HandleAllocated() || !Showing)
      return;

    DrawInfo.Horz.GridExtent = ClientWidth;
    DrawInfo.Vert.GridExtent = ClientHeight;
    // Ignore scroll bars for initial calculation
    if(ScrollBarVisible(Windows.SB_HORZ))
      DrawInfo.Vert.GridExtent+=SysMetric.HScrollCy;
      
    if(ScrollBarVisible(Windows.SB_VERT))
      DrawInfo.Horz.GridExtent+=SysMetric.VScrollCx;


    OldTopLeft.Assign(_topLeft);
    // Temporarily mark us as not having scroll bars to avoid recursion
    OldScrollBars = _scrollBars;
    _scrollBars = TScrollStyle.None;
    Updated = false;

    try
    {
      // Update scrollbars
      SetHorzRange();
      DrawInfo.Vert.GridExtent = ClientHeight;
      SetVertRange();
      if(DrawInfo.Horz.GridExtent != ClientWidth)
      {
        DrawInfo.Horz.GridExtent = ClientWidth;
        SetHorzRange();
      }
    }
    finally
    {
      _scrollBars = OldScrollBars;
    }
    UpdateScrollPos();
    if((_topLeft.X != OldTopLeft.X) || (_topLeft.Y != OldTopLeft.Y))
      TopLeftMoved(OldTopLeft.X, OldTopLeft.Y);
    
  }



  void KeyDown(TKeyCode Key, TShiftState Shift)
  {



    void Restrict(TGridCoord Coord, int MinX, int MinY, int MaxX, int MaxY)
    {
        if(Coord.X > MaxX)
          Coord.X = MaxX;
        else
        if(Coord.X < MinX)
          Coord.X = MinX;

        if(Coord.Y > MaxY)
          Coord.Y = MaxY;
        else
        if(Coord.Y < MinY)
          Coord.Y = MinY;
    }


    super.KeyDown(Key, Shift);
    bool NeedsInvalidating = false;
    if(!CanGridAcceptKey(Key, Shift))
      Key.Code = 0;
    int RTLFactor = UseRightToLeftAlignment()? -1 : 1;

    TGridCoord NewCurrent = _current.Copy();
    TGridCoord NewTopLeft = _topLeft.Copy();

    // CalcPageExtents
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    int PageWidth = DrawInfo.Horz.LastFullVisibleCell - LeftCol;
    if(PageWidth < 1)
      PageWidth = 1;
    int PageHeight = DrawInfo.Vert.LastFullVisibleCell - TopRow;
    if(PageHeight < 1)
      PageHeight = 1;


    if(Shift.contains(ShiftStates.Ctrl))
    {
      switch(Key.Code)
      {

      }
    }
    else
    {
      switch(Key.Code)
      {
        case KeyCode.UP:
          NewCurrent.Y--;
          break;

        case KeyCode.DOWN:
          NewCurrent.Y++;
          break;

        case KeyCode.LEFT:
          if(Options.contains(GridOptions.RowSelect))
            NewCurrent.Y-=RTLFactor;
          else
            NewCurrent.X-=RTLFactor;
          break;

        case KeyCode.RIGHT:
          if(Options.contains(GridOptions.RowSelect))
            NewCurrent.Y+=RTLFactor;
          else
            NewCurrent.X+=RTLFactor;
          break;

        case KeyCode.PAGE_DOWN:
          NewCurrent.Y+=PageHeight;
          NewTopLeft.Y+=PageHeight;
          break;

        case KeyCode.PAGE_UP:
            NewCurrent.Y-=PageHeight;
            NewTopLeft.Y-=PageHeight;
          break;

        case KeyCode.HOME:
          if(Options.contains(GridOptions.RowSelect))
            NewCurrent.Y = FixedRows;
          else
            NewCurrent.X = FixedCols;
          break;

        case KeyCode.END:
          if(Options.contains(GridOptions.RowSelect))
            NewCurrent.Y = RowCount - 1;
          else
            NewCurrent.X = ColCount - 1;
          break;

        case KeyCode.TAB:
          if(!Shift.contains(ShiftStates.Alt))
          do {
            if(Shift.contains(ShiftStates.Shift))
            {
              NewCurrent.X--;
              if(NewCurrent.X < FixedCols)
              {
                NewCurrent.X = ColCount - 1;
                NewCurrent.Y--;
                if(NewCurrent.Y < FixedRows)
                  NewCurrent.Y = RowCount - 1;
              }
              Shift = TShiftState();
            }
            else
            {
              NewCurrent.X++;
              if(NewCurrent.X >= ColCount)
              {
                NewCurrent.X = FixedCols;
                NewCurrent.Y++;
                if(NewCurrent.Y >= RowCount)
                  NewCurrent.Y = FixedRows;
              }
            }
          } while(!(TabStops[NewCurrent.X] || (NewCurrent.X == _current.X)));
          break;

        case KeyCode.F2:
          EditorMode = true;
          break;
      }
    }

    TGridCoord MaxTopLeft = TGridCoord(ColCount - 1, RowCount - 1);
    MaxTopLeft = CalcMaxTopLeft(MaxTopLeft, DrawInfo);
    Restrict(NewTopLeft, FixedCols, FixedRows, MaxTopLeft.X, MaxTopLeft.Y);
    if((NewTopLeft.X != LeftCol) || (NewTopLeft.Y != TopRow))
      MoveTopLeft(NewTopLeft.X, NewTopLeft.Y);
    Restrict(NewCurrent, FixedCols, FixedRows, ColCount - 1, RowCount - 1);
    if((NewCurrent.X != Col) || (NewCurrent.Y != Row))
      FocusCell(NewCurrent.X, NewCurrent.Y, !Shift.contains(ShiftStates.Shift));
    if(NeedsInvalidating)
      Invalidate();
  }



  void MouseDown(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    bool MoveDrawn = false;
    HideEdit();
    if(!ComponentState.contains(ComponentStates.Designing) && (CanFocus() || GetParentForm(this) == null))
    {

      SetFocus();
      if(!IsActiveControl())
      {
        MouseCapture = false;
        return;
      }
    }
    if(Button == TMouseButton.Left && Shift.contains(ShiftStates.Double))
      DblClick();
    else
    if(Button == TMouseButton.Left)
    {
      TGridDrawInfo DrawInfo = TGridDrawInfo();
      CalcDrawInfo(DrawInfo);
      // Check grid sizing
      CalcSizingState(X, Y, _gridSizing, DrawInfo);
      if(_gridSizing.State != TGridState.Normal)
      {
        if((_gridSizing.State == TGridState.ColSizing) && UseRightToLeftAlignment())
          _gridSizing.Pos = ClientWidth - _gridSizing.Pos;
        DrawSizingLine(DrawInfo);
        return;
      }

      TGridCoord CellHit = CalcCoordFromPoint(X, Y, DrawInfo);
      if((CellHit.X >= FixedCols) && (CellHit.Y >= FixedRows))
      {
        if(Options.contains(GridOptions.Editing))
        {
          if((CellHit.X == _current.X) && (CellHit.Y == _current.Y))
            ShowEditor();
          else
          {
            MoveCurrent(CellHit.X, CellHit.Y, true, true);
            UpdateEdit();
          }
          Click();
        }
        else
        {
          _gridSizing.State = TGridState.Selecting;
          
          if(Shift.contains(ShiftStates.Shift))
            MoveAnchor(CellHit);
          else
            MoveCurrent(CellHit.X, CellHit.Y, true, true);
        }
      }
      else
      if(Options.contains(GridOptions.RowMoving) && (CellHit.X >= 0) &&
        (CellHit.X < FixedCols) && (CellHit.Y >= FixedRows))
      {
        _gridSizing.MoveIndex = CellHit.Y;
        _gridSizing.MovePos = _gridSizing.MoveIndex;
        if(BeginRowDrag(_gridSizing.MoveIndex, _gridSizing.MovePos, TPoint(X,Y)))
        {
          _gridSizing.State = TGridState.RowMoving;
          Update();
          DrawMove();
          MoveDrawn = true;

        }
      }
      else
      if(Options.contains(GridOptions.ColMoving) && (CellHit.Y >= 0) &&
        (CellHit.Y < FixedRows) && (CellHit.X >= FixedCols))
      {
        _gridSizing.MoveIndex = CellHit.X;
        _gridSizing.MovePos = _gridSizing.MoveIndex;
        if(BeginColumnDrag(_gridSizing.MoveIndex, _gridSizing.MovePos, TPoint(X,Y)))
        {
          _gridSizing.State = TGridState.ColMoving;
          Update();
          DrawMove();
          MoveDrawn = true;

        }
      }
    }
    try
    {
      super.MouseDown(Button, Shift, X, Y);
    }
    catch(E)
    {
      if(MoveDrawn)
        DrawMove();
    }
  }

  void MouseMove(TShiftState Shift, int X, int Y)
  {
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    switch(_gridSizing.State)
    {
      case TGridState.Selecting:
      case TGridState.ColMoving:
      case TGridState.RowMoving:
        TGridCoord CellHit = CalcCoordFromPoint(X, Y, DrawInfo);
        if((CellHit.X >= FixedCols) && (CellHit.Y >= FixedRows) &&
           (CellHit.X <= DrawInfo.Horz.LastFullVisibleCell+1) &&
           (CellHit.Y <= DrawInfo.Vert.LastFullVisibleCell+1))
        {
          switch(_gridSizing.State)
          {
            case TGridState.Selecting:
              if(CellHit.X != _anchor.X || CellHit.Y != _anchor.Y)
                MoveAnchor(CellHit);
              break;
            case TGridState.ColMoving:
              MoveAndScroll(X, CellHit.X, DrawInfo, DrawInfo.Horz, Windows.SB_HORZ, TPoint(X,Y));
              break;
            case TGridState.RowMoving:
              MoveAndScroll(Y, CellHit.Y, DrawInfo, DrawInfo.Vert, Windows.SB_VERT, TPoint(X,Y));
              break;
            default:
              break;
          }
        }
        break;

      case TGridState.RowSizing:
      case TGridState.ColSizing:
          
          if(_gridSizing.State == TGridState.RowSizing)
            _gridSizing.Pos = Y + _gridSizing.Ofs;
          else
            _gridSizing.Pos = X + _gridSizing.Ofs;
          DrawSizingLine(DrawInfo); 
        break;

      default:
        var tmp = TGridSizing(this); 
        CalcSizingState(X, Y, tmp, DrawInfo);
        TCursor cur = tmp.State==TGridState.ColSizing? TCursor.ColResize : Cursor;
        Handle.style.cursor = cur.name;
        break;
    }
    super.MouseMove(Shift, X, Y);
  }

  void MouseUp(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    int ResizeLine(TGridAxisDrawInfo AxisInfo)
    {
      int Result = AxisInfo.FixedBoundary;
      for(int i = AxisInfo.FirstGridCell; i<_gridSizing.Index; i++)
        Result+=(AxisInfo.GetExtent(i) as int) + AxisInfo.EffectiveLineWidth;
      return _gridSizing.Pos - Result;
    }

    try
    {
      switch(_gridSizing.State)
      {
        case TGridState.Selecting:
          MouseMove(Shift, X, Y);
          
          UpdateEdit();
          Click();
          break;

        case TGridState.RowSizing:
        case TGridState.ColSizing:
          TGridDrawInfo DrawInfo = TGridDrawInfo();
          CalcDrawInfo(DrawInfo);
          DrawSizingLine(DrawInfo);
          if((_gridSizing.State == TGridState.ColSizing) && UseRightToLeftAlignment())
            _gridSizing.Pos = ClientWidth - _gridSizing.Pos;
          if(_gridSizing.State == TGridState.ColSizing)
          {
            int NewSize = ResizeLine(DrawInfo.Horz);
            if(NewSize > 1)
            {
              ColWidths[_gridSizing.Index] = NewSize;
              UpdateDesigner();
            }
          }
          else
          {
            int NewSize = ResizeLine(DrawInfo.Vert);
            if(NewSize > 1)
            {
              RowHeights[_gridSizing.Index] = NewSize;
              UpdateDesigner();
            }
          }
          break;

        case TGridState.ColMoving:
            DrawMove();
            
            if(EndColumnDrag(_gridSizing.MoveIndex, _gridSizing.MovePos, TPoint(X,Y))
              && (_gridSizing.MoveIndex != _gridSizing.MovePos))
            {
              MoveColumn(_gridSizing.MoveIndex, _gridSizing.MovePos);
              UpdateDesigner();
            }
            UpdateEdit();
          break;

        case TGridState.RowMoving:
            DrawMove();
            
            if(EndRowDrag(_gridSizing.MoveIndex, _gridSizing.MovePos, TPoint(X,Y))
              && (_gridSizing.MoveIndex != _gridSizing.MovePos))
            {
              MoveRow(_gridSizing.MoveIndex, _gridSizing.MovePos);
              UpdateDesigner();
            }
            UpdateEdit();
          break;

        default:
          UpdateEdit();
          break;
      }
      super.MouseUp(Button, Shift, X, Y);
    }
    finally
    {
      _gridSizing.State = TGridState.Normal;
    }
  }

  void MoveAndScroll(int Mouse, int CellHit, TGridDrawInfo DrawInfo, TGridAxisDrawInfo Axis,
    int ScrollBar, TPoint MousePt)
  {

  }

  int GetColWidths(int Index)
  {
    if(!_colWidths.Allocated() || (Index >= ColCount))
      return DefaultColWidth;
    return _colWidths[Index];
  }

  int GetRowHeights(int Index)
  {
    
    return DefaultRowHeight-GridLineWidth; // new

  }



  bool GetTabStops(int Index)
  {
    if(!_tabStops.Allocated())
      return true;
    return _tabStops[Index] != 0;
  }

  int get VisibleColCount
  {
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    return DrawInfo.Horz.LastFullVisibleCell - LeftCol + 1;
  }

  int get VisibleRowCount
  {
    TGridDrawInfo DrawInfo = TGridDrawInfo();
    CalcDrawInfo(DrawInfo);
    return DrawInfo.Vert.LastFullVisibleCell - TopRow + 1;
  }



  void SetColWidths(int Index, int Value)
  {
    if(!_colWidths.Allocated())
      _colWidths.Update(ColCount, DefaultColWidth);
    if(Index >= ColCount)
      InvalidOp(Consts.SIndexOutOfRange);
    if(Value != _colWidths[Index])
    {
      ResizeCol(Index, _colWidths[Index], Value);
      _colWidths[Index] = Value;
      ColWidthsChanged();
    }
  }



  void SetRowHeights(int Index, int Value)
  {
    if(!_rowHeights.Allocated())
      _rowHeights.Update(RowCount, DefaultRowHeight);
    if(Index >= RowCount)
      InvalidOp(Consts.SIndexOutOfRange);
    if(Value != _rowHeights[Index])
    {
      ResizeRow(Index, _rowHeights[Index], Value);
      _rowHeights[Index] = Value;
      RowHeightsChanged();
    }
  }

  void SetTabStops(int Index, bool Value)
  {
    if(!_tabStops.Allocated())
      _tabStops.Update(ColCount, 1);
    if(Index >= ColCount)
      InvalidOp(Consts.SIndexOutOfRange);
    _tabStops[Index] = Value? 1 : 0;
  }

  void HideEdit()
  {
    if(_inplaceEdit == null)
      return;
    try
    {
      UpdateText();
    }
    finally
    {
      _inplaceCol = -1;
      _inplaceRow = -1;
      _inplaceEdit!.Hide();
    }
  }

  void UpdateEdit()
  {

  }

  void UpdateText()
  {
    if((_inplaceCol != -1) && (_inplaceRow != -1))
      SetEditText(_inplaceCol, _inplaceRow, _inplaceEdit!.Text);
  }

  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_SIZE:
        super.Dispatch(Message);
        UpdateScrollRange();

        if(UseRightToLeftAlignment())
          Invalidate();
        break;



      case WM_VSCROLL:
      case WM_HSCROLL:
        SCROLLINFO pos = Message.WParam;
        ModifyScrollBar(Message.Msg==WM_VSCROLL? Windows.SB_VERT : Windows.SB_HORZ, pos.ScrollCode, pos.Position, true);
        break;

      case CM_SETFOCUS:
        if(HandleAllocated() && Windows.GetFocus()!=_grid!.table)
        {
          Windows.SetFocus(_grid!);
          Invalidate();
        }
        break;

      default:
        super.Dispatch(Message);
        break;
    }
  }



  void _wmKillFocus(TMessage Message)
  {
    super._wmKillFocus(Message);
    InvalidateRect(Selection);
    if((_inplaceEdit != null)/* and (Msg.FocusedWnd <> FInplaceEdit.Handle)*/)
      HideEdit();
  }



  void _wmSetFocus(TMessage Message)
  {
    super._wmSetFocus(Message);
    if((_inplaceEdit == null) )
    {
      InvalidateRect(Selection);
      UpdateEdit();
    }
  }



  void ColWidthsChanged()
  {
    UpdateScrollRange();
    UpdateEdit();
  }

  void RowHeightsChanged()
  {
    UpdateScrollRange();
    UpdateEdit();
  }



  void UpdateDesigner()

  {
    if(HandleAllocated())
      ConstrainGrid();

  }

  bool DoMouseWheelDown(TShiftState Shift, TPoint MousePos)
  {
    if(super.DoMouseWheelDown(Shift, MousePos))
      return true;
    if(Row < RowCount - 1)
      Row = Row + 1;
    return true;
  }

  bool DoMouseWheelUp(TShiftState Shift, TPoint MousePos)
  {
    if(super.DoMouseWheelUp(Shift, MousePos))
      return true;
    if(Row > FixedRows)
      Row = Row - 1;
    return true;
  }



  bool BeginColumnDrag(int Origin, int Destination, TPoint MousePt)
  {
    return true;
  }

  bool BeginRowDrag(int Origin, int Destination, TPoint MousePt)
  {
    return true;
  }

  bool EndColumnDrag(int Origin, int Destination, TPoint MousePt)
  {
    return true;
  }

  bool EndRowDrag(int Origin, int Destination, TPoint MousePt)
  {
    return true;
  }

  void _cmShowingChanged(TMessage Message)
  {
    super._cmShowingChanged(Message);
    if(Showing)
      UpdateScrollRange();
  }
}



class TCustomDrawGrid extends TCustomGrid
{

  TCustomDrawGrid(TComponent AOwner) : super(AOwner)
  {

  }

}

class TDrawGrid extends TCustomDrawGrid
{
  TDrawGrid(TComponent AOwner) : super(AOwner)
  {

  }

}



class TStringGrid extends TDrawGrid
{


  TStringGrid(TComponent AOwner) : super(AOwner)
  {
    Initialize();
  }


}
