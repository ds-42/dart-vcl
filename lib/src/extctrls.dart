part of vcl;


enum TBevelStyle { Lowered, Raised }
enum TBevelShape { Box, Frame, TopLine, BottomLine, LeftLine,
                   RightLine, Spacer }

class TBevel extends TWinControl //TGraphicControl
{
  TBevel(TComponent AOwner) : super(AOwner)
  {
    // ControlStyle := ControlStyle + [csReplicatable];
    _style = TBevelStyle.Lowered;
    _shape = TBevelShape.Box;
    Width = 50;
    Height = 50;

    Flex.BreakBefore = true;     // new
    Flex.SetMargin(0, 5, 0, 0);  // new
  }

  TBevelStyle _style = TBevelStyle.Lowered;
  TBevelStyle
    get Style => _style;
    set Style(TBevelStyle Value)
    {
      if(Value == _style)
        return;
      _style = Value;
      Invalidate();
    }

  TBevelShape _shape = TBevelShape.Box;
  TBevelShape
    get Shape => _shape;
    set Shape(TBevelShape Value)
    {
      if(Value == _shape)
        return;
      _shape = Value;
      Invalidate();
    }

  void CreateWnd()
  {
    super.CreateWnd();
    _update_control(WindowHandle!.handle);
  }

  void _update_control(Element elem)
  {
    elem.style.border = null;

    String style = '2px ${ Style==TBevelStyle.Lowered? 'groove' : 'ridge' }';

    switch(Shape)
    {
      case TBevelShape.Box:
        elem.style.border = '1px ${ Style==TBevelStyle.Lowered? 'inset' : 'outset' }';
        break;
      case TBevelShape.Frame:
        elem.style.border = style;
        break;
      case TBevelShape.TopLine:
        elem.style.borderTop = style;
        break;
      case TBevelShape.LeftLine:
        elem.style.borderLeft = style;
        break;
      case TBevelShape.RightLine:
        elem.style.borderRight = style;
        break;
      case TBevelShape.BottomLine:
        elem.style.borderBottom = style;
        break;
      case TBevelShape.Spacer:
        break;
    }

  }

  void InvalidateControl(bool IsVisible, bool IsOpaque) // new
  {
    if(HandleAllocated())
      _update_control(Handle.handle);

    super.InvalidateControl(IsVisible, IsOpaque);
  }
}



class TCustomPanel extends TCustomControl
{
  bool CanFocus() => false;
  
  TBevelCut _bevelInner = TBevelCut.None;
  TBevelCut
    get BevelInner => _bevelInner;
    set BevelInner(TBevelCut Value)
    {
      if(BevelInner == Value)
        return;
      _bevelInner = Value;
      Realign();
      Invalidate();
    }

  TBevelCut _bevelOuter = TBevelCut.Raised;
  TBevelCut
    get BevelOuter => _bevelOuter;
    set BevelOuter(TBevelCut Value)
    {
      if(_bevelOuter == Value)
        return;
      _bevelOuter = Value;
      Realign();
      Invalidate();
    }

  int _bevelWidth = 1;
  int
    get BevelWidth => _bevelWidth;
    set BevelWidth(int Value)
    {
      if(_bevelWidth == Value)
        return;
      _bevelWidth = Value;
      Realign();
      Invalidate();
    }

  void _update_control(Element elem)
  {
    int key = _bevelOuter.index*4+_bevelInner.index;
    int w = 1; // BevelWidth
    String? style;
    String  color='';
    switch(key)
    {
      case 1: // none+lowered
      case 4: // lowered+none
        style='inset';
        break;
      case 2: // none+raised
      case 8: // raised+none
        style='outset';
        break;
      case 3: // none+Space
      case 12: // Space+none
        style='solid';
        color='gray';
        break;
      case 5: // raised+raised
        style='inset'; w=2;
        break;
      case 6: // lowered+raised
        style='groove'; w=2;
        break;
      case 9: // raised+lowered
        style='ridge'; w=2;
        break;
      case 10: // raised+raised
        style='outset'; w=2;
        break;
      case 15: // space+space
        style='double';
        color='gray';
        w=2;
        break;
    }
    elem.style.border = style==null? null : "${w+BevelWidth-1}px $color $style";

  }

