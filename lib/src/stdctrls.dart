part of vcl;

enum TCheckBoxState { Unchecked, Checked, Grayed }

enum TComboBoxStyle { DropDown, Simple }

enum TListBoxStyle { Standard, OwnerDrawFixed, OwnerDrawVariable, Virtual, VirtualOwnerDraw }


typedef int TLBFindDataEvent(TWinControl Control, String FindString);





class TCustomGroupBox extends TWinControl
{


  TCustomGroupBox(TComponent? AOwner) : super(AOwner)
  {
    ControlStyle.assign( [ControlStyles.AcceptsControls, ControlStyles.CaptureMouse, ControlStyles.ClickEvents,
      ControlStyles.SetCaption, ControlStyles.DoubleClicks, ControlStyles.Replicatable] );
    Width = 185;
    Height = 105;
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    var group = HGroupBox();

    group.legend.text = _getText();
    WindowHandle = group;
  }

  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      

    }
    super.WndProc(Message);
  }

  TRect GetClientRect() // new
  {
    return TRect(0, 0, Width-5, Height-20); // нужно исправить
  }


}

class TGroupBox extends TCustomGroupBox
{
  TGroupBox(TComponent? AOwner) : super(AOwner)
  {

  }

  String
    get Caption => _getText();
    set Caption(String Value) => _setText(Value);


}

class TCustomLabel extends TWinControl
{


  TCustomLabel(TComponent AOwner) : super(AOwner)
  {
    
    Width = 65;
    Height = 17;
    _autoSize = true;
    
  }

  bool CanFocus()
  {
    return false;
  }

  String get Caption => _getText();
  void set Caption(String Value) => _setText(Value);

  String GetLabelText()
  {
    return Caption;
  }

  void SetAutoSize(bool Value)
  {
    if(WindowHandle != null)
      (WindowHandle as HLabel).autoSize = Value;
    super.SetAutoSize(Value);
  }


  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HLabel();

  }


  void AdjustBounds()
  { 
    if(!ComponentState.contains(ComponentStates.Reading) && AutoSize)
    {
      var size = CalcCaptionSize();
      SetBounds(Left, Top, size.cx, size.cy);

    }
  }

  TRect GetControlExtents()
  {
    if(!AutoSize)
      return super.GetControlExtents();
    TSize size = CalcCaptionSize();
    return TRect(0, 0, size.cx, size.cy);
  }

  
  TSize CalcCaptionSize()
  {
    if(HandleAllocated())
    {
      WindowHandle!.style.width = null;
      WindowHandle!.style.height = null;
      CssRect rect = WindowHandle!.handle.borderEdge;
      return TSize((rect.width+1).truncate(), (rect.height+1).truncate());
    }

    var label = LabelElement();
    label.text = this.Caption;
    label.style
      ..fontFamily = Font.Name
      ..fontSize = '${Font.Size}pt'
      ..fontWeight = '${Font.Weight}'
      ..fontStyle = '${Font.Italic? 'italic' : 'normal'}';
    document.body!.append(label);
    CssRect rect = label.borderEdge;
    var Result = TSize((rect.width+1).truncate(), (rect.height+1).truncate());
    label.remove();
    return Result;
  }


  TAlignment _alignment = TAlignment.LeftJustify;
  TAlignment
    get Alignment => _alignment;
    set Alignment(TAlignment Value)
    {
      if(_alignment == Value)
        return;
      _alignment = Value;

    }



  void _cmTextChanged(TMessage Message)
  {

    AdjustBounds();
  }


}


class TLabel extends TCustomLabel
{

  TLabel(TComponent AOwner) : super(AOwner)
  {

  }

}

class TCustomEdit extends TWinControl
{
  bool _readOnly = false;
  bool
    get ReadOnly => _readOnly;
    set ReadOnly(bool Value)
    {
      if(ReadOnly == Value)
        return;
      _readOnly = Value;
      if(HandleAllocated())
        Windows.SendMessage(Handle, EM_SETREADONLY, Value? 1:0, 0);
    }

  String
    get Text => _getText();
    set Text(String Value) => _setText(Value);



  TCustomEdit(TComponent? AOwner) : super(AOwner)
  {

    Width = SysMetric.InputCx;
    Height = SysMetric.InputCy;
    TabStop = true;
    ParentColor = false;

    Flex.MinWidth = TMetric(100);

    AdjustHeight();
  }



  TBorderStyle _borderStyle = TBorderStyle.Single;
  TBorderStyle
    get BorderStyle => _borderStyle;
    set BorderStyle(TBorderStyle Value)
    {
      if(_borderStyle == Value)
        return;
      _borderStyle = Value;
      UpdateHeight();
      RecreateWnd();
    }



  int _maxLength = 0;
  int
    get MaxLength => _maxLength;
    set MaxLength(int value)
    {
      if(_maxLength == value)
        return;
      _maxLength = value;
      if(HandleAllocated())
        DoSetMaxLength(value);
    }

  void DoSetMaxLength(int value)
  {
    Windows.SendMessage(Handle, EM_LIMITTEXT, value, 0);
  }



  String _passwordChar='';
  String get PasswordChar => _passwordChar;
  void set PasswordChar(String Value)
  {
    if(_passwordChar == Value)
      return;
    _passwordChar = Value;
    IfHandleAllocated((InputElement input)
    {
      input.type = PasswordChar==''? 'text' : 'password';

    });
  }

