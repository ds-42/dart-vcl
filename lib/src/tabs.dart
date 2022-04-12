part of vcl;

// eash TEdgeType is made up of one or two of these parts
enum TEdgePart { SelectedLeft, UnselectedLeft, SelectedRight, UnselectedRight }

// represents the intersection between two tabs, or the edge of a tab
enum TEdgeType { None, FirstIsSel, FirstNotSel, LastIsSel, LastNotSel,
                 NotSelToSel, SelToNotSel, NotSelToNotSel}

enum TTabStyle { Standard, OwnerDraw }

typedef  bool TTabChangeEvent(TObject Sender, int NewTab);

class TTabPos
{
  int Size = 0;
  int StartPos = 0;
}

class TScroller extends TCustomControl
{

 TScroller(TComponent? AOwner) : super(AOwner)
 {

 }

  int _min = 0;
  int
    get Min => _min;
    set Min(int Value)
    {
      if(Value < _max)
        _min = Value;
    }

  int _max = 0;
  int
    get Max => _max;
    set Max(int Value)
    {
      if(Value > _min)
        _max = Value;
    }

  int _position = 0;
  int
    get Position => _position;
    set Position(int Value)
    {
      if(Value == Position)
        return;
      if(Value < Min) Value = Min;
      if(Value > Max) Value = Max;
      _position = Value;
      Invalidate();
      if(OnClick!=null)
        OnClick!(this);
    }

}

class TTabList extends TStringList
{
  final TTabSet Tabs;

  TTabList(this.Tabs) : super();

  int Add(String S)
  {
    int Result = super.Add(S);
    Tabs.Invalidate();
    return Result;
  }

  void Insert(int Index, String S)
  {
    super.Insert(Index, S);
    if(Index <= Tabs.TabIndex)
      Tabs._tabIndex++;
    Tabs.Invalidate();
  }

  void Delete(int Index)
  {
    int OldIndex = Tabs.TabIndex;
    super.Delete(Index);

    if(OldIndex < Count)
      Tabs._tabIndex = OldIndex;
    else
      Tabs._tabIndex = Count - 1;
    Tabs.Invalidate();
    if(OldIndex == Index)
      Tabs.Click();  // deleted selected tab
  }

  void Put(int Index, String S)
  {
    super.Put(Index, S);
    Tabs.Invalidate();
  }

  void Clear()
  {
    super.Clear();
    Tabs._tabIndex = -1;
    Tabs.Invalidate();
  }

  void AddStrings(TStrings Strings)
  {
    Windows.SendMessage(Tabs.Handle, WM_SETREDRAW, 0, 0);
    super.AddStrings(Strings);
    Windows.SendMessage(Tabs.Handle, WM_SETREDRAW, 1, 0);
    Tabs.Invalidate();
  }
}

class TTabSet extends TCustomControl
{
  static const EdgeWidth = 9;  // This controls the angle of the tab edges

  int _ownerDrawHeight = 20;

  final _memBitmap = TBitmap(); // used for off-screen drawing

  final _tabPositions = <TTabPos>[];
  bool _doFix = false;

  late final TScroller _scroller;
  TScroller get Scroller => _scroller;

  int _firstIndex = 0;
  int
    get FirstIndex => _firstIndex;
    set FirstIndex(int Value)
    {
      if((Value >= 0) && (Value < Tabs.Count))
      {
        _firstIndex = Value;
        Invalidate();
      }
    }

  bool _autoScroll = true;
  bool
    get AutoScroll => _autoScroll;
    set AutoScroll(bool Value)
    {
      if(Value == AutoScroll)
        return;
      _autoScroll = Value;
      Scroller.Visible = false;
      Windows.ShowWindow(Scroller.Handle, Windows.SW_HIDE);
      Invalidate();
    }

  TColor _backgroundColor = clBtnFace;
  TColor
    get BackgroundColor => _backgroundColor;
    set BackgroundColor(TColor Value)
    {
      if(BackgroundColor == Value)
        return;
      _backgroundColor = Value;
      
      _memBitmap.Canvas.Brush.Style = TBrushStyle.Solid;
      Invalidate();
    }

  bool _ditherBackground = true;
  bool
    get DitherBackground => _ditherBackground;
    set DitherBackground(bool Value)
    {
      if(DitherBackground == Value)
        return;
      _ditherBackground = Value;
      
      _memBitmap.Canvas.Brush.Style = TBrushStyle.Solid;
      Invalidate();
    }