  void InvalidateControl(bool IsVisible, bool IsOpaque) // new
  {
    if(HandleAllocated())
      _update_control(Handle.handle);

    super.InvalidateControl(IsVisible, IsOpaque);
  }
    

  TCustomPanel(TComponent AOwner) : super(AOwner)
  {
    
    Width = 185;
    Height = 41;
    Color = clBtnFace;
    
  }



  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HPanel();
    _update_control(WindowHandle!.handle);
    WindowHandle!.handle.text = Params.Caption;
    if(Color!=clNone)
      WindowHandle!.style.backgroundColor = Color.html;

  }

  void CreateWnd()
  {
    super.CreateWnd();
    _updateStyle(); 
  }

  void _updateStyle()
  {
    if(WindowHandle!.handle.text==null || WindowHandle!.handle.text!.isEmpty)
    {
      WindowHandle!.handle.classes.remove('text');
      WindowHandle!.style.lineHeight = null;
    }
    else
    {
      WindowHandle!.handle.classes.add('text');
      WindowHandle!.style.lineHeight = '${Height}px';
    }
  }


}

class TPanel extends TCustomPanel
{
  String
    get Caption => _getText();
    set Caption(String Value) => _setText(Value);

  TPanel(TComponent AOwner) : super(AOwner)
  {

  }
}


enum TResizeStyle { None, Line, Update, Pattern }

class TSplitter extends TGraphicControl
{


  bool _autoSnap = true;
  bool
    get AutoSnap => _autoSnap;
    set AutoSnap(bool Value) => _autoSnap = Value;

  TControl? _control;
  TPoint _downPos = TPoint();

  int _minSize = 30;
  int _maxSize =  0;
  int _newSize =  0;
  int _split   =  0;
  int _oldSize = -1;

  TResizeStyle _resizeStyle = TResizeStyle.Pattern;
  TResizeStyle
    get ResizeStyle => _resizeStyle;
    set ResizeStyle(TResizeStyle Value) => _resizeStyle = Value;

  int
    get MinSize => _minSize;
    set MinSize(int Value)
    {
      if(Value<0)
        Value=0;
      _minSize = Value;
    }

  TSplitter(TComponent AOwner) : super(AOwner)
  {
    Align = TAlign.Left;
    Width = 3;
    Cursor = TCursor.HSplit;
  }

  

  void DrawLine()
  {

  }



  TControl? FindControl()
  {
    TPoint P = TPoint(Left, Top);
    switch(Align)
    {
      case TAlign.Left:   P.x--; break;
      case TAlign.Right:  P.x+=Width; break;
      case TAlign.Top:    P.y--; break;
      case TAlign.Bottom: P.y+=Height; break;
      default: return null;
    }
    for(var ctrl in [...Parent!._controls, ...Parent!._winControls])
    {
      if(ctrl.Visible && ctrl.Enabled)
      {
        TRect R = ctrl.BoundsRect;
        if((R.right - R.left) == 0)
          if(Align==TAlign.Top || Align==TAlign.Left)
            R.left--;
          else
            R.right++;
        if((R.bottom - R.top) == 0)
          if(Align==TAlign.Top || Align==TAlign.Left)
            R.top--;
          else
            R.bottom++;
        if(PtInRect(R, P))
          return ctrl;
      }
    }
    return null;
  }

  void RequestAlign()
  {
    super.RequestAlign();
    if((Cursor != TCursor.VSplit) && (Cursor != TCursor.HSplit))
      return;
    if(Align == TAlign.Bottom || Align == TAlign.Top)
      Cursor = TCursor.VSplit;
    else
      Cursor = TCursor.HSplit;
  }

  void Paint()

  {

    if(Beveled)
    {


    }
    
  }

  bool DoCanSplitResize(Integer NewSize)
  {
    bool Result = CanSplitResize(NewSize);
    if(Result && (NewSize.Value <= MinSize) && _autoSnap)
      NewSize.Value = 0;
    return Result;
  }

  bool CanSplitResize(Integer NewSize)
  {
    bool Result = true;

    return Result;
  }