  int get SelStart => GetSelStart();
  void set SelStart(int Value) => SetSelStart(Value);

  int GetSelStart()
  {

    return IfHandleAllocated((InputElement input) =>
      input.selectionStart ?? 0, 0);
  }

  void SetSelStart(int Value)
  {
    IfHandleAllocated((InputElement input) =>
      input.selectionStart = Value );

  }

  void SetSelectionRange(int start, int length)
  {
    IfHandleAllocated((InputElement input) =>
        input.setSelectionRange(start, start+length) );
  }

  int get SelLength => GetSelLength();
  void set SelLength(int Value) => SetSelLength(Value);

  int GetSelLength()
  {


    return IfHandleAllocated((InputElement input) =>
       (input.selectionEnd??0)-(input.selectionStart??0), 0);
  }

  void SetSelLength(int Value)
  {

  }

  void Clear()
  {
    (Handle.clientHandle as InputElement).value = '';
  }



  void SelectAll()
  {
    IfHandleAllocated((InputElement input) =>
      input.setSelectionRange(0, this.Text.length) );

  }


  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HInput();
    var elem = WindowHandle!.handle as InputElement;

    if(Enabled==false)
      elem.disabled = true;

    if(ReadOnly)
      elem.readOnly=true;
    elem.spellcheck = false;

    if(PasswordChar != '')
      elem.type='password';

    
    WindowHandle!.setColor(Color);

    elem.value = Params.Caption;

    (Handle.clientHandle as InputElement).setMaxLength(MaxLength);
  }

  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {


      case CM_ENABLEDCHANGED:
        IfHandleAllocated((InputElement input) =>
          input.disabled = !Enabled );
        break;

    }

    switch(Message.Msg)
    {
      case EM_LIMITTEXT:
        (Handle.clientHandle as InputElement).setMaxLength(MaxLength);
        return;

      case EM_SETREADONLY:
        IfHandleAllocated((InputElement input) =>
          input.readOnly=toBoolDef(Message.WParam, false) );
        return;
    }
    super.WndProc(Message);

  }



  void UpdateHeight()
  {

  }

  void AdjustHeight()
  {

  }

  void Change()
  {
    super.Changed();
    if(OnChange != null)
      OnChange!(this);
  }



  void _cmColorChanged(TMessage Message) // new
  {
    if(WindowHandle is HInput)
      WindowHandle!.setColor(Color);

    super._cmColorChanged(Message);
  }


  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;

}

class TEdit extends TCustomEdit
{
  
  TEdit(TComponent AOwner) : super(AOwner)
  {
  }

}


class _memoStrings extends TStrings
{
  final Memo;
  _memoStrings(this.Memo) : super();



  int GetCount()
  {
    if(Memo.HandleAllocated())
    {
      int Result = Windows.SendMessage(Memo.Handle, EM_GETLINECOUNT, 0, 0);

      return Result;
    }
    return 0;
  }

  String Get(int Index)
  {
    return Windows.SendMessage(Memo.Handle, EM_GETLINE, Index, null);
  }

  void Put(int Index, String S)
  {
    int SelStart = Windows.SendMessage(Memo.Handle, EM_LINEINDEX, Index, 0);
    int LineLength = Windows.SendMessage(Memo.Handle, EM_LINELENGTH, Index, 0);
    if(SelStart >= 0)
    {
      Windows.SendMessage(Memo.Handle, EM_SETSEL, SelStart, SelStart + LineLength);
      Windows.SendMessage(Memo.Handle, EM_REPLACESEL, 0, S);
    }
  }

  void Insert(int Index, String S)
  {
    if(Index < 0)
      return;
    String Line;
    int SelStart = Windows.SendMessage(Memo.Handle, EM_LINEINDEX, Index, 0);
    if(SelStart >= 0)
      Line = S + '\n';
    else
    {
      int SelStart = Windows.SendMessage(Memo.Handle, EM_LINEINDEX, Index - 1, 0);
      if(SelStart < 0)
        return;
      int LineLen = Windows.SendMessage(Memo.Handle, EM_LINELENGTH, SelStart, 0);
      if(LineLen == 0)
        return;
      SelStart+=LineLen;
      Line = '\n' + S;
    }
    Windows.SendMessage(Memo.Handle, EM_SETSEL, SelStart, SelStart);
    Windows.SendMessage(Memo.Handle, EM_REPLACESEL, 0, Line);
  }

  void Delete(int Index)
  {
    int SelStart = Windows.SendMessage(Memo.Handle, EM_LINEINDEX, Index, 0);
    if(SelStart >= 0)
    {
      int SelEnd = Windows.SendMessage(Memo.Handle, EM_LINEINDEX, Index + 1, 0);
      if(SelEnd < 0)
        SelEnd = SelStart + toIntDef(Windows.SendMessage(Memo.Handle, EM_LINELENGTH, SelStart, 0), 0);
      Windows.SendMessage(Memo.Handle, EM_SETSEL, SelStart, SelEnd);
      Windows.SendMessage(Memo.Handle, EM_REPLACESEL, 0, "");
    }
  }

  void Clear()
  {
    Memo.Clear();
  }



