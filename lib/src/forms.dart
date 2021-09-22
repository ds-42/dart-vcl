part of vcl;

enum TScrollBarKind { Horizontal, Vertical }
  
enum TFormBorderStyle { None, Sizeable, Dialog, }

enum TBorderStyle { None, Single }


TClass HintWindowClass = THintWindow.classType;


bool _focusMessages=true;
bool get FocusMessages=> _focusMessages=true;

int _focusCount = 0;
int get FocusCount => _focusCount;

const DefHintColor = clInfoBk;  // default hint window color
const DefHintPause = 500;       //  default pause before hint window displays (ms)
const DefHintShortPause = 0;    // default reshow pause to 0, was DefHintPause div 10
const DefHintHidePause = DefHintPause * 5;



HWND? FindTopMostWindow(HWND ActiveWindow)
{
  HWND TaskActiveWindow = ActiveWindow;
  HWND? TaskFirstWindow;
  HWND? TaskFirstTopMost;

  bool DoFindWindow(HWND hWnd, dynamic Param)
  {
    if((hWnd != TaskActiveWindow) && (hWnd != Application._handle) &&
      Windows.IsWindowVisible(hWnd) && Windows.IsWindowEnabled(hWnd))
    {
      if(TaskFirstWindow == null)
        TaskFirstWindow = hWnd;

    }
    return true;
  }

  Windows.EnumThreadWindows(/*GetCurrentThreadID*/null, DoFindWindow, null);
  if(TaskFirstWindow != null)
    return TaskFirstWindow;
  else
    return TaskFirstTopMost;
}

bool SendFocusMessage(HWND hWnd, MESSAGE Msg)
{
  int Count = FocusCount;
  Windows.SendMessage(hWnd, Msg, null, null);
  return FocusCount == Count;
}




// Form utility functions

TCustomForm? GetParentForm(TControl? Control)
{
  if(Control == null || Control is TCustomForm)
     return Control as TCustomForm;

  if(Control.Parent != null)
  {
    while(Control!.Parent != null)
      Control = Control.Parent;
    if(Control is TCustomForm)
      return Control;
  }
  return null;
}

TCustomForm ValidParentForm(TControl Control)
{
  TCustomForm? Result = GetParentForm(Control);
  if(Result == null)
    throw EInvalidOperation.CreateFmt(Consts.SParentRequired, [Control.Name]);
  return Result;
}



enum TWindowState { Normal, Minimized, Maximized }

class TScrollingWinControl extends TWinControl
{

  bool _autoScroll = true;
  bool
    get AutoScrool => _autoScroll;
    set AutoScroll(bool Value)
    {
      if(_autoScroll != Value)
      {
        _autoScroll = Value;
        if(Value)
        {
          CalcAutoRange();
        }
        else
        {
  
        }
      }
    }
    
  TScrollingWinControl(TComponent? AOwner) : super(AOwner)
  {

  }


  void CreateParams(TCreateParams Params)
  {
    super.CreateParams(Params);

  }

  void CreateWnd()
  {
    super.CreateWnd();
    Windows.SetActiveWindow(Handle); // new
    
  }

  void AlignControls(TControl? AControl, TRect ARect)
  {
    CalcAutoRange();
    super.AlignControls(AControl, ARect);
  }



  int _autoRangeCount = 0;

  void CalcAutoRange()
  {
    if(_autoRangeCount <= 0)
    {

    }
  }



  bool _updatingScrollBars = false;
  void UpdateScrollBars()
  {
    if(_updatingScrollBars==false && HandleAllocated())
      try
      {
        _updatingScrollBars = true;

      }
      finally
      {
        _updatingScrollBars = false;
      }
  }

  void AutoScrollInView(TControl AControl)
  {
    if(!AControl.ComponentState.contains(ComponentStates.Loading) &&
      !ComponentState.contains(ComponentStates.Loading))
      ScrollInView(AControl);
  }

  void DisableAutoRange()
  {
    _autoRangeCount++;
  }

  void EnableAutoRange()
  {
    if(_autoRangeCount <= 0)
      return;
    _autoRangeCount--;

  }

  void ScrollInView(TControl AControl)
  {

  }



  void Resizing(TWindowState State)
  {
    // Overridden by TCustomFrame
  }

  void _wmSize(TWMSize Message)
  {
    _autoRangeCount++;
    try
    {
      super._wmSize(Message);
      TWindowState NewState = TWindowState.Normal;

      Resizing(NewState);
    }
    finally
    {
      _autoRangeCount--;
    }
    _updatingScrollBars = true;
    try
    {
      CalcAutoRange();
    }
    finally
    {
      _updatingScrollBars = false;
    }

  }



  void AdjustClientRect(TRect Rect)
  {

    super.AdjustClientRect(Rect);
  }


}


enum TFormStyle { Normal, MDIChild, MDIForm, StayOnTop }


enum TPosition { Designed, Default, DefaultSizeOnly,
                 ScreenCenter, DesktopCenter, MainFormCenter, OwnerFormCenter }

enum TCloseAction {None, Hide, Free, Minimize}
typedef Future<void> TCloseEvent(TObject Sender, TPointer<TCloseAction> Action);

enum FormStates { Creating, Visible, Showing, Modal, CreatedMDIChild, Activated }

typedef TFormState = Set<FormStates>;



class HCustomForm extends HForm
{
  Completer<TModalResult>? _modal;

  TCustomForm Owner;
  HCustomForm(this.Owner) : super();

  Future<TModalResult> ShowModal() async
  {
    if(_modal != null)
      throw UnsupportedError('Form is modal');

    _modal = Completer<TModalResult>();
    return _modal!.future;
  }

  void Close()
  {

      Owner.Close();

  }

  void set ModalResult(TModalResult value)
  {
    if(_modal == null)
      return;
    CloseModal(value);
  }


  void CloseModal(TModalResult Value) async
  {
    try
    {
      var CloseAction = TPointer(TCloseAction.None);
      if(await Owner.CloseQuery())
      {
        CloseAction.Value = TCloseAction.Hide;
        await Owner.DoClose(CloseAction);
      }

      if(CloseAction.Value == TCloseAction.None)
        Owner._modalResult = TModalResult.None;
      else
      {
        Owner._modalResult = Value;
        _modal!.complete(Value);
        _modal = null;

        if(CloseAction.Value == TCloseAction.Free)
          Owner.Destroy();
      }
    }
    catch(E)
    {
      Owner._modalResult = TModalResult.None;
      Application.HandleException(Owner);
    }
  }

}

class TCustomForm extends TScrollingWinControl
{
  HForm? _form;

  static List ShowCommands = [Windows.SW_SHOWNORMAL, Windows.SW_SHOWMINNOACTIVE, Windows.SW_SHOWMAXIMIZED];