  int _endMargin = 5;
  int
    get EndMargin => _endMargin;
    set EndMargin(int Value)
    {
      if(Value == EndMargin)
        return;
      _endMargin = Value;
      Invalidate();
    }

  int _startMargin = 5;
  int
    get StartMargin => _startMargin;
    set StartMargin(int Value)
    {
      if(Value==StartMargin)
        return;
      _startMargin = Value;
      Invalidate();
    }

  TColor _selectedColor = clBtnFace;
  TColor
    get SelectedColor => _selectedColor;
    set SelectedColor(TColor Value)
    {
      if(SelectedColor == Value)
        return;
      _selectedColor = Value;
      
      Invalidate();
    }

  bool _softTop = false;
  bool
    get SoftTop => _softTop;
    set SoftTop(bool Value)
    {
      if(Value == SoftTop)
        return;
      _softTop = Value;
      
      Invalidate();
    }

  TTabStyle _style = TTabStyle.Standard;
  TTabStyle
    get Style => _style;
    set TabStyle(TTabStyle Value)
    {
      if(_style == Value)
        return;
      _style = Value;
      
      Invalidate();
    }

  int _tabHeight = 20;
  int
    get TabHeight => _ownerDrawHeight;
    set TabHeight(int Value)
    {
      if(Value == _ownerDrawHeight)
        return;
      int SaveHeight = _ownerDrawHeight;
      try
      {
        _ownerDrawHeight = Value;
        
        Invalidate();
      }
      catch(e)
      {
        _ownerDrawHeight = SaveHeight;
        throw e;
      }
    }

  late final TStrings _tabs;
  TStrings
    get Tabs => _tabs;
    set Tabs(TStrings Value)
    {
      Tabs.Assign(Value);
      _tabIndex = -1;
      if(Tabs.Count > 0)
        TabIndex = 0;
      else
        Invalidate();
    }

  int _tabIndex = -1;
  int
    get TabIndex => _tabIndex;
    set TabIndex(int Value)
    {
      if(Value == TabIndex)
        return;
      if((Value < -1) || (Value >= Tabs.Count))
        throw TException.CreateRes(Consts.SInvalidTabIndex);

      if(CanChange(Value))
      {
        _tabIndex = Value;
        FixTabPos();
        Click();
        Invalidate();
      }
    }

  TColor _unselectedColor = clWindow;
  TColor
    get UnselectedColor => _unselectedColor;
    set UnelectedColor(TColor Value)
    {
      if(UnselectedColor == Value)
        return;
      _unselectedColor = Value;
      
      Invalidate();
    }

  int _visibleTabs = 0; // set by draw routine
  int get VisibleTabs => _visibleTabs;

  TTabChangeEvent? _onChange;
  TTabChangeEvent?
    get OnChange => _onChange;
    set OnChange(TTabChangeEvent? Value) => _onChange = Value;

  TTabSet(TComponent? AOwner) : super(AOwner)
  {
    ControlStyle.assign( [ControlStyles.CaptureMouse, ControlStyles.DoubleClicks, ControlStyles.Opaque] );

    Width = 185;
    Height = 21;

    _tabs = TTabList(this);
    
    // CreateScroller();
    _scroller = TScroller(this);
    Scroller
      ..Parent = this
      ..Top = 3
      ..Min = 0
      ..Max = 0
      ..Position = 0
      ..Visible = false
      ..OnClick = (Sender) =>
          FirstIndex = Scroller.Position;

  }

  void CreateWnd()
  {
    super.CreateWnd();
    WindowHandle!.style.overflow = 'hidden';
  }

  /// cache the tab position data, and return number of visible tabs
  int CalcTabPositions(int Start, int Stop, TCanvas Canvas, int First)
  {
    _tabPositions.clear();  /// erase all previously cached data
    int Index = First;
    while((Start < Stop) && (Index < Tabs.Count))
    {
      var TabPos = TTabPos();
      TabPos.StartPos = Start;
      TabPos.Size = ItemWidth(Index);
      Start+=TabPos.Size + EdgeWidth; // next usable position

      if(Start <= Stop)
      {
        _tabPositions.add(TabPos); // add to list
        Index++;
      }
    }
    return Index - First;
  }

