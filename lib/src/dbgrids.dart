part of vcl;


enum TColumnValue { Color, Width, Font, Alignment, ReadOnly, TitleColor,
    TitleCaption, TitleAlignment, TitleFont, ImeMode, ImeName }

typedef TColumnValues = Set<TColumnValue>;


///  TColumn defines internal storage for column attributes.  If IsStored is
///  True, values assigned to properties are stored in this object, the grid-
///  or field-based default sources are not modified.  Values read from
///  properties are the previously assigned value, if any, or the grid- or
///  field-based default values if nothing has been assigned to that property.
///  This class also publishes the column attribute properties for persistent
///  storage.

///  If IsStored is True, the column does not maintain local storage of
///  property values.  Assignments to column properties are passed through to
///  the underlying grid- or field-based default sources.


enum TDBGridColumnsState { Default, Customized }




enum DBGridOptions { Editing, AlwaysShowEditor, Titles, Indicator,
    ColumnResize, ColLines, RowLines, Tabs, RowSelect,
    AlwaysShowSelection, ConfirmDelete, CancelOnExit, MultiSelect }

typedef TDBGridOptions = Set<DBGridOptions>;



const int IndicatorWidth = 11;

class TGridDataLink extends TDataLink
{

  TCustomDBGrid Grid;



  final _fieldMap = <int>[];
  int get FieldCount => _fieldMap.length;

  bool _modified = false;
  bool _inUpdateData = false;

  bool _sparseMap = false;
  bool
    get SparseMap => _sparseMap;
    set SparseMap(bool Value) => _sparseMap=Value;

  late final TItems<TField?> Fields;

  TGridDataLink(this.Grid) : super()
  {
    Fields = TItems<TField?>(
      (int ndx)
      {
        if((0 <= ndx) && (ndx < FieldCount) && (_fieldMap[ndx] >= 0))
          return DataSet!.FieldList.Objects[_fieldMap[ndx]];
        return null;
      },
      () => throw UnimplementedError() );
    VisualControl = true;
  }

  void Destroy()
  {
    ClearMapping();
    super.Destroy();
  }

  bool get DefaultFields
  {
    bool Result = true;
    if(DataSet != null)
      Result = DataSet!.DefaultFields;
    if(Result && SparseMap)
      for(int i = 0; i<FieldCount; i++)
        if(_fieldMap[i] < 0)
          return false;
    return Result;
  }

  void AddMapping(String FieldName)
  {
    TField? Field = SparseMap? DataSet!.FindField(FieldName) : DataSet!.FieldByName(FieldName);
    if(Field != null)
    {
      _fieldMap.add(DataSet!.FieldList.IndexOfObject(Field));
      Field.FreeNotification(Grid);
    }
    else
      _fieldMap.add(-1);
  }

  void ActiveChanged()
  {
    if(Active && DataSource != null && DataSource!.DataSet != null && DataSource!.DataSet!.IsUniDirectional)
      DatabaseError(DBConsts.SDataSetUnidirectional);
    Grid.LinkActive(Active);
    _modified = false;
  }

  void ClearMapping()
  {
    _fieldMap.clear();
  }

  void Modified()
  {
    _modified = true;
  }

  void DataSetChanged()
  {

    Grid.DataChanged();
    _modified = false;
  }

  void DataSetScrolled(int Distance)
  {
    Grid.Scroll(Distance);
  }

  void LayoutChanged()
  {
    // FLayoutFromDataset determines whether default column width is forced to
    //  be at least wide enough for the column title.
    bool SaveState = Grid._layoutFromDataset;
    Grid._layoutFromDataset = true;
    try
    {
      Grid.LayoutChanged();
    }
    finally
    {
      Grid._layoutFromDataset = SaveState;
    }
    super.LayoutChanged();
  }

  void FocusControl(TField Field)
  {

    Grid.SelectedField = Field;
    if(Grid.SelectedField == Field && Grid.AcquireFocus())
    {
      
      Grid.ShowEditor();
    }
  }

  void EditingChanged()
  {
    Grid.EditingChanged();
  }

  void RecordChanged(TField? Field)
  {
    Grid.RecordChanged(Field);
    _modified = false;
  }

  void UpdateData()
  {
    _inUpdateData = true;
    try
    {
      if(_modified)
        Grid.UpdateData();
      _modified = false;
    }
    finally
    {
      _inUpdateData = false;
    }
  }

  int GetMappedIndex(int ColIndex)
  {
    if((0 <= ColIndex) && (ColIndex < FieldCount))
      return _fieldMap[ColIndex];
    return -1;
  }

  void Reset()
  {
    if(_modified)
      RecordChanged(null);
    else
      DataSet!.Cancel();
  }

  bool IsAggRow(int Value)
  {
    return false;
  }

  void BuildAggMap()
  {

  }

}

class TColumnTitle extends TPersistent
{
  final TColumn Column;

  String _caption = '';
  String
    get Caption
    {
      if(Column._assignedValues.contains(TColumnValue.TitleCaption))
        return _caption;
      return DefaultCaption();
    }
    set Caption(String Value) => SetCaption(Value);

  void SetCaption(String Value)
  {
    if(Column.IsStored)
    {
      if(Column._assignedValues.contains(TColumnValue.TitleCaption) && (Value == _caption))
        return;
      _caption = Value;
      Column._assignedValues << TColumnValue.TitleCaption;
      Column.Changed(false);
    }
    else
    {
      TCustomDBGrid? Grid = Column.Grid;
      if(Grid!=null && Grid.DataLink.Active && Column.Field!=null)
        Column.Field!.DisplayLabel = Value;
    }
  }





  TColumnTitle(this.Column) : super()
  {

  }

  void Destroy()
  {

    super.Destroy();
  }

  void Assign(TPersistent Source)
  {
    if(Source is TColumnTitle)
    {

      if(Source.Column._assignedValues.contains(TColumnValue.TitleCaption))
        Caption = Source.Caption;

    }
    else
      super.Assign(Source);
  }