  TWinControl? _activeControl;
  TWinControl?
    get ActiveControl => _activeControl;
    set ActiveControl(TWinControl? Control)
    {
      if(_activeControl == Control)
        return;

      if(!((Control == null) || (Control != this) &&
          (GetParentForm(Control) == this) && (ComponentState.contains(ComponentStates.Loading) ||
          Control.CanFocus())))
        throw EInvalidOperation(Consts.SCannotFocus);
      _activeControl = Control;
      if(!ComponentState.contains(ComponentStates.Loading))
      {
        if(_active)
          SetWindowFocus();
        ActiveChanged();
      }
    }

  String
    get Caption => _getText();
    set Caption(String text) => _setText(text);

  TWinControl? _focusedControl;

  TFormBorderStyle _borderStyle = TFormBorderStyle.Sizeable;
  TFormBorderStyle
    get BorderStyle => _borderStyle;
    set BorderStyle(TFormBorderStyle Value)
    {
      if(_borderStyle == Value)
        return;

      _borderStyle = Value;
      AutoScroll = _borderStyle == TFormBorderStyle.Sizeable;
      if(!ComponentState.contains(ComponentStates.Designing))
      {
        RecreateWnd();
      }
    }

  TWindowState _windowState = TWindowState.Normal;
  TWindowState
    get WindowState => _windowState;
    set WindowState(TWindowState Value)
    {
      if(_windowState == Value)
        return;
      _windowState = Value;
      if(!ComponentState.contains(ComponentStates.Designing) && Showing)
        Windows.ShowWindow(Handle, ShowCommands[Value.index]);

      // new
      if(WindowState==TWindowState.Maximized && _form!=null)
        _form!.Maximize = true;
    }
    
  bool _keyPreview = false;
  bool
    get KeyPreview => _keyPreview;
    set KeyPreview(bool Value) => _keyPreview = Value;

  bool _active = true;
  bool get Active => _active;

  TFormStyle _formStyle = TFormStyle.Normal;
  TFormStyle get FormStyle => _formStyle;

  set FormStyle(TFormStyle Value)
  {
    if(FormStyle == Value)
      return;

    if(!ComponentState.contains(ComponentStates.Designing))
      DestroyHandle();

    _formStyle = Value;

    if(!ComponentState.contains(ComponentStates.Designing))
      UpdateControlState();

  }

  TPosition _position = TPosition.Default; 
  TPosition
    get Position => _position;
    set Position(TPosition Value)
    {
      if(_position == Value)
        return;
      _position = Value;
      if(!ComponentState.contains(ComponentStates.Designing))
        RecreateWnd();
    }

    
  TMainMenu? _menu;
  TMainMenu?
    get Menu => _menu;
    set Menu(TMainMenu? Value)
    {
      if(Value != null)
        for(int i = 0; i<Screen.FormCount; i++)
          if((Screen.Forms[i].Menu == Value) && (Screen.Forms[i] != this))
            throw EInvalidOperation.CreateFmt(Consts.SDuplicateMenus, [Value.Name]);
      if(_menu != null)
        _menu!.WindowHandle = null;
      if((ComponentState.contains(ComponentStates.Destroying)) ||
        ((Value != null) && (Value.ComponentState.contains(ComponentStates.Destroying))))
        Value = null;
      _menu = Value;
      if(Value != null)
        Value.FreeNotification(this);
      if((Value != null) && (ComponentState.contains(ComponentStates.Destroying) ||
        (BorderStyle != TFormBorderStyle.Dialog)))
      {
        if(!(Menu!.AutoMerge || (FormStyle == TFormStyle.MDIChild)) ||
          ComponentState.contains(ComponentStates.Designing))
        {
          if(HandleAllocated())
          {
            if(_form!.Menu != Menu!.Handle)
              _form!.Menu = Menu!.Handle;
            Value.WindowHandle = _form;
          }
        }
        else
        if(FormStyle != TFormStyle.MDIChild)
          if(HandleAllocated())
            _form!.Menu=null;
      }
      else
      if(HandleAllocated())
        _form!.Menu=null;
      if(Active)
        MergeMenu(true);
      RefreshMDIMenu();
    }

  TModalResult _modalResult = TModalResult.None;
  TModalResult
    get ModalResult => _modalResult;
    set ModalResult(TModalResult Value) => SetModalResult(Value);

  void SetModalResult(TModalResult Value)
  {
    if(_modalResult == Value)
      return;
    _modalResult = Value;
     (_form as HCustomForm).ModalResult = Value;
  }
    
  TNotifyEvent? _onActivate;
  TNotifyEvent?
    get OnActivate => _onActivate;
    set OnActivate(TNotifyEvent? Value) => _onActivate=Value;

  TCloseEvent? _onClose;
  TCloseEvent?
    get OnClose => _onClose;
    set OnClose(TCloseEvent? Value) => _onClose=Value;

  TNotifyEvent? _onDeactivate;
  TNotifyEvent?
    get OnDeactivate => _onDeactivate;
    set OnDeactivate(TNotifyEvent? Value) => _onDeactivate=Value;

  TNotifyEvent? _onHide;
  TNotifyEvent?
    get OnHide => _onHide;
    set OnHide(TNotifyEvent? Value) => _onHide=Value;

  TNotifyEvent? _onShow;
  TNotifyEvent?
    get OnShow => _onShow;
    set OnShow(TNotifyEvent? Value) => _onShow=Value;

  TFormState _formState = TFormState();
  TFormState get FormState => _formState;
    
  TCustomForm(TComponent? AOwner) : super(AOwner)
  {
    _visible = false;
    Height = 240;
    Width = 320;

    Left = 0;
    Top = 0;
    Width = 320;
    Height = 240;

    Visible = false;
    ParentColor = false;

    Screen.AddForm(this);
  }

  void Destroy()
  {

    try
    {

      MergeMenu(false);
      if(HandleAllocated())
        DestroyWindowHandle();
      Screen.RemoveForm(this);

      super.Destroy();
    }
    finally
    {

    }
  }



  Future<void> DoClose(TPointer<TCloseAction> Action) async
  {
    if(_onClose!=null)
      await _onClose!(this, Action);
  }

  void DoHide()
  {
    if(_onHide!=null)
      _onHide!(this);
  }

  void DoShow()
  {
    if(_onShow!=null)
      _onShow!(this);
  }

  TRect GetClientMetric()
  {
    int cxb = GetSystemMetrics(SysMetric.CXBORDER);
    int cyb = GetSystemMetrics(SysMetric.CYBORDER);
    return TRect(cxb,cyb,cxb,cyb);
  }

  TRect GetClientRect()
  {
    int cyc = 0;
    if(BorderStyle!=TBorderStyle.None)
      cyc+=GetSystemMetrics(SysMetric.CYCAPTION);
    TRect r = GetClientMetric();
    if(Menu != null)
      cyc+= GetSystemMetrics(SysMetric.CYMENU);
    return TRect(0, 0, Width-r.left-r.right-2, Height-cyc-r.top-r.bottom-2);

  }