  int ItemAtPos(TPoint Pos)
  {
    if((Pos.x < 0) || (Pos.x > ClientHeight))
      return -1;
    for(int i = 0; i<_tabPositions.length; i++)
    {
      var TabPos = _tabPositions[i];
      if((Pos.x >= TabPos.StartPos) && (Pos.x <= TabPos.StartPos + TabPos.Size))
        return i;
    }
    return -1;
  }

  TRect ItemRect(int Item)
  {
    if(_tabPositions.isNotEmpty && (Item >= 0) && (Item < _tabPositions.length))
    {
      var TabPos = _tabPositions[Item];
      var Result = TRect(TabPos.StartPos, 0, TabPos.StartPos + TabPos.Size, _tabHeight);
      InflateRect(Result, 1, -2);
      return Result;
  }
    else
      return TRect(0, 0, 0, 0);
  }

  void Paint()
  {
    if(!HandleAllocated())
      return;
    // Set the size of the off-screen bitmap.  Make sure that it is tall enough to
    //  display the entire tab, even if the screen won't display it all.  This is
    //  required to avoid problems with using FloodFill.
    _memBitmap.Width = ClientWidth;
    if(ClientHeight < _tabHeight + 5)
      _memBitmap.Height = _tabHeight + 5;
    else
      _memBitmap.Height = ClientHeight;
    _memBitmap.Canvas.Font = this.Canvas.Font;

    int TabStart = StartMargin + EdgeWidth;        // where does first text appear?
    int LastTabPos = Width - EndMargin;            // tabs draw until this position
    Scroller.Left = Width - Scroller.Width - 2;

    // do initial calculations for how many tabs are visible
    _visibleTabs = CalcTabPositions(TabStart, LastTabPos, _memBitmap.Canvas, FirstIndex);

    // enable the scroller if FAutoScroll = True and not all tabs are visible
    if(AutoScroll && (VisibleTabs < Tabs.Count))
    {
      LastTabPos -= Scroller.Width - 4;
      // recalc the tab positions
      _visibleTabs = CalcTabPositions(TabStart, LastTabPos, _memBitmap.Canvas,  FirstIndex);

      // set the scroller's range
      Scroller.Visible = true;
      Windows.ShowWindow(Scroller.Handle, Windows.SW_SHOW);
      Scroller.Min = 0;
      Scroller.Max = Tabs.Count - VisibleTabs;
      Scroller.Position = FirstIndex;
    }
    else
    if(VisibleTabs >= Tabs.Count)
    {
      Scroller.Visible = false;
      Windows.ShowWindow(Scroller.Handle, Windows.SW_HIDE);
    }

    if(_doFix)
    {
      FixTabPos();
      _visibleTabs = CalcTabPositions(TabStart, LastTabPos, _memBitmap.Canvas, FirstIndex);
    }
    _doFix = false;

    // draw background of tab area
    TCanvas cnv = _memBitmap.Canvas;
    cnv.Handle.init();
    
    cnv.Brush.Color = BackgroundColor;
    cnv.FillRectangle(0, 0, _memBitmap.Width, _memBitmap.Height);

    // draw top edget
    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    //  \               /--------------/
    //   \             /\             /
    //    \___________/  \___________/

    cnv.Pen.Width = 1;
    cnv.Pen.Color = clBtnShadow;
    cnv.MoveTo(0, 0);
    cnv.LineTo(_memBitmap.Width + 1, 0);

    if(!SoftTop)
    {
      cnv.Pen.Color = clWindowFrame;
      cnv.MoveTo(0, 1);
      cnv.LineTo(_memBitmap.Width + 1, 1);
    }

    for(int Tab = 0; Tab < _tabPositions.length; Tab++)
    {
      var TabPos = _tabPositions[Tab];

      bool isFirst = Tab == 0;
      bool isLast  = Tab == VisibleTabs - 1;
      bool isSelected = Tab + FirstIndex == TabIndex;
      bool isPrevSelected = (Tab + FirstIndex) - 1 == TabIndex;

      // Rule: every tab paints its leading edge, only the last tab paints a
      //  trailing edge
      TEdgeType Trailing = TEdgeType.None;
      TEdgeType Leading;

      if(isLast)
        Trailing = isSelected? TEdgeType.LastIsSel : TEdgeType.LastNotSel;

      if(isFirst)
        Leading = isSelected? TEdgeType.FirstIsSel : TEdgeType.FirstNotSel;
      else  // not first
      {
        if(isPrevSelected)
          Leading = TEdgeType.SelToNotSel;
        else
          Leading = isSelected? TEdgeType.NotSelToSel : TEdgeType.NotSelToNotSel;
      }

      // draw leading edge
      // |XXXX|================================
      // | X  |             /--------------/
      // |  X |            /\             /
      // |   X|___________/  \___________/
      if(Leading != TEdgeType.None)
        PaintEdge(TabPos.StartPos - EdgeWidth, 0, _tabHeight - 1, Leading);

      // set up the canvas
      var R = TRect(TabPos.StartPos, 0, TabPos.StartPos + TabPos.Size, _tabHeight);

      cnv.Brush.Color = isSelected? SelectedColor : UnselectedColor;
      Windows.ExtTextOut(cnv.Handle, TabPos.StartPos, 2, Windows.ETO_OPAQUE, R, '', 0, null);

      // restore font for drawing the text
      _memBitmap.Canvas.Font = this.Canvas.Font;
      // Owner
      if(Style == TTabStyle.OwnerDraw)
        DrawTab(cnv, R, Tab + FirstIndex, isSelected);
      else
      {
        R.Top += 2;
        Windows.DrawText(cnv.Handle, Tabs.Strings[Tab + FirstIndex], -1, R, Windows.DT_CENTER );
      }

      // draw trailing edge
      // ===============|XXXX|=================
      //  \             |  XX|-------------/
      //   \            | XX |            /
      //    \___________|X  X|___________/
      // or
      // ==============================|XXXX|==
      //  \               /------------|XXX |
      //   \             /\            | X  |
      //    \___________/  \___________|X   |
      if(Trailing != TEdgeType.None)
        PaintEdge(TabPos.StartPos + TabPos.Size, 0, _tabHeight - 1, Trailing);

      // draw connecting lines above and below the text
      // ====================================
      //  \               /-XXXXXXXXXXX--/
      //   \             /\             /
      //    \XXXXXXXXXXX/  \XXXXXXXXXXX/
      cnv.Pen.Color = clWindowFrame;
      cnv.MoveTo(TabPos.StartPos, _tabHeight - 1);
      cnv.LineTo(TabPos.StartPos + TabPos.Size, _tabHeight - 1);

      if(isSelected)
      {
        cnv.Pen.Color = clBtnShadow;
        cnv.MoveTo(TabPos.StartPos, _tabHeight - 2);
        cnv.LineTo(TabPos.StartPos + TabPos.Size + 1, _tabHeight - 2);
      }
      else
      {
        if(SoftTop)
          cnv.Pen.Color = BackgroundColor;
        else
          cnv.Pen.Color = clWindowFrame;
        cnv.MoveTo(TabPos.StartPos-1, 1);
        cnv.LineTo(TabPos.StartPos + TabPos.Size, 1);

        cnv.Pen.Color = clBtnShadow;
        cnv.MoveTo(TabPos.StartPos-1, 0);
        cnv.LineTo(TabPos.StartPos + TabPos.Size + 1, 0);
      }
    }

    // draw onto the screen
    Canvas.Draw(0, 0, _memBitmap);
  }