  String DefaultCaption()
  {
    TField? Field = Column.Field;
    return Field==null? Column.FieldName : Field.DisplayName;
  }


}

class TColumn extends TCollectionItem
{
  TField? _field;
  TField?
    get Field
    {
      // Returns Nil if FieldName can't be found in dataset
      var grid = Grid;
      if(_field == null && _fieldName.isNotEmpty && grid!=null && grid.DataLink.DataSet!=null)
      {
        TDataSet? DataSet = grid.DataLink.DataSet;
        if(DataSet!.Active || !DataSet.DefaultFields)
          SetField(DataSet.FindField(FieldName));
      }
      return _field;
    }
    set Field(TField? Value) => SetField(Value);

  void SetField(TField? Value)
  {
    if(_field == Value)
      return;
    var grid = Grid;
    if((_field!=null) && (grid != null))
      _field!.RemoveFreeNotification(grid);
    if((Value!=null) && (Value.ComponentState.contains(ComponentStates.Destroying)))
      Value = null;    // don't acquire references to fields being destroyed
    _field = Value;
    if(Value!=null)
    {
      if(grid != null)
        _field!.FreeNotification(grid);
      _fieldName = Value.FullName;
    }
    if(!IsStored)
    {
      if(Value == null)
        _fieldName = "";
      RestoreDefaults();
    }
    Changed(false);
  }

  String _fieldName = '';
  String
    get FieldName => _fieldName;
    set FieldName(String Value)
    {
      TField? AField;
      var grid = Grid;
      if((grid!=null) && (grid.DataLink.DataSet!=null) &&
        !(grid.ComponentState.contains(ComponentStates.Loading)) && Value.isNotEmpty)
          AField = grid.DataLink.DataSet!.FindField(Value); // no exceptions
      _fieldName = Value;
      SetField(AField);
      Changed(false);
    }

  bool get Showing
  {
    bool Result = Expanded==false && Visible;
    if(Result)
    {
      TColumn? Col = this;
      do {
        Col = Col!.ParentColumn;
      } while(Col!=null && Col.Expanded!=false);
      return Col == null;
    }
    return false;
  }


  int _width = 64;
  int
    get Width
    {
      if(!Showing)
        return -1;
      else
      if(_assignedValues.contains(TColumnValue.Width))
        return _width;
      return DefaultWidth();
    }
    set Width(int Value) => SetWidth(Value);

  void SetWidth(int Value)
  {

    bool DoSetWidth = IsStored;
    if(!DoSetWidth)
    {
      var grid = Grid;
      if(grid!=null)
      {
        if(grid.HandleAllocated() && (Field!=null) && grid._updateFields)
        { 

        }
        if((!grid._layoutFromDataset) || (_assignedValues.contains(TColumnValue.Width)))
          DoSetWidth = true;
      }
      else
        DoSetWidth = true;
    }
    if(DoSetWidth)
    {
      if((_assignedValues.contains(TColumnValue.Width) || (Value != DefaultWidth()))
        && (Value != -1))
      {
        _width = Value;
        _assignedValues << TColumnValue.Width;
      }
      Changed(false);
    }
  }

  TColumnTitle? _title;
  TColumnTitle
    get Title => _title!;
    set Title(TColumnTitle Value) => Title.Assign(Value);


  TColumnValues _assignedValues = TColumnValues();

  bool _visible = true;
  bool get Visible {
    bool Result = _visible;
    if(Result)
    {
      TColumn? Col = ParentColumn;
      Result = Result && ((Col == null) || Col.Visible);
    }
    return Result;
  }
  set Visible(bool Value)
  {
    if(Value == _visible)
      return;
    _visible = Value;
    Changed(true);
  }

  bool _expanded = true;
  bool
    get Expanded => _expanded && Expandable;
    set Expanded(bool Value)
    {
      if(Value == _expanded)
        return;
      var grid = Grid;
      bool WasShowing = (grid != null) && grid.Columns.Items[grid.SelectedIndex].Showing;
      _expanded = Value;
      Changed(true);
      if((grid != null) && WasShowing)
      {
        if(grid.Columns.Items[grid.SelectedIndex].Showing)
          // The selected cell was hidden by this expand operation
          // Select 1st child (next col = 1) when parent is expanded
          // Select child's parent (prev col = -1) when parent is collapsed
          grid.MoveCol(grid.Col, _expanded? 1 : -1);
      }
    }

  bool get Expandable
  {
    TField? Fld = Field;
    return (Fld != null) && ([TFieldType.ADT, TFieldType.Array].contains(Fld.DataType));
  }

  bool _stored = true;
  bool
    get IsStored => _stored;
    set IsStored(bool Value) => _stored = Value;

  TCustomDBGrid? get Grid {
    if((Collection!=null) && (Collection is TDBGridColumns))
      return (Collection as TDBGridColumns).Grid;
    return null;
  }

  TAlignment
    get Alignment
    {
    
      return TAlignment.LeftJustify;
    }
    set Alignment(TAlignment Value)
    {

   }


  TColumn() : super()
  {

    try
    {

      _title = CreateTitle();
    }
    finally
    {

    }
  }

  void Destroy()
  {
    _title!.Destroy();
    _title = null;

    super.Destroy();
  }

  void Assign(TPersistent Source)
  {
    if(Source is TColumn)
    {
      Collection?.BeginUpdate();
      try
      {
        RestoreDefaults();
        FieldName = Source.FieldName;

        if(Source._assignedValues.contains(TColumnValue.Width))
          Width = Source.Width;
        
        if(Source._assignedValues.contains(TColumnValue.Alignment))
          Alignment = Source.Alignment;

        Title = Source.Title;

        _visible = Source._visible;

      }
      finally
      {
        Collection?.EndUpdate();
      }
    }
    else
      super.Assign(Source);
  }