  set Visible(bool Value)
  {
    if(FormState.contains(FormStates.Creating))
    {
      if(Value)
        FormState << FormStates.Visible;
      else
        FormState >> FormStates.Visible;
    }
    else
    {
      if(Value && (Visible != Value))
        SetWindowToMonitor();
      super.Visible = Value;
    }
  }

  void VisibleChanging()
  {
    if((FormStyle == TFormStyle.MDIChild) && Visible)
      throw EInvalidOperation(Consts.SMDIChildNotVisible);
  }

  bool WantChildKey(TControl Child, TMessage Message)
  {
    return false;
  }



  void WndProc(TMessage Message)
  {

    switch(Message.Msg)
    {
      case WM_LBUTTONDBLCLK:
        if(BorderStyle==TFormBorderStyle.Dialog)
          return; 
        break;


      case WM_ACTIVATE:
      case WM_SETFOCUS:
      case WM_KILLFOCUS:
          if(!FocusMessages)
            return;
          if((Message.Msg == WM_SETFOCUS) && !(ComponentState.contains(ComponentStates.Designing)))
          {
            HWND? FocusHandle;
            if(FormStyle == TFormStyle.MDIForm)
            {

            }
            else
              if((_activeControl != null) && (_activeControl != this))
                FocusHandle = _activeControl!.Handle;
            if(FocusHandle != null)
            {
              Windows.SetFocus(FocusHandle);
              return;
            }
          }
        break;

      case CM_EXIT:
        if(HostDockSite != null)
          Deactivate();
        break;

      case CM_ENTER:
        if(HostDockSite != null)
          Activate();
        break;

    default:

      break;
    }
    super.WndProc(Message);
  }



  HWND? _clientHandle;
  HWND? get ClientHandle => _clientHandle;

  void AlignControls(TControl? AControl, TRect Rect)
  {
    super.AlignControls(AControl, Rect);
    if(ClientHandle != null)
      Windows.SetWindowPos(_clientHandle!, HWND.BOTTOM, Rect.left, Rect.top, Rect.width,
          Rect.height, Windows.SWP_NOZORDER | Windows.SWP_NOACTIVATE);
  }


  void RefreshMDIMenu()
  {
    if(FormStyle == TFormStyle.MDIForm)
    {
      HMENU? MenuHandle;
      if(Menu != null)
        MenuHandle = Menu!.Handle;
      
    }
  }


  void SetWindowToMonitor()
  {

  }

  void CreateParams(TCreateParams Params)
  {

    super.CreateParams(Params);

      if(Parent == null && ParentWindow == null)
      {
        Params.WndParent = Application.Handle;
        
      }

      TFormBorderStyle CreateStyle = _borderStyle;

      if((FormStyle == TFormStyle.MDIChild) )
      {
        CreateStyle = TFormBorderStyle.Sizeable;
      }

      Params.Width = Width;
      Params.Height = Height;
      switch(CreateStyle)
      {

      }

  }

  void CreateWnd()
  {
    super.CreateWnd();
    
  }

  void CreateWindowHandle(TCreateParams Params)
  {

    /// new ///
    var form = _form = HCustomForm(this);
    form.ownedWindow = Params.WndParent;
    form.Title = _borderStyle != TBorderStyle.None;
    if(WindowState == TWindowState.Maximized)
    {
      form.Maximize = true;
      Params.X=null;
      Params.Y=null;
      Params.Width=null;
      Params.Height=null;
    }
    form.show();

    form.caption.text = Params.Caption;
    WindowHandle = _form;

    TRect r = GetClientMetric();
    int cyc = 0;
    if(BorderStyle != TBorderStyle.None)
      cyc+=GetSystemMetrics(SysMetric.CYCAPTION);

    if(Menu != null)
    {
      form.Menu = Menu!.Handle;
      cyc += GetSystemMetrics(SysMetric.CYMENU);
    }

    form.client.style
      ..left = '${r.left}px'
      ..top = '${r.top+cyc}px'
      ..right = '${r.right}px'
      ..bottom = '${r.bottom}px';
  }

  void DestroyWindowHandle()
  {

      super.DestroyWindowHandle();
    if(_form != null)
    {
      _form!.release();
      _form=null;
    }

  }


  void DefocusControl(TWinControl Control, bool Removing)
  {

    if(Removing && Control.ContainsControl(_focusedControl))
      _focusedControl = Control.Parent;
    if(Control.ContainsControl(_activeControl))
      ActiveControl = null;
  }

  void FocusControl(TWinControl Control)
  {

    bool WasActive = _active;
    ActiveControl = Control;
    if(!WasActive)
      SetFocus();
  }

  bool SetFocusedControl(TWinControl Control)
  {

    _focusCount++;
    
      if(Control != this)
        _activeControl = Control;
      else
        _activeControl = null;
    Screen._activeControl = Control;
    Screen._activeCustomForm = this;
    Screen._customForms.remove(this);
    Screen._customForms.insert(0, this);
    if(this is TForm)
    {
      Screen._activeForm = this as TForm;
      Screen._forms.remove(this);
      Screen._forms.insert(0, this as TForm);
    }
    else
      Screen._activeForm = null;

    HWND FocusHandle;
    TWinControl? TempControl;
    if(!Control.ControlState.contains(ControlStates.Focusing))
    {
      Control.ControlState << ControlStates.Focusing;
      try
      {
        if(Screen._focusedForm != this)
        {
          if(Screen._focusedForm != null)
          {
            FocusHandle = Screen._focusedForm!.Handle;
            Screen._focusedForm = null;
            if(!SendFocusMessage(FocusHandle, CM_DEACTIVATE))
              return false;
          }
          Screen._focusedForm = this;
          if(!SendFocusMessage(Handle, CM_ACTIVATE))
            return false;
        }
        if(_focusedControl == null)
          _focusedControl = this;
        if(_focusedControl != Control)
        {
          while((_focusedControl != null) && !_focusedControl!.ContainsControl(Control))
          {
            FocusHandle = _focusedControl!.Handle;
            _focusedControl = _focusedControl!.Parent;
            if(!SendFocusMessage(FocusHandle, CM_EXIT))
              return false;
          }
          while(_focusedControl != Control)
          {
            TempControl = Control;
            while(TempControl!.Parent != _focusedControl)
              TempControl = TempControl.Parent;
            _focusedControl = TempControl;
            if(!SendFocusMessage(TempControl.Handle, CM_ENTER))
              return false;
          }
          TempControl = Control.Parent;
          while(TempControl != null)
          {
            if(TempControl is TScrollingWinControl)
              TempControl.AutoScrollInView(Control);
            TempControl = TempControl.Parent;
          }
          Perform(CM_FOCUSCHANGED, 0, Control);

        }
      }
      finally
      {
        Control.ControlState >> ControlStates.Focusing;
      }
      Screen.UpdateLastActive();
      return true;
    }
    return false;
  }