  String GetTextStr()
  {
    return Memo.Text;
  }

  void SetTextStr(String Value)
  {
    Memo.Text = Value;

  }

}

abstract class TCustomMemo extends TCustomEdit
{
  late final TStrings _lines;
  TStrings
    get Lines => _lines;
    set Lines(TStrings Value) => _lines.Assign(Value);


  TCustomMemo(TComponent AOwner) : super(AOwner)
  {
    Width = 185;
    Height = 89;

    _lines = _memoStrings(this);
  }

  void Destroy()
  {
    _lines.Destroy();
    super.Destroy();
   }


  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HTextArea();
    var area = WindowHandle as HTextArea;
    var elem = area.handle as TextAreaElement;
    elem.setMaxLength(MaxLength);
    area.wrap = WordWrap;
    elem.spellcheck = false;
    elem.text = Params.Caption;
    if(ReadOnly)
      elem.readOnly=true;
  }



  TPoint get CaretPos => GetCaretPos();
  void set CaretPos(TPoint Value) => SetCaretPos(Value);

  TPoint GetCaretPos()
  {
    TPoint Result = TPoint();

    return Result;
  }

  void SetCaretPos(TPoint Value)
  {

  }



  bool _wordWrap = true;
  bool
    get WordWrap => _wordWrap;
    set WordWrap(bool Value)
    {
      if(_wordWrap==Value)
        return;
      _wordWrap = Value;

      // RecreateWnd;
      if(HandleAllocated())
        (WindowHandle as HTextArea).wrap = Value;
    }


  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_KEYDOWN:
        if(Message.WParam == Windows.VK_RETURN)
          return;
        break;

    }

    switch(Message.Msg)
    {
      case EM_LIMITTEXT:
        (WindowHandle as TextAreaElement).setMaxLength(MaxLength);
        return;
    }

    super.WndProc(Message);
  }

}

class TMemo extends TCustomMemo
{
  TMemo(TComponent AOwner) : super(AOwner)
  {

  }

}

abstract class TCustomComboBoxStrings extends TStrings
{
  late final TCustomCombo ComboBox;

  dynamic PerformHandle(MESSAGE msg, dynamic wParam, dynamic lParam)
  {
    return ComboBox.PerformHandle(msg, wParam, lParam);
  }

  int GetCount()
  {
    return PerformHandle(CB_GETCOUNT, 0, 0);
  }

  dynamic GetObject(int Index)
  {
    dynamic Result = PerformHandle(CB_GETITEMDATA, Index, 0);
    if(Result == Windows.CB_ERR)
      this.Error(RTLConsts.SListIndexError, Index);
    return Result;
  }

  void PutObject(int Index, dynamic AObject)
  {
    PerformHandle(CB_SETITEMDATA, Index, AObject);
  }

  String Get(int Index)
  {
    String? text = PerformHandle(CB_GETLBTEXT, Index, null);
    return text ?? '';
  }

  void Clear()
  {
    String S = ComboBox.Text;
    PerformHandle(CB_RESETCONTENT, 0, 0);
    ComboBox.Text = S;
    ComboBox.Update();
  }

  void Delete(int Index)
  {
    PerformHandle(CB_DELETESTRING, Index, 0);
  }

  int IndexOf(String S)
  {
    return PerformHandle(CB_FINDSTRINGEXACT, -1, S);
  }

  void SetUpdateState(bool Updating)
  {
    PerformHandle(WM_SETREDRAW, Updating? 0 : 1, 0);
    if(!Updating)
      ComboBox.Refresh();
  }
}

class TComboBoxStrings extends TCustomComboBoxStrings
{

  int Add(String S)
  {
    int? Result = PerformHandle(CB_ADDSTRING, 0, S);
    if(Result == null)
      throw EOutOfResources(Consts.SInsertLineError);
    return Result;
  }

  void Insert(int Index, String S)
  {
    if(PerformHandle(CB_INSERTSTRING, Index, S) == null)
      throw EOutOfResources(Consts.SInsertLineError);
  }
}

abstract class TCustomCombo extends TCustomListControl
{
  String get Text => _getText();
  void set Text(String Value) => _setText(Value);


  int _itemIndex = -1;

  int _saveIndex = -1;

    int GetItemCount();
    int get ItemCount => GetItemCount();

  TCustomCombo(TComponent AOwner) : super(AOwner)
  {

    Width = 145;
    Height = 25;
    TabStop = true;
    ParentColor = false;

  }

  void Destroy()
  {

    super.Destroy();
  }

  dynamic PerformHandle(MESSAGE msg, dynamic wParam, dynamic lParam)
  {
    return Windows.SendMessage(Handle, msg, wParam, lParam);
  }

  void Clear()
  {
    SetTextBuf('');
    _items.Clear();
    _saveIndex = -1;
  }



  void SelectAll()
  {
    Windows.SendMessage(Handle, CB_SETEDITSEL, 0, 0xFFFF0000);
  }



  int GetItemIndex()
  {
    if(ComponentState.contains(ComponentStates.Loading))
      return _itemIndex;
    return PerformHandle(CB_GETCURSEL, 0, 0);
  }