  TColumnTitle CreateTitle()
  {
    return TColumnTitle(this);
  }



  int DefaultWidth()
  {

    var grid = Grid;
    if(grid == null)
      return 64;
    
    if(Field != null)
    {
      bool RestoreCanvas = grid.HandleAllocated()==false;

      try
      {

      }
      finally
      {

      }
      return grid.DefaultColWidth; // new
    }
    else
      return grid.DefaultColWidth;
  }


  TColumn? get ParentColumn
  {
    TField? Fld = Field;
    if((Fld != null) && (Fld.ParentField != null) && (Collection != null))
    {
      for(int i = Index - 1; i>=0; i--)
      {
        TColumn Col = Collection!.Items[i] as TColumn;
        if(Fld.ParentField == Col.Field)
          return Col;
      }
    }
    return null;
  }


  void RestoreDefaults()
  {

  }


  int Depth()
  {
    var Col = ParentColumn;
    if(Col != null)
      return Col.Depth() + 1;
    return 0;
  }

}

class TDBGridColumns extends TCollection
{
  final TCustomDBGrid Grid;

  late final TItems<TColumn> _columns;
  TItems<TColumn> get Items => _columns;

  TDBGridColumns(this.Grid) : super((Sender) => TColumn())
  {
    _columns = TItems<TColumn>.from(super.Items);
  }

  TColumn Add()
  {
    return super.Add() as TColumn;
  }

  TColumn AddEx( [ String? name, String? caption, int? width ] )
  {
    BeginUpdate();
    TColumn col = super.Add() as TColumn;
    if(name != null)
      col.FieldName = name;
    if(caption != null)
      col.Title.Caption = caption;
    if(width != null)
      col.Width = width;
    EndUpdate();
    return col;
  }



  void Update(TCollectionItem? Item)
  {
    if(Grid.ComponentState.contains(ComponentStates.Loading))
      return;
    if(Item == null)
      Grid.LayoutChanged();
    else
    {
      int Raw = Grid.DataToRawColumn(Item.Index);
      Grid.InvalidateCol(Raw);
      Grid.SetColWidths(Raw, (Item as TColumn).Width);
    }
  }

  TColumn InternalAdd()
  {
    TColumn Result = Add();
    Result.IsStored = false;
    return Result;
  }

  TDBGridColumnsState get State
  {
    return (Count > 0) && (_items[0] as TColumn).IsStored? TDBGridColumnsState.Customized : TDBGridColumnsState.Default;
  }

}

class TCustomDBGrid extends TCustomGrid
{


  bool _readOnly = false;
  bool
    get ReadOnly => _readOnly;
    set ReadOnly(bool Value) => _readOnly = Value;


  bool _isESCKey = false;
  bool _layoutFromDataset = false;

  final TDBGridOptions _dbOptions = TDBGridOptions.from( {
    DBGridOptions.Editing, DBGridOptions.Titles, DBGridOptions.Indicator,
    DBGridOptions.ColumnResize, DBGridOptions.ColLines, DBGridOptions.RowLines,
    DBGridOptions.Tabs, DBGridOptions.ConfirmDelete, DBGridOptions.CancelOnExit });

  TDBGridOptions
    get DBOptions => _dbOptions;
    set DBOptions(TDBGridOptions value)
    {
      if(DBOptions.isEqual(value))
        return;

      var NewGridOptions = TGridOptions();
      if(value.contains(DBGridOptions.ColLines))
      {
        NewGridOptions.add(GridOptions.FixedVertLine);
        NewGridOptions.add(GridOptions.VertLine);
      }
      if(value.contains(DBGridOptions.RowLines))
      {
        NewGridOptions.add(GridOptions.FixedHorzLine);
        NewGridOptions.add(GridOptions.HorzLine);
      }
      if(value.contains(DBGridOptions.ColumnResize))
      {
        NewGridOptions.add(GridOptions.ColSizing);
        NewGridOptions.add(GridOptions.ColMoving);
      }
      if(value.contains(DBGridOptions.Tabs))
        NewGridOptions.add(GridOptions.Tabs);
      if(value.contains(DBGridOptions.RowSelect))
      {
        NewGridOptions.add(GridOptions.RowSelect);
        value.remove(DBGridOptions.AlwaysShowEditor);
        value.remove(DBGridOptions.Editing);
      }
      if(value.contains(DBGridOptions.Editing))
        NewGridOptions.add(GridOptions.Editing);
      if(value.contains(DBGridOptions.AlwaysShowEditor))
        NewGridOptions.add(GridOptions.AlwaysShowEditor);
      super.Options = NewGridOptions;


      var ChangedOptions = (_dbOptions + value) - (_dbOptions * value);
      _dbOptions.assign(value);

      var LayoutOptions = TDBGridOptions.from( {
        DBGridOptions.Editing, DBGridOptions.AlwaysShowEditor, DBGridOptions.Titles, DBGridOptions.Indicator,
        DBGridOptions.ColLines, DBGridOptions.RowLines, DBGridOptions.RowSelect, DBGridOptions.AlwaysShowSelection } );

      if(HandleAllocated() && (ChangedOptions * LayoutOptions).isNotEmpty)
        LayoutChanged();
    }

  int _titleOffset = 1;
  int get TitleOffset => _titleOffset;

  int _indicatorOffset = 1;
  int get IndicatorOffset => _indicatorOffset;

  int _updateLock = 0;
  int get UpdateLock => _updateLock;

  int _layoutLock = 0;
  int get LayoutLock => _layoutLock;

  bool _inColExit = false;

  bool _selecting = false;
  int _selRow = 0;

  late final TGridDataLink DataLink;



  String _editText = "";
  String GetEditText(int ACol, int ARow)
  {
    _editText = "";
    if(DataLink.Active)
    {
      TColumn withColumn = Columns.Items[RawToDataColumn(ACol)];
      if(withColumn.Field!=null)
        _editText = withColumn.Field!.Text;
    }
    return _editText;
  }