  void ActiveChanged()
  {
  }


  void SetWindowFocus()
  {
    TWinControl FocusControl;
    if(_activeControl != null)
      FocusControl = _activeControl!;
    else
      FocusControl = this;
    if(FocusControl.HandleAllocated())
    {
      FocusControl.Perform(CM_SETFOCUS);
      if(FocusControl.Focused())
        FocusControl.Perform(CM_UIACTIVATE);

    }
  }

  void SetActive(bool Value)
  {

    _active = Value;

    if(Value)
    {
      if(ActiveControl == null && !ComponentState.contains(ComponentStates.Designing))
        ActiveControl = FindNextControl(null, true, true, false);
      MergeMenu(true);
      SetWindowFocus();
    }
  }

  void SendCancelMode(TControl Sender)
  {

  }

  void MergeMenu(bool MergeState)
  {

  }

  void DoNestedActivation(MESSAGE Msg, TWinControl? Control, TCustomForm Form)
  {
    if(Control == null)
      return;
    // Find the closest parent which is a form
    while((Control!.Parent != null) && !(Control is TCustomForm))
      Control = Control.Parent;
    if((Control!=null) && (Control != Form))
      Windows.SendMessage(Control.Handle, Msg, 0, 0);
  }

  void Activate()
  {
    DoNestedActivation(CM_ACTIVATE, ActiveControl, this);
    if(_onActivate!=null)
      _onActivate!(this);
  }

  void Deactivate()
  {
    DoNestedActivation(CM_DEACTIVATE, ActiveControl, this);
    if(_onDeactivate!=null)
      _onDeactivate!(this);
  }



  void Resizing(TWindowState State)
  {
    if(ComponentState != ComponentStates.Designing)
      _windowState = State;
    if(State != TWindowState.Minimized)
      RequestAlign();

  }



  void Close() async
  {
    if(FormState.contains(FormStates.Modal))
      ModalResult = TModalResult.Cancel;
    else
    {
      if(await CloseQuery())
      {
        var CloseAction = TPointer(TCloseAction.Hide);
        if(FormStyle == TFormStyle.MDIChild)
        {

          CloseAction.Value = TCloseAction.None;
        }
        await DoClose(CloseAction);

        if(CloseAction.Value != TCloseAction.None)
        {
          if(Application.MainForm == this)
            Application.Terminate();
          else
          if(CloseAction.Value == TCloseAction.Hide)
            Hide();
          else
          if(CloseAction.Value == TCloseAction.Minimize)
            WindowState = TWindowState.Minimized;
          else
            Destroy();
        }
      }
    }
  }

  Future<bool> CloseQuery() async
  {
    bool Result = false;
    if(FormStyle == TFormStyle.MDIForm)
    {

    }
    Result = true;

    return Result;
  }



  void Hide()
  {
    Visible = false;
  }

  void Show()
  {
    Visible = true;
    BringToFront();
  }

  void SetFocus()
  {
    if(!_active)
    {
      if(!(Visible && Enabled))
        throw EInvalidOperation(Consts.SCannotFocus);
      SetWindowFocus();
    }
  }



  Future<TModalResult> ShowModal() async
  {

    if(Visible || Enabled==false || (FormState.contains(FormStates.Modal)) ||  (FormStyle == TFormStyle.MDIChild))
      throw EInvalidOperation(Consts.SCannotShowModal);

    FormState << FormStates.Modal;

    HWND? ActiveWindow = Windows.GetActiveWindow();
    int SaveFocusCount = FocusCount;
    Screen._saveFocusedList.insert(0, Screen._focusedForm);
    Screen._focusedForm = this;
    TCursor SaveCursor = Screen.Cursor;
    Screen.Cursor = TCursor.Default;
    int SaveCount = Screen._cursorCount;


    try
    {
      Show();
      _form!.showOverlay();

      try
      {
        Windows.SendMessage(Handle, CM_ACTIVATE, 0, 0);

        if(_activeControl!=null)
          _activeControl!.Perform(CM_SETFOCUS); // new

        ModalResult = TModalResult.None;

        _modalResult = await (_form as HCustomForm).ShowModal();

        Windows.SendMessage(Handle, CM_DEACTIVATE, 0, 0);
        if(Windows.GetActiveWindow() != Handle)
          ActiveWindow = null;
      }
      finally
      {
        Hide();
      }
    }
    finally
    {

      if(Screen._cursorCount == SaveCount)
        Screen.Cursor = SaveCursor;
      else
        Screen.Cursor = TCursor.Default;

      if(Screen._saveFocusedList.isNotEmpty)
      {
        Screen._focusedForm = Screen._saveFocusedList.first;
        Screen._saveFocusedList.remove(Screen._focusedForm);
      }
      else
        Screen._focusedForm = null;
      if(ActiveWindow != null)
        Windows.SetActiveWindow(ActiveWindow);

      _focusCount = SaveFocusCount;
      FormState >> FormStates.Modal;
    }
    return ModalResult;
  }

  void UpdateActions()
  {
    void TraverseClients(TWinControl Container)
    {
      if(!Container.Showing)
        return;

      for(int i = 0; i<Container.ControlCount; i++)
      {
        TControl Control = Container.Controls[i];
        if(Control.ControlStyle.contains(ControlStyles.ActionClient) && Control.Visible)
            Control.InitiateAction();
        if(Control is TWinControl)
          TraverseClients(Control);
      }
    }

    if((ComponentState.contains(ComponentStates.Designing)) || !Showing)
      return;
    // Update form
    InitiateAction();
    // Update main menu's top-most items
    if(Menu != null)
    {

    }
    // Update any controls
    TraverseClients(this);
  }

  void UpdateWindowState()
  {
    if(HandleAllocated())
    {

    }
  }

  void RequestAlign()
  {
    if(Parent == null)
      Screen.AlignForm(this);
    else
      super.RequestAlign();
  }



  void MouseWheelHandler(TMessage Message)
  {
    if(_focusedControl != null)
      Message.Result = _focusedControl!.Perform(CM_MOUSEWHEEL, Message.WParam, Message.LParam);
    else
      super.MouseWheelHandler(Message);
  }



  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CM_ACTIVATE:           _cmActivate(Message); break;
      case CM_DEACTIVATE:         _cmDeactivate(Message); break;

      case WM_ACTIVATE:           _wmActivate(Message); break;
      case WM_NCHITTEST:          Message.Result = _wmHitTest(Message);  break;

