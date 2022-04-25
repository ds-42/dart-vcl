part of vcl;

enum TButtonState { Up, Disabled, Down, Exclusive }

class TSpeedButton extends TWinControl 
{

  HGlyphElement _glyph = HGlyphElement(); 

  bool _dragging = false;

  bool _mouseInControl = false;
  bool get MouseInControl => _mouseInControl;
  
  TButtonState _state = TButtonState.Up;

  void _changeState(TButtonState st) 
  {
    if(_state==st)
      return;
    _state = st;
    _updateState();
  }

  void _updateState()
  {
    if(HandleAllocated())
    {
      String name='';
      switch(_state)
      {
      
        case TButtonState.Up: name = HSpeedButton.STATE_UP; break;
        case TButtonState.Disabled: name = 'disabled'; break;
        case TButtonState.Down: name = HSpeedButton.STATE_DOWN; break;
        case TButtonState.Exclusive: name = HSpeedButton.STATE_EXCLUSIVE; break;
      }
      (Handle as HSpeedButton).changeState(name);
    }
  }

  TSpeedButton(TComponent? AOwner) : super(AOwner)
  { 
    Flex.Grow = 0; 
    // _glyph.onChange = (ptr){ Invalidate(); };
    SetBounds(0, 0, 22, 22);
    TNotifyEvent eb;
    ControlStyle.assign( [ControlStyles.CaptureMouse, ControlStyles.DoubleClicks] ); 
  }

  String
    get Caption => _getText(); 
    set Caption(String Value) => _setText(Value); 

  bool CanFocus() => false; 

  void CreateWindowHandle(TCreateParams Params) 
  {
    var btn = HSpeedButton();
    btn.glyph.assign(_glyph);
    _glyph = btn.glyph;
    WindowHandle = btn;
  }

  void DestroyWindowHandle()
  {
    var btn = WindowHandle as HSpeedButton;
    _glyph = HGlyphElement();
    _glyph.assign(btn.glyph);
    super.DestroyWindowHandle();
  }

  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CM_BUTTONPRESSED:
        _cmButtonPressed(Message);
        break;

      case WM_LBUTTONDBLCLK:
        super.Dispatch(Message);
        if(_down)
          DblClick();
        break;

      default:
        super.Dispatch(Message);
        break;
    }
  }

  void UpdateTracking()
  {

  }

  void MouseDown(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    super.MouseDown(Button, Shift, X, Y);

    if(Shift.contains(ShiftStates.Double)) 
      return;

    if((Button == TMouseButton.Left) && Enabled)
    {
      if(!_down)
      {
        _changeState(TButtonState.Down);
        // Invalidate();
      }
      _dragging = true;
    }
  }

  void MouseMove(TShiftState Shift, int X, int Y)
  {
    super.MouseMove(Shift, X, Y);
    if(_dragging)
    {
      var NewState = Down? TButtonState.Exclusive : TButtonState.Up;
      if(ClientRect.accept(X, Y))
        NewState = Down? TButtonState.Exclusive : TButtonState.Down;
      if(NewState != _state)
      {
        _changeState(NewState);
        // Invalidate();
      }
    }
    else
    if(!_mouseInControl)
      UpdateTracking();
  }

  void MouseUp(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    super.MouseUp(Button, Shift, X, Y);
    if(_dragging)
    {
      _dragging = false;
      bool DoClick = ClientRect.accept(X, Y);
      if(GroupIndex == 0)
      {
        // Redraw face in-case mouse is captured
        _changeState(TButtonState.Up);
        _mouseInControl = false;
        // if(DoClick && !(_state==TButtonState.Exclusive || _state==TButtonState.Down))
        //  Invalidate();
      }
      else
      if(DoClick)
      {
        Down = !Down;
        if(Down)
          Repaint();
      }
      else
      {
        if(Down)
          _changeState(TButtonState.Exclusive);
        Repaint();
      }
      if(DoClick)
        Click();
      UpdateTracking();
    }
  }

  void Click()
  {
    super.Click();
  }

  HGlyphElement get Glyph => _glyph;

  set Glyph(HGlyphElement value)
  {
    _glyph.assign(value);
    //Invalidate();
  }

  int
    get NumGlyphs => Glyph.numGlyphs.cx; // NumGlyphs
    set NumGlyphs(int Value)
    {
      if(Value==0) 
      { // auto detect
        Glyph.numGlyphs = SIZE(0, 1);
        return;
      }

      if(Value < 1)
        Value = 1;
      else
      if(Value > 4)
        Value = 4;

      if(Value == Glyph.numGlyphs.cx)
        return;
      Glyph.numGlyphs = SIZE(Value, 1);
//      Invalidate();
    }

  void UpdateExclusive()
  {
    if(_groupIndex != 0 && Parent != null)
    {
      TMessage Msg = TMessage(CM_BUTTONPRESSED);
      Msg.WParam = _groupIndex;
      Msg.LParam = this;
      Msg.Result = 0;
      Parent!.Broadcast(Msg);
    }
  }

  bool _down = false;
  bool
    get Down => _down;
    set Down(bool Value)
    {
      if(_groupIndex == 0)
        Value = false;
      if(Value == _down)
        return;

      if(_down && (!_allowAllUp))
        return;
      _down = Value;
      if(Value)
      {
        // if(_state == TButtonState.Up)
        //   Invalidate();
        _changeState(TButtonState.Exclusive);
      }
      else
      {
        _changeState(TButtonState.Up);
        Repaint();
      }
      if(Value)
        UpdateExclusive();
    }

  bool _flat = false;
  bool
    get Flat => _flat;
    set Flat(bool Value)
    {
      if(Value == Flat)
        return;
      _flat = Value;
      // Invalidate();
    }

  int _groupIndex = 0;
  int
    get GroupIndex => _groupIndex;
    set GroupIndex(int Value)
    {
      if(_groupIndex == Value)
        return;
      _groupIndex = Value;
      UpdateExclusive();
    }

  bool _allowAllUp = false;
  bool
    get AllowAllUp => _allowAllUp;
    set AllowAllUp(bool Value)
    {
      if(_allowAllUp == Value)
        return;
      _allowAllUp = Value;
      UpdateExclusive();
    }

  void _cmButtonPressed(TMessage Message)
  {
    if(Message.WParam == _groupIndex)
    {
      TSpeedButton Sender = Message.LParam;
      if(Sender != this)
      {
        if(Sender.Down && _down)
        {
          _down = false;
          // FState := bsUp;
          _changeState(TButtonState.Up);
          
          // Invalidate();
        }
        _allowAllUp = Sender.AllowAllUp;
      }
    }
  }

}