  void SetItemIndex(int Value)
  {
    if(ComponentState.contains(ComponentStates.Loading))
      _itemIndex = Value;
    else
    if(GetItemIndex() != Value)
      PerformHandle(CB_SETCURSEL, Value, 0); // new
  }


  void WndProc(TMessage Message)
  {

    switch(Message.Msg)
    {

      case CN_COMMAND:
        _cnCommand(TWMCommand(Message));
        return;
    }
    super.WndProc(Message);
  }

  void _cnCommand(TWMCommand Message)
  {
    switch(Message.NotifyCode)
    {

      case CBN_SELCHANGE:
        Text = Items.Strings[ItemIndex];
        Click();
        Select();
        break;

    }
  }

  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;

  void Change()
  {
    super.Changed();
    if(_onChange!=null)
      OnChange!(this);
  }



  TNotifyEvent? _onSelect;
  TNotifyEvent?
    get OnSelect => _onSelect;
    set OnSelect(TNotifyEvent? Value) => _onSelect = Value;

  void Select()
  {
    if(OnSelect != null)
      OnSelect!(this);
    else
      Change();
  }


  TStrings _items = TComboBoxStrings();
  TStrings get Items => _items;
  void set Items(TStrings Value) => SetItems(Value);

  void SetItems(TStrings Value)
  {

      _items.Assign(Value);
  }

  void ClearSelection()
  {
    ItemIndex = -1;
  }

  void CopySelection(TCustomListControl Destination)
  {
    if(ItemIndex != -1)
      Destination.AddItem(Items.Strings[ItemIndex], Items.Objects[ItemIndex]);
  }



  int GetCount()
  {
    return GetItemCount();
  }



  void AddItem(String Item, dynamic AObject)
  {
    Items.AddObject(Item, AObject);
  }

  String get ItemString 
  {
    int ndx = ItemIndex;
    if(ndx>=0)
      return Items.Strings[ndx];
    return "";
  }

  dynamic get ItemObject 
  {
    int ndx = ItemIndex;
    if(ndx>=0)
      return Items.Objects[ndx];
    return null;
  }

  set ItemObject(dynamic val) 
  {
    ItemIndex = Items.IndexOfObject(val);
  }
}

class TCustomComboBox extends TCustomCombo
{


  TCustomComboBox(TComponent AOwner) : super(AOwner)
  {
    (_items as TComboBoxStrings).ComboBox = this;
    Height = 21;

  }



  TComboBoxStyle _style = TComboBoxStyle.DropDown;
  TComboBoxStyle get Style => _style;
  void set Style(TComboBoxStyle Value)
  {
    if(_style == Value)
      return;
    _style = Value;


    RecreateWnd();
  }



  HComboBox? _combo;
  void CreateWindowHandle(TCreateParams Params)
  {
    if(_combo == null)
      _combo = HComboBox();


    WindowHandle = _combo;

    WindowHandle!.setColor(Color);
    switch(Style)
    {
      case TComboBoxStyle.DropDown:
        break;

      case TComboBoxStyle.Simple:
        _combo!.input.style.width = 'calc(100% - 2px)';
        break;

      default:
        break;
    }

    _combo!.input.value = Params.Caption;
    _combo!.input.select(); //setSelectionRange(0, _combo!.input.value!.length);

    _combo!.Enabled = Enabled;


  }



  dynamic PerformHandle(MESSAGE msg, dynamic wParam, dynamic lParam)
  {
    if(_combo == null)
      _combo = HComboBox();

    var res = Windows.SendMessage(_combo!, msg, wParam, lParam);

    switch(msg)
    {
      case CB_SETCURSEL:
        if(!HandleAllocated())
        { // Component not ready. Emulate OnSelect
          this.Text = _combo!.input.value ?? '';
          Click();
          Select();
        }
        break;
    }

    return res;
  }

  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CM_ENABLEDCHANGED:
        if(_combo!=null)
          _combo!.Enabled = Enabled;
        break;

    }
    super.WndProc(Message);
  }

  int GetItemCount()
  {
    return _items.Count;
  }



}

class TComboBox extends TCustomComboBox
{
  TComboBox(TComponent AOwner) : super(AOwner)
  {

  }


}

/// TButtonActionLinkClass = class of TButtonActionLink;

class TButtonActionLink extends TWinControlActionLink
{


  static TClass get classType => TClass( TButtonActionLink, (AOwner) => TButtonActionLink(AOwner) );

  TButtonActionLink(TComponent AOwner) : super(AOwner);


}

class TButtonControl extends TWinControl
{
  bool _clicksDisabled = false;
  bool get ClicksDisabled => _clicksDisabled;
  void set ClicksDisabled(bool Value) => _clicksDisabled=Value;

  TButtonControl(TComponent AOwner) : super(AOwner)
  {
    Width = 75;
    Height = SysMetric.InputCy;
    
  }

  void ActionChange(TObject Sender, bool CheckDefaults)
  {
    super.ActionChange(Sender, CheckDefaults);
    if(Sender is TCustomAction)
    {
      if(!CheckDefaults || (Checked == false))
        Checked = Sender.Checked;
    }
  }

  TMetaClass GetActionLinkClass()
  {
    return TButtonActionLink.classType;
  }

  bool get Checked => GetChecked();
  void set Checked(bool Value) => SetChecked(Value);

  bool GetChecked()
  {
    return false;
  }