  void PaintEdge(int X, int Y, int H, TEdgeType Edge)
  {
    var Canvas = _memBitmap.Canvas;

    void DrawUL()
    {
      Canvas.Pen.Color = clBtnShadow;
      Canvas.PolylineEx(X, Y, [ 0,0, EdgeWidth+1, 0] );

      Canvas.Pen.Color = UnselectedColor;
      Canvas.Brush.Color = UnselectedColor;
      Canvas.PolylineEx(X, Y, [ 3,1,  EdgeWidth-1,H,  EdgeWidth,H,  EdgeWidth,1 ], true);

      if(SoftTop)
      {
        Canvas.Pen.Color = BackgroundColor;
        Canvas.PolylineEx(X, Y, [ 4,1,  EdgeWidth+1,1 ] );
        Canvas.Pen.Color = clWindowFrame;
        Canvas.PolylineEx(X, Y, [ 3,1,  EdgeWidth-1,H,  EdgeWidth,H ] );
      }
      else
      {
        Canvas.Pen.Color = clWindowFrame;
        Canvas.PolylineEx(X, Y, [ 0,1,  EdgeWidth+1,1,  3,1,  EdgeWidth-1,H,  EdgeWidth,H ] );
      }
    }

    void DrawSL()
    {
      Canvas.Pen.Color = SelectedColor;
      Canvas.Brush.Color = SelectedColor;
      Canvas.PolylineEx(X, Y, [3,0, EdgeWidth-1,H, EdgeWidth,H, EdgeWidth,0, 3,0], true );

      Canvas.Pen.Color = clBtnShadow;
      Canvas.PolylineEx(X, Y, [0,0, 4,0] );

      Canvas.Pen.Color = clWindowFrame;
      if(SoftTop)
        Canvas.PolylineEx(X, Y, [3,1, EdgeWidth-1,H, EdgeWidth,H] );
      else
        Canvas.PolylineEx(X, Y, [0,1, 3,1, EdgeWidth-1,H, EdgeWidth,H]);

      Canvas.Pen.Color = clBtnHighlight;
      Canvas.PolylineEx(X, Y, [4,1, EdgeWidth, H+1] );
    }

    void DrawUR()
    {
      Canvas.Pen.Color = clBtnShadow;
      Canvas.PolylineEx(X, Y, [ -1,0,  EdgeWidth+1,0 ] );

      Canvas.Pen.Color = UnselectedColor;
      Canvas.Brush.Color = UnselectedColor;
      Canvas.PolylineEx(X, Y, [ EdgeWidth-3,1,  1,H,  0,H,  0,1,  EdgeWidth-3,1 ], true );

      Canvas.Pen.Color = clBtnShadow;
      Canvas.PolylineEx(X, Y, [ -1,0,  EdgeWidth+1,0 ] );

      if(SoftTop)
      {
        Canvas.Pen.Color = BackgroundColor;
        Canvas.PolylineEx(X, Y, [ 0,1,  EdgeWidth-1,1 ] );
        Canvas.Pen.Color = clWindowFrame;
        Canvas.PolylineEx(X, Y, [ EdgeWidth-2,1,  2,H,  -1,H ] );
      }
      else
      {
        Canvas.Pen.Color = clWindowFrame;
        Canvas.PolylineEx(X, Y, [ 0,1,  EdgeWidth+1,1,  EdgeWidth-2,1,  2,H,  -1,H ] );
      }
    }

    void DrawSR()
    {
      Canvas.Pen.Color = SelectedColor;
      Canvas.Brush.Color = SelectedColor;
      Canvas.PolylineEx(X, Y, [ EdgeWidth-3,1,  2,H,  0,H,  0,0,  EdgeWidth+1,0 ], true);

      Canvas.Pen.Color = clBtnShadow;
      Canvas.PolylineEx(X, Y, [ EdgeWidth+1,0,  EdgeWidth-3,0,  EdgeWidth-3,1,   /*0*/1,H,  -1,H] );

      Canvas.Pen.Color = clWindowFrame;
      if(SoftTop)
        Canvas.PolylineEx(X, Y, [ EdgeWidth-2,1,  2,H,  -1,H ] );
      else
        Canvas.PolylineEx(X, Y, [ EdgeWidth,1,  EdgeWidth-2,1,  2,H,  -1,H ] );
    }

    Canvas.Brush.Color = clWhite;
    Canvas.Font.Color = clBlack;

    switch(Edge)
    {
      case TEdgeType.FirstIsSel:
        DrawSL();
        break;

      case TEdgeType.LastIsSel:
        DrawSR();
        break;

      case TEdgeType.FirstNotSel:
        DrawUL();
        break;

      case TEdgeType.LastNotSel:
        DrawUR();
        break;

      case TEdgeType.NotSelToSel:
        DrawUR();
        DrawSL();
        break;

      case TEdgeType.SelToNotSel:
        DrawUL();
        DrawSR();
        break;

      case TEdgeType.NotSelToNotSel:
        DrawUL();
        DrawUR();
        break;

      default:
        break;
    }
  }