  void SetEditText(int ACol, int ARow, final String Value)
  {
    _editText = Value;
  }

  late final TDBGridColumns _columns;
  TDBGridColumns
    get Columns => _columns; // write SetColumns;
    set Columns(TDBGridColumns Value) => Columns.Assign(Value);

  final _visibleColumns = <TColumn>[];

  bool _acquireFocus = true;

  bool _updateFields = true;


  TCustomDBGrid(TComponent AOwner) :
        super(AOwner)
  {

    _virtualView = true;

    ScrollBars = TScrollStyle.Horizontal;
    Options.assign( { GridOptions.FixedHorzLine, GridOptions.FixedVertLine, GridOptions.HorzLine,
      GridOptions.VertLine, GridOptions.ColSizing, GridOptions.ColMoving, GridOptions.Tabs, GridOptions.Editing } );

    _columns = TDBGridColumns(this);
    RowCount = 2;
    ColCount = 2;
    DataLink = CreateDataLink();

  }

  void Destroy()
  {

    super.Destroy();
  }

  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_HSCROLL:
        super.Dispatch(Message);
        UpdateScrollPos(); // new
        break;

      case WM_VSCROLL:
        _wmVScroll(Message);
        break;

      case WM_SIZE:
        super.Dispatch(Message);
        if(UpdateLock == 0)
          UpdateRowCount();
        UpdateScrollBar(); // new

        InvalidateTitles();
        break;