  void MouseDown(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    super.MouseDown(Button, Shift, X, Y);
    if(Button == TMouseButton.Left)
    {
      _control = FindControl();

      _downPos = TPoint(X, Y);
      if(_control!=null)
      {
        if(Align == TAlign.Left || Align == TAlign.Right)
        {
          _maxSize = Parent!.ClientWidth - MinSize;
          for(var ctrl in [...Parent!._controls, ...Parent!._winControls])
            if(ctrl.Visible && (ctrl.Align==TAlign.Left || ctrl.Align==TAlign.Right))
              _maxSize-=ctrl.Width;
          _maxSize+=_control!.Width;
        }
        else
        {
          _maxSize = Parent!.ClientHeight - MinSize;
          for(var ctrl in [...Parent!._controls, ...Parent!._winControls])
            if(ctrl.Visible && (ctrl.Align==TAlign.Top || ctrl.Align==TAlign.Bottom))
              _maxSize-=ctrl.Height;
          _maxSize+=_control!.Height;
        }
        UpdateSize(X, Y);

        if(ResizeStyle==TResizeStyle.Line || ResizeStyle==TResizeStyle.Pattern)
          DrawLine();
      }
    }
  }

  void UpdateControlSize()
  {
    if(_newSize == _oldSize)
      return;

    switch(Align)
    {
      case TAlign.Left:
        _control!.Width = _newSize;
        break;

      case TAlign.Top:
        _control!.Height = _newSize;
        break;

      case TAlign.Right:
        Parent!.DisableAlign();
        try
        {
          _control!.Left = _control!.Left + (_control!.Width - _newSize);
          _control!.Width = _newSize;
        }
        finally
        {
          Parent!.EnableAlign();
        }
        break;

      case TAlign.Bottom:
        Parent!.DisableAlign();
        try
        {
          _control!.Top = _control!.Top + (_control!.Height - _newSize);
          _control!.Height = _newSize;
        }
        finally
        {
          Parent!.EnableAlign();
        }
        break;

      default:
        break;
    }
    Update();

    _oldSize = _newSize;
  }

  void CalcSplitSize(int X, int Y, Integer NewSize, Integer Split)
  {
    if(Align==TAlign.Left || Align==TAlign.Right)
      Split.Value = X - _downPos.x;
    else
      Split.Value = Y - _downPos.y;
    int S = 0;
    switch(Align)
    {
      case TAlign.Left:   S = _control!.Width + Split.Value; break;
      case TAlign.Right:  S = _control!.Width - Split.Value; break;
      case TAlign.Top:    S = _control!.Height + Split.Value; break;
      case TAlign.Bottom: S = _control!.Height - Split.Value; break;
      default: break;
    }
    NewSize.Value = S;
    if(S < _minSize)
      NewSize.Value = _minSize;
    else
    if(S > _maxSize)
      NewSize.Value = _maxSize;
    if(S != NewSize.Value)
    {
      if(Align==TAlign.Right || Align==TAlign.Bottom)
        S = S - NewSize.Value;
      else
        S = NewSize.Value - S;
      Split.Value+=S;
    }
  }

  void UpdateSize(int X, int Y)
  {
    var ns = Integer(_newSize);
    var s  = Integer(_split);
    CalcSplitSize(X, Y, ns, s);
    _split = s.Value;
    _newSize = ns.Value;
  }

  void MouseMove(TShiftState Shift, int X, int Y)
  {
    super.MouseMove(Shift, X, Y);
    if((Shift.contains(ShiftStates.Left)) && (_control!=null))
    {
      var NewSize = Integer();
      var Split   = Integer();
      CalcSplitSize(X, Y, NewSize, Split);
      if(DoCanSplitResize(NewSize))
      {
        if(ResizeStyle == TResizeStyle.Line || ResizeStyle == TResizeStyle.Pattern)
          DrawLine();
        _newSize = NewSize.Value;
        _split = Split.Value;
        if(ResizeStyle == TResizeStyle.Update)
          UpdateControlSize();
        if(ResizeStyle == TResizeStyle.Line || ResizeStyle == TResizeStyle.Pattern)
          DrawLine();
      }
    }
  }

  void MouseUp(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    super.MouseUp(Button, Shift, X, Y);
    if(_control!=null)
    {
      if(ResizeStyle == TResizeStyle.Line || ResizeStyle == TResizeStyle.Pattern)
        DrawLine();
      UpdateControlSize();
      StopSizing();
    }
  }



  bool _beveled = false;
  bool
    get Beveled => _beveled;
    set Beveled(bool Value)
    {
      _beveled = Value;
      Repaint();
    }

  void StopSizing()
  {
    if(_control!=null)
    {

      _control = null;

    }

  }
}