  void FixTabPos()
  {
    int _lastVisibleTab;

    int GetRightSide()
    {
      int Result = Width - EndMargin;
      if(AutoScroll && (VisibleTabs < Tabs.Count - 1))
        Result-=Scroller.Width + 4;
      return Result;
    }

    int ReverseCalcNumTabs(int Start, int Stop, TCanvas Canvas, int Last)
    {
      if(HandleAllocated())
      {
        int Result = Last;
        while((Start >= Stop) && (Result >= 0))
        {
          var W = Integer(Canvas.TextWidth(Tabs.Strings[Result]));
          if(Style == TTabStyle.OwnerDraw)
            MeasureTab(Result, W);
          Start -= W.Value + EdgeWidth; // next usable position
          if(Start >= Stop)
            Result--;
        }
        if((Start < Stop) || (Result < 0))
          Result++;
        return Result;
      }
      return FirstIndex;
    }

    if(Tabs.Count > 0)
    {
      _lastVisibleTab = FirstIndex + VisibleTabs - 1;
      if(TabIndex > _lastVisibleTab)
        _firstIndex = ReverseCalcNumTabs(GetRightSide(), StartMargin + EdgeWidth,
            Canvas, TabIndex);
      else
      if((TabIndex >= 0) && (TabIndex < FirstIndex))
        _firstIndex = TabIndex;
    }
  }