      default:
        super.Dispatch(Message);
        break;
    }
  }

  ///  C O N T R O L   M E S S A G E S ///

  void _cmActivate(TMessage Message)
  {
    if(!ComponentState.contains(ComponentStates.Reading))
      Activate();
    else
      _formState<<FormStates.Activated;
  }

  void _cmDeactivate(TMessage Message)
  {
    if(!ComponentState.contains(ComponentStates.Reading))
      Deactivate();
    else
     _formState >> FormStates.Activated;
  }

  void _cmDialogKey(TMessage Message /*TCMDialogKey*/)
  {

    super._cmDialogKey(Message);
  }

  void _cmShowingChanged(TMessage Message)
  {

    void UpdateFormPosition(int X, int Y)
    {
      if(X + Width > Screen.Width)
        X = Screen.Width - Width;
      if(Y + Height > Screen.Height)
        Y = Screen.Height - Height;
      if(X < 0) X = 0;
      if(Y < 0) Y = 0;

      SetBounds(X, Y, Width, Height);
    }

    if(!ComponentState.contains(ComponentStates.Designing) && FormState.contains(FormStates.Showing))
      throw EInvalidOperation(Consts.SVisibleChanged);
    Application.UpdateVisible();
    FormState << FormStates.Showing;
    try
    {
      if(ComponentState.contains(ComponentStates.Designing) == false)
      {
        if(Showing)
        {
          try
          {
            DoShow();
          }
          catch(E)
          {
            Application.HandleException(this);
          }

          if(Position == TPosition.ScreenCenter ||
             (Position == TPosition.MainFormCenter && FormStyle == TFormStyle.MDIChild))
          {
            if(FormStyle == TFormStyle.MDIChild)
              UpdateFormPosition(
                  (Application.MainForm!.ClientWidth - Width) ~/ 2,
                  (Application.MainForm!.ClientHeight - Height) ~/ 2);
            else
              UpdateFormPosition(
                  (Screen.Width - Width) >> 1,
                  (Screen.Height - Height) >> 1);
            if(Visible)
              SetWindowToMonitor();
          }
          else
          if([TPosition.MainFormCenter, TPosition.OwnerFormCenter].contains(Position))
          {
            TCustomForm? CenterForm = Application.MainForm;

            if(Position == TPosition.OwnerFormCenter && Owner is TControl)
              CenterForm = GetParentForm(Owner as TControl);
            if(CenterForm == null)
              UpdateFormPosition(
                  (Screen.Width - Width) ~/ 2,
                  (Screen.Height - Height) ~/ 2);
            else
              UpdateFormPosition(
                  (CenterForm.Width - Width + CenterForm.Left*2) ~/ 2,
                  (CenterForm.Height - Height + CenterForm.Top*2) ~/ 2);
            if(Visible)
              SetWindowToMonitor();
          }
          else
          if(Position == TPosition.DesktopCenter)
          {
            if(FormStyle == TFormStyle.MDIChild)
              UpdateFormPosition(
                  (Application.MainForm!.ClientWidth - Width) ~/ 2,
                  (Application.MainForm!.ClientHeight - Height) ~/ 2);
            else
              UpdateFormPosition(
                  (Screen.DesktopWidth - Width) ~/ 2,
                  (Screen.DesktopHeight - Height) ~/ 2);
          }
          _position = TPosition.Designed;

        }
        else
        {
          try
          {
            DoHide();
          }
          catch(E)
          {
            Application.HandleException(this);
          }

          if(Screen.ActiveForm == this)
            MergeMenu(false);

          if(FormState.contains(FormStates.Modal))
          {
//            _form!.hide();
            Windows.SetWindowPos(Handle, null, 0, 0, 0, 0,
                Windows.SWP_HIDEWINDOW | Windows.SWP_NOZORDER | Windows.SWP_NOACTIVATE |
                Windows.SWP_NOSIZE | Windows.SWP_NOMOVE);
          }
          else
          {
            HWND? NewActiveWindow;
            if((Windows.GetActiveWindow() == Handle) && !Windows.IsIconic(Handle))
              NewActiveWindow = FindTopMostWindow(Handle);
            if(NewActiveWindow != null)
            {
              Windows.SetWindowPos(Handle, null, 0, 0, 0, 0,
                Windows.SWP_HIDEWINDOW | Windows.SWP_NOZORDER | Windows.SWP_NOACTIVATE |
                Windows.SWP_NOSIZE | Windows.SWP_NOMOVE);
              Windows.SetActiveWindow(NewActiveWindow);
            }
            else
              Windows.ShowWindow(Handle, Windows.SW_HIDE);
          }
        }
      }
    }
    finally
    {
      FormState >> FormStates.Showing;
    }
  }

///  W I N D O W   M E S S A G E S ///

  void _wmActivate(TMessage Message)// TWMActivate
  {
    if(_form != null)
    {
      if(LOWORD(Message.WParam)==0)
        _form!.title.classes.add('inactive');
      else
        _form!.title.classes.remove('inactive');
    }



    if((FormStyle != TFormStyle.MDIForm) || ComponentState.contains(ComponentStates.Designing))
      SetActive(LOWORD(Message.WParam) != Windows.WA_INACTIVE);
  }

  int _wmHitTest(TMessage Message)
  { // new
    super.Dispatch(Message);
    int Result = Message.Result;
    switch(BorderStyle)
    {
      case TFormBorderStyle.Dialog:
        switch(Result)
        {
          case Windows.HTCAPTION:
            return Result;
          default:
            return Windows.HTCLIENT;
        } break;

      default:
        return Result;
    }
  }



}

class TForm extends TCustomForm
{

  TForm(TComponent? AOwner) : super(AOwner)
  {
  }


}

class TScreen extends TComponent
{
  int _pixelsPerInch = 96; 
  int get PixelsPerInch => _pixelsPerInch;

  late int _width;
  int get Width => _width;

  late int _height;
  int get Height => _height;

  int get DesktopWidth => Width; /// temp
  int get DesktopHeight => Height; /// temp

  final _forms = <TForm>[];
  late final TItems<TForm> Forms;

  int get FormCount => _forms.length;

  List<TCustomForm> _customForms = <TCustomForm>[];
  late final TItems<TCustomForm> CustomForms;

  int get CustomFormCount => _customForms.length;


  TWinControl? _activeControl;
  TWinControl? get ActiveControl => _activeControl;

  TCustomForm? _activeCustomForm;
  TCustomForm? get ActiveCustomForm => _activeCustomForm;

  TForm? _activeForm;
  TForm? get ActiveForm => _activeForm;

  TCustomForm? _focusedForm;
  TCustomForm? get FocusedForm => _focusedForm; // new
  List _saveFocusedList = [];

  TScreen(TComponent? AOwner) : super(AOwner)
  {
    Forms = TItems<TForm>(
      (int ndx) => _forms[ndx],
      ()        => _forms.iterator );

    CustomForms = TItems<TCustomForm>(
      (int ndx) => _customForms[ndx],
      ()        => _customForms.iterator);

    _width = window.innerWidth!;
    _height = window.innerHeight!;

    window.onResize.listen((event)
    {
      _width = window.innerWidth!;
      _height = window.innerHeight!;

      _customForms.forEach((form)
      {
        if(form.HandleAllocated())
        {
          if(form._form!.Maximize)
            Windows.SetWindowPos(form._form!, null, 0, 0, _width, _height, 0);
        }
      });
    });

  }