  void SetChecked(bool Value)
  {
  }

  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CM_GETVALUE:
        Message.Result = Checked;
        return;

      case CM_SETVALUE:
        bool? val = tryToBool(Message.LParam);
        if(val!=null)
          Checked = val;
        return;

      case WM_LBUTTONDOWN:
      case WM_LBUTTONDBLCLK:
        if(!ComponentState.contains(ComponentStates.Designing) && !Focused())
        {
          _clicksDisabled = true;
          Windows.SetFocus(Handle);
          _clicksDisabled = false;
          if(!Focused())
            return;
        }
        break;

      case CN_COMMAND:
        if(_clicksDisabled)
          return;
        break;
    }
    super.WndProc(Message);
  }
}

class TButton extends TButtonControl
{
  TModalResult _modalResult = TModalResult.None;
  TModalResult get ModalResult => _modalResult;
  void set ModalResult(TModalResult Value) => _modalResult = Value;



  TButton(TComponent AOwner) : super(AOwner)
  {

    Flex.Justify = TFlexJustify.Left;
    TabStop = true;
  }

  String get Caption => _getText();
  void set Caption(String Value) => _setText(Value);

  void CreateParams(TCreateParams Params)
  {
    super.CreateParams(Params);
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HButton();
    WindowHandle!.handle.text = Params.Caption;

    if(Enabled==false)
      (WindowHandle!.handle as ButtonElement).disabled = true;
  }

  void Click()
  {
    TCustomForm? Form = ParentForm;
    if (Form != null)
      Form.ModalResult = ModalResult;
    super.Click();
  }

  void KeyDown(TKeyCode Key, TShiftState Shift)
  {
    if(Key.Code==Windows.VK_RETURN || Key.Code==Windows.VK_SPACE)
    {
      Click();
      return;
    }
    super.KeyDown(Key, Shift);
  }

}



class TCustomCheckBox extends TButtonControl
{

  TCheckBoxState _state = TCheckBoxState.Unchecked;
  TCheckBoxState get State
  {
    if(HandleAllocated())
      _state = Windows.SendMessage(Handle, BM_GETCHECK, null, null); // new
    return _state;
  }
  void set State(TCheckBoxState Value)
  {
    if(_state == Value)
      return;
    _state = Value;
    if(HandleAllocated())
      Windows.SendMessage(Handle, BM_SETCHECK, _state, null);
    if(!ClicksDisabled)
      Click();
  }


  TCustomCheckBox(TComponent AOwner) : super(AOwner)
  {
    Width = 97;
    Height = 17;
    TabStop = true;
    ControlStyle.assign( [ControlStyles.SetCaption, ControlStyles.DoubleClicks] );

  }


  bool _allowGrayed = false;
  bool
    get AllowGrayed => _allowGrayed;
    set AllowGrayed(bool value) => _allowGrayed = value;

  void Toggle()
  {
    switch(State)
    {
      case TCheckBoxState.Unchecked:
        State = AllowGrayed? TCheckBoxState.Grayed : TCheckBoxState.Checked;
        break;
      case TCheckBoxState.Checked:
        State = TCheckBoxState.Unchecked;
        break;
      case TCheckBoxState.Grayed:
        State = TCheckBoxState.Checked;
        break;
    }
  }

  void Click()
  {
    super.Changed();
    super.Click();
  }

  bool GetChecked()
  {
    return State == TCheckBoxState.Checked;
  }



  void SetChecked(bool Value)
  {
     State = Value? TCheckBoxState.Checked : TCheckBoxState.Unchecked;
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    HCheckBox cb = HCheckBox();
    cb.caption.text = Params.Caption;
    cb.check.checked = _state == TCheckBoxState.Checked;
    if(Enabled==false)
    {
      cb.handle.setAttribute('disabled', '');

    }
    WindowHandle = cb;

  }

  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CM_ENABLEDCHANGED:
        if(HandleAllocated())
        {
          if(Enabled)
            Handle.handle.removeAttribute('disabled');
          else
            Handle.handle.setAttribute('disabled','');
        }
        break;
    }

    super.WndProc(Message);
  }



  void _cnCommand(TWMCommand Message)
  {
    if(Message.NotifyCode == Windows.BN_CLICKED)
      Toggle();
  }

}

class TCheckBox extends TCustomCheckBox
{
  TCheckBox(TComponent AOwner) : super(AOwner)
  {

  }

  String get Caption => _getText();
  void set Caption(String Value) => _setText(Value);


}


class TRadioButton extends TButtonControl
{


  TRadioButton(TComponent AOwner) : super(AOwner)
  {
    Width = 113;
    Height = 17;
    ControlStyle.assign( [ControlStyles.SetCaption, ControlStyles.DoubleClicks] );

  }

  String get Caption => _getText();
  void set Caption(String Value) => _setText(Value);



  bool _checked = false;
  bool GetChecked() => _checked;

  void SetChecked(bool Value)
  {
    void TurnSiblingsOff()
    {
      if(Parent == null)
        return;
      for(var Sibling in Parent!.Controls)
      {
        if((Sibling != this) && (Sibling is TRadioButton))
        {
            if((Sibling.Action!=null) &&
               (Sibling.Action is TCustomAction) &&
               (Sibling.Action as TCustomAction).AutoCheck)
              (Sibling.Action as TCustomAction).Checked = false;
          Sibling.SetChecked(false);
        }
      }
    }

    if(_checked == Value)
      return;
    _checked = Value;
    TabStop = Value;
    if(HandleAllocated())
      Windows.SendMessage(Handle, BM_SETCHECK, Checked? 1 : 0, 0);
    if(Value)
    {
      TurnSiblingsOff();
      super.Changed();
      if(!ClicksDisabled)
        Click();
    }
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    var rb = HRadioButton();
    rb.caption.text = Params.Caption;
    rb.radio.checked = _checked;
    WindowHandle = rb;
//    rb.handle.onClick.listen((event) => Checked=true ); // временно пока не пойму как работает переключение
  }



  void _cnCommand(TWMCommand Message)
  {
    switch(Message.NotifyCode)
    {
      case Windows.BN_CLICKED:
        SetChecked(true);
        break;
      case Windows.BN_DOUBLECLICKED:
        DblClick();
        break;
    }
  }

}

class TListBoxStrings extends TStrings
{
  TCustomListBox? _listBox;
  TCustomListBox get ListBox => _listBox!;

  int GetCount()
  {
    if(!ListBox.HandleAllocated()) // new
      return 0;
    return Windows.SendMessage(ListBox.Handle, LB_GETCOUNT, 0, 0);
  }

  String Get(int Index)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style))
      return ListBox.DoGetData(Index);
    else
    {
      int? Len = Windows.SendMessage(ListBox.Handle, LB_GETTEXTLEN, Index, 0);
      if(Len == null)
        this.Error(RTLConsts.SListIndexError, Index);
      if(Len == 0)
        return '';
      return Windows.SendMessage(ListBox.Handle, LB_GETTEXT, Index, null);
    }
  }

  TObject? GetObject(int Index)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style))
      return ListBox.DoGetDataObject(Index);
    else
    {
      TObject? Result = ListBox.GetItemData(Index);
      if(Result == null)
        this.Error(RTLConsts.SListIndexError, Index);
      return Result;
    }
  }

  void Put(int Index, String S)
  {
    int I = ListBox.ItemIndex;
    dynamic TempData = ListBox.InternalGetItemData(Index);
    // Set the Item to 0 in case it is an object that gets freed during Delete
    ListBox.InternalSetItemData(Index, null);
    Delete(Index);
    InsertObject(Index, S, null);
    ListBox.InternalSetItemData(Index, TempData);
    ListBox.ItemIndex = I;
  }

  void PutObject(int Index, dynamic AObject)
  {
    if((Index != -1) && !( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style)))
      ListBox.SetItemData(Index, AObject);
  }

  int Add(String S)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style))
      return - 1;
    int? Result = Windows.SendMessage(ListBox.Handle, LB_ADDSTRING, 0, S);
    if(Result == null)
      throw EOutOfResources(Consts.SInsertLineError);
    return Result;
  }

  void Insert(int Index, String S)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style))
      return;
    if(Windows.SendMessage(ListBox.Handle, LB_INSERTSTRING, Index, S) == null)
      throw EOutOfResources(Consts.SInsertLineError);
  }

  void Delete(int Index)
  {
    ListBox.DeleteString(Index);
  }

  void Exchange(int Index1, int Index2)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style))
      return;
    BeginUpdate();
    try
    {
      String TempString = Strings[Index1];
      TObject? TempData = ListBox.InternalGetItemData(Index1);
      Strings[Index1] = Strings[Index2];
      ListBox.InternalSetItemData(Index1, ListBox.InternalGetItemData(Index2));
      Strings[Index2] = TempString;
      ListBox.InternalSetItemData(Index2, TempData);
      if(ListBox.ItemIndex == Index1)
        ListBox.ItemIndex = Index2;
      else
      if(ListBox.ItemIndex == Index2)
        ListBox.ItemIndex = Index1;
    }
    finally
    {
      EndUpdate();
    }
  }

  void Clear()
  {
    ListBox.ResetContent();
  }

  void SetUpdateState(bool Updating)
  {
    Windows.SendMessage(ListBox.Handle, WM_SETREDRAW, Updating? 0 : 1, 0);
    if(!Updating)
      ListBox.Refresh();
  }

  int IndexOf(String S)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style))
      return ListBox.DoFindData(S);
    else
      return Windows.SendMessage(ListBox.Handle, LB_FINDSTRINGEXACT, -1, S);
  }

  void Move(int CurIndex, int NewIndex)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(ListBox.Style))
      return;
    BeginUpdate();
    ListBox._moving = true;
    try
    {
      if(CurIndex != NewIndex)
      {
        String TempString = Get(CurIndex);
        TObject? TempData = ListBox.InternalGetItemData(CurIndex);
        ListBox.InternalSetItemData(CurIndex, null);
        Delete(CurIndex);
        Insert(NewIndex, TempString);
        ListBox.InternalSetItemData(NewIndex, TempData);
      }
    }
    finally
    {
      ListBox._moving = false;
      EndUpdate();
    }
  }

}

class TCustomListBox extends TCustomMultiSelectListControl
{