  bool CanChange(int NewIndex)
  {
    bool Result = true;
    if(OnChange != null)
      Result = OnChange!(this, NewIndex);
    return Result;
  }

  void SelectNextTab(bool Direction) 
  {
    if(Tabs.Count <= 1)
      return;
    int NewIndex = TabIndex;
    if(Direction)
      NewIndex++;
    else
      NewIndex--;
    if(NewIndex == Tabs.Count)
      NewIndex = 0;
    else
    if(NewIndex < 0)
      NewIndex = Tabs.Count - 1;
    TabIndex = NewIndex;
  }

  void DrawTab(TCanvas TabCanvas, TRect R, int Index, bool Selected)
  {
    
  }

  void MeasureTab(int Index, Integer TabWidth)
  { 
  }

  void MouseDown(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    super.MouseDown(Button, Shift, X, Y);
    if((Button == TMouseButton.Left) && (Y <= TabHeight))
    {
      int Extra;
      if(Y < TabHeight~/2)
        Extra = EdgeWidth ~/ 3;
      else
        Extra = EdgeWidth ~/ 2;

      int i=-1;
      for(var TabPos in _tabPositions)
      {
        i++;
        int MinLeft = TabPos.StartPos - Extra;
        int MaxRight = TabPos.StartPos + TabPos.Size + Extra;
        if((X >= MinLeft) && (X <= MaxRight))
        {
          TabIndex = FirstIndex + i;
          break;
        }
      }
    }
  }

  void _wmSize(TWMSize Message)
  {
    int CalcNumTabs(int Start, int Stop, TCanvas Canvas, int First)
    {
      int Result = First;
      while((Start < Stop) && (Result < Tabs.Count))
      {
        Start += ItemWidth(Result) + EdgeWidth; // next usable position
        if(Start <= Stop)
          Result++;
      }
      return Result;
    }

    super._wmSize(Message);

    if(Tabs.Count > 1)
    {
      int LastTabPos = Width - EndMargin;
      int NumVisTabs = CalcNumTabs(StartMargin + EdgeWidth, LastTabPos, Canvas, 0);
      if((TabIndex == Tabs.Count) || (NumVisTabs > VisibleTabs) ||
         (NumVisTabs == Tabs.Count))
        FirstIndex = Tabs.Count - NumVisTabs;
      _doFix = true;
    }
    Invalidate();
  }

  TRect MinClientRect()
  {
    return MinClientRectEx(Tabs.Count, false);
  }

  TRect MinClientRectEx(int TabCount, bool IncludeScroller)
  {
    var Result = TRect(0, 0, StartMargin, _tabHeight + 5);
    for(int i=0; i<TabCount; i++)
      Result.Right +=ItemWidth(i) + EdgeWidth;
    Result.Right+=EndMargin;
    if(IncludeScroller)
      Result.Right+=Scroller.Width + 4;
    return Result;
  }

  int ItemWidth(int Index)
  {
    var Result = Integer(Canvas.TextWidth(Tabs.Strings[Index]));
    if (Style == TTabStyle.OwnerDraw)
      MeasureTab(Index, Result);
    return Result.Value;
  }

}