  int get DesktopTop
  {
    return 0;

  }

  int get DesktopLeft
  {
    return 0;

  }



  void UpdateLastActive()
  {

  }

  void AddForm(TCustomForm AForm)
  {
    _customForms.add(AForm);
    if(AForm is TForm)
    {
      _forms.add(AForm);
      Application.UpdateVisible();
    }
  }

  void RemoveForm(TCustomForm AForm)
  {
    _customForms.remove(AForm);
    _forms.remove(AForm);
    Application.UpdateVisible();
    if(_customForms.isEmpty && (Application._hintWindow != null))
      Application._hintWindow!.ReleaseHandle();
  }



  int _cursorCount = 0;

  TCursor _cursor = TCursor.Default;
  TCursor
    get Cursor => _cursor;
    set Cursor(TCursor Value)
    {
      if(Cursor!=Value)
      {
        _cursor = Value;
        if(Value == TCursor.Default)
        {
          // Reset the cursor to the default by sending a WM_SETCURSOR to the
          // window under the cursor
          TPoint P = Windows.GetCursorPos();
          var Handle = Windows.WindowFromPoint(P);
          if((Handle != null) )
          {
            int code = Windows.SendMessage(Handle, WM_NCHITTEST, 0, P);
            Windows.SendMessage(Handle, WM_SETCURSOR, Handle, [code, WM_MOUSEMOVE] );
            return;
          }
        }
        Windows.SetCursor(Value);
      }
      _cursorCount++;
    }



  final _controlState = TControlState();

  int _alignLevel = 0;

  void DisableAlign()
  {
    _alignLevel++;
  }

  void EnableAlign()
  {
    _alignLevel--;
    if(_alignLevel == 0 && _controlState.contains(ControlStates.AlignmentNeeded))
      Realign();
  }

  void Realign()
  {
    AlignForm(null);
  }

  void AlignForms(TCustomForm AForm, TRect Rect)
  {

  }

  void AlignForm(TCustomForm? AForm)
  {
    if(_alignLevel != 0)
      _controlState << ControlStates.AlignmentNeeded;
    else
    {
      DisableAlign();
      try
      {

      }
      finally
      {
        _controlState >> ControlStates.AlignmentNeeded;
        EnableAlign();
      }
    }
  }

  final _fonts = TStringList();
  TStrings get Fonts
  {
    if(_fonts.Count > 0)
      return _fonts;

    EnumFontFamilies( (String name){ _fonts.Append(name); } );
    return _fonts;
  }
}

/// Hint functions

String GetHint(TControl? Control)
{
  while(Control != null)
  {
    if(Control.Hint.isEmpty)
      Control = Control.Parent;
    else
      return Control.Hint;
  }
  return '';
}

TControl? GetHintControl(TControl? Control)
{
  var Result = Control;
  while((Result != null) && !Result.ShowHint)
    Result = Result.Parent;
  if((Result != null) && (Result.ComponentState.contains(ComponentStates.Designing)))
    Result = null;
  return Result;
}



void HookHintHooks()
{

}

void UnhookHintHooks()
{

}



TScreen? _screen;
TScreen get Screen
{
  if(_screen == null)
    _screen = TScreen(null);
  return _screen!;
}


class THintInfo
{
  TControl? HintControl;
  TClass?   HintWindowClass;
  TPoint    HintPos = TPoint();
  int       HintMaxWidth = 0;
  TColor    HintColor = clInfoBk;
  TRect     CursorRect = TRect();
  TPoint    CursorPos = TPoint();
  int       ReshowTimeout = 0;
  int       HideTimeout = 0;
  String    HintStr = '';
  dynamic   HintData;
}


typedef void TMessageEvent(MSG Msg, TPointer<bool> Handled);
typedef void TIdleEvent(TObject Sender, TPointer<bool> Done);
typedef void TShowHintEvent(TPointer<String> HintStr, TPointer<bool> CanShow,
  THintInfo HintInfo);


final _objectFactory = Map<Type,TObjectCreator>();

void DefineObjectFactory(Type type, TObjectCreator f) =>
  _objectFactory[type] = f;

TObject? CreateObjectInstance(Type type, TComponent Owner)
{
  TObjectCreator? fnc = _objectFactory[type];

  if(fnc!=null)
  {
    try
    {
      return fnc(Owner);
    }
    catch(E)
    {
      return null;
    }
  }
  return null;
}

class TApplication extends TComponent
{
  HWND? _handle;
  HWND? get Handle => _handle;
  set Handle(HWND? Value)
  {
    if(!_handleCreated && (Value != _handle))
    {
      if(_handle != null)
      {

      }
      _handle = Value;
      if(_handle != null)
      {

      }
    }
  }


  TForm? _mainForm;
  TForm? get MainForm => _mainForm;
  TControl? _mouseControl;

  bool _showMainForm=true;
  bool
    get ShowMainForm => _showMainForm;
    set ShowMainForm(bool Value) => _showMainForm = Value;

  String
    get Title => document.title;
    set Title(String Value) => document.title = Value;

    bool _handleCreated = false;
    bool _running = false;

  TNotifyEvent? _onActivate;
  TNotifyEvent?
    get OnActivate => _onActivate;
    set OnActivate(TNotifyEvent? Value) => _onActivate=Value;

    
  TNotifyEvent? _onHint;
  TNotifyEvent?
    get OnHint => _onHint;
    set OnHint(TNotifyEvent? event) => _onHint = event;

  TMessageEvent? _onMessage;
  TMessageEvent?
    get OnMessage => _onMessage;
    set OnMessage(TMessageEvent? event) => _onMessage = event;

  TApplication(TComponent? AOwner) : super(AOwner)
  {
    DefineObjectFactory(TForm, (_) => TForm(_ as TComponent) );

    if(SysMetric.SmartMode)
    {
      document.body!.style.overflow='hidden'; // отключение обновления страницы свайпом вниз
    }
    
    CreateHandle();

  }



  void CreateHandle()
  {
    _handle = Windows.GetDesktopWindow(); /// new

  }



  void Minimize()
  {

  }



  bool IsDlgMsg(MSG Msg)
  {

    return false;
  }

  bool IsMDIMsg(MSG Msg)
  {

    return false;
  }

  bool IsKeyMsg(MSG msg)
  {
    bool Result = false;

    if(msg.message >= WM_KEYFIRST && msg.message <= WM_KEYLAST)
    {
      HWND? Wnd = null; //GetCapture();
      if(Wnd == null)
      {
        Wnd = msg.hwnd;
        if((MainForm != null) && (Wnd == MainForm!.ClientHandle))
          Wnd = MainForm!.Handle;
        else
        {
          // Find the nearest VCL component.  Non-VCL windows wont know what
          // to do with CN_BASE offset messages anyway.
          // TOleControl.WndProc needs this for TranslateAccelerator
          while((FindControl(Wnd) == null) && (Wnd != null))
            Wnd = Windows.GetParent(Wnd);
          if(Wnd == null)
            Wnd = msg.hwnd;
        }
        MESSAGE? cm = TWinControl.WM_TO_CM[msg.message];

        if(cm != null && toIntDef(Windows.SendMessage(Wnd, cm /*CN_BASE + Message*/, msg.wParam, msg.lParam), 0) != 0)
          Result = true;
      }

    }
    return Result;
  }

  bool IsHintMsg(MSG Msg)
  {
    if(_hintWindow != null && _hintWindow!.IsHintMsg(Msg))
      CancelHint();
    return false;
  }



  TCustomForm? CreateForm(Type type)
  {
    TObject? instance = CreateObjectInstance(type, this);

    if(instance==null)
      return null;

    if(_mainForm == null && instance is TForm)
      _mainForm = instance;


    return instance as TCustomForm;

  }

  Future<void> Run() async
  {
    _running = true;
    try
    {

      if(_mainForm != null)
      {

        if(_showMainForm)
          await _mainForm!.ShowModal(); // new
      }
    }
    finally
    {
      _running = false;
    }
  }

  void Terminate()
  {

  }

  void HandleException(TObject Sender)
  {

  }



  Future<void> ShowException(TException E) async
  {
    String Msg = E.Message;
    if((Msg.isNotEmpty)/* && (AnsiLastChar(Msg) > '.')*/)
      Msg = Msg + '.';
    await MessageBox(Msg, Title, Windows.MB_OK + Windows.MB_ICONSTOP);
  }



  bool _showHint = false;
  bool
    get ShowHint => _showHint;
    set ShowHint(bool Value)
    {
      if(_showHint == Value)
        return;
      _showHint = Value;
      if(_showHint)
      {
        _hintWindow = HintWindowClass.Create(this);
        _hintWindow!.Color = HintColor;
      }
      else
      {
        _hintWindow!.Free();
        _hintWindow = null;
      }
    }

  TColor _hintColor = DefHintColor;
  TColor
    get HintColor => _hintColor;
    set HintColor(TColor Value)
    {
      if(HintColor == Value)
        return;
      _hintColor = Value;
      if(_hintWindow != null)
        _hintWindow!.Color = _hintColor;
    }

  TIdleEvent? _onIdle;
  TIdleEvent?
    get OnIdle => _onIdle;
    set OnIdle(TIdleEvent? value) => _onIdle = value;

  void DoActionIdle()
  {
    for(var form in Screen._customForms)
    {
      if(form.HandleAllocated() && Windows.IsWindowVisible(form.Handle) &&
        Windows.IsWindowEnabled(form.Handle))
          form.UpdateActions();
    }
  }

  TControl? DoMouseIdle()
  {
    TPoint P = Windows.GetCursorPos();
    TControl? Result = FindDragTarget(P, true);
    if(Result != null && Result.ComponentState.contains(ComponentStates.Designing))
      Result = null;
    TControl? CaptureControl = GetCaptureControl();
    if(_mouseControl != Result)
    {
      if((_mouseControl != null && CaptureControl == null) ||
        (CaptureControl != null && _mouseControl == CaptureControl))
        _mouseControl!.Perform(CM_MOUSELEAVE, 0, 0);
      _mouseControl = Result;
      if((_mouseControl != null && CaptureControl == null) ||
        (CaptureControl != null && _mouseControl == CaptureControl))
        _mouseControl!.Perform(CM_MOUSEENTER, 0, 0);
    }
    return Result;
  }

  void Idle() 
  {
    var ctrl = DoMouseIdle();

    if(ShowHint && (_mouseControl == null))
      CancelHint();
    Application.Hint = GetLongHint(GetHint(ctrl));
    bool done = true;
    try
    {
      if(_onIdle!=null)
      {
        var pDone = TPointer(done);
        _onIdle!(this, pDone);
        done = pDone.Value;
      }
      if(done)
        DoActionIdle();
    }
    catch(E)
    {

    }

  }



  String _hint = '';
  String
    get Hint => _hint;
    set Hint(String Value)
    {
      if(Hint == Value)
        return;
      _hint = Value;

      if(OnHint != null)
        OnHint!(this);
      else // Fire THintAction to anyone interested
      {
        var action = THintAction(this);
        action.Hint = Value;
        try
        {
          action.Execute();
        }
        finally
        {
          action.Free();
        }
      }
    }



  void UpdateVisible()
  {
    void SetVisible(bool Value)
    {

      // Dont auto-update visibility if somebody else has hidden app window

    }

    if(_handle != null)
    {
      for(int i = 0; i<Screen.FormCount; i++)
      {
        TForm Form = Screen.Forms[i];
        if(Form.Visible && ((Form.ParentWindow == null) || Form.HandleAllocated() ||
          !Windows.IsChild(Form.Handle, Form.ParentWindow)))
        {
          SetVisible(true);
          return;
        }
      }
      SetVisible(false);
    }
  }



  /// Hint window processing
  TControl?       _hintControl;
  TRect           _hintCursorRect = TRect();
  THintWindow?    _hintWindow;
  bool            _hintActive = false;
  Timer?          _timerHandle;
  int             _hintPause = DefHintPause;
  int             _hintShortPause = DefHintShortPause;
  bool            _hintShortCuts = true;
  int             _hintHidePause = DefHintHidePause;
  TShowHintEvent? _onShowHint;

  int
    get HintPause => _hintPause;
    set HintPause(int value) => _hintPause=value;

  int
    get HintShortPause => _hintShortPause;
    set HintShortPause(int value) => _hintShortPause = value;

  TShowHintEvent?
    get OnShowHint => _onShowHint;
    set OnShowHint(TShowHintEvent? value) => _onShowHint = value;

  bool
    get HintShortCuts => _hintShortCuts;
    set HintShortCuts(bool value) => _hintShortCuts = value;

  int
    get HintHidePause => _hintHidePause;
    set HintHidePause(int value) => _hintHidePause = value;

  void StartHintTimer(int value, bool show)
  {
    StopHintTimer();
    if(value==-1)
      return;
    _timerHandle = Timer(Duration(milliseconds: value), ()
    {
      try
      {
        HintTimerExpired(show);
      }
      catch(E)
      {
        Application.HandleException(Application);
      }
    });
  }

  void StopHintTimer()
  {
    if(_timerHandle != null)
    {
      _timerHandle!.cancel();
      _timerHandle = null;
    }
  }

  void HintMouseMessage(TControl Control, TMessage Message)
  {
    TControl? NewHintControl = GetHintControl(FindDragTarget(Control.ClientToScreen(Message.LParam), true));
    if((NewHintControl == null) || !NewHintControl.ShowHint)
      CancelHint();
    else
    {
      if( (NewHintControl != _hintControl) ||
         (!PtInRect(_hintCursorRect, Control.ClientToScreen(Message.LParam))) )
      {
        bool WasHintActive = _hintActive;
        var Pause = TPointer(WasHintActive? _hintShortPause : _hintPause);
        NewHintControl.Perform(CM_HINTSHOWPAUSE, WasHintActive, Pause);
        // Show hint immediately if no pause
        if(WasHintActive && (Pause.Value == 0))
        {
          _hintActive = WasHintActive;
          _hintControl = NewHintControl;
          ActivateHint(Windows.GetCursorPos());
        }
        else
        {
          CancelHint();
          _hintActive = WasHintActive;
          _hintControl = NewHintControl;
          StartHintTimer(Pause.Value, true);
        }
      }
    }
  }

  void HintTimerExpired(bool show)
  {
    StopHintTimer();
    if(show)
    {
      TPoint p = Windows.GetCursorPos();
      ActivateHint(p);
    }
    else
      HideHint();
  }

  void HideHint()
  {
    if((_hintWindow != null) && _hintWindow!.HandleAllocated() &&
        Windows.IsWindowVisible(_hintWindow!.Handle))
        Windows.ShowWindow(_hintWindow!.Handle, Windows.SW_HIDE);
  }

  void CancelHint()
  {
    if(_hintControl == null)
      return;
    HideHint();
    _hintControl = null;
    _hintActive = false;
    UnhookHintHooks();
    StopHintTimer();
  }

  void ActivateHint(TPoint CursorPos)
  {

    /// Return number of scanlines between the scanline containing cursor hotspot
    /// and the last scanline included in the cursor mask.
    int GetCursorHeightMargin()
    {
      return 16;

    }

    void ValidateHintWindow(TClass? HintClass)
    {
      if(HintClass == null)
        HintClass = HintWindowClass;

      if((_hintWindow == null) || (_hintWindow!.ClassType() != HintClass))
      {
        if(_hintWindow!=null)
          _hintWindow!.Free();
        _hintWindow = HintClass.Create(this);
      }
    }



    var HintInfo = THintInfo();
    _hintActive = false;
    if(_showHint && (_hintControl != null) && 
      (_hintControl = GetHintControl(FindDragTarget(CursorPos, true))) != null)
    {
      HintInfo.HintControl = _hintControl;
      HintInfo.HintPos     = CursorPos;
      HintInfo.HintPos.y += GetCursorHeightMargin();
      HintInfo.HintMaxWidth = Screen.Width;
      HintInfo.HintColor = HintColor;
      HintInfo.CursorRect = _hintControl!.BoundsRect;
      var ClientOrigin = _hintControl!.ClientOrigin;
      var ParentOrigin = TPoint(0, 0);

      if(_hintControl!.Parent != null)
        ParentOrigin = _hintControl!.Parent!.ClientOrigin;
      else
      if((_hintControl is TWinControl) &&
        ((_hintControl as TWinControl).ParentWindow != null))
          Windows.ClientToScreen((_hintControl as TWinControl).ParentWindow, ParentOrigin);
      OffsetRect(HintInfo.CursorRect, ParentOrigin.x - ClientOrigin.x,  ParentOrigin.y - ClientOrigin.y);
      HintInfo.CursorPos = _hintControl!.ScreenToClient(CursorPos);
      HintInfo.HintStr = GetShortHint(GetHint(_hintControl));
      HintInfo.ReshowTimeout = 0;
      HintInfo.HideTimeout = _hintHidePause;
      HintInfo.HintWindowClass = HintWindowClass;
      HintInfo.HintData = null;
      bool CanShow = _hintControl?.Perform(CM_HINTSHOW, 0, HintInfo) == 0;
      if(CanShow && _onShowHint!=null)
      {
        var pHintStr = TPointer<String>(HintInfo.HintStr);
        var pCanShow = TPointer<bool>(CanShow);
        _onShowHint!(pHintStr, pCanShow, HintInfo);
        HintInfo.HintStr = pHintStr.Value;
        CanShow = pCanShow.Value;
      }
      _hintActive = CanShow && (_hintControl != null);
      if(_hintActive && HintInfo.HintStr.isNotEmpty)
      {
        ValidateHintWindow(HintInfo.HintWindowClass);


        /// calculate the width of the hint based on HintStr and MaxWidth
        var HintWinRect = _hintWindow!.CalcHintRect(HintInfo.HintMaxWidth, HintInfo.HintStr, HintInfo.HintData);
        OffsetRect(HintWinRect, HintInfo.HintPos.x, HintInfo.HintPos.y);


        // Convert the client's rect to screen coordinates
        _hintCursorRect.TopLeft     = _hintControl!.ClientToScreen(HintInfo.CursorRect.TopLeft);
        _hintCursorRect.BottomRight = _hintControl!.ClientToScreen(HintInfo.CursorRect.BottomRight);

        _hintWindow!.Color = HintInfo.HintColor;
        _hintWindow!.ActivateHintData(HintWinRect, HintInfo.HintStr, HintInfo.HintData);
        HookHintHooks();
        if(HintInfo.ReshowTimeout > 0)
          StartHintTimer(HintInfo.ReshowTimeout, true);
        else
          StartHintTimer(HintInfo.HideTimeout, false);
        return;
      }
    }

    if(HintInfo.ReshowTimeout > 0)
      StartHintTimer(HintInfo.ReshowTimeout, true);
    else
      CancelHint();
  }



  Future<void> TryBlock(Future<void> Function() block, [Future<Object?> Function(Object)? excp]) async // new
  {
    try
    {
      await block();
    }
    catch(E)
    {
      Future<void> showException(Object E) async
      {
        if(E is TException)
          await ShowException(E);
        else
          await MessageBox('$E', Title, Windows.MB_OK + Windows.MB_ICONSTOP);
      }

      if(excp==null)
        await showException(E);
      else
      {
        try
        {
          // return E;
          // return Future.error(E);
          var e = await excp(E);
          if(e != null)
            return Future.error(e);
        }
        catch(E)
        {
          await showException(E);
        }
      }
    }
  }

}

TApplication? _application;

bool ApplicationAllocated() => _application != null;

TApplication get Application
{
  if(_application == null)
  {
    _application = TApplication(null);
    _application!.ShowHint = true; // new, emulate Controls.InitControls
  }
  return _application!;
}

TApplication? START_APPLICATION(TApplication? app)
{
  TApplication? Result = _application;
  _application = app;
  if(app!=null)
    _application!.ShowHint = true; // new, emulate Controls.InitControls
  return Result;
}