  late final TStrings _items;
  TStrings
    get Items => _items;
    set Items(TStrings Value)
    {
      if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(Style))
      {
        switch(Style)
        {
          case TListBoxStyle.Virtual:
            Style = TListBoxStyle.Standard;
            break;
          case TListBoxStyle.VirtualOwnerDraw:
            Style = TListBoxStyle.OwnerDrawFixed;
            break;
          default:
            break;
        }
      }
      Items.Assign(Value);
    }


  TListBoxStyle _style = TListBoxStyle.Standard;
  TListBoxStyle get Style => _style;
  void set Style(TListBoxStyle Value)
  {
    if(_style == Value)
      return;
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(Value) )
    {
      Items.Clear();
      Sorted = false;
    }
    _style = Value;
    RecreateWnd();
  }


  bool _sorted = false;
  bool get Sorted => _sorted;
  void set Sorted(bool Value)
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(Style))
      return;
    if(_sorted == Value)
      return;
    _sorted = Value;
    RecreateWnd();
  }

  TLBFindDataEvent? _onDataFind;
  TLBFindDataEvent?
    get OnDataFind => _onDataFind;
    set OnDataFind(TLBFindDataEvent? Value) => _onDataFind = Value;

    bool _moving = false;


  late final TItems<bool> Selected;

    

  TCustomListBox(TComponent AOwner) : super(AOwner)
  {
    
    Selected = TItems<bool>(
        (int Index)
        {
          int? R = Windows.SendMessage(Handle, LB_GETSEL, Index, 0);
          if(R == null)
              throw EListError.CreateResFmt(RTLConsts.SListIndexError, [Index]);
          return R != 0;
        },
        () => throw UnimplementedError(),
        (int Index, bool Value)
        {
          if(_multiSelect)
          {
            if(Windows.SendMessage(Handle, LB_SETSEL, Value, Index) == null)
              throw EListError.CreateResFmt(RTLConsts.SListIndexError, [Index]);
          }
          else
          if(Value)
          {
            if(Windows.SendMessage(Handle, LB_SETCURSEL, Index, 0) == null)
              throw EListError.CreateResFmt(RTLConsts.SListIndexError, [Index]);
          }
          else
            Windows.SendMessage(Handle, LB_SETCURSEL, -1, 0);
        }
    );

    Width = 121;
    Height = 97;
    TabStop = true;

    _items = TListBoxStrings();
    (_items as TListBoxStrings)._listBox = this;

  }



  void AddItem(String Item, TObject AObject)
  {
    Items.AddObject(Item, AObject);
  }

  TObject? GetItemData(int Index)
  {
    return Windows.SendMessage(Handle, LB_GETITEMDATA, Index, 0);
  }

  void SetItemData(int Index, dynamic AData)
  {
    Windows.SendMessage(Handle, LB_SETITEMDATA, Index, AData);
  }

  TObject? InternalGetItemData(int Index)
  {
    return GetItemData(Index);
  }

  void InternalSetItemData(int Index, dynamic AData)
  {
    SetItemData(Index, AData);
  }

  void DeleteString(int Index)
  {
    Windows.SendMessage(Handle, LB_DELETESTRING, Index, 0);
  }

  void ResetContent()
  {
    if( [TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(Style))
      return;
    Windows.SendMessage(Handle, LB_RESETCONTENT, 0, 0);
  }

  void Clear()
  {
    _items.Clear();
  }

  void ClearSelection()
  {
    if(MultiSelect)
      for(int i = 0; i < Items.Count; i++)
        Selected[i] = false;
    else
      ItemIndex = -1;
  }

  void CopySelection(TCustomListControl Destination)
  {
    if(MultiSelect)
    {
      for(int i = 0; i < Items.Count; i++)
        if(Selected[i])
          Destination.AddItem(Items.Strings[i], Items.Objects[i]);
    }
    else
    if(ItemIndex != -1)
      Destination.AddItem(Items.Strings[ItemIndex], Items.Objects[ItemIndex]);
  }



  int GetItemIndex()
  {
    if(MultiSelect)
      return Windows.SendMessage(Handle, LB_GETCARETINDEX, 0, 0);
    return Windows.SendMessage(Handle, LB_GETCURSEL, 0, 0);
  }

  int _count = 0;
  int get Count => GetCount(); 

  int GetCount()
  {
    if([TListBoxStyle.Virtual, TListBoxStyle.VirtualOwnerDraw].contains(Style))
      return _count;
    return Items.Count;
  }

  int GetSelCount()
  {
    return Windows.SendMessage(Handle, LB_GETSELCOUNT, 0, 0);
  }

  void SetItemIndex(int Value)
  {
    if(GetItemIndex() != Value)
      if(MultiSelect)
        Windows.SendMessage(Handle, LB_SETCARETINDEX, Value, 0);
      else
        Windows.SendMessage(Handle, LB_SETCURSEL, Value, 0);
  }



  void SetMultiSelect(bool Value)
  {
    if(_multiSelect == Value)
      return;
    _multiSelect = Value;
    RecreateWnd();
  }



  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HSelect();
    (WindowHandle!.handle as SelectElement).size = 4;
  }


  void SelectAll()
  {
    if(_multiSelect)
      for(int i = 0; i < Items.Count; i++)
        Selected[i] = true;
  }



  String DoGetData(int Index)
  {

    return '';
  }

  TObject? DoGetDataObject(int Index)
  {

    return null;
  }

  int DoFindData(String Data)
  {
    if(_onDataFind != null)
      return _onDataFind!(this, Data);
    return -1;
  }



}