      default:
        super.Dispatch(Message);
        break;
    }
  }

  bool AcquireFocus()
  {
    if(_acquireFocus && CanFocus() && !ComponentState.contains(ComponentStates.Designing))
    {
      SetFocus();
      return Focused() || (InplaceEditor != null) && InplaceEditor!.Focused();
    }
    return true;
  }

  int RawToDataColumn(int ACol)
  {
    return ACol - _indicatorOffset;
  }

  int DataToRawColumn(int ACol)
  {
    return ACol + _indicatorOffset;
  }

  bool AcquireLayoutLock()
  {
    bool Result = (_updateLock == 0) && (_layoutLock == 0);
    if(Result)
      BeginLayout();
    return Result;
  }

  void BeginLayout()
  {
    BeginUpdate();
    if(_layoutLock == 0)
      Columns.BeginUpdate();
    _layoutLock++;
  }

  void BeginUpdate()
  {
    _updateLock++;
  }

  void CancelLayout()
  {
    if(_layoutLock > 0)
    {
      if(_layoutLock == 1)
        Columns.EndUpdate();
      _layoutLock--;
      EndUpdate();
    }
  }



  void ColEnter()
  {
    UpdateIme();
    
  }

  void ColExit()
  {
    
  }



  void ColWidthsChanged()
  {
    super.ColWidthsChanged();
    if((DataLink.Active || (Columns.State == TDBGridColumnsState.Customized)) &&
      AcquireLayoutLock())
    {
      try
      {
        for(int i=_indicatorOffset; i<ColCount; i++)
          Columns.Items[i - _indicatorOffset].Width = ColWidths[i];
      }
      finally
      {
        EndLayout();
      }
    }
  }

  TDBGridColumns CreateColumns()
  {
    return TDBGridColumns(this);
  }

  TGridDataLink CreateDataLink()
  {
    return TGridDataLink(this);
  }



  void CreateWnd()
  {
    BeginUpdate();   // prevent updates in WMSize message that follows WMCreate
    try
    {
      super.CreateWnd();
    }
    finally
    {
      EndUpdate();
    }
    UpdateRowCount();
    UpdateActive();
    UpdateScrollBar();

  }

  void DataChanged()
  {
    if(!HandleAllocated())
      return;
    UpdateRowCount();
    UpdateScrollBar();
    UpdateActive();
    InvalidateEditor();

    Invalidate();
  }



  void DefineFieldMap()
  {
    if(Columns.State == TDBGridColumnsState.Customized)
    { //  Build the column/field map from the column attributes
      DataLink.SparseMap = true;
      for(int i = 0; i < Columns.Count; i++)
        DataLink.AddMapping(Columns.Items[i].FieldName);
    }
    else
    { // Build the column/field map from the field list order
      DataLink.SparseMap = false;
      TDataSet WithDataSet = DataLink.DataSet!;
      for(int i= 0; i<WithDataSet.FieldList.Count; i++)
      {
        TField WithField = WithDataSet.FieldList.Fields[i];
        if(WithField.Visible)
          DataLink.AddMapping(WithField.FullName);
      }
    }
  }




  void DrawCell(TGridCell Cell)
  {


    super.DrawCell(Cell); // new
    int ARow=Cell.Row-_titleOffset;
    int ACol=Cell.Col-_indicatorOffset;


    if(Cell.State.contains(TGridDrawStates.Fixed) && ACol<0)
    {

      if(DataLink.Active)
      {

      }
    }
    else

    if(ACol<Columns.Count)

    {
      TColumn DrawColumn = Columns.Items[ACol];
      if(!DrawColumn.Showing)
        return;

      if(ARow < 0)
      {
        Cell.Value = DrawColumn.Title.Caption;
        Cell.Alignment = TAlignment.Center;
        
      }
      else
      if(!DataLink.Active)
      {

      }
      else
      {

        int OldActive = DataLink.ActiveRecord;
        try
        {
          DataLink.ActiveRecord = ARow;

          // new
          if(DrawColumn.Field == null)
          {
            Cell.Alignment = TAlignment.LeftJustify;
            DrawColumnCellEx(Cell, DrawColumn, "");
          }
          else
          {
            Cell.Alignment = DrawColumn.Field!.Alignment;
            DrawColumnCellEx(Cell, DrawColumn, DrawColumn.Field!.DisplayText);
          }
        }
        finally
        {
          DataLink.ActiveRecord = OldActive;
        }

      }
    }

  }

  void DrawColumnCellEx(TGridCell Cell, TColumn col, String data)
  {
    Cell.Value = data;
  }




  void EditingChanged()
  {
    if(DBOptions.contains(DBGridOptions.Indicator))
      InvalidateCell(0, _selRow);
  }

  void EndLayout()
  {
    if(_layoutLock > 0)
    {
      try
      {
        try
        {
          if(_layoutLock == 1)
            InternalLayout();
        }
        catch(E)
        {
          print('Catch TCustomDBGrid.EndLayout 1 [$E]');
        }
        finally
        {
          if(_layoutLock == 1)
            Columns.EndUpdate();
        }
      }
      catch(E)
      {
        print('Catch TCustomDBGrid.EndLayout 2 [$E]');
      }
      finally
      {
        _layoutLock--;
        EndUpdate();
      }
    }
  }

  void EndUpdate()
  {
    if(_updateLock > 0)
      _updateLock--;
  }





  void KeyDown(TKeyCode Key, TShiftState Shift)
  {
    void ClearSelection()
    {
      if(DBOptions.contains(DBGridOptions.MultiSelect))
      {

        _selecting = false;
      }
    }

    void DoSelection(bool Select, int Direction)
    {
      bool AddAfter = false;
      BeginUpdate();
      try
      {
        if(DBOptions.contains(DBGridOptions.MultiSelect) && DataLink.Active)
          if(Select && Shift.contains(ShiftStates.Shift))
          {
            if(!_selecting)
            {

              _selecting = true;
              AddAfter = true;
            }

          }
          else
            ClearSelection();
        DataLink.MoveBy(Direction);

      }
      finally
      {
        EndUpdate();
      }
    }

    void NextRow(bool Select)
    {
      TDataSet WithDataSet = DataLink.DataSet!;
      if((WithDataSet.State == TDataSetState.Insert) && !WithDataSet.Modified && !DataLink._modified)
        if(DataLink.Eof)
          return;
        else
          WithDataSet.Cancel();
      else
        DoSelection(Select, 1);
      if(DataLink.Eof && WithDataSet.CanModify && !ReadOnly && DBOptions.contains(DBGridOptions.Editing))
        WithDataSet.Append();
    }

    void PriorRow(bool Select)
    {
      TDataSet WithDataSet = DataLink.DataSet!;
      if((WithDataSet.State == TDataSetState.Insert) && !WithDataSet.Modified && DataLink.Eof && !DataLink._modified)
        WithDataSet.Cancel();
      else
        DoSelection(Select, -1);
    }

    void Tab(bool GoForward)
    {
      int ACol = Col;
      int Original = ACol;
      BeginUpdate();    // Prevent highlight flicker on tab to next/prior row
      try
      {
        while(true)
        {
          if(GoForward)
            ACol++;
          else
            ACol--;
          if(ACol >= ColCount)
          {
            NextRow(false);
            ACol = _indicatorOffset;
          }
          else
          if(ACol < _indicatorOffset)
          {
            PriorRow(false);
            ACol = ColCount - _indicatorOffset;
          }
          if(ACol == Original)
            return;
          if(TabStops[ACol])
          {
            MoveCol(ACol, 0);
            return;
          }
        }
      }
      finally
      {
        EndUpdate();
      }
    }

    bool DeletePrompt()
    {
      String Msg;

      return true;
    }


    if(!DataLink.Active || !CanGridAcceptKey(Key, Shift))
      return;
    if(UseRightToLeftAlignment())
    {
      if(Key.Code == KeyCode.LEFT)
        Key.Code = KeyCode.RIGHT;
      else
      if(Key.Code == KeyCode.RIGHT)
        Key.Code = KeyCode.LEFT;
    }
    TDataSet WithDataSet = DataLink.DataSet!;

      if(Shift.contains(ShiftStates.Ctrl))
      {
        List RowMovementKeys = [ KeyCode.UP, KeyCode.PAGE_UP, KeyCode.DOWN, KeyCode.PAGE_DOWN, KeyCode.HOME, KeyCode.END ];
        if(RowMovementKeys.contains(Key.Code))
          ClearSelection();
        switch(Key.Code)
        {
          case KeyCode.UP:
          case KeyCode.PAGE_UP:
            DataLink.MoveBy(-DataLink.ActiveRecord);
            break;

          case KeyCode.DOWN:
          case KeyCode.PAGE_DOWN:
            DataLink.MoveBy(DataLink.BufferCount - DataLink.ActiveRecord - 1);
            break;

          case KeyCode.LEFT:
            MoveCol(_indicatorOffset, 1);
            break;

          case KeyCode.RIGHT:
            MoveCol(ColCount - 1, -1);
            break;

          case KeyCode.HOME:
            WithDataSet.First();
            break;

          case KeyCode.END:
            WithDataSet.Last();
            break;

          case KeyCode.DELETE:
            if(!ReadOnly && !WithDataSet.IsEmpty() && WithDataSet.CanModify && DeletePrompt())
            {

              WithDataSet.Delete();
            }
        }
      }
      else
      {
        switch(Key.Code)
        {
          case KeyCode.UP:
            PriorRow(true);
            break;

          case KeyCode.DOWN:
            NextRow(true);
            break;

          case KeyCode.LEFT:
            if(DBOptions.contains(DBGridOptions.RowSelect))
              PriorRow(false);
            else
              MoveCol(Col - 1, -1);
            break;

          case KeyCode.RIGHT:
            if(DBOptions.contains(DBGridOptions.RowSelect))
              NextRow(false);
            else
              MoveCol(Col + 1, 1);
            break;

          case KeyCode.HOME:
            if((ColCount == _indicatorOffset+1) || DBOptions.contains(DBGridOptions.RowSelect))
            {
              ClearSelection();
              WithDataSet.First();
            }
            else
              MoveCol(_indicatorOffset, 1);
            break;

          case KeyCode.END:
            if((ColCount == _indicatorOffset+1) || DBOptions.contains(DBGridOptions.RowSelect))
            {
              ClearSelection();
              WithDataSet.Last();
            }
            else
              MoveCol(ColCount - 1, -1);
            break;

          case KeyCode.PAGE_DOWN:
            {
              ClearSelection();
              DataLink.MoveBy(VisibleRowCount);
            }
            break;

          case KeyCode.PAGE_UP:
            {
              ClearSelection();
              DataLink.MoveBy(-VisibleRowCount);
            }
            break;

          case KeyCode.INSERT:
            if(WithDataSet.CanModify && !ReadOnly && DBOptions.contains(DBGridOptions.Editing))
            {
              ClearSelection();
              WithDataSet.Insert();
            }
            break;

          case KeyCode.TAB:
            if(!Shift.contains(ShiftStates.Alt))
              Tab(!Shift.contains(ShiftStates.Shift));
            break;

          case KeyCode.ESC:
            {
              
              DataLink.Reset();
              ClearSelection();
              if(!DBOptions.contains(DBGridOptions.AlwaysShowEditor))
                HideEditor();
            }
            break;

          case KeyCode.F2:
            EditorMode = true;
            break;
        }
      }
  }


  // InternalLayout is called with layout locks and column locks in effect }
  void InternalLayout()
  {
    bool FieldIsMapped(TField? F)
    {
      if(F == null)
        return false;
      for(int i = 0; i<DataLink.FieldCount; i++)
        if(DataLink.Fields[i] == F)
          return true;
      return false;
    }

    void CheckForPassthroughs()  // check for Columns.State flip-flop
    {

    }

    void ResetColumnFieldBindings()
    {
      if(Columns.State == TDBGridColumnsState.Default)
      {
        // Destroy columns whose fields have been destroyed or are no longer
        //  in field map
        if(!DataLink.Active && DataLink.DefaultFields)
          Columns.Clear();
        else
        for(int j = Columns.Count-1; j>=0; j--)
        {
          TColumn WithColumn = Columns.Items[j];
          if((WithColumn.Field == null) || !FieldIsMapped(WithColumn.Field))
            Columns.Delete(j); // Free;
        }
        int i = DataLink.FieldCount;
        if((i == 0) && (Columns.Count == 0))
          i++;
        for(int j = 0; j<i; j++)
        {
          TColumn Column;
          TField? Fld = DataLink.Fields[j];
          if(Fld != null)
          {
            int k = j;
            // Pointer compare is valid here because the grid sets matching
            //  column.field properties to nil in response to field object
            //  free notifications.  Closing a dataset that has only default
            //  field objects will destroy all the fields and set associated
            //  column.field props to nil.
            while((k < Columns.Count) && (Columns.Items[k].Field != Fld))
              k++;
            if(k < Columns.Count)
              Column = Columns.Items[k];
            else
            {
              Column = Columns.InternalAdd();
              Column.Field = Fld;

            }
          }
          else
            Column = Columns.InternalAdd();
          Column.Index = j;
        }

      }
      else
      {
        // Force columns to reaquire fields (in case dataset has changed)
        for(int i = 0; i < Columns.Count; i++)
          Columns.Items[i].Field = null;
      }
    }

    void MeasureTitleHeights()
    {

    }


    if(ComponentState.contains(ComponentStates.Loading) || ComponentState.contains(ComponentStates.Destroying))
      return;


    CheckForPassthroughs();
    _indicatorOffset = 0;
    if(DBOptions.contains(DBGridOptions.Indicator))
      _indicatorOffset++;
    DataLink.ClearMapping();
    if(DataLink.Active)
      DefineFieldMap();
;
    ResetColumnFieldBindings();
    _visibleColumns.clear();
    for(int i = 0; i<Columns.Count; i++)
      if(Columns.Items[i].Showing)
        _visibleColumns.add(Columns.Items[i]);
    ColCount = Columns.Count + _indicatorOffset;
    super.FixedCols = _indicatorOffset;
    _titleOffset = 0;
    if(DBOptions.contains(DBGridOptions.Titles))
    {
      _titleOffset = 1;
      if(DataLink.DataSet != null  /*&& _dataLink.DataSet.ObjectView*/)
      {
        for(int i=0; i<Columns.Count; i++)
        {
          if(Columns.Items[i].Showing)
          {
            int j = Columns.Items[i].Depth();
            if(j>=_titleOffset)
              _titleOffset = j + 1;
          }
        }
      }
    }
    UpdateRowCount();
    MeasureTitleHeights();
    SetColumnAttributes();
    UpdateActive();
    Invalidate();
  }

  void LayoutChanged()
  {
    if(AcquireLayoutLock())
      EndLayout();
  }

  void LinkActive(bool Value)
  {
    if(!Value)
      HideEditor();

    try
    {
      LayoutChanged();
    }
    catch(E)
    {
      print(E);
    }
    finally
    {
      for(int i = ComponentCount-1; i>=0; i--)
      {

      }
      UpdateScrollBar();
      if(Value && DBOptions.contains(DBGridOptions.AlwaysShowEditor))
        ShowEditor();
    }
  }



  bool DoMouseWheelDown(TShiftState Shift, TPoint MousePos)
  {
    KeyDown(TKeyCode(KeyCode.DOWN), TShiftState());
    return true;
  }

  bool DoMouseWheelUp(TShiftState Shift, TPoint MousePos)
  {
    KeyDown(TKeyCode(KeyCode.UP), TShiftState());
    return true;
  }

  void MouseDown(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    if(!AcquireFocus())
      return;

    if(Shift.contains(ShiftStates.Double) && Button == TMouseButton.Left)
    {
      DblClick();
      return;
    }

    if(Sizing(X, Y))
    {
      DataLink.UpdateData();
      super.MouseDown(Button, Shift, X, Y);
      return;
    }

    TGridCoord Cell = MouseCoord(X, Y);
    if(Cell.X < 0 && Cell.Y < 0)
    {
      super.MouseDown(Button, Shift, X, Y);
      return;
    }



    if((ComponentState.contains(ComponentStates.Designing) || DBOptions.contains(DBGridOptions.ColumnResize)) &&
      (Cell.Y < _titleOffset))
    {
      DataLink.UpdateData();
      super.MouseDown(Button, Shift, X, Y);
      return;
    }

    if(DataLink.Active)

    {
      BeginUpdate();   // eliminates highlight flicker when selection moves
      try
      {
        DataLink.UpdateData(); // validate before moving
        HideEditor();
        int OldCol = Col;
        int OldRow = Row;
        if((Y >= _titleOffset) && (Cell.Y - Row != 0))
          DataLink.MoveBy(Cell.Y - Row);
        if(X >= _indicatorOffset)
          MoveCol(Cell.X, 0);
        if((Button == TMouseButton.Left) && DBOptions.contains(DBGridOptions.MultiSelect) && DataLink.Active)

        if((Button == TMouseButton.Left) &&
          ((Cell.X == OldCol && Cell.Y == OldRow) || DBOptions.contains(DBGridOptions.AlwaysShowEditor)))
          ShowEditor();         // put grid in edit mode
        else
          InvalidateEditor();  // draw editor, if needed
      }
      finally
      {
        EndUpdate();
      }
    }
  }



  void MoveCol(int RawCol, int Direction)
  {
    DataLink.UpdateData();
    if(RawCol >= ColCount)
      RawCol = ColCount - 1;
    if(RawCol < _indicatorOffset)
      RawCol = _indicatorOffset;
    if(Direction != 0)
    {
      while((RawCol < ColCount) && (RawCol >= _indicatorOffset) && (ColWidths[RawCol] <= 0))
        RawCol+=Direction;
      if((RawCol >= ColCount) || (RawCol < _indicatorOffset))
        return;
    }
    int OldCol = Col;
    if(RawCol != OldCol)
    {
      if(!_inColExit)
      {
        _inColExit = true;
        try
        {
          ColExit();
        }
        finally
        {
          _inColExit = false;
        }
        if(Col != OldCol)
          return;
      }
      if(!DBOptions.contains(DBGridOptions.AlwaysShowEditor))
        HideEditor();
      Col = RawCol;
      ColEnter();
    }
  }



  void RecordChanged(TField? Field)
  {
    if(HandleAllocated() == false)
      return;
    if(Field == null)
      Invalidate();
    else
    {
      for(int i = 0; i<Columns.Count; i++)
        if(Columns.Items[i].Field == Field)
          InvalidateCol(DataToRawColumn(i));
    }
    TField? CField = SelectedField;
    if(((Field == null) || (CField == Field)) &&
      ((CField != null) && (CField.Text != _editText) &&
      (_isESCKey)))
    {
      InvalidateEditor();
      if(InplaceEditor != null)
        InplaceEditor!.Deselect();
    }
  }

  void Scroll(int Distance)
  {
    
    if(HandleAllocated()==false)
      return;
    TRect OldRect = BoxRect(0, Row, ColCount - 1, Row);
    if((DataLink.ActiveRecord >= RowCount - _titleOffset))
      UpdateRowCount();
    UpdateScrollBar();
    UpdateActive();
    TRect NewRect = BoxRect(0, Row, ColCount - 1, Row);
    Windows.ValidateRect(Handle, OldRect);
    Windows.InvalidateRect(Handle, OldRect, false);
    Windows.InvalidateRect(Handle, NewRect, false);
    if(Distance != 0)
    {
      HideEditor();
      try
      {
        if(Distance.abs() > VisibleRowCount)
        {
          Invalidate();
          return;
        }
        else
        {
          int RowHeight = DefaultRowHeight;
          if(DBOptions.contains(DBGridOptions.RowLines))
            RowHeight+=GridLineWidth;
          if(DBOptions.contains(DBGridOptions.Indicator))
          {
            OldRect = BoxRect(0, _selRow, ColCount - 1, _selRow);
            Windows.InvalidateRect(Handle, OldRect, false);
          }
          NewRect = BoxRect(0, _titleOffset, ColCount - 1, 1000);
          
          if(DBOptions.contains(DBGridOptions.Indicator))
          {
            NewRect = BoxRect(0, Row, ColCount - 1, Row);
            Windows.InvalidateRect(Handle, NewRect, false);
          }
        }
      }
      finally
      {
        if(DBOptions.contains(DBGridOptions.AlwaysShowEditor))
          ShowEditor();
      }
    }
    if(UpdateLock == 0)
      Update();
  }

  bool ReadOnlyField(TField Field)
  {

    if(!Field.ReadOnly && (Field.FieldKind == TFieldKind.Lookup))
    {
      if(Field.DataSet == null)
        return true;
      TField? MasterField = Field.DataSet!.FindField(Field.KeyFields);
      if(MasterField == null)
        return true;
      return MasterField.ReadOnly;
    }
    return false;
  }

  void SetColumnAttributes()
  {
    for(int i = 0; i<Columns.Count; i++)
    {
      TColumn withColumn = Columns.Items[i];
      TabStops[i + _indicatorOffset] = Showing && !ReadOnly && DataLink.Active &&
        (withColumn.Field!=null) && !(withColumn.Field!.FieldKind == TFieldKind.Calculated) && !ReadOnlyField(withColumn.Field!);
      ColWidths[i + _indicatorOffset] = withColumn.Width;
    }
    if(DBOptions.contains(DBGridOptions.Indicator))
      ColWidths[0] = IndicatorWidth;
  }


  TDataSource? get DataSource => DataLink.DataSource;
  void set DataSource(TDataSource? Value)
  {
    if(Value == DataLink.DataSource)
      return;
    if(Value!=null && Value.DataSet!=null && Value.DataSet!.IsUniDirectional)
      DatabaseError(DBConsts.SDataSetUnidirectional);

    DataLink.DataSource = Value;
    if(Value != null)
      Value.FreeNotification(this);
  }

  TField? get SelectedField {
    int Index = SelectedIndex;
    if(Index != -1)
      return Columns.Items[Index].Field;
    return null;
  }

  set SelectedField(TField? Value)
  {
    if(Value == null)
      return;
    for(int i = 0; i<Columns.Count; i++)
      if(Columns.Items[i].Field == Value)
        MoveCol(DataToRawColumn(i), 0);
  }

  int get SelectedIndex {
    return RawToDataColumn(Col);
  }

  void set SelectedIndex(int Value)
  {
    MoveCol(DataToRawColumn(Value), 0);
  }


  void UpdateActive()
  {
    if(DataLink.Active && HandleAllocated() && !ComponentState.contains(ComponentStates.Loading))
    {
      int NewRow = DataLink.ActiveRecord + _titleOffset;
      if(Row != NewRow)
      {
        if(!DBOptions.contains(DBGridOptions.AlwaysShowEditor))
          HideEditor();
        MoveColRow(Col, NewRow, false, false);
        InvalidateEditor();
      }
      TField? Field = SelectedField;
      if((Field!=null) && (Field.Text != _editText))
        InvalidateEditor();
    }
  }

  void UpdateData()
  {
    TField? Field = SelectedField;
    if(Field != null)
      Field.Text = _editText;
  }

  int GetMaxVisibleRowCount()
  { // new
    int mem = _rowCount;
    _rowCount = 1000;
    int Result = VisibleRowCount;
    _rowCount = mem;
    return Result;
  }

  void UpdateRowCount()
  {
    int OldRowCount = RowCount;
    if(RowCount <= _titleOffset)
      RowCount = _titleOffset + 1;
    FixedRows = _titleOffset;
    
    if(!DataLink.Active || (DataLink.RecordCount == 0) || !HandleAllocated())
      RowCount = 1 + _titleOffset;
    else
    {

      DataLink.BufferCount = GetMaxVisibleRowCount();
      RowCount = DataLink.RecordCount + _titleOffset;
      if(DBOptions.contains(DBGridOptions.RowSelect))
        TopRow = FixedRows;
      UpdateActive();
    }
    if(OldRowCount != RowCount)
    {
      ConstrainGrid(); // new

    }
  }

  void UpdateScrollBar()
  {
    if(DataLink.Active && HandleAllocated())
    {
      TDataSet ds = DataLink.DataSet!;
      TScrollInfo SIOld = ScrollArea.GetInfo(Windows.SB_VERT);
      TScrollInfo SINew = TScrollInfo.info(SIOld);
      if(ds.IsSequenced())
      {
        SINew.nMin = 1;
        SINew.nPage = VisibleRowCount;
        SINew.nMax = ds.RecordCount + SINew.nPage - 1;
        if([TDataSetState.Inactive, TDataSetState.Browse, TDataSetState.Edit].contains(ds.State))
          SINew.nPos = ds.RecNo;  // else keep old pos
      }
      else
      {
        SINew.nMin = 0;
        SINew.nPage = 0;
        SINew.nMax = 4;
        if(DataLink.Bof)
          SINew.nPos = 0;
        else
        if(DataLink.Eof)
          SINew.nPos = 4;
        else
          SINew.nPos = 2;
      }
      if((SINew.nMin != SIOld.nMin) || (SINew.nMax != SIOld.nMax) ||
        (SINew.nPage != SIOld.nPage) || (SINew.nPos != SIOld.nPos))
        ScrollArea.SetInfo(Windows.SB_VERT, SINew);
    }
  }



  void _wmVScroll(TMessage Message) 
  {
    if(!AcquireFocus())
      return;
    if(DataLink.Active)
    {
      SCROLLINFO pos = Message.WParam as SCROLLINFO;
      switch(pos.ScrollCode)
      {
        case Windows.SB_LINEUP:   DataLink.MoveBy(-DataLink.ActiveRecord - 1); break;
        case Windows.SB_LINEDOWN: DataLink.MoveBy(DataLink.RecordCount - DataLink.ActiveRecord); break;
        case Windows.SB_PAGEUP:   DataLink.MoveBy(-VisibleRowCount); break;
        case Windows.SB_PAGEDOWN: DataLink.MoveBy(VisibleRowCount); break;
        case Windows.SB_BOTTOM:   DataLink.DataSet!.Last(); break;
        case Windows.SB_TOP:      DataLink.DataSet!.First(); break;

        case Windows.SB_THUMBPOSITION:
          TDataSet ds = DataLink.DataSet!;
          if(ds.IsSequenced())
          {
            TScrollInfo SI = ScrollArea.GetInfo(Windows.SB_VERT);

            if(SI.nTrackPos <= 1)
              ds.First();
            else
            if(SI.nTrackPos >= ds.RecordCount)
              ds.Last();
            else
              ds.RecNo = SI.nTrackPos;
          }
          else
          switch(pos.Position)
          {
            case 0: DataLink.DataSet!.First(); break;
            case 1: DataLink.MoveBy(-VisibleRowCount); break;
            case 2: return;
            case 3: DataLink.MoveBy(VisibleRowCount); break;
            case 4: DataLink.DataSet!.Last(); break;
          }
      }
    }
  }



  void UpdateIme()
  {

  }



  void InvalidateTitles()
  {
    if(HandleAllocated() && DBOptions.contains(DBGridOptions.Titles))
    {
      TGridDrawInfo DrawInfo = TGridDrawInfo();
      CalcFixedInfo(DrawInfo);
      TRect R = TRect(0, 0, Width, DrawInfo.Vert.FixedBoundary);
      Windows.InvalidateRect(Handle, R, false);
    }
  }


}

class TDBGrid extends TCustomDBGrid
{

  TDBGrid(TComponent AOwner) : super(AOwner)
  {

  }

}