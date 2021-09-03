part of vcl;


enum TButtonState { Up, Disabled, Down, Exclusive }


class TSpeedButton  extends TWinControl
{
  TButtonState _state = TButtonState.Up;

  final HGlyph _glyph = HGlyph();

  String get ImageUrl => _glyph.ImageUrl;
  void set ImageUrl(String Value) => _glyph.ImageUrl = Value;

  bool _dragging = false;

  bool _mouseInControl = false;
  bool get MouseInControl => _mouseInControl;



  TSpeedButton(TComponent AOwner) : super(AOwner)
  {
    ControlStyle>>ControlStyles.ClickEvents; // new /** клики выполняются самим обыектом */
    Flex.Grow = 0;

    SetSize(22, 22);

  }



  String get Caption => _getText();
  void set Caption(String Value) => _setText(Value);

  bool CanFocus()
  {
    return false;
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HSpeedButton();
    var button = WindowHandle!.handle as ButtonElement;
    button.tabIndex = -1;

    _glyph.setParent(WindowHandle);
    _glyph.owner = WindowHandle;

    if(Enabled == false)
      button.disabled = true;


    if(Params.Caption.isNotEmpty)
      WindowHandle!.handle.text = Params.Caption;

  }

  void CreateWnd()
  {
    super.CreateWnd();
    _glyph.handle.owner = Handle;
    _updateStateName();
  }

  void DestroyWindowHandle()
  {
    _glyph.handle.remove();
    super.DestroyWindowHandle();
  }




  void UpdateGlyph(int index, [int? width=null, int? height=null]) // new
  {
    _glyph.Update(index, width, height);
    UpdateGlyphPosition();
  }

  void UpdateGlyphPosition() // new
  {
    bool down = _state==TButtonState.Down || _state==TButtonState.Exclusive;
    _glyph.style.left = "${ ((Width-_glyph.Width-2) ~/ 2)+(down? 1 : 0) }px";
    _glyph.style.top  = "${ ((Height-_glyph.Height-2) ~/2)+(down? 1 : 0) }px";
  }

  void SetBounds(int? ALeft, int? ATop, int? AWidth, int? AHeight) // new
  {
    super.SetBounds(ALeft, ATop, AWidth, AHeight);
    UpdateGlyphPosition();
  }

  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CM_ENABLEDCHANGED:
        UpdateGlyph(Enabled? 0 : 1);
        if(HandleAllocated())
          (Handle.handle as ButtonElement).disabled = !Enabled;
        
        break;

      case CM_BUTTONPRESSED:
        _cmButtonPressed(Message);
        break;


      default:
        super.Dispatch(Message);
        break;
    }
  }


  void UpdateTracking()
  {

  }



  void _updateState(TButtonState st)
  {
    if(_state==st)
      return;
    _state = st;
    _updateStateName();
  }

  void _updateStateName()
  {
    if(HandleAllocated())
    {
      String name='';
      switch(_state)
      {

        case TButtonState.Up: name = 'up'; break;
        case TButtonState.Disabled: name = 'disabled'; break;
        case TButtonState.Down: name = 'down'; break;
        case TButtonState.Exclusive: name = 'exclusive'; break;
      }
      if(name.isEmpty)
        Handle.handle.removeAttribute('state');
      else
        Handle.handle.setAttribute('state', name); //classes.add('test');
    }
    UpdateGlyphPosition();
  }

  void MouseDown(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    super.MouseDown(Button, Shift, X, Y);
    if((Button == TMouseButton.Left) && Enabled)
    {
      if(!_down)
      {
        _updateState(TButtonState.Down);
        Invalidate();
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
        _updateState(NewState);
        Invalidate();
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
        _updateState(TButtonState.Up);
        _mouseInControl = false;
        if(DoClick && !(_state==TButtonState.Exclusive || _state==TButtonState.Down))
          Invalidate();
      }
      else
      if(DoClick)
      {
        Down = !Down;
        if(Down)
          Invalidate(); // Repaint
      }
      else
      {
        if(Down)
          _updateState(TButtonState.Exclusive);
        Invalidate(); // Repaint;
      }
      if(DoClick)  // new
        Click();
      UpdateTracking();
    }
  }

  void Click()
  {
    super.Click();
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
        if(_state == TButtonState.Up)
          Invalidate();
        _updateState(TButtonState.Exclusive);
      }
      else
      {
        _updateState(TButtonState.Up);
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
      Invalidate();
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
          _updateState(TButtonState.Up);

          Invalidate();
        }
        _allowAllUp = Sender.AllowAllUp;
      }
    }
  }


}