class TListBox extends TCustomListBox
{
  TListBox(TComponent AOwner) : super(AOwner)
  {

  }

}


class TScrollBar extends TWinControl
{
  HScrollBar? _scrollBar;

  TScrollBar(TComponent AOwner) : super(AOwner)
  {
    Width = 121;
    Height = GetSystemMetrics(Windows.SM_CYHSCROLL);
    TabStop = true;
    ControlStyle.assign( [ControlStyles.Framed, ControlStyles.DoubleClicks, ControlStyles.Opaque] );

  }

  TScrollBarKind _kind = TScrollBarKind.Horizontal;
  TScrollBarKind get Kind => _kind;
  void set Kind(TScrollBarKind Value)
  {
    if(_kind == Value)
      return;
    _kind = Value;

    // new
    if(Value == TScrollBarKind.Horizontal)
      SetBounds(Left, Top, Height, GetSystemMetrics(Windows.SM_CYHSCROLL));
    else
      SetBounds(Left, Top, GetSystemMetrics(Windows.SM_CXVSCROLL), Width);

    if(HandleAllocated())
      _scrollBar!.kind=Kind;

  }

  int _position = 0;
  int
    get Position => _position;
    set Position(int Value) => SetParams(Value, _min, _max);

  int _min = 0;
  int
    get Min => _min;
    set Min(int Value) => SetParams(_position, Value, _max);

  int _max = 100;
  int
    get Max => _max;
    set Max(int Value) => SetParams(_position, _min, Value);
  

  int _pageSize = 0;
  int
    get PageSize => _pageSize;
    set PageSize(int value)
    {
      if(_pageSize == value || value > _max)
        return;
      _pageSize = value;
      
      if(HandleAllocated())
        _scrollBar!.page = _pageSize;
    }

  int _RTLFactor = 1;

  int _smallChange = 1;
  int
    get SmallChange => _smallChange;
    set SmallChange(int Value) => _smallChange=Value;

  int _largeChange = 1;
  int
    get LargeChange => _largeChange;
    set LargeChange(int Value) => _largeChange=Value;

  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;


  void CreateWindowHandle(TCreateParams Params)
  {
    _scrollBar = HScrollBar();
    _scrollBar!.kind = Kind;
    WindowHandle = _scrollBar;
  }

  void CreateWnd()
  {
    super.CreateWnd();
    _scrollBar!.update(Position, Min, Max, PageSize, Enabled);
  }


  bool NotRightToLeft()
  {
    return !IsRightToLeft() || _kind == TScrollBarKind.Vertical;
  }


  void SetParams(int APosition, int AMin, int AMax)
  {
    if(AMax < AMin || AMax < _pageSize)
      throw EInvalidOperation(Consts.SScrollBarRange);
    if(APosition < AMin)
      APosition = AMin;
    if(APosition > AMax)
      APosition = AMax;
    if(_min != AMin || _max != AMax)
    {
      _min = AMin;
      _max = AMax;

    }
    if(_position != APosition)
    {
      _position = APosition;
      if(HandleAllocated())
        _scrollBar!.pos=_position;

      Enabled = true;
      Change();
    }
  }

  void Change()
  {
    super.Changed();
    if(_onChange != null)
      _onChange!(this);
  }

  void Scroll(int ScrollCode, int ScrollPos)
  {

  }

  void DoScroll(TMessage Message)
  {

    SCROLLINFO ScrollInfo = Message.WParam;
    int NewPos = _position;
    switch(ScrollInfo.ScrollCode)
    {
      case Windows.SB_LINEUP:   NewPos-=_smallChange * _RTLFactor; break;
      case Windows.SB_LINEDOWN: NewPos+=_smallChange * _RTLFactor; break;
      case Windows.SB_PAGEUP:   NewPos-=_largeChange * _RTLFactor; break;
      case Windows.SB_PAGEDOWN: NewPos+=_largeChange * _RTLFactor; break;
      case Windows.SB_THUMBPOSITION:
      case Windows.SB_THUMBTRACK:
        
          NewPos = _scrollBar!.pos;
          // We need to reverse the positioning because SetPosition below
          //  calls SetParams that reverses the position. This acts as a
          //  double negative.
          if(!NotRightToLeft())
            NewPos = _max - NewPos;
        break;
      case Windows.SB_TOP:    NewPos = _min; break;
      case Windows.SB_BOTTOM: NewPos = _max; break;
    }
    if(NewPos < _min)
      NewPos = _min;
    if(NewPos > _max)
      NewPos = _max;
    int ScrollPos = NewPos;
    Scroll(ScrollInfo.ScrollCode, ScrollPos);
    Position=ScrollPos;
  }

  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CN_HSCROLL:
      case CN_VSCROLL:
        DoScroll(Message);
        break;
      case WM_WINDOWPOSCHANGED:
        super.Dispatch(Message);
        if(_scrollBar!=null);
          _scrollBar!._refresh(defSize: _kind==TScrollBarKind.Vertical? Height : Width);
        break;
      default:
        super.Dispatch(Message);
        break;
    }
  }


}
