part of vcl;

// VCL control message IDs


const MESSAGE CM_ACTIVATE            = MESSAGE(0xb000, 'CM_ACTIVATE');
const MESSAGE CM_DEACTIVATE          = MESSAGE(0xb001, 'CM_DEACTIVATE');

const MESSAGE CM_DIALOGKEY           = MESSAGE(0xb005, 'CM_DIALOGKEY');
const MESSAGE CM_DIALOGCHAR          = MESSAGE(0xb006, 'CM_DIALOGCHAR');
const MESSAGE CM_FOCUSCHANGED        = MESSAGE(0xb007, 'CM_FOCUSCHANGED');
const MESSAGE CM_PARENTFONTCHANGED   = MESSAGE(0xb008, 'CM_PARENTFONTCHANGED');
const MESSAGE CM_PARENTCOLORCHANGED  = MESSAGE(0xb009, 'CM_PARENTCOLORCHANGED');
const MESSAGE CM_HITTEST             = MESSAGE(0xb00a, 'CM_HITTEST');
const MESSAGE CM_VISIBLECHANGED      = MESSAGE(0xb00b, 'CM_VISIBLECHANGED');
const MESSAGE CM_ENABLEDCHANGED      = MESSAGE(0xb00c, 'CM_ENABLEDCHANGED');
const MESSAGE CM_COLORCHANGED        = MESSAGE(0xb00d, 'CM_COLORCHANGED');
const MESSAGE CM_FONTCHANGED         = MESSAGE(0xb00e, 'CM_FONTCHANGED');
const MESSAGE CM_CURSORCHANGED       = MESSAGE(0xb00f, 'CM_CURSORCHANGED');
const MESSAGE CM_CTL3DCHANGED        = MESSAGE(0xb010, 'CM_CTL3DCHANGED');
const MESSAGE CM_PARENTCTL3DCHANGED  = MESSAGE(0xb011, 'CM_PARENTCTL3DCHANGED');
const MESSAGE CM_TEXTCHANGED         = MESSAGE(0xb012, 'CM_TEXTCHANGED');
const MESSAGE CM_MOUSEENTER          = MESSAGE(0xb013, 'CM_MOUSEENTER'); // wParam: null, lParam: null|Control
const MESSAGE CM_MOUSELEAVE          = MESSAGE(0xb014, 'CM_MOUSELEAVE'); // wParam: null, lParam: null|Control
const MESSAGE CM_MENUCHANGED         = MESSAGE(0xb015, 'CM_MENUCHANGED');

const MESSAGE CM_BUTTONPRESSED       = MESSAGE(0xb018, 'CM_BUTTONPRESSED');
const MESSAGE CM_SHOWINGCHANGED      = MESSAGE(0xb019, 'CM_SHOWINGCHANGED');
const MESSAGE CM_ENTER               = MESSAGE(0xb01a, 'CM_ENTER');
const MESSAGE CM_EXIT                = MESSAGE(0xb01b, 'CM_EXIT');

const MESSAGE CM_WANTSPECIALKEY      = MESSAGE(0xb01e, 'CM_WANTSPECIALKEY');

const MESSAGE CM_SHOWHINTCHANGED       = MESSAGE(0xb022, 'CM_SHOWHINTCHANGED');
const MESSAGE CM_PARENTSHOWHINTCHANGED = MESSAGE(0xb023, 'CM_PARENTSHOWHINTCHANGED');

const MESSAGE CM_TABSTOPCHANGED      = MESSAGE(0xb028, 'CM_TABSTOPCHANGED');
const MESSAGE CM_UIACTIVATE          = MESSAGE(0xb029, 'CM_UIACTIVATE');
const MESSAGE CM_UIDEACTIVATE        = MESSAGE(0xb02a, 'CM_UIDEACTIVATE');

const MESSAGE CM_CONTROLLISTCHANGE   = MESSAGE(0xb02c, 'CM_CONTROLLISTCHANGE');

const MESSAGE CM_CHILDKEY            = MESSAGE(0xb02e, 'CM_CHILDKEY');

const MESSAGE CM_HINTSHOW            = MESSAGE(0xb030, 'CM_HINTSHOW');


const MESSAGE CM_RECREATEWND         = MESSAGE(0xb033, 'CM_RECREATEWND');
const MESSAGE CM_INVALIDATE          = MESSAGE(0xb034, 'CM_INVALIDATE');

const MESSAGE CM_CONTROLCHANGE       = MESSAGE(0xb036, 'CM_CONTROLCHANGE');
const MESSAGE CM_CHANGED             = MESSAGE(0xb037, 'CM_CHANGED'); // wParam: null, lParam: TControl

const MESSAGE CM_HINTSHOWPAUSE       = MESSAGE(0xb041, 'CM_HINTSHOWPAUSE');

const MESSAGE CM_MOUSEWHEEL          = MESSAGE(0xb043, 'CM_MOUSEWHEEL');


// new
const MESSAGE CM_GETINSTANCE         = MESSAGE(0xb100, 'CM_GETINSTANCE');

const MESSAGE CM_SETVALUE            = MESSAGE(0xb103, 'CM_SETVALUE'); // lParam: dynamic
const MESSAGE CM_GETVALUE            = MESSAGE(0xb104, 'CM_GETVALUE'); // lResult: dynamic
const MESSAGE CM_CLEARVALUE          = MESSAGE(0xb105, 'CM_CLEARVALUE');
const MESSAGE CM_ISEMPTY             = MESSAGE(0xb106, 'CM_ISEMPTY');
const MESSAGE CM_CANFOCUS            = MESSAGE(0xb107, 'CM_CANFOCUS');
const MESSAGE CM_SETFOCUS            = MESSAGE(0xb108, 'CM_SETFOCUS');
const MESSAGE CM_GETCAPTION          = MESSAGE(0xb109, 'CM_GETCAPTION');

// VCL control notification IDs

const MESSAGE CN_COMMAND             = MESSAGE(0xbd11, 'CN_COMMAND');


const MESSAGE CN_KEYDOWN             = MESSAGE(0xbd00, 'CN_KEYDOWN');
const MESSAGE CN_KEYUP               = MESSAGE(0xbd01, 'CN_KEYUP');
const MESSAGE CN_CHAR                = MESSAGE(0xbd02, 'CN_CHAR');

const MESSAGE CN_HSCROLL             = MESSAGE(0xbd14, 'CN_HSCROLL');
const MESSAGE CN_VSCROLL             = MESSAGE(0xbd15, 'CN_VSCROLL');

// TModalResult values
enum TModalResult { None, Ok, Cancel, Abort, Retry, Ignore, Yes, No, All, NoToAll, YesToAll }

abstract class ModalResults
{
  static final _items = <TLocale, Map<TModalResult, String> >
  {
    TLocale.ENGLISH: {
      TModalResult.Ok:       'OK',
      TModalResult.Cancel:   'Cancel',
      TModalResult.Abort:    'Abort',
      TModalResult.Retry:    'Retry',
      TModalResult.Ignore:   'Ignore',
      TModalResult.Yes:      'Yes',
      TModalResult.No:       'No',
      TModalResult.All:      'All',
      TModalResult.NoToAll:  'No to all',
      TModalResult.YesToAll: 'Yes to all',
    },
    TLocale.RUSSIAN: {
      TModalResult.Ok:       'OK',
      TModalResult.Cancel:   'Отмена',
      TModalResult.Abort:    'Прервать',
      TModalResult.Retry:    'Повторить',
      TModalResult.Ignore:   'Пропустить',
      TModalResult.Yes:      'Да',
      TModalResult.No:       'Нет',
      TModalResult.All:      'Все',
      TModalResult.NoToAll:  'Нет для всех',
      TModalResult.YesToAll: 'Да для всех',
    },
  };

  static Map<TModalResult, String> GetNames([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<TModalResult, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String ResultToStr(TModalResult mr, [TLocale? locale]) =>
    TLocaleSet.ValueByIdent(ModalResults._items, mr, locale) ?? mr.toString();
}



class TCursor
{
  final int    _id;
  final String name;

  const TCursor._(this._id, this.name);
  const TCursor(String _name) : this._(0, _name);

  static const Default      = TCursor._(  0, 'default');
  static const None         = TCursor._( -1, 'none');
  static const Arrow        = TCursor._( -2, 'default');
  static const Cross        = TCursor._( -3, 'crosshair');
  static const IBeam        = TCursor._( -4, 'text');
  static const Size         = TCursor._( -5, 'move');
  static const SizeNESW     = TCursor._( -6, 'nesw-resize');
  static const SizeNS       = TCursor._( -7, 'n-resize');
  static const SizeNWSE     = TCursor._( -8, 'nwse-resize');
  static const SizeWE       = TCursor._( -9, 'w-resize');
  static const UpArrow      = TCursor._(-10, 'n-resize');   // *
  static const HourGlass    = TCursor._(-11, 'wait');
  static const Drag         = TCursor._(-12, 'grab');       // *
  static const NoDrag       = TCursor._(-13, 'no-drop');    // *
  static const HSplit       = TCursor._(-14, 'col-resize');
  static const VSplit       = TCursor._(-15, 'row-resize');
  static const MultiDrag    = TCursor._(-16, 'grabbing');   // *
  static const SQLWait      = TCursor._(-17, 'progress');   // *
  static const No           = TCursor._(-18, 'not-allowed');
  static const AppStart     = TCursor._(-19, 'progress');
  static const Help         = TCursor._(-20, 'help');
  static const HandPoint    = TCursor._(-21, 'pointer');
  static const SizeAll      = TCursor._(-22, 'move');

  static const Alias        = TCursor('alias');
  static const AllScroll    = TCursor('all-scroll');
  static const Auto         = TCursor('auto');
  static const Cell         = TCursor('cell');
  static const ColResize    = TCursor('col-resize');
  static const ContextMenu  = TCursor('context-menu');
  static const Copy         = TCursor('copy');
  static const CrossHair    = TCursor('crosshair');
  static const eResize      = TCursor('e-resize');
  static const ewResize     = TCursor('ew-resize');
  static const Grab         = TCursor('grab');
  static const Grabbing     = TCursor('grabbing');
  static const Inherit      = TCursor('inherit');
  static const Initial      = TCursor('initial');
  static const Move         = TCursor('move');
  static const nResize      = TCursor('n-resize');
  static const neResize     = TCursor('ne-resize');
  static const neswResize   = TCursor('nesw-resize');
  static const NoDrop       = TCursor('no-drop');
  static const NotAllowed   = TCursor('not-allowed');
  static const nsResize     = TCursor('ns-resize');
  static const nwResize     = TCursor('nw-resize');
  static const nwseResize   = TCursor('nwse-resize');
  static const Pointer      = TCursor('pointer');
  static const Progress     = TCursor('progress');
  static const Revert       = TCursor('revert');
  static const RowResize    = TCursor('row-resize');
  static const sResize      = TCursor('s-resize');
  static const seResize     = TCursor('se-resize');
  static const swResize     = TCursor('sw-resize');
  static const Text         = TCursor('text');
  static const Unset        = TCursor('unset');
  static const VerticalText = TCursor('vertical-text');
  static const vResize      = TCursor('v-resize');
  static const ZoomIn       = TCursor('zoom-in');
  static const ZoomOut      = TCursor('zoom-out');
}


enum TAlign { None, Top, Bottom, Left, Right, Client, Custom }


enum ControlStates { LButtonDown, Clicked, 
    ReadingState, AlignmentNeeded, Focusing, CustomPaint, DestroyingHandle, }

typedef TControlState = Set<ControlStates>;

enum ControlStyles { AcceptsControls, CaptureMouse,
    DesignInteractive, ClickEvents, Framed, SetCaption, Opaque,
    DoubleClicks, FixedWidth, FixedHeight, NoDesignVisible,
    Replicatable, NoStdEvents, DisplayDragImage, Reflector,
    ActionClient, MenuEvents }

typedef TControlStyle = Set<ControlStyles>;

enum TMouseButton { Left, Right, Middle}


enum TAnchorKind { Left, Top, Right, Bottom }

typedef TAnchors = Set<TAnchorKind>;



class TCreateParams
{
  String Caption = '';
  UINT Style = 0;
  UINT ExStyle = 0;
  HWND? WndParent;
  int? X;
  int? Y;
  int? Width;
  int? Height;
  dynamic Param;
  
}



class TAlignInfo
{
  var AlignList = <TControl>[];
  int ControlIndex = 0;
  var Align = TAlign.Left;
  int Scratch = 0;
}

  

enum TBevelCut { None, Lowered, Raised, Space }



TAnchors AnchorAlign(TAlign Value)
{
  switch(Value)
  {
    case TAlign.None:
      return TAnchors.from([TAnchorKind.Left, TAnchorKind.Top]);
    case TAlign.Top:
      return TAnchors.from([TAnchorKind.Left, TAnchorKind.Top, TAnchorKind.Right]);
    case TAlign.Bottom:
      return TAnchors.from([TAnchorKind.Left, TAnchorKind.Right, TAnchorKind.Bottom]);
    case TAlign.Left:
      return TAnchors.from([TAnchorKind.Left, TAnchorKind.Top, TAnchorKind.Bottom]);
    case TAlign.Right:
      return TAnchors.from([TAnchorKind.Right, TAnchorKind.Top, TAnchorKind.Bottom]);
    case TAlign.Client:
      return TAnchors.from([TAnchorKind.Left, TAnchorKind.Top, TAnchorKind.Right, TAnchorKind.Bottom]);
    default:
      return TAnchors.from([TAnchorKind.Left, TAnchorKind.Top]);
  }
}


// Find a TWinControl given a window handle
// The global atom table is trashed when the user logs off.  The extra test
//  below protects UI interactive services after the user logs off.
TWinControl? FindElementControl(Element? elem)
{
  if(elem == null)
    return null;
  dynamic Result = Windows.SendElementMessage(elem, CM_GETINSTANCE);
  if(Result is TWinControl)
    return Result;
  return null;
}

TWinControl? FindControl(HWND? hwnd)
{
  if(hwnd==null)
    return null;

  dynamic Result = Windows.SendMessage(hwnd, CM_GETINSTANCE);
  if(Result is TWinControl)
    return Result;
  return null;

}


String GetShortHint(String hint)
{
  int i = hint.indexOf('|');
  if(i==-1)
    return hint;
  return hint.substring(0, i);
}

String GetLongHint(String hint)
{
  int i = hint.indexOf('|');
  if(i == -1)
    return hint;
  return hint.substring(i+1);
}

// Mouse capture management

TControl? _captureControl;
TControl? get CaptureControl => _captureControl;

TControl? GetCaptureControl()
{
  TControl? Result = FindControl(Windows.GetCapture());
  if((Result != null) && (CaptureControl != null) && (CaptureControl!.Parent == Result))
    return CaptureControl;
  return Result;
}

void SetCaptureControl(TControl? Control)
{
  Windows.ReleaseCapture();
  _captureControl = null;
  if(Control != null)
  {
    if(!(Control is TWinControl))
    {
      if(Control.Parent == null)
        return;
      _captureControl = Control;
      Control = Control.Parent;
    }
    Windows.SetCapture((Control as TWinControl).Handle);
  }
}


TWinControl? FindVCLWindow(TPoint Pos)
{
  var Handle = Windows.WindowFromPoint(Pos);
  TWinControl? Result;
  while(Handle != null)
  {
    Result = FindControl(Handle);
    if(Result != null)
      return Result;
    Handle = Windows.GetParent(Handle);
  }
  return Result;
}

TControl? FindDragTarget(TPoint Pos, bool AllowDisabled)
{
  TWinControl? Window = FindVCLWindow(Pos);
  if(Window != null)
  {
    TControl? Result = Window;
    TControl? Control = Window.ControlAtPos(Window.ScreenToClient(Pos), AllowDisabled);
    if(Control != null)
      Result = Control;
    return Result;
  }
  return null;
}



// TControlCanvas

class TControlCanvas extends TCanvas
{
  final TControl Control;
///  CanvasRenderingContext2D _deviceContext;


  TControlCanvas(this.Control);

  void CreateHandle()
  {

  }



static void FreeDeviceContexts()
{

}


}

class TSizeConstraints extends TPersistent
{
  TControl _control;
  TControl get Control => _control;

  int _maxHeight = 0;
  int _maxWidth = 0;
  int _minHeight = 0;
  int _minWidth = 0;

  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;

  int
    get MaxHeight => _maxHeight;
    set MaxHeight(int Value)
    {
      if(Value<0 || Value == _maxHeight)
        return;
      _maxHeight = Value;
      if(Value > 0 && Value < MinHeight)
        _minHeight = Value;
      Change();
    }

  int
    get MaxWidth => _maxWidth;
    set MaxWidth(int Value)
    {
      if(Value<0 || Value == MaxWidth)
        return;
      _maxWidth = Value;
      if(Value > 0 && Value < MinWidth)
        _minWidth = Value;
      Change();
    }

  int
    get MinHeight => _minHeight;
    set MinHeight(int Value)
    {
      if(Value<0 || Value == MinHeight)
        return;
      _minHeight = Value;
      if(MaxHeight > 0 && Value > MaxHeight)
        _maxHeight = Value;
      Change();
    }

    int
      get MinWidth => _minWidth;
      set MinWidth(int Value)
      {
        if(Value<0 || Value == MinWidth)
          return;
        _minWidth = Value;
        if(MaxWidth > 0 && Value > MaxWidth)
          _maxWidth = Value;
        Change();
      }

  TSizeConstraints(this._control) : super();

  void AssignTo(TPersistent Dest)
  {
    if(Dest is TSizeConstraints)
    {
      Dest._minHeight = _minHeight;
      Dest._maxHeight = _maxHeight;
      Dest._minWidth = _minWidth;
      Dest._maxWidth = _maxWidth;
      Dest.Change();
    }
    else
      super.AssignTo(Dest);
  }

  void Change()
  {
    if(_onChange != null)
      _onChange!(this);
  }
}



class TControlActionLink extends TActionLink
{


  static TClass get classType => TClass( TControlActionLink, (AOwner) => TControlActionLink(AOwner) );

  TControl? _client;

  TControlActionLink(TObject AClient) : super(AClient);

  void AssignClient(TObject AClient)
  {
    _client = AClient as TControl;
  }

  bool DoShowHint(TPointer<String> HintStr)
  {
    bool Result = true;
    if(Action is TCustomAction)
    {
      if((Action as TCustomAction).DoHint(HintStr) && Application.HintShortCuts &&
        ((Action as TCustomAction).ShortCut != TShortCut.None) )
      {
        if(HintStr.Value.isNotEmpty)
          HintStr.Value = "Format('%s (%s)', [HintStr, ShortCutToText(TCustomAction(Action).ShortCut)])";
      }
    }
    return Result;
  }


}

class TControl extends TComponent
{
  TFlexControlParams? _flex;
  TFlexControlParams get Flex
  {
    if(_flex==null)
      _flex = TFlexControlParams(this);
    return _flex!;
  }

  TWinControl? _parent;
  TWinControl?
    get Parent => _parent;
    set Parent(TWinControl? Value) => SetParent(Value);

  TCustomForm? get ParentForm => GetParentForm(this); // new

  void SetParent(TWinControl? AParent)
  {
    if(_parent == AParent)
      return;

    if(AParent == this)
      throw EInvalidOperation.CreateRes(Consts.SControlParentSetToSelf);

    if(_parent != null)
      _parent!.RemoveControl(this);

    if(AParent != null)
    {
      AParent.InsertControl(this);
      UpdateAnchorRules();
    }


  }

  TWndMethod _windowProc = (message){}; // dummy
  TWndMethod
    get WindowProc => _windowProc;
    set WindowProc(TWndMethod value) => _windowProc = value;

  int _left = 0;
  int _top = 0;
  int _width = 0;
  int _height = 0;

  int get Height => _height;
  int get Left => _left;
  int get Top => _top;
  int get Width => _width;

  set Left(int Value)
  {
    SetBounds(Value, Top, Width, Height);

  }

  set Top(int Value)
  {
    SetBounds(Left, Value, Width, Height);

  }

  set Width(int Value)
  {
    SetBounds(Left, Top, Value, Height);

  }

  set Height(int Value)
  {
    SetBounds(Left, Top, Width, Value);

  }

  TRect get ClientRect => GetClientRect();

  TRect GetClientRect()
  {
    return TRect(0, 0, Width, Height);
  }

  int get ClientHeight => ClientRect.height;
  int get ClientWidth => ClientRect.width;
  set ClientHeight(int Value) => SetClientSize(ClientWidth, Value);
  set ClientWidth(int Value) => SetClientSize(Value, ClientHeight);

  void SetClientSize(int cx, int cy)
  {
    TRect rect=GetClientRect();
    SetBounds(Left, Top, Width - rect.right + cx, Height - rect.bottom + cy);

  }

  bool
    get MouseCapture => GetCaptureControl() == this;
    set MouseCapture(bool Value)
    {
      if(MouseCapture != Value)
        SetCaptureControl(Value? this : null);
    }

  TControlStyle _controlStyle = TControlStyle();
  TControlStyle get ControlStyle => _controlStyle;

  TControlState _controlState = TControlState();
  TControlState get ControlState => _controlState; 
  /*FDesktopFont: Boolean;*/

  bool _visible = true;
  bool get Visible => _visible;
  set Visible(bool Value)
  {
    if(_visible == Value)
      return;

    VisibleChanging();
    _visible = Value;
    Perform(CM_VISIBLECHANGED, Value, 0);
    RequestAlign();
  }

  bool _enabled = true;
  bool get Enabled => GetEnabled();
  bool GetEnabled()
  {
    return _enabled;
  }

  set Enabled(bool Value) => SetEnabled(Value);
  void SetEnabled(bool Value)
  {
    if(_enabled == Value)
      return;

    _enabled = Value;
    Perform(CM_ENABLEDCHANGED);

  }


  bool _parentFont=true;
  bool get ParentFont => _parentFont;
  void set ParentFont(bool Value)
  {
    if(_parentFont == Value)
      return;
    _parentFont = Value;
    if((_parent != null) && !ComponentState.contains(ComponentStates.Reading))
      Perform(CM_PARENTFONTCHANGED, 0, 0);
  }

  TAlign _align = TAlign.None;
  TAlign get Align => _align;

  set Align(TAlign Value)
  {
    if(_align != Value)
    {
      TAlign OldAlign = _align;
      _align = Value;
      Anchors = AnchorAlign(Value);
      if(! ComponentState.contains(ComponentStates.Loading) && (!ComponentState.contains(ComponentStates.Designing) ||
        (Parent != null)) && (Value != TAlign.Custom) && (OldAlign != TAlign.Custom))
          if(([TAlign.Top,TAlign.Bottom].contains(OldAlign) == [TAlign.Right, TAlign.Left].contains(Value)) &&
            ![TAlign.None, TAlign.Client].contains(OldAlign) && ![TAlign.None, TAlign.Client].contains(Value))
            SetBounds(Left, Top, Height, Width);
          else
           AdjustSize();
    }
    RequestAlign();
  }

  bool _autoSize = false;
  bool get AutoSize => _autoSize;
  set AutoSize(bool Value) => SetAutoSize(Value);

  void SetAutoSize(bool Value)
  {
    if(_autoSize != Value)
    {
      _autoSize = Value;
      if(Value)
        AdjustSize();
    }
  }

  

  final _anchors = TAnchors.from({ TAnchorKind.Left, TAnchorKind.Top });
  TAnchors
    get Anchors => _anchors;
    set Anchors(TAnchors Value) 
    {
      if(Anchors.isEqual(Value))
        return;
      _anchors.assign(Value);
      UpdateAnchorRules();
    }

  bool _anchorMove = false;



  // property Caption: TCaption read GetText write SetText stored IsCaptionStored;
  String
    get _caption => _getText();
    set _caption(String val) => _setText(val);

  String _text="";
  String
    get WindowText => _text;
    set WindowText(String value) => _text = value;

  String _getText()
  {
    return Perform(WM_GETTEXT);

  }

  void _setText(String AText)
  {
    Perform(WM_SETTEXT, null, AText);
    Perform(CM_TEXTCHANGED);

  }

  TFont _font = TFont();
  TFont get Font => _font;
  void set Font(TFont Value) => _font.Assign(Value);

  TControlActionLink? _actionLink;
  TControlActionLink?
    get ActionLink => _actionLink;
    set ActionLink(TControlActionLink? value) => _actionLink = value;

  TColor _color = clWindow;
  TColor get Color => _color;
  set Color(TColor Value)
  {
    if(_color == Value)
      return;
    _color = Value;
    _parentColor = false;
    Perform(CM_COLORCHANGED);
  }

  TSizeConstraints? _constraints;
  TSizeConstraints get Constraints => _constraints!;
  void set Constraints(TSizeConstraints Value) => _constraints=Value;



  String _hint = "";
  String get Hint => _hint;
  set Hint(String Value)
  {
    if(_hint == Value)
      return;
    _hint = Value;


  }


  TPoint _anchorRules = TPoint(0, 0);
  TPoint _originalParentSize = TPoint(0, 0);


  bool _showHint = false;
  bool get ShowHint => _showHint;
  set ShowHint(bool Value) => SetShowHint(Value);

  void SetShowHint(bool Value)
  {
    if(_showHint == Value)
      return;
    _showHint = Value;
    _parentShowHint = false;
    Perform(CM_SHOWHINTCHANGED);
  }


  TWinControl? _hostDockSite;
  TWinControl?
    get HostDockSite => _hostDockSite;
    set HostDockSite(TWinControl? Value) =>
      Dock(Value, BoundsRect);

  int _wheelAccumulator = 0;
  int get WheelAccumulator => _wheelAccumulator;
  void set WheelAccumulator(int Value) => _wheelAccumulator = Value;

    
  TCanResizeEvent? _onCanResize;
  TCanResizeEvent?
    get OnCanResize => _onCanResize;
    set OnCanResize(TCanResizeEvent? Value) => _onCanResize=Value;


  TMouseEvent? _onMouseDown;
  TMouseEvent?
    get OnMouseDown => _onMouseDown;
    set OnMouseDown(TMouseEvent? Value) => _onMouseDown=Value;

  TMouseMoveEvent? _onMouseMove;
  TMouseMoveEvent?
    get OnMouseMove => _onMouseMove;
    set OnMouseMove(TMouseMoveEvent? Value) => _onMouseMove=Value;

  TMouseEvent? _onMouseUp;
  TMouseEvent?
    get OnMouseUp => _onMouseUp;
    set OnMouseUp(TMouseEvent? Value) => _onMouseUp=Value;


  TNotifyEvent? _onClick;
  TNotifyEvent?
    get OnClick => _onClick;
    set OnClick(TNotifyEvent? Value) => _onClick = Value;

  void Click()
  {
    // Call OnClick if assigned and not equal to associated action's OnExecute.
    //  If associated action's OnExecute assigned then call it, otherwise, call
    //  OnClick.
    if((OnClick!=null) && (Action != null) && (_onClick != Action!.OnExecute))
      OnClick!(this);
    else
    if(!(ComponentState.contains(ComponentStates.Designing)) && (ActionLink != null))
      ActionLink!.Execute(this);
    else
    if(OnClick != null)
      OnClick!(this);
  }

  TNotifyEvent? _onDblClick;
  TNotifyEvent?
    get OnDblClick => _onDblClick;
    set OnDblClick(TNotifyEvent? Value) => _onDblClick = Value;

    

  TControl(TComponent? AOwner) : super(AOwner)
  {

    _windowProc = WndProc;
    ControlStyle.assign([ ControlStyles.CaptureMouse, ControlStyles.ClickEvents,
                          ControlStyles.SetCaption, ControlStyles.DoubleClicks ]);
    _font.OnChange = FontChanged;

    _constraints = TSizeConstraints(this);
    _constraints!.OnChange = (Sender) => DoConstraintsChange(Sender); 
    Enabled = true;
  
  }

  void Destroy()
  {
    Parent = null;
    super.Destroy();
  }



  TBasicAction? get Action => GetAction();

  TBasicAction? GetAction() // virtual
  {
    return ActionLink == null? null : ActionLink!.Action;
  }

  void set Action(TBasicAction? Value)
  {
    if(Value == null)
    {
      ActionLink!.Free();
      ActionLink = null;
      _controlStyle >> ControlStyles.ActionClient;
    }
    else
    {
      _controlStyle << ControlStyles.ActionClient;
      if(ActionLink == null)
        ActionLink = GetActionLinkClass().Create(this);
      ActionLink!.Action = Value;
      ActionLink!.OnChange = (Sender) // DoActionChange;
      {
        if(Sender == Action)
          ActionChange(Sender, false);
      };

      ActionChange(Value, Value.ComponentState.contains(ComponentStates.Loading));
      Value.FreeNotification(this);
    }
  }

  bool IsAnchorsStored()
  {
    return !Anchors.isEqual(AnchorAlign(Align));
  }



  void RequestAlign()
  {
    if(Parent != null)
      Parent!.AlignControl(this);
  }

  void Resize()
  {


  }


  void MoveTo(int ALeft, int ATop) => SetBounds(ALeft, ATop, Width, Height); // new
  void SetSize(int AWidth, int AHeight) => SetBounds(Left, Top, AWidth, AHeight); // new

  void SetBounds(int? ALeft, int? ATop, int? AWidth, int? AHeight)
  {
    if(ALeft == null)    ALeft=_left;
    if(ATop == null)     ATop=_top;

    Integer W = Integer(AWidth==null? _width : AWidth);
    Integer H = Integer(AHeight==null? _height : AHeight);

    if(CheckNewSize(W, H) &&
        ((ALeft != _left) || (ATop != _top) ||
        (W.Value != _width) || (H.Value != _height)))
    {
      InvalidateControl(Visible, false);
      _left = ALeft;
      _top = ATop;
      _width = W.Value;
      _height = H.Value;
      UpdateAnchorRules();
      Invalidate();
      Perform(WM_WINDOWPOSCHANGED, null, null);
      RequestAlign();
      if(!ComponentState.contains(ComponentStates.Loading))
        Resize();
    }
  }

  void UpdateAnchorRules()
  {
    if(!_anchorMove && ! ComponentState.contains(ComponentStates.Loading))
    {
      TAnchors Anchors = TAnchors();
      Anchors.assign(_anchors);

      if(Anchors.isEqual([TAnchorKind.Left, TAnchorKind.Top]))
      {
        _originalParentSize.x = 0;
        _originalParentSize.y = 0;
        return;
      }
      if(Anchors.contains(TAnchorKind.Right))
         _anchorRules.x = Anchors.contains(TAnchorKind.Left)? Width : Left;
      else
         _anchorRules.x = Left + (Width>>1);

      if(Anchors.contains(TAnchorKind.Bottom))
         _anchorRules.y = Anchors.contains(TAnchorKind.Top)? Height : Top;
      else
         _anchorRules.y = Top + (Height>>1);

      if(Parent != null)
      {
        if(Parent!.ComponentState.contains(ComponentStates.Reading))
        {
          
        }
        else
        if(Parent!.HandleAllocated())
          _originalParentSize = Parent!.ClientRect.BottomRight;
        else
        {
          _originalParentSize.x = Parent!.Width;
          _originalParentSize.y = Parent!.Height;
        }
      }
    }
  }

  void Dock(TWinControl? NewDockSite, TRect ARect)
  {
    
  }



  TRect get BoundsRect
  {
    return TRect(Left, Top, Left+Width, Top+Height);
  }

  void set BoundsRect(TRect Rect)
  {
    SetBounds(Rect.left, Rect.top, Rect.width, Rect.height);
  }

  TPoint get ClientOrigin => GetClientOrigin();
  TPoint GetClientOrigin()
  {
    if(Parent == null)
      throw EInvalidOperation.CreateFmt(Consts.SParentRequired, [Name]);

    TPoint Origin = Parent!.ClientOrigin;
    return TPoint(Origin.x+_left, Origin.y+_top);
  }

  TPoint ClientToScreen(TPoint point)
  {
    TPoint origin = ClientOrigin;
    return TPoint(point.x + origin.x, point.y + origin.y);
  }

  TPoint ScreenToClient(TPoint point)
  {
    TPoint origin = ClientOrigin;
    return TPoint(point.x - origin.x, point.y - origin.y);
  }

  void SendCancelMode(TControl Sender)
  {
    TControl? Control = this;
    while(Control != null)
    {
      if(Control is TCustomForm)
        Control.SendCancelMode(Sender);
      Control = Control.Parent;
    }
  }

  void SendDockNotification(MESSAGE Msg, dynamic WParam, dynamic LParam)
  {

  }

  void Changed()
  {
    Perform(CM_CHANGED, 0, this);
  }



  void SetTextBuf(String Buffer)
  {
    Perform(WM_SETTEXT, 0, Buffer);
    Perform(CM_TEXTCHANGED, 0, 0);
  }


  void FontChanged(TObject Sender)
  {
    _parentFont = false;

    Perform(CM_FONTCHANGED, 0, 0);
  }



  bool _parentShowHint = true;
  bool
    get ParentShowHint => _parentShowHint;
    set ParentShowHint(bool Value)
    {
      if(ParentShowHint == Value)
        return;
      _parentShowHint = Value;
      if((Parent != null) && !(ComponentState.contains(ComponentStates.Reading)))
        Perform(CM_PARENTSHOWHINTCHANGED, 0, 0);
    }



  bool _parentColor = true;
  bool get ParentColor => _parentColor;
  void set ParentColor(bool Value)
  {
    if(_parentColor == Value)
      return;
    _parentColor = Value;
    if(_parent != null && ComponentState.contains(ComponentStates.Reading))
      Perform(CM_PARENTCOLORCHANGED, 0, 0);
  }



  TCursor _cursor = TCursor.Default;
  TCursor
    get Cursor => _cursor;
    set Cursor(TCursor Value)
    {
      if(_cursor == Value)
        return;
      _cursor = Value;
      Perform(CM_CURSORCHANGED, 0, 0);
    }


  void BringToFront()
  {
    SetZOrder(true);
  }

  void SendToBack()
  {
    SetZOrder(false);
  }

  void SetZOrderPosition(int Position)
  {
    if(_parent != null)
    {
      int i = _parent!._controls.indexOf(this);
      if(i >= 0)
      {
        int Count = _parent!._controls.length;
        if(Position < 0)
          Position = 0;
        if(Position >= Count)
          Position = Count - 1;
        if(Position != i)
        {
          _parent!._controls.removeAt(i);
          _parent!._controls.insert(Position, this);
          InvalidateControl(Visible, true);

        }
      }
    }
  }

  void SetZOrder(bool TopMost)
  {
    if(_parent == null)
      return;
    if(TopMost)
      SetZOrderPosition(_parent!.ControlCount - 1);
    else
      SetZOrderPosition(0);
  }

  HDC? GetDeviceContext()
  {
    if(Parent == null)
      throw EInvalidOperation.CreateFmt(Consts.SParentRequired, [Name]);
    HDC? Result = Parent!.GetDeviceContext();

    return Result;
  }

  void InvalidateControl(bool IsVisible, bool IsOpaque)
  {

  }

  void Invalidate()
  {
    InvalidateControl(Visible, ControlStyle.contains(ControlStyles.Opaque));
  }

  void MouseWheelHandler(TMessage Message)
  {
    TCustomForm? Form = ParentForm;
    if((Form != null) && (Form != this))
      Form.MouseWheelHandler(Message);
    else
      Message.Result = Perform(CM_MOUSEWHEEL, Message.WParam, Message.LParam);
  }

  void Hide()
  {
    Visible = false;
  }

  void Show()
  {
    if(Parent != null)
      Parent!.ShowControl(this);
    if (!ComponentState.contains(ComponentStates.Designing) || !ControlStyle.contains(ControlStyles.NoDesignVisible))
      Visible = true;
  }

  void Update()
  {
    if(Parent != null)
      Parent!.Update();
  }

  void Refresh()
  {
    Repaint();
  }

  void Repaint()
  {

  }



  bool IsRightToLeft()
  {
    return false;

  }



  bool UseRightToLeftAlignment()
  {
    
    return false;
  }



  bool DoMouseWheel(TShiftState Shift, int WheelDelta, TPoint MousePos)
  {

    bool Result = false;

    if(Result)
      return true;

    _wheelAccumulator+=WheelDelta;
    while(_wheelAccumulator.abs() >= WHEEL_DELTA)
    {
      bool IsNeg = _wheelAccumulator < 0;
      _wheelAccumulator = _wheelAccumulator.abs() - WHEEL_DELTA;
      if(IsNeg)
      {
        if(_wheelAccumulator != 0)
          _wheelAccumulator = -_wheelAccumulator;
        Result = DoMouseWheelDown(Shift, MousePos);
      }
      else
        Result = DoMouseWheelUp(Shift, MousePos);
    }
    return Result;
  }

  bool DoMouseWheelDown(TShiftState Shift, TPoint MousePos)
  {
    bool Result = false;

    return Result;
  }

  bool DoMouseWheelUp(TShiftState Shift, TPoint MousePos)
  {
    bool Result = false;

    return Result;
  }



  void DoConstraintsChange(TObject Sender)
  {
    AdjustSize();
  }

  bool CanAutoSize(Integer NewWidth, Integer NewHeight)
  {
    return true;
  }

  bool CanResize(Integer NewWidth, Integer NewHeight)
  {
    var Result = TPointer(true);
    if(OnCanResize != null)
      OnCanResize!(this, NewWidth, NewHeight, Result);
    return Result.Value;
  }

  bool DoCanAutoSize(Integer NewWidth, Integer NewHeight)
  {
    if(Align != TAlign.Client)
    {
      Integer W = NewWidth.Copy();
      Integer H = NewHeight.Copy();
      bool Result = CanAutoSize(W, H);
      if([TAlign.None, TAlign.Left, TAlign.Right].contains(Align))
        NewWidth.Value = W.Value;
      if([TAlign.None, TAlign.Top, TAlign.Bottom].contains(Align))
        NewHeight.Value = H.Value;
      return Result;
    }
    return true;
  }

  bool DoCanResize(Integer NewWidth, Integer NewHeight)
  {
    bool Result = CanResize(NewWidth, NewHeight);
    if(Result == true)
      DoConstrainedResize(NewWidth, NewHeight);
    return Result;
  }

  void ConstrainedResize(Integer MinWidth, Integer MinHeight, Integer MaxWidth, Integer MaxHeight)
  {

  }

  TPoint CalcCursorPos()
  {
    var Result = TPoint.from(Windows.GetCursorPos());
    return ScreenToClient(Result);
  }



  void DoConstrainedResize(Integer NewWidth, Integer NewHeight)
  {
    Integer MinWidth = Integer(Constraints.MinWidth);
    Integer MinHeight = Integer(Constraints.MinHeight);
    Integer MaxWidth = Integer(Constraints.MaxWidth);
    Integer MaxHeight = Integer(Constraints.MaxHeight);

    // Allow override of constraints
    ConstrainedResize(MinWidth, MinHeight, MaxWidth, MaxHeight);
    if(MaxWidth.Value > 0 && NewWidth > MaxWidth)
      NewWidth.Value = MaxWidth.Value;
    else
    if(MinWidth.Value > 0 && NewWidth < MinWidth)
      NewWidth.Value = MinWidth.Value;
    if(MaxHeight.Value > 0 && NewHeight > MaxHeight)
      NewHeight.Value = MaxHeight.Value;
    else
    if(MinHeight.Value > 0 && NewHeight < MinHeight)
      NewHeight.Value = MinHeight.Value;
  }

  // ignore: avoid_init_to_null
  dynamic Perform(MESSAGE msg, [ dynamic wParam = null, dynamic lParam = null, dynamic result=0 ])
  {
    TMessage Message = TMessage(msg);
    Message.WParam=wParam;
    Message.LParam=lParam;
    Message.Result=result;
    WindowProc(Message);
    return Message.Result;
  }




  void UpdateBoundsRect(TRect R)
  {
    _left = R.left;
    _top = R.top;
    _width = R.width;
    _height = R.height;
    UpdateAnchorRules();
  }

  void VisibleChanging()
  {

  }

  TScroll get ScrollArea => GetScrollArea();
  TScroll GetScrollArea() => TScroll(); 


  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case CM_COLORCHANGED:          _cmColorChanged(Message); break;
      case CM_ENABLEDCHANGED:        _cmEnabledChanged(Message); break;
      case CM_FONTCHANGED:           _cmFontChanged(Message); break;
      case CM_GETVALUE:              _cmGetValue(Message); break;

      case CM_HINTSHOW:              _cmHintShow(Message); break;
      case CM_HITTEST:               _cmHitTest(Message); break;
      case CM_MOUSEENTER:            _cmMouseEnter(Message); break;
      case CM_MOUSELEAVE:            _cmMouseLeave(Message); break;
      case CM_MOUSEWHEEL:            _cmMouseWheel(TWMMouseWheel(Message)); break;
      case CM_PARENTFONTCHANGED:     _cmParentFontChanged(Message); break;
      case CM_PARENTCOLORCHANGED:    _cmParentColorChanged(Message); break;
      case CM_PARENTSHOWHINTCHANGED: _cmParentShowHintChanged(Message); break;
      case CM_TEXTCHANGED:           _cmTextChanged(Message); break;

      case CM_SETVALUE:              _cmSetValue(Message); break;
      case CM_VISIBLECHANGED:        _cmVisibleChanged(Message); break;

      case WM_COMMAND:               _wmCommand(TWMCommand(Message)); break;
      case WM_LBUTTONDOWN:           _wmLButtonDown(TWMMouse(Message)); break;
      case WM_LBUTTONUP:             _wmLButtonUp(TWMMouse(Message)); break;
      case WM_LBUTTONDBLCLK:         _wmLButtonDblClick(TWMMouse(Message)); break;
      case WM_MOVE:                  _wmMove(TWMMove(Message)); break;
      case WM_MOUSEMOVE:             _wmMouseMove(TWMMouse(Message)); break;
      case WM_RBUTTONUP:             _wmRButtonUp(TWMMouse(Message)); break;
      case WM_SETFONT:               _wmSetFont(Message); break;
      case WM_SIZE:                  _wmSize(TWMSize(Message)); break;
      case WM_WINDOWPOSCHANGING:     _wmWindowPosChanging(TWMWindowPosMsg(Message)); break;
      case WM_WINDOWPOSCHANGED:      _wmWindowPosChanged(TWMWindowPosMsg(Message)); break;
      case WM_MOUSEWHEEL:            _wmMouseWheel(TWMMouseWheel(Message)); break;


      default:
        super.Dispatch(Message);
        break;
    }
  }

  void WndProc(TMessage Message) // TControl::WndProc
  {

    TCustomForm? Form;
    if(ComponentState.contains(ComponentStates.Designing))
    {
      Form = GetParentForm(this);
      if((Form != null) )
          return;
    }
    if((Message.Msg >= WM_KEYFIRST) && (Message.Msg <= WM_KEYLAST))
    {
      Form = GetParentForm(this);
      if((Form != null) && Form.WantChildKey(this, Message))
        return;
    }
    else
    if((Message.Msg >= WM_MOUSEFIRST) && (Message.Msg <= WM_MOUSELAST))
    {
      if(!ControlStyle.contains(ControlStyles.DoubleClicks))
      {
        switch(Message.Msg)
        {
          case WM_LBUTTONDBLCLK: Message.Msg = WM_LBUTTONDOWN; break;
          case WM_RBUTTONDBLCLK: Message.Msg = WM_RBUTTONDOWN; break;
          case WM_MBUTTONDBLCLK: Message.Msg = WM_MBUTTONDOWN; break;
        }
      }

      switch(Message.Msg)
      {
        case WM_MOUSEMOVE:
          Application.HintMouseMessage(this, Message);
          break;

        case WM_LBUTTONDOWN:
        case WM_LBUTTONDBLCLK:

          _controlState << ControlStates.LButtonDown;
          break;

        case WM_LBUTTONUP:
          _controlState >> ControlStates.LButtonDown;
          break;

        default:

          break;
      }
    }
    else
    if(Message.Msg == CM_VISIBLECHANGED)
      SendDockNotification(Message.Msg, Message.WParam, Message.LParam);
    Dispatch(Message);
  }

  void DefaultHandler(TMessage Message)
  {

    switch(Message.Msg)
    {
      case WM_GETTEXT:
        Message.Result = _text;

        break;

     case WM_SETTEXT:
       _text = Message.LParam;

          SendDockNotification(Message.Msg, Message.WParam, Message.LParam);
        break;

    }
  }



  void DblClick()
  {
    if(_onDblClick!=null)
      _onDblClick!(this);
  }


  void MouseDown(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    if(_onMouseDown!=null)
      _onMouseDown!(this, Button, Shift, X, Y);
  }

  void DoMouseDown(TWMMouse Message, TMouseButton Button, TShiftState Shift)
  {
    if(!ControlStyle.contains(ControlStyles.NoStdEvents))
      if(Width > 32768 || Height > 32768)
      {
        TPoint pt = CalcCursorPos();
        MouseDown(Button, Shift, pt.x, pt.y);
      }
      else
        MouseDown(Button, Shift, Message.XPos, Message.YPos);
  }



  bool CheckNewSize(Integer NewWidth,  Integer NewHeight)
  {
    Integer W = NewWidth.Copy();
    Integer H = NewHeight.Copy();
    if(DoCanResize(W, H))
    {
      Integer W2 = W.Copy();
      Integer H2 = H.Copy();
      bool Result = !AutoSize || (DoCanAutoSize(W2, H2) && (W2 == W) && (H2 == H)) || DoCanResize(W2, H2);
      if(Result)
      {
        NewWidth.Value = W2.Value;
        NewHeight.Value = H2.Value;
      }
      return Result;
    }
    return false;
  }


  void MouseMove(TShiftState Shift, int X, int Y)
  {
    if(_onMouseMove!=null)
      _onMouseMove!(this, Shift, X, Y);
  }

  void MouseUp(TMouseButton Button, TShiftState Shift, int X, int Y)
  {
    if(_onMouseUp!=null)
      _onMouseUp!(this, Button, Shift, X, Y);
  }

  void DoMouseUp(TWMMouse Message, TMouseButton Button)
  {
    if(!ControlStyle.contains(ControlStyles.NoStdEvents))
      MouseUp(Button, Message.Shift, Message.XPos, Message.YPos);
  }

  void _wmMouseMove(TWMMouse Message)
  {
    super.Dispatch(Message.handle);
    if(!ControlStyle.contains(ControlStyles.NoStdEvents))
      if(Width > 32768 || Height > 32768)
      {
        TPoint pt=CalcCursorPos();
        MouseMove(Message.Shift, pt.x, pt.y);
      }
      else
        MouseMove(Message.Shift, Message.XPos, Message.YPos);
  }

  void _wmLButtonDown(TWMMouse Message)
  {
    SendCancelMode(this);
    super.Dispatch(Message.handle);
    if(ControlStyle.contains(ControlStyles.CaptureMouse))
      MouseCapture = true;
    if(ControlStyle.contains(ControlStyles.ClickEvents))
      ControlState<<ControlStates.Clicked;
    DoMouseDown(Message, TMouseButton.Left, TShiftState());
  }

  void _wmLButtonUp(TWMMouse Message)
  {
    super.Dispatch(Message.handle);
    if(ControlStyle.contains(ControlStyles.CaptureMouse))
      MouseCapture = false;
    if(ControlState.contains(ControlStates.Clicked))
    {
      ControlState>>ControlStates.Clicked;
      if(PtInRect(ClientRect, Message.Pos))
        Click();
    }
    DoMouseUp(Message, TMouseButton.Left);
  }

  void _wmLButtonDblClick(TWMMouse Message)
  {
    if(!Enabled)
       return;
    SendCancelMode(this);
    super.Dispatch(Message.handle);
    if(ControlStyle.contains(ControlStyles.CaptureMouse))
      MouseCapture = true;
    if(ControlStyle.contains(ControlStyles.ClickEvents))
      DblClick();
    DoMouseDown(Message, TMouseButton.Left, TShiftState.from( [ShiftStates.Double] ));
  }

  void _wmRButtonUp(TWMMouse Message)
  {
    super.Dispatch(Message.handle);
    DoMouseUp(Message, TMouseButton.Right);
  }



  void ActionChange(TObject Sender, bool CheckDefaults)
  {
    if(Sender is TCustomAction)
    {
      if(!CheckDefaults || _caption.isEmpty || (_caption == Name))
        _caption = Sender.Caption;
      if(!CheckDefaults || (Enabled == true))
        Enabled = Sender.Enabled;
      if(!CheckDefaults || Hint.isEmpty)
        Hint = Sender.Hint;
      if(!CheckDefaults || (Visible == true))
        Visible = Sender.Visible;
      if(!CheckDefaults || (OnClick!=null))
        OnClick = Sender.OnExecute;
    }
  }

  TMetaClass GetActionLinkClass()
  {
    return TControlActionLink.classType; 
  }



  void AdjustSize()
  {
    if(!ComponentState.contains(ComponentStates.Loading))
      SetBounds(Left, Top, Width, Height);
  }



  void InitiateAction()
  {
    if(ActionLink != null)
      ActionLink!.Update();
  }



  ///  C O N T R O L   M E S S A G E S ///

  void _cmColorChanged(TMessage Message)
  {
    Invalidate();
  }

  void _cmEnabledChanged(TMessage Message)
  {
    Invalidate();
  }

  void _cmFontChanged(TMessage Message)
  {

  }



  void _cmGetValue(TMessage Message)
  {

    Message.Result = Perform(WM_GETTEXT);
  }

  void _cmHintShow(TMessage Message)
  {
    if(ActionLink != null)
    {
      THintInfo info = Message.LParam;
      var pHintStr = TPointer<String>(info.HintStr);
      Message.Result = ActionLink!.DoShowHint(pHintStr)? 0 : 1;
      info.HintStr = pHintStr.Value;
    }
  }

  void _cmHitTest(TMessage Message) 
  {
    Message.Result = Windows.HTCLIENT;
  }

  void _cmParentColorChanged(TMessage Message)
  {
    if(_parentColor)
    {
      if(Message.WParam != 0)
        Color = Message.LParam;
      else
        Color=_parent!._color;
      _parentColor = true;
    }
  }

  void _cmParentShowHintChanged(TMessage Message)
  {
    if(ParentShowHint)
    {
      SetShowHint(Parent!.ShowHint);
      _parentShowHint = true;
    }
  }


  void _cmParentFontChanged(TMessage Message)
  {
    if(_parentFont==false)
      return;
    
    _parentFont = true;
  }

  void _cmSetValue(TMessage Message)
  {

    Perform(WM_SETTEXT, null, Message.LParam==null? '' : '${ Message.LParam }');
  }

  void _cmTextChanged(TMessage Message)
  {
  }
  
  void _cmMouseWheel(TWMMouseWheel Message)
  {
    if(DoMouseWheel(Message.ShiftState, Message.WheelDelta, Message.Pos))
      Message.Result = 1;
    else
    if(Parent != null)
      Message.Result = Parent!.Perform(CM_MOUSEWHEEL, Message.WParam, Message.LParam);
  }

  void _cmMouseEnter(TMessage Message)
  {
    if(_parent != null)
      _parent!.Perform(CM_MOUSEENTER, 0, this);
  }

  void _cmMouseLeave(TMessage Message)
  {
    if(_parent != null)
      _parent!.Perform(CM_MOUSELEAVE, 0, this);
  }

  void _cmVisibleChanged(TMessage Message)
  {
    if(!ComponentState.contains(ComponentStates.Designing) ||
        (ControlStyle.contains(ControlStyles.NoDesignVisible)))
    {
      InvalidateControl(true, Visible && (ControlStyle.contains(ControlStyles.Opaque)));
    }
  }

  ///  W I N D O W   M E S S A G E S ///

  void _wmCommand(TWMCommand Message)
  {
    if(!TWinControl.DoControlMsg(Message.Ctl, Message.handle))
      super.Dispatch(Message.handle);
  }

  void _wmMove(TWMMove Message)
  {
    super.Dispatch(Message.handle);
  }


  void _wmMouseWheel(TWMMouseWheel Message)
  {


    MouseWheelHandler(Message.handle);
    if(Message.Result == null)
      super.Dispatch(Message.handle);
  }

  void _wmSetFont(TMessage Message)
  {
  }

  void _wmSize(TWMSize Message)
  {
    super.Dispatch(Message.handle);
  }

  void _wmWindowPosChanging(TWMWindowPosMsg Message)
  {
    super.Dispatch(Message.handle);
  }

  void _wmWindowPosChanged(TWMWindowPosMsg Message)
  {
    super.Dispatch(Message.handle);
    // Update min/max width/height to actual extents control will allow
    if((ComponentState * [ComponentStates.Reading, ComponentStates.Loading]).isEmpty)
    {
      if((Constraints.MaxWidth > 0) && (Width > Constraints.MaxWidth))
        Constraints._maxWidth = Width;
      else
      if((Constraints.MinWidth > 0) && (Width < Constraints.MinWidth))
        Constraints._minWidth = Width;
      if((Constraints.MaxHeight > 0) && (Height > Constraints.MaxHeight))
        Constraints._maxHeight = Height;
      else
      if((Constraints.MinHeight > 0) && (Height < Constraints.MinHeight))
        Constraints._minHeight = Height;

    }
  }
}

///  TWinControlActionLinkClass = class of TWinControlActionLink;

class TWinControlActionLink extends TControlActionLink
{


  TWinControlActionLink(TComponent AOwner) : super(AOwner);

  
}

class _controlsIterator extends Iterator<TControl>
{
  int   ndx = -1;
  final TWinControl ctrl;

  _controlsIterator(this.ctrl);

  @override
  TControl get current => ctrl._getControl(ndx);

  @override
  bool moveNext() => ++ndx<(ctrl._controls.length + ctrl._winControls.length);
}


class TWinControl extends TControl
{

  int _alignLevel = 0;
  int get AlignLevel => _alignLevel; // temp

  HWND? _handle;
  HWND get Handle
  {
    HandleNeeded();
    return _handle!;
  }

  HWND?
    get WindowHandle => _handle;
    set WindowHandle(HWND? h) => _handle = h;




  HWND? _parentWindow;
  HWND?
    get ParentWindow => _parentWindow;
    set ParentWindow(HWND? Value)
    {
      if(_parent == null && _parentWindow != Value)
      {
        if(_handle != null && _parentWindow != null && Value != null)
        {
          _parentWindow = Value;
          _handle!.setParent(Value);
          
        }
        else
        {
          DestroyHandle();
          _parentWindow = Value;
        }
        UpdateControlState();
      }
    }

  final _tabList = <TWinControl>[];

  final _controls = <TControl>[];
  int get ControlCount => _controls.length + _winControls.length;

  late final TItems<TControl> Controls;

  TControl _getControl(int ndx)
  {
    if(ndx < _controls.length)
      return _controls[ndx];
    return _winControls[ndx - _controls.length];
  }


  final _winControls = <TWinControl>[];

  int _tabOrder = -1;
  int get TabOrder {
    if(Parent != null)
      return Parent!._tabList.indexOf(this);
    return -1;
  }

  set TabOrder(int Value) {

    UpdateTabOrder(Value);
  }

  void UpdateTabOrder(int Value)
  {
    int CurIndex = TabOrder;
    if(CurIndex >= 0)
    {
      int Count = Parent!._tabList.length;
      if(Value < 0)
        Value = 0;
      if(Value >= Count)
        Value = Count - 1;
      if(Value != CurIndex)
      {
        Parent!._tabList.removeAt(CurIndex);
        Parent!._tabList.insert(Value, this);
      }
    }
  }

  bool _tabStop = false;
  bool get TabStop => _tabStop;
  void set TabStop(bool Value) {
    if(_tabStop == Value)
      return;
    _tabStop = Value;
    if(HandleAllocated())
    {

    }
    Perform(CM_TABSTOPCHANGED, 0, 0);
  }

  bool _ctl3D = false;
  bool get Ctl3D => _ctl3D;
  void set Ctl3D(bool Value)
  {
    if(_ctl3D == Value)
        return;
    _ctl3D = Value;
    _parentCtl3D = false;
    Perform(CM_CTL3DCHANGED, 0, 0);
  }

  bool _showing = false;
  bool get Showing => _showing;
    

  bool _parentCtl3D = true;
  bool get ParentCtl3D => _parentCtl3D;
  void SetParentCtl3D(bool Value)
  {
    if(_parentCtl3D == Value)
      return;
    _parentCtl3D = Value;
    if((_parent != null) && !ComponentState.contains(ComponentStates.Reading))
      Perform(CM_PARENTCTL3DCHANGED, 0, 0);
  }


  TNotifyEvent? _onEnter;
  TNotifyEvent?
    get OnEnter => _onEnter;
    set OnEnter(TNotifyEvent? Value) => _onEnter = Value;

  TNotifyEvent? _onExit;
  TNotifyEvent?
    get OnExit => _onExit;
    set OnExit(TNotifyEvent? Value) => _onExit = Value;

  TKeyEvent? _onKeyDown;
  TKeyEvent?
    get OnKeyDown => _onKeyDown;
    set OnKeyDown(TKeyEvent? Value) => _onKeyDown = Value;

  TKeyPressEvent? _onKeyPress;
  TKeyPressEvent?
    get OnKeyPress => _onKeyPress;
    set OnKeyPress(TKeyPressEvent? Value) => _onKeyPress = Value;

  TKeyEvent? _onKeyUp;
  TKeyEvent?
    get OnKeyUp => _onKeyUp;
    set OnKeyUp(TKeyEvent? Value) => _onKeyUp = Value;

    

    bool _doubleBuffered = false;
    bool get DoubleBuffered => _doubleBuffered;
    void set DoubleBuffered(bool Value) => _doubleBuffered = Value;


  TWinControl(TComponent? AOwner) : super(AOwner)
  {
    Controls = TItems<TControl>(
      _getControl,
      () => _controlsIterator(this) );
  
 }

  void Destroy()
  {
    if(_handle != null)
    {
      _handle!.handle.remove();
      _handle = null;
    }
    super.Destroy();
  }




  void AdjustClientRect(TRect Rect)
  {
    
  }

  void AlignControls(TControl? AControl, TRect Rect)
  {
    List<TControl> AlignList = <TControl>[];


    bool InsertBefore(TControl C1, TControl C2, TAlign AAlign)
    {
      switch(AAlign)
      {
        case TAlign.Top:
          return C1.Top < C2.Top;
        case TAlign.Bottom:
          return (C1.Top + C1.Height) >= (C2.Top + C2.Height);
        case TAlign.Left:
          return C1.Left < C2.Left;
        case TAlign.Right:
          return (C1.Left + C1.Width) >= (C2.Left + C2.Width);
        case TAlign.Custom:
          return CustomAlignInsertBefore(C1, C2);
        default:
          return false;
      }
    }

    void DoPosition(TControl Control, TAlign AAlign, TAlignInfo AlignInfo)
    {

      int NewLeft=0, NewTop=0, NewWidth=0, NewHeight=0;
      if((AAlign == TAlign.None) || !Control.Anchors.isEqual(AnchorAlign(AAlign)))
      {

        if((Control._originalParentSize.x != 0) && (Control._originalParentSize.y != 0))
        {
          NewLeft = Control.Left;
          NewTop = Control.Top;
          NewWidth = Control.Width;
          NewHeight = Control.Height;
          TPoint ParentSize;
          if(Control.Parent!.HandleAllocated())
            ParentSize = Control.Parent!.ClientRect.BottomRight;
          else
            ParentSize = TPoint(Control.Parent!.Width, Control.Parent!.Height);
          if(Control.Anchors.contains(TAnchorKind.Right))
            if(Control.Anchors.contains(TAnchorKind.Left))
              // The AnchorRules.X is the original width
              NewWidth = ParentSize.x - (Control._originalParentSize.x - Control._anchorRules.x);
            else
              // The AnchorRules.X is the original left
              NewLeft = ParentSize.x - (Control._originalParentSize.x - Control._anchorRules.x);
          else
          if(!Control.Anchors.contains(TAnchorKind.Left))
            // The AnchorRules.X is the original middle of the control
            NewLeft = MulDiv(Control._anchorRules.x, ParentSize.x, Control._originalParentSize.x) - (NewWidth>>1);
          if(Control.Anchors.contains(TAnchorKind.Bottom))
            if(Control.Anchors.contains(TAnchorKind.Top))
              // The AnchorRules.Y is the original height
              NewHeight = ParentSize.y - (Control._originalParentSize.y - Control._anchorRules.y);
            else
              // The AnchorRules.Y is the original top
              NewTop = ParentSize.y - (Control._originalParentSize.y - Control._anchorRules.y);
          else
          if(!Control.Anchors.contains(TAnchorKind.Top))
            // The AnchorRules.Y is the original middle of the control
            NewTop = MulDiv(Control._anchorRules.y, ParentSize.y, Control._originalParentSize.y) - (NewHeight>>1);
          Control._anchorMove = true;
          try
          {
            Control.SetBounds(NewLeft, NewTop, NewWidth, NewHeight);
          }
          finally
          {
            Control._anchorMove = false;
          }
        }
        if(AAlign == TAlign.None)
          return;
      }

      NewWidth = Rect.width;
      if((NewWidth < 0) || ([TAlign.Left, TAlign.Right, TAlign.Custom].contains(AAlign)))
        NewWidth = Control.Width;
      NewHeight = Rect.height;
      if((NewHeight < 0) || ([TAlign.Top, TAlign.Bottom, TAlign.Custom].contains(AAlign)))
        NewHeight = Control.Height;
      NewLeft = Rect.left;
      NewTop = Rect.top;
      switch(AAlign)
      {
        case TAlign.Top:
          Rect.top+=NewHeight;
          break;
        case TAlign.Bottom:
          Rect.bottom-=NewHeight;
          NewTop = Rect.bottom;
          break;
        case TAlign.Left:
          Rect.left+=NewWidth;
          break;
        case TAlign.Right:
          Rect.right-=NewWidth;
          NewLeft = Rect.right;
          break;
        case TAlign.Custom:
          NewLeft = Control.Left;
          NewTop = Control.Top;
          CustomAlignPosition(Control, NewLeft, NewTop, NewWidth, NewHeight, Rect, AlignInfo);
          break;
        default:
          break;
      }

      Control._anchorMove = true;
      try
      {
        Control.SetBounds(NewLeft, NewTop, NewWidth, NewHeight);
      }
      finally
      {
        Control._anchorMove = false;
      }
      // Adjust client rect if control didn't resize as we expected
      if((Control.Width != NewWidth) || (Control.Height != NewHeight))
      {
        switch(AAlign)
        {
          case TAlign.Top:
            Rect.top-=NewHeight - Control.Height;
            break;
          case TAlign.Bottom:
            Rect.bottom+=NewHeight - Control.Height;
            break;
          case TAlign.Left:
            Rect.left-=NewWidth - Control.Width;
            break;
          case TAlign.Right:
            Rect.right+=NewWidth - Control.Width;
            break;
          case TAlign.Client:
            Rect.right+=NewWidth - Control.Width;
            Rect.bottom+=NewHeight - Control.Height;
            break;
          default:
            break;
        }
      }
    }



    void DoAlign(TAlign AAlign)
    {
      AlignList.clear();
      if((AControl != null) && ((AAlign == TAlign.None) || AControl.Visible ||
        AControl.ComponentState.contains(ComponentStates.Designing) &&
        !AControl.ControlStyle.contains(ControlStyles.NoDesignVisible)) &&
          (AControl.Align == AAlign))
        AlignList.add(AControl);
      for(int i = 0; i<ControlCount; i++)
      {
        TControl Control = Controls[i];
        if((Control.Align == AAlign) && ((AAlign == TAlign.None) || (Control.Visible ||
           (Control.ControlStyle.contains(ControlStyles.AcceptsControls)  && Control.ControlStyle.contains(ControlStyles.AcceptsControls))) ||
            Control.ComponentState.contains(ComponentStates.Designing) &&
           !Control.ControlStyle.contains(ControlStyles.NoDesignVisible)))
        {
          if(Control == AControl)
            continue;
          int j = 0;
          while((j < AlignList.length) && !InsertBefore(Control, AlignList[j], AAlign))
            j++;
          AlignList.insert(j, Control);
        }
      }

      for(int i = 0; i<AlignList.length; i++)
      {
        TAlignInfo AlignInfo = TAlignInfo();
        AlignInfo.AlignList = AlignList;
        AlignInfo.ControlIndex = i;
        AlignInfo.Align = AAlign;
        DoPosition(AlignList[i], AAlign, AlignInfo);
      }
    }

    bool AlignWork()
    {
      for(int i = ControlCount - 1; i>=0; i--)
        if((Controls[i].Align != TAlign.None) ||
            !Controls[i].Anchors.isEqual([TAnchorKind.Left, TAnchorKind.Top]))
          return true;
      return false;
    }

    
    if(AlignWork())
    {
      AdjustClientRect(Rect);
      AlignList = <TControl>[];
      try
      {
        DoAlign(TAlign.Top);
        DoAlign(TAlign.Bottom);
        DoAlign(TAlign.Left);
        DoAlign(TAlign.Right);
        DoAlign(TAlign.Client);
        DoAlign(TAlign.Custom);
        DoAlign(TAlign.None);// Move anchored controls
        ControlsAligned();
      }
      finally
      {
        AlignList.clear();

      }
    }
    // Apply any constraints
    if(Showing)
      AdjustSize();
  }

  void AlignControl(TControl? AControl)
  {
    if(!HandleAllocated() || ComponentState.contains(ComponentStates.Destroying))
      return;

    if(_alignLevel != 0)
      ControlState<<ControlStates.AlignmentNeeded;
    else
    {
      DisableAlign();
      try
      {
        AlignControls(AControl, GetClientRect());
      }
      finally
      {
        ControlState>>ControlStates.AlignmentNeeded;
        EnableAlign();
      }
    }
  }

  void DisableAlign()
  {
    _alignLevel++;
  }

  void EnableAlign()
  {
    _alignLevel--;
    if(_alignLevel == 0 && ControlState.contains(ControlStates.AlignmentNeeded))
      Realign();
  }

  void Realign()
  {
    AlignControl(null);
  }


  bool ContainsControl(TControl? Control)
  {
    while((Control != null) && (Control != this))
      Control = Control.Parent;
    return Control != null;
  }

  void RemoveFocus(bool Removing)
  {
    TCustomForm? Form = ParentForm;
    if(Form != null)
      Form.DefocusControl(this, Removing);
  }

  void InsertControl(TControl AControl)
  {
    void Insert(TControl AControl)
    {
      if(AControl == null)
        return;
      if(AControl is TWinControl)
      {
        _winControls.add(AControl);
        _tabList.add(AControl);
      }
      else
        _controls.add(AControl);
      AControl._parent = this;
    }

    AControl.ValidateContainer(this);
    Perform(CM_CONTROLLISTCHANGE, AControl, true);
    Insert(AControl);
    if(!(AControl.ComponentState.contains(ComponentStates.Reading)))
    {
      AControl.Perform(CM_PARENTCOLORCHANGED, 0, 0);
      AControl.Perform(CM_PARENTFONTCHANGED, 0, 0);
      AControl.Perform(CM_PARENTSHOWHINTCHANGED, 0, 0);
      
      if(AControl is TWinControl)
      {
        AControl.Perform(CM_PARENTCTL3DCHANGED, 0, 0);
        UpdateControlState();
      }
      else
      if(HandleAllocated())
        AControl.Invalidate();
      AlignControl(AControl);
    }
    Perform(CM_CONTROLCHANGE, AControl, true);
  }

  void RemoveControl(TControl AControl)
  {

    void Remove(TControl AControl)
    {
      if(AControl is TWinControl)
      {
        _tabList.remove(AControl);
        _winControls.remove(AControl);
      }
      else
        _controls.remove(AControl);
      AControl._parent = null;
    }

    Perform(CM_CONTROLCHANGE, AControl, false);
    if(AControl is TWinControl)
    {
      AControl.RemoveFocus(true);
      AControl.DestroyHandle();
    }
    else
    if(HandleAllocated())
      AControl.InvalidateControl(AControl.Visible, false);
    Remove(AControl);
    Perform(CM_CONTROLLISTCHANGE, AControl, false);
    Realign();
  }




  void Broadcast(TMessage Message)
  {
    for(int i=0; i<ControlCount; i++)
    {
      Controls[i].WindowProc(Message);
      if(Message.Result != 0)
        return;
    }
  }

  void NotifyControls(MESSAGE Msg)
  {
    TMessage Message = TMessage(Msg);
    Message.WParam = 0;
    Message.LParam = 0;
    Message.Result = 0;
    Broadcast(Message);
  }

  

  void AddBiDiModeExStyle(TPointer<UINT> ExStyle)
  {

  }

  void CreateParams(TCreateParams Params)
  {
    Params.Caption = _text;
    Params.Style = Windows.WS_CHILD | Windows.WS_CLIPSIBLINGS;
    var lpExStyle = TPointer(Params.ExStyle);
    AddBiDiModeExStyle(lpExStyle);
    Params.ExStyle = lpExStyle.Value;
    if (ControlStyle.contains(ControlStyles.AcceptsControls))
    {
      Params.Style |= Windows.WS_CLIPCHILDREN;
      Params.ExStyle |= Windows.WS_EX_CONTROLPARENT;
    }
    if (!(ComponentState.contains(ComponentStates.Designing)) && !Enabled)
      Params.Style |= Windows.WS_DISABLED;
    if(_tabStop)
      Params.Style |= Windows.WS_TABSTOP;
    Params.X = _left;
    Params.Y = _top;
    Params.Width = _width;
    Params.Height = _height;
    if(Parent != null)
      Params.WndParent = Parent!.Handle;
    else
      Params.WndParent = _parentWindow;

  
  }

  WNDPROC? _defWndProc;

  void CreateWnd()
  {

    TCreateParams Params = TCreateParams();
    CreateParams(Params);

      if((Params.WndParent == null) && (Params.Style & Windows.WS_CHILD != 0))
        if((Owner != null) && (Owner!.ComponentState.contains(ComponentStates.Reading)) &&
          (Owner is TWinControl))
          Params.WndParent = (Owner as TWinControl).Handle;
        else
          throw EInvalidOperation.CreateFmt(Consts.SParentRequired, [Name]);


    CreateWindowHandle(Params);

    if(WindowHandle == null)
      throw UnsupportedError("RaiseLastOSError");

    var hwnd = WindowHandle!;

    _defWndProc = Windows.ChangeWindowProc(hwnd, (elem, message)
    {
      if(message.Msg == CM_GETINSTANCE)
        message.Result = this;
      else
        WndProc(message);
    });

    Windows.InitWindow(hwnd, INITSTRUCT(
      exStyle: Params.ExStyle,
      windowName: Params.Caption,
      style: Params.Style,
      x: Params.X,
      y: Params.Y,
      width: Params.Width,
      height: Params.Height,
      parent: Params.WndParent,
      param: Params.Param));



    if(Cursor!=TCursor.Default)
      hwnd.clientHandle.style.cursor = Cursor.name;


    /// new ///*



    /// new *///



    UpdateBounds();
    Perform(WM_SETFONT, null, 1);
    if(AutoSize)
      AdjustSize();
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    _handle = HWND( DivElement() );
    _handle!.style.position ='absolute';
    _handle!.style.boxSizing='border-box';

  }




  void DestroyWnd()
  {
    _text = Perform(WM_GETTEXT);

    TControlCanvas.FreeDeviceContexts();
    DestroyWindowHandle();
  }

  void DestroyWindowHandle()
  {
    _controlState << ControlStates.DestroyingHandle;
    try
    {
      _handle!.handle.remove();

    }
    finally
    {
      _controlState >> ControlStates.DestroyingHandle;
    }

    Windows.DestroyWindow(_handle!);
    _defWndProc = null;
    _handle = null;
  }

  HWINDOW? PrecedingWindow(TWinControl Control)
  {
    for( int i = _winControls.indexOf(Control) + 1; i < _winControls.length; i++)
    {
      var Result = _winControls[i]._handle;
      if(Result != null)
        return Result;
    }
    return HWND_TOP;
  }

  TNotifyEvent? _onCreateHandle;
  TNotifyEvent? // new
    get OnCreateHandle => _onCreateHandle;
    set OnCreateHandle(TNotifyEvent? Value) => _onCreateHandle = Value;

  void CreateHandle()
  {
    if(_handle == null)
    {
      CreateWnd();

      if(Parent != null)
        Windows.SetWindowPos(_handle!, Parent!.PrecedingWindow(this), 0, 0, 0, 0,
            Windows.SWP_NOMOVE | Windows.SWP_NOSIZE | Windows.SWP_NOACTIVATE);
      for(int i = 0; i<ControlCount; i++)
        Controls[i].UpdateAnchorRules();

      if(OnCreateHandle != null) // new
        OnCreateHandle!(this);
    }
  }

  bool CustomAlignInsertBefore(TControl C1, TControl C2)
  {
    // Notification
    return false;
  }

  void CustomAlignPosition(TControl Control, int NewLeft, int NewTop, int NewWidth, int NewHeight, TRect AlignRect, TAlignInfo AlignInfo)
  {
    // Notification
  }

  void DestroyHandle()
  {
    if(_handle != null)
    {
      for(int i = 0; i < _winControls.length; i++)
        _winControls[i].DestroyHandle();
      DestroyWnd();
    }
  }

  void RecreateWnd()
  {
    if(_handle != null)
      Perform(CM_RECREATEWND, 0, 0);
  }

  void UpdateShowing()
  {
    bool ShowControl = (_visible || ComponentState.contains(ComponentStates.Designing) &&
      !ControlStyle.contains(ControlStyles.NoDesignVisible) &&
      !ControlState.contains(ControlStates.ReadingState));
    if(ShowControl)
    {
      if(_handle == null)
        CreateHandle();

      for(var item in _winControls)
        item.UpdateShowing();
    }
    if(_handle != null)
    {
      if(_showing != ShowControl)
      {
        _showing = ShowControl;
        try
        {
          Perform(CM_SHOWINGCHANGED, 0, 0);
        }
        catch(E)
        {
          _showing = !ShowControl;
          throw E;
        }
      }
    }
  }

  void UpdateControlState()
  {
    TWinControl Control = this;
    while(Control.Parent != null)
    {
      Control = Control.Parent!;
      if(Control.Showing == false)
        return;
    }

    if(Control is TCustomForm || Control._parentWindow != null)
      UpdateShowing();
  }



  TControl? ControlAtPos(TPoint Pos, bool AllowDisabled, [bool AllowWinControls = false] )
  {
    TControl? LControl;
    bool HitTest(TControl AControl, TPoint P)
    {
      int? State = AControl.Perform(CM_HITTEST, 0, P);
      return State!=null || State!=Windows.HTNOWHERE;
    }

    bool GetControlAtPos(TControl AControl)
    {
//      with AControl do
      TPoint P = TPoint(Pos.x - AControl.Left, Pos.y - AControl.Top);
      if(PtInRect(AControl.ClientRect, P) && (AControl.ComponentState.contains(ComponentStates.Designing) &&
          (AControl.Visible || !AControl.ControlStyle.contains(ControlStyles.NoDesignVisible)) ||
          (AControl.Visible && (AControl.Enabled || AllowDisabled) && HitTest(AControl, P))))
      {
        LControl = AControl;
        return true;
      }
      return false;
    }

    if(AllowWinControls)
      for(int i = _winControls.length - 1; i>=0; i--)
        if(GetControlAtPos(_winControls[i]))
          break;

    if(LControl == null)
      for(int i = _controls.length - 1; i>=0; i--)
        if(GetControlAtPos(_controls[i]))
          break;

    return LControl;
  }



  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_SETFOCUS:
        TCustomForm? Form = ParentForm;
        if(Form != null && !Form.SetFocusedControl(this))
          return;
        break;

      case WM_KILLFOCUS:
        if(ControlState.contains(ControlStates.Focusing))
          return;
        break;

      case WM_NCHITTEST:
        super.WndProc(Message);
        if(Message.Result == Windows.HTTRANSPARENT &&
          ControlAtPos(ScreenToClient(TPoint.from(Message.LParam)), false) != null)
            Message.Result = Windows.HTCLIENT;
        return;

    }
    super.WndProc(Message);
  }

  void DefaultHandler(TMessage Message)
  {
    if(_handle != null)
    {
      
          if(_defWndProc != null)
            _defWndProc!(_handle!.handle, Message);
            
        if(Message.Msg == WM_SETTEXT)
          SendDockNotification(Message.Msg, Message.WParam, Message.LParam);

    }
    else
      super.DefaultHandler(Message);
  }

  static Map<MESSAGE,MESSAGE> WM_TO_CM =
  {
    WM_COMMAND: CN_COMMAND,
    WM_VSCROLL: CN_VSCROLL,
    WM_HSCROLL: CN_HSCROLL,
    WM_KEYDOWN: CN_KEYDOWN,
    WM_KEYUP:   CN_KEYUP,
    WM_CHAR:    CN_CHAR,
//    WM_UNICHAR: CM_UNICHAR,
  };

  static bool DoControlMsg(HWND? ControlHandle, TMessage Message)
  {
    TWinControl? Control = FindControl(ControlHandle);
    if(Control != null)
    {
      MESSAGE? cm = WM_TO_CM[Message.Msg];
      if(cm != null)
      {
        Message.Result = Control.Perform(cm, Message.WParam, Message.LParam);
        return true;
      }
    }
    return false;
  }



  void DoEnter()
  {
    if(_onEnter!=null)
      _onEnter!(this);
  }

  void DoExit()
  {
    if(_onExit!=null)
      _onExit!(this);
  }



  void ControlsAligned()
  {
    // Notification
  }


  void KeyDown(TKeyCode Key, TShiftState Shift)
  {
    if(_onKeyDown != null)
      _onKeyDown!(this, Key, Shift);
  }

  bool DoKeyDown(TWMKey Message)
  {
    TCustomForm? Form = ParentForm;
    if(Form != null && Form != this && Form.KeyPreview && Form.DoKeyDown(Message))
      return true;

    if(!ControlStyle.contains(ControlStyles.NoStdEvents))
    {
      TKeyCode Key = TKeyCode(Message.CharCode);
      KeyDown(Key, Message.ShiftState);
      if(Key.Code == 0 || Key.Code == null)
      {
        Message.Result = 0;
        return true;
      }
    }
    return false;
  }


  void KeyUp(TKeyCode Key, TShiftState Shift)
  {
    if(_onKeyUp != null)
      _onKeyUp!(this, Key, Shift);
  }

  bool DoKeyUp(TWMKey Message)
  {
    TCustomForm? Form = ParentForm;
    if((Form != null) && (Form != this) && Form.KeyPreview && Form.DoKeyUp(Message))
      return true;

    if(!ControlStyle.contains(ControlStyles.NoStdEvents))
    {
      TKeyCode Key = TKeyCode(Message.CharCode);
      KeyUp(Key, Message.ShiftState);
      if(Key.Code == 0 || Key.Code == null)
      {
        Message.Result = 0;
        return true;
      }
    }
    return false;
  }


  void KeyPress(TKeyCode Key)
  {
    if(_onKeyPress != null)
      _onKeyPress!(this, Key);
  }

  bool DoKeyPress(TWMKey Message)
  {
    TCustomForm? Form = ParentForm;
    if((Form != null) && (Form != this) && Form.KeyPreview &&
      Form.DoKeyPress(Message))
        return true;
    if(!ControlStyle.contains(ControlStyles.NoStdEvents))
    {
      TKeyCode Key = TKeyCode(Message.CharCode);
      KeyPress(Key);
      if(Key.Code==0 || Key.Code == null)
      {
        Message.Result = 0;
        return true;
      }
    }
    return false;
  }


  void Dispatch(TMessage Message) // TWinControl::Dispatch
  {
    switch(Message.Msg)
    {
      case CM_CANFOCUS:           _cmCanFocus(Message); break;
      case CM_CHILDKEY:           _cmChildKey(Message); break;
      case CM_CTL3DCHANGED:       _cmCtl3DChanged(Message); break;
      case CM_CURSORCHANGED:      _cmCursorChanged(Message); break;
      case CM_DIALOGCHAR:         _cmDialogChar(Message); break;
      case CM_DIALOGKEY:          _cmDialogKey(Message); break;
      case CM_ENTER:              _cmEnter(Message); break;
      case CM_EXIT:               _cmExit(Message); break;
      case CM_INVALIDATE:         _cmInvalidate(Message); break;
      case CM_PARENTCTL3DCHANGED: _cmParentCtl3DChanged(Message); break;
      case CM_RECREATEWND:        _cmRecreateWnd(Message); break;
      case CM_SETFOCUS:           _cmSetFocus(Message); break;
      case CM_SHOWINGCHANGED:     _cmShowingChanged(Message); break;
      case CM_SHOWHINTCHANGED:    _cmShowHintChanged(Message); break;

      case CN_KEYDOWN:            _cnKeyDown(TWMKey(Message)); break;
      case CN_KEYUP:              _cnKeyUp(TWMKey(Message)); break;
      case CN_CHAR:               _cnChar(TWMKey(Message)); break;
      case CN_COMMAND:            _cnCommand(TWMCommand(Message)); break;

      case WM_CHAR:               _wmChar(TWMKey(Message)); break;
      case WM_NCHITTEST:          _wmNCHitTest(Message); break;
      case WM_HSCROLL:            _wmHScroll(Message); break;
      case WM_KEYDOWN:            _wmKeyDown(TWMKey(Message)); break;
      case WM_KILLFOCUS:          _wmKillFocus(Message); break;
      case WM_KEYUP:              _wmKeyUp(TWMKey(Message)); break;
      case WM_PAINT:              _wmPaint(TWMPaint(Message)); break;
      case WM_SETCURSOR:          _wmSetCursor(Message); break;
      case WM_SETFOCUS:           _wmSetFocus(Message); break;
      case WM_VSCROLL:            _wmVScroll(Message); break;

      default:
        super.Dispatch(Message);
        break;
    }
  }



  bool IsMenuKey(TWMKey Message)
  {

    return false;
  }

  void SetBounds(int? ALeft, int? ATop, int? AWidth, int? AHeight)
  {
    if(ALeft == null)    ALeft=_left;
    if(ATop == null)     ATop=_top;
    if(AWidth == null)   AWidth=_width;
    if(AHeight == null)  AHeight=_height;

    if((ALeft != _left) || (ATop != _top) ||
      (AWidth != _width) || (AHeight != _height))
    {
/*      _left = ALeft;
      _top = ATop;
      _width = AWidth;
      _height = AHeight;*/

      if(HandleAllocated() && !Windows.IsIconic(_handle!))
        Windows.SetWindowPos(_handle!, null, ALeft, ATop, AWidth, AHeight, Windows.SWP_NOZORDER | Windows.SWP_NOACTIVATE);
      else
      {
        _left = ALeft;
        _top = ATop;
        _width = AWidth;
        _height = AHeight;
        if(HandleAllocated())
        {

        }
      }
      UpdateAnchorRules();
      RequestAlign();
    }
  }


  void ShowControl(TControl AControl)
  {
    if(Parent != null)
      Parent!.ShowControl(this);
  }

  void SetZOrderPosition(int Position)
  {
    if(_parent == null)
      return;

    if(_parent!._controls != null)
      Position-=_parent!._controls.length;
    int I = _parent!._winControls.indexOf(this);
    if(I >= 0)
    {
      int Count = _parent!._winControls.length;
      if(Position < 0)      Position = 0;
      if(Position >= Count) Position = Count - 1;
      if(Position != I)
      {
        _parent!._winControls.removeAt(I);
        _parent!._winControls.insert(Position, this);
      }
    }
    if(_handle != null)
    {

    }
  }

  void SetZOrder(bool TopMost)
  {
    if(_parent != null)
    {
      int N = TopMost? _parent!._winControls.length - 1 : 0;
      int M = _parent!._controls.length;
      SetZOrderPosition(M + N);
    }
    else
    if(_handle != null)
    {
      Windows.SetWindowPos(_handle!, TopMost? HWND_TOP : HWND_BOTTOM, 0, 0, 0, 0,
        Windows.SWP_NOMOVE + Windows.SWP_NOSIZE);
    }
  }

  HDC? GetDeviceContext()
  {

    return null;

  }



  void Invalidate()
  {
    Perform(CM_INVALIDATE, 0, 0);
  }

  void Update()
  {
    if(HandleAllocated())
      Windows.UpdateWindow(_handle!);
  }

  void Repaint()
  {
    Invalidate();
    Update();
  }

  void InvalidateFrame()
  {

  }

  bool CanFocus()
  {
    TCustomForm? Form = ParentForm;
    if(Form == null)
      return false;

    TWinControl? Control = this;
    while(Control != Form)
    {
      if(!(Control!.Visible && Control.Enabled))
        return false;
      Control = Control.Parent;
    }
    return true;
  }

  SetFocus()
  {
    TCustomForm? Parent = ParentForm;
    if(Parent != null)
      Parent.FocusControl(this);
    else
    if(ParentWindow != null)
      Windows.SetFocus(Handle);
    else
      ValidParentForm(this);


  }

  bool Focused()
  {
    return (_handle != null) && Windows.GetFocus()==_handle;
  }

  void HandleNeeded()
  {
    if(_handle == null)
    {
      if(Parent != null)
        Parent!.HandleNeeded();
      CreateHandle();
    }
  }

  TRect GetControlExtents()
  {
    TRect Result = TRect(SysUtils.MAXLONG, SysUtils.MAXLONG, 0, 0);
    int mWidth = 0;
    int mHeight = 0;
    for(int i = 0; i < ControlCount; i++)
    {
      TControl ctrl = Controls[i];
      if(ctrl.Visible || ctrl.ComponentState.contains(ComponentStates.Designing) &&
        !ctrl.ControlStyle.contains(ControlStyles.NoDesignVisible))
      {
        if([TAlign.Left, TAlign.Right].contains(ctrl.Align))
          mWidth+=ctrl.Width;
        if([TAlign.Top, TAlign.Bottom].contains(ctrl.Align))
          mHeight+=ctrl.Height;

        if(ctrl.Left < Result.left)
          Result.left = ctrl.Left;
        if(ctrl.Top < Result.top)
          Result.top = ctrl.Top;
        if(ctrl.Left + ctrl.Width > Result.right)
          Result.right = ctrl.Left + ctrl.Width;
        if(ctrl.Top + ctrl.Height > Result.bottom)
          Result.bottom = ctrl.Top + ctrl.Height;
      }
    }
    if(mWidth>Result.width)
      Result.right=Result.left+mWidth;
    if(mHeight>Result.height)
      Result.bottom=Result.top+mHeight;
    return Result;
  }

  TPoint GetClientOrigin()
  {
    if(ParentWindow == HWND_DESKTOP) // new;
      return TPoint(_left, _top);

    var result = TPoint(0, 0);
    Windows.ClientToScreen(Handle, result);
    return result;

  }



  void AdjustSize()
  {
    if(!ComponentState.contains(ComponentStates.Loading) && HandleAllocated())
    {
      Windows.SetWindowPos(Handle, null, 0, 0, Width, Height,
          Windows.SWP_NOACTIVATE | Windows.SWP_NOMOVE | Windows.SWP_NOZORDER);
      RequestAlign();
    }
  }



  bool HandleAllocated()
  {
    return _handle != null;
  }

  dynamic IfHandleAllocated<T>(dynamic Function(T client) proc, [dynamic res]) // new
  {
    if(_handle != null)
      return proc(_handle!.clientHandle as T);
    return res;
  }

  void UpdateBounds()
  {

    var Rect = TRect(_left, _top, _left+_width, _top+_height);
    

    if(Windows.IsIconic(_handle!))
    {
      throw UnimplementedError();

    }
    else
      Windows.GetWindowRect(_handle!, Rect);

    if(Windows.GetWindowLong(_handle!, Windows.GWL_STYLE) & Windows.WS_CHILD != 0)
    {
      HWND? ParentHandle = Windows.GetWindowLong(_handle!, Windows.GWL_HWNDPARENT);
      if(ParentHandle != null)
      {
        var TopLeft     = Rect.TopLeft;
        var BottomRight = Rect.BottomRight;
        Windows.ScreenToClient(ParentHandle, TopLeft);
        Windows.ScreenToClient(ParentHandle, BottomRight);
        Rect.left    = TopLeft.x;
        Rect.top     = TopLeft.y;
        Rect.right   = BottomRight.x;
        Rect.bottom  = BottomRight.y;
      }
    }
    _left = Rect.Left;
    _top = Rect.Top;
    _width = Rect.Width;
    _height = Rect.Height;
    UpdateAnchorRules();

/*    if(_handle==null)
      return;
/**    if(_handle!.handle.offsetParent==null)
    {
      print(_handle!.handle.getOffsetRect(rect));
    }**/
    TRect rect = TRect();
/**    print(_handle!.handle.offsetRect);
    print(_handle!.handle.borderRect);
    print(_handle!.handle.contentRect);**/
    if(Windows.IsIconic(_handle))
    {
/**      WindowPlacement.Length := SizeOf(WindowPlacement);
      GetWindowPlacement(FHandle, @WindowPlacement);
      Rect := WindowPlacement.rcNormalPosition;**/
    }
    else
    if(!_handle!.handle.getOffsetRect(rect))
      return;

/**      Windows.GetWindowRect(_handle, Rect);

/**    if GetWindowLong(FHandle, GWL_STYLE) and WS_CHILD <> 0 then
    begin**/
      var ParentHandle = Windows.GetParent(_handle);
///      ParentHandle := GetWindowLong(FHandle, GWL_HWNDPARENT);
      if(ParentHandle != null)
      {
        Windows.ScreenToClient(ParentHandle, Rect.TopLeft);
        Windows.ScreenToClient(ParentHandle, Rect.BottomRight);
      }
/**    end;*/
**/
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    UpdateAnchorRules();**/
  }

  void GetTabOrderList(List<TWinControl> list)
  {
    for(TWinControl Control in _tabList)
    {
      list.add(Control);
      Control.GetTabOrderList(list);
    }
  }

  TWinControl? FindNextControl(TWinControl? CurControl, bool GoForward, bool CheckTabStop, bool CheckParent)
  {
    TWinControl? Result;
    final list = <TWinControl>[];
    try
    {
      GetTabOrderList(list);
      if(list.length > 0)
      {
        int StartIndex = CurControl==null? -1 : list.indexOf(CurControl);
        if(StartIndex == -1)
          StartIndex = GoForward? list.length - 1 : 0;
        int i = StartIndex;
        do
        {
          if(GoForward)
          {
            i++;
            if(i == list.length)
              i = 0;
          }
          else
          {
            if(i == 0)
              i = list.length;
            i--;
          }
          CurControl = list[i];
          if(CurControl.CanFocus() &&
              (!CheckTabStop || CurControl.TabStop) &&
              (!CheckParent || (CurControl.Parent == this)))
            Result = CurControl;
        } while((Result == null) && (i != StartIndex));
      }
    }
    finally
    {

    }
    return Result;
  }

  void SelectNext(TWinControl CurControl, bool GoForward, bool CheckTabStop)
  {
    var ctrl = FindNextControl(CurControl, GoForward, CheckTabStop, !CheckTabStop);
    if(ctrl != null)
      ctrl.SetFocus();
  }

  void SelectFirst()
  {
    TCustomForm? Form = ParentForm;
    if(Form == null)
      return;

    TWinControl? Control = FindNextControl(null, true, true, false);
    if(Control == null)
      Control = FindNextControl(null, true, false, false);
    if(Control != null)
      Form.ActiveControl = Control;
  }




  bool CanResize(Integer NewWidth, Integer NewHeight)
  {
    return super.CanResize(NewWidth, NewHeight);
  }



  void CalcConstraints(Integer MinWidth, Integer MinHeight,
                       Integer MaxWidth, Integer MaxHeight)
  {
    const int sNone=0, sReg=1, sStretch=2, sOther=3; 

    void DoCalcConstraints(TControl Control,
                           Integer MinWidth, Integer MinHeight,
                           Integer MaxWidth, Integer MaxHeight)
    {
      if(Control.Constraints.MinWidth > 0)
        MinWidth.Value = Control.Constraints.MinWidth;
      else
        MinWidth.Value = 0;
      if(Control.Constraints.MinHeight > 0)
        MinHeight.Value = Control.Constraints.MinHeight;
      else
        MinHeight.Value = 0;
      if(Control.Constraints.MaxWidth > 0)
        MaxWidth.Value = Control.Constraints.MaxWidth;
      else
        MaxWidth.Value = 0;
      if(Control.Constraints.MaxHeight > 0)
        MaxHeight.Value = Control.Constraints.MaxHeight;
      else
        MaxHeight.Value = 0;
      // Allow override of constraints
      Control.ConstrainedResize(MinWidth, MinHeight, MaxWidth, MaxHeight);
    }

    if(!HandleAllocated() || ControlCount == 0)
      return;
    // Adjust min/max size to compensate for non-client area
    TRect R = GetClientRect();
    AdjustClientRect(R);
    if(IsRectEmpty(R))
      return; // Coming from an icon view, don't do constraints
    int AdjustMinWidth = Width - R.width;
    int AdjustMinHeight = Height - R.height;
    int AdjustMaxWidth = Width - R.width;
    int AdjustMaxHeight = Height - R.height;
    if(MinWidth.Value > 0)  MinWidth.Value-=AdjustMinWidth;
    if(MinHeight.Value > 0) MinHeight.Value-=AdjustMinHeight;
    if(MaxWidth.Value > 0)  MaxWidth.Value-=AdjustMaxWidth;
    if(MaxHeight.Value > 0) MaxHeight.Value-=AdjustMaxHeight;
    //Compare incoming min/max constraints with those that we calculate
    try
    {
      int TotalMinWidth = 0,  TotalMinWidth2 = 0;
      int TotalMaxWidth = 0,  TotalMaxWidth2 = 0;
      int TotalMinHeight = 0, TotalMinHeight2 = 0;
      int TotalMaxHeight = 0, TotalMaxHeight2 = 0;
      int WidthScale =sNone; //: TScale;
      int HeightScale=sNone; //: TScale;
      for(int I = 0; I<ControlCount; I++)
      {
        TControl Control = Controls[I];

        if(Control.Visible || (Control.ComponentState.contains(ComponentStates.Designing)) &&
           !(Control.ControlStyle.contains(ControlStyles.NoDesignVisible)))
        {
          Integer ControlMinWidth = Integer();
          Integer ControlMaxWidth = Integer();
          Integer ControlMinHeight = Integer();
          Integer ControlMaxHeight = Integer();
          DoCalcConstraints(Control, ControlMinWidth, ControlMinHeight, ControlMaxWidth, ControlMaxHeight);

          switch(Control.Align)
          {
            case TAlign.Top:
            case TAlign.Bottom:
              WidthScale = sReg;
              break;
            case TAlign.Client:
              WidthScale = sStretch;
              break;
            case TAlign.None:
              if(Anchors.contains(TAnchorKind.Left) && Anchors.contains(TAnchorKind.Right))
              {
                WidthScale = sReg;
                // Adjust Anchored controls
                if(ControlMinWidth.Value > 0)
                  ControlMinWidth.Value = R.width - Control.Width - ControlMinWidth.Value;
                if(ControlMaxWidth.Value > 0)
                  ControlMaxWidth.Value = R.width + ControlMaxWidth.Value - Control.Width;
              }
              else
                WidthScale = sNone;
              break;
            default:
              WidthScale = sOther;
              break;
          }

          switch(Control.Align)
          {
            case TAlign.Left:
            case TAlign.Right:
              HeightScale = sReg;
              break;
            case TAlign.Client:
              HeightScale = sStretch;
              break;
            case TAlign.None:
              if(Anchors.contains(TAnchorKind.Top) && Anchors.contains(TAnchorKind.Bottom))
              {
                HeightScale = sReg;
                // Adjust Anchored controls
                if(ControlMinHeight.Value > 0)
                  ControlMinHeight.Value = R.height - Control.Height - ControlMinHeight.Value;
                if(ControlMaxHeight.Value > 0)
                  ControlMaxHeight.Value = R.height + ControlMaxHeight.Value - Control.Height;
              }
              else
                HeightScale = sNone;
              break;
            default:
              HeightScale = sOther;
          }

          // Calculate min/max width
          switch (WidthScale)
          {
            case sReg:
            case sStretch:
              {
                if((ControlMinWidth.Value > 0) && (ControlMinWidth > MinWidth))
                {
                  MinWidth.Value = ControlMinWidth.Value;
                  if(MinWidth.Value > TotalMinWidth)
                    TotalMinWidth = MinWidth.Value;
                }
                if((ControlMaxWidth.Value > 0) && (ControlMaxWidth < MaxWidth))
                {
                  MaxWidth.Value = ControlMaxWidth.Value;
                  if(MaxWidth.Value > TotalMaxWidth)
                    TotalMaxWidth = MaxWidth.Value;
                }
              } break;

            case sOther:
              {
                TotalMinWidth2+=Width;
                TotalMaxWidth2+=Width;
              } break;
          }

          // Calculate min/max height
          switch(HeightScale)
          {
            case sReg:
            case sStretch:
              {
                if((ControlMinHeight.Value > 0) && (ControlMinHeight > MinHeight))
                {
                  MinHeight.Value = ControlMinHeight.Value;
                  if(MinHeight.Value > TotalMinHeight)
                    TotalMinHeight = MinHeight.Value;
                }
                if((ControlMaxHeight.Value > 0) && (ControlMaxHeight < MaxHeight))
                {
                  MaxHeight.Value = ControlMaxHeight.Value;
                  if(MaxHeight.Value > TotalMaxHeight)
                    TotalMaxHeight = MaxHeight.Value;
                }
              } break;

            case sOther:
              {
                TotalMinHeight2+=Height;
                TotalMaxHeight2+=Height;
              } break;
          }
        }
      }
      if((TotalMinWidth > 0) && (TotalMinWidth+TotalMinWidth2 > MinWidth.Value))
        MinWidth.Value = TotalMinWidth+TotalMinWidth2;
      if((TotalMaxWidth > 0) && ((MaxWidth.Value == 0) || (TotalMaxWidth+TotalMaxWidth2 > MaxWidth.Value)))
        MaxWidth.Value = TotalMaxWidth+TotalMaxWidth2;
      if((TotalMinHeight > 0) && (TotalMinHeight+TotalMinHeight2 > MinHeight.Value))
        MinHeight.Value = TotalMinHeight+TotalMinHeight2;
      if((TotalMaxHeight > 0) && ((MaxHeight.Value == 0) || (TotalMaxHeight+TotalMaxHeight2 > MaxHeight.Value)))
        MaxHeight.Value = TotalMaxHeight+TotalMaxHeight2;
    }
    finally
    {
      if(MinWidth.Value > 0) MinWidth.Value+=AdjustMinWidth;
      if(MinHeight.Value > 0) MinHeight.Value+=AdjustMinHeight;
      if(MaxWidth.Value > 0) MaxWidth.Value+=AdjustMaxWidth;
      if(MaxHeight.Value > 0) MaxHeight.Value+=AdjustMaxHeight;
    }
  }

  void ConstrainedResize(Integer MinWidth, Integer MinHeight,
                         Integer MaxWidth, Integer MaxHeight)
  {
    CalcConstraints(MinWidth, MinHeight, MaxWidth, MaxHeight);
    super.ConstrainedResize(MinWidth, MinHeight, MaxWidth, MaxHeight);
  }



  bool CanAutoSize(Integer NewWidth, Integer NewHeight)
  {
    
    bool Result = true;
    // Restrict size to visible extents of children
    if(HandleAllocated() && (Align != TAlign.Client) &&
      (!ComponentState.contains(ComponentStates.Designing) || ControlCount > 0))
    {
      TRect Extents = GetControlExtents();
      // Here's where HandleAllocated is needed
      TRect R = GetClientRect();
      AdjustClientRect(R);
      DisableAlign();
      try
      {
        for(int i = 0; i < ControlCount; i++)
        {
          TControl ctrl = Controls[i];
          if(ctrl.Visible || ctrl.ComponentState.contains(ComponentStates.Designing) &&
            !ctrl.ControlStyle.contains(ControlStyles.NoDesignVisible))
          {
            int LeftOffset = 0;
            int TopOffset = 0;
            if([TAlign.None, TAlign.Left, TAlign.Right].contains(Align))
              LeftOffset = Extents.left - R.left;
            if([TAlign.None, TAlign.Top, TAlign.Bottom].contains(Align))
              TopOffset = Extents.top - R.top;
            ctrl.SetBounds(ctrl.Left - LeftOffset, ctrl.Top - TopOffset, ctrl.Width, ctrl.Height);
          }
        }
      }
      finally
      {
        ControlState >> ControlStates.AlignmentNeeded;
        EnableAlign();
      }
      if([TAlign.None, TAlign.Left, TAlign.Right].contains(Align))
      {
        if(Extents.right - Extents.left > 0)
        {
          NewWidth.Value = Extents.right - Extents.left + Width - (R.right - R.left);
          if(Align == TAlign.Right)
            RequestAlign();
        }
        else
          NewWidth.Value = 0;
      }
      if([TAlign.None, TAlign.Top, TAlign.Bottom].contains(Align))
        if(Extents.bottom - Extents.top > 0)
        {
          NewHeight.Value = Extents.bottom - Extents.top + Height - (R.bottom - R.top);
          if(Align == TAlign.Bottom)
            RequestAlign();
        }
        else
          NewHeight.Value = 0;
    }
    return Result;
  }



  

  void _cmColorChanged(TMessage Message)
  {
    super._cmColorChanged(Message);
    //FBrush.Color := FColor;
    NotifyControls(CM_PARENTCOLORCHANGED);
  }

  void _cmCursorChanged(TMessage Message)
  {
    if(Windows.GetCapture() == null)
    {
      var P = TPoint.from(Windows.GetCursorPos());
      if(FindDragTarget(P, false) == this)
        Perform(WM_SETCURSOR, Handle, Windows.HTCLIENT);
    }
  }

  void _cmCtl3DChanged(TMessage Message)
  {
    if(ControlStyle.contains(ControlStyles.Framed) && (Parent != null) &&
        HandleAllocated() && Windows.IsWindowVisible(_handle!))
      InvalidateFrame();
    NotifyControls(CM_PARENTCTL3DCHANGED);
  }

  void _cmCanFocus(TMessage Message)
  {
    Message.Result = CanFocus();
  }

  void _cmChildKey(TMessage Message)
  {
    if(_parent != null)
      _parent!.WindowProc(Message);
  }

  void _cmDialogChar(TMessage Message/* TCMDialogChar*/)
  {
    Broadcast(Message);
  }

  void _cmDialogKey(TMessage Message /*TCMDialogKey*/)
  {
    Broadcast(Message);
  }

  void _cmEnabledChanged(TMessage Message)
  {
    if(!Enabled && (Parent != null))
      RemoveFocus(false);
    if(HandleAllocated() && !ComponentState.contains(ComponentStates.Designing))
      Windows.EnableWindow(_handle!, Enabled);
  }

  void _cmEnter(TMessage Message)
  {

    DoEnter();
  }

  void _cmExit(TMessage Message)
  {
    DoExit();
  }

  void _cmInvalidate(TMessage Message)
  {
    if(HandleAllocated())
    {
      if(Parent != null)
        Parent!.Perform(CM_INVALIDATE, 1, 0);
      if(Message.WParam == 0)
        Windows.InvalidateRect(_handle!, null, !ControlStyle.contains(ControlStyles.Opaque));
    }
  }

  void _cmFontChanged(TMessage Message)
  {
    super._cmFontChanged(Message);
    if(HandleAllocated())
      Perform(WM_SETFONT, /*FFont.Handle*/ null, 0);
    NotifyControls(CM_PARENTFONTCHANGED);
  }

  void _cmParentCtl3DChanged(TMessage Message)
  {
    if(!_parentCtl3D)
      return;
    if(Message.WParam != 0)
      Ctl3D = Message.LParam != 0;
    else
      Ctl3D = _parent!._ctl3D;
    _parentCtl3D = true;
  }

  void _cmRecreateWnd(TMessage Message)
  {
     bool WasFocused = Focused();
     DestroyHandle();
     UpdateControlState();
     if(WasFocused && (_handle != null))
       Windows.SetFocus(_handle!);
  }

  void _cmSetFocus(TMessage Message)
  {
    if(HandleAllocated())
      Windows.SetFocus(Handle);
  }

  void _cmShowingChanged(TMessage Message)
  {
    int flags = Windows.SWP_NOSIZE | Windows.SWP_NOMOVE |
                Windows.SWP_NOZORDER | Windows.SWP_NOACTIVATE |
                (Showing? Windows.SWP_SHOWWINDOW : Windows.SWP_HIDEWINDOW);
    Windows.SetWindowPos(_handle!, null, 0, 0, 0, 0, flags);
  }

  void _cmShowHintChanged(TMessage Message)
  {
    super.Dispatch(Message);
    NotifyControls(CM_PARENTSHOWHINTCHANGED);
  }


  void _cmVisibleChanged(TMessage Message)
  {
    if(!Visible && (Parent == null))
      RemoveFocus(false);

    if(!ComponentState.contains(ComponentStates.Designing) ||
        ControlStyle.contains(ControlStyles.NoDesignVisible))
      UpdateControlState();
  }

  

  void _cnKeyDown(TWMKey Message)
  {
    Message.Result = 1;
    if(IsMenuKey(Message))
      return;
    if(!ComponentState.contains(ComponentStates.Designing))
    {
      if(Perform(CM_CHILDKEY, Message.CharCode, this) != 0)
        return;
      int Mask = 0;
      switch(Message.CharCode)
      {
        case Windows.VK_TAB:
          Mask = Windows.DLGC_WANTTAB;
          break;
        case Windows.VK_LEFT:
        case Windows.VK_RIGHT:
        case Windows.VK_UP:
        case Windows.VK_DOWN:
          Mask = Windows.DLGC_WANTARROWS;
          break;
        case Windows.VK_RETURN:
        case Windows.VK_EXECUTE:
        case Windows.VK_ESCAPE:
        case Windows.VK_CANCEL:
          Mask = Windows.DLGC_WANTALLKEYS;
          break;
      }
      if((Mask != 0) &&
        (toIntDef(Perform(CM_WANTSPECIALKEY, Message.CharCode, 0), 0) == 0) &&
        ((toIntDef(Perform(WM_GETDLGCODE, 0, 0), 0) & Mask) == 0) &&
        (toIntDef(GetParentForm(this)!.Perform(CM_DIALOGKEY, Message.CharCode, Message.ShiftState), 0) == 0))
          return;
    }
    Message.Result = 0;
  }

  void _cnKeyUp(TWMKey Message)
  {
    if(ComponentState.contains(ComponentStates.Designing))
      return;

    switch(Message.CharCode)
    {
      case Windows.VK_TAB:
      case Windows.VK_LEFT:
      case Windows.VK_RIGHT:
      case Windows.VK_UP:
      case Windows.VK_DOWN:
      case Windows.VK_RETURN:
      case Windows.VK_EXECUTE:
      case Windows.VK_ESCAPE:
      case Windows.VK_CANCEL:
        Message.Result = Perform(CM_WANTSPECIALKEY, Message.CharCode, 0);
        break;
    }
  }

  void _cnChar(TWMKey Message)
  {
    if(ComponentState.contains(ComponentStates.Designing))
      return;
    Message.Result = 1;
    if(((toIntDef(Perform(WM_GETDLGCODE, 0, 0), 0) & Windows.DLGC_WANTCHARS) == 0) &&
      (toIntDef(GetParentForm(this)!.Perform(CM_DIALOGCHAR, Message.CharCode, Message.ShiftState), 0) != 0))
        return;
    Message.Result = 0;
  }

  void _cnCommand(TWMCommand Message) // new
  {
  }


  

  ///  W I N D O W   M E S S A G E S ///

  void _wmCommand(TWMCommand Message)
  {
    if(!DoControlMsg(Message.Ctl, Message.handle))
      super._wmCommand(Message);
  }

  void _wmChar(TWMKey Message) {
    if(DoKeyPress(Message))
      Message.handle.Result = 0;
    else
      super.Dispatch(Message.handle);
  }

  void _wmNCHitTest(TMessage Message)
  {
    if (ComponentState.contains(ComponentStates.Designing) && (_parent != null))
      Message.Result = Windows.HTCLIENT;
    else
      super.Dispatch(Message);

  }

  _wmSetCursor(TMessage Message)
  {
///    with Message do
    if(Message.WParam == _handle)
    {
      List params = Message.LParam;
      int HitTest = params[0];
      switch(HitTest)
      {
        case Windows.HTCLIENT:
          TCursor Cursor = Screen.Cursor;
          if(Cursor == TCursor.Default)
          {
            var P = TPoint.from(Windows.GetCursorPos());
            var Control = ControlAtPos(ScreenToClient(P), false);
            if(Control != null)
              if(Control.ComponentState.contains(ComponentStates.Designing))
                Cursor = TCursor.Arrow;
              else
                Cursor = Control.Cursor;
            if(Cursor == TCursor.Default)
              if(ComponentState.contains(ComponentStates.Designing))
                Cursor = TCursor.Arrow;
              else
                Cursor = _cursor;
          }
          if(Cursor != TCursor.Default)
          {
            Windows.SetCursor(Cursor);
            Message.Result = 1;
            return;
          }
          break;

      }
    }
    super.Dispatch(Message);
  }

  void _wmSetFocus(TMessage Message)
  {
    super.Dispatch(Message);
    // SetIme;
  }

  void _wmKillFocus(TMessage Message)
  {
    super.Dispatch(Message);
    
  }

  void _wmKeyDown(TWMKey Message) {
    if(!DoKeyDown(Message))
      super.Dispatch(Message.handle);
  }

  void _wmKeyUp(TWMKey Message) {
    if(!DoKeyUp(Message))
      super.Dispatch(Message.handle);
  }

  void _wmHScroll(TMessage Message){ 
    if(!DoControlMsg(Message.LParam, Message))
      super.Dispatch(Message);
  }

  void _wmVScroll(TMessage Message)
  {
    if(!DoControlMsg(Message.LParam, Message))
      super.Dispatch(Message);
  }

  void _wmSetFont(TMessage Message)
  {
    super._wmSetFont(Message);
    if(HandleAllocated())
    {
      if(_parentFont)
        Windows.SelectFont(_handle!, null);
      else
        Windows.SelectFont(_handle!, Message.WParam == null? _font : Message.WParam);
    }
  }

  void _wmSize(TWMSize Message)
  {
    UpdateBounds();
    super._wmSize(Message);
    Realign();
    if(!(ComponentState.contains(ComponentStates.Loading)))
      Resize();
  }

  void _wmMove(TWMMove Message)
  {
    super._wmMove(Message);
    UpdateBounds();
  }

  void _wmPaint(TWMPaint Message)
  {
    
  }

  void _wmWindowPosChanged(TWMWindowPosMsg Message)
  {
    var flags = Message.WindowPos.flags;

    bool Framed = _ctl3D && (ControlStyle.contains(ControlStyles.Framed)) && (Parent != null) &&
      (flags & Windows.SWP_NOREDRAW == 0);
    bool Moved = (flags & Windows.SWP_NOMOVE == 0) && Windows.IsWindowVisible(_handle!);
    bool Sized = (flags & Windows.SWP_NOSIZE == 0) && Windows.IsWindowVisible(_handle!);
    if(Framed && (Moved || Sized))
      InvalidateFrame();
    if(!ControlState.contains(ControlStates.DestroyingHandle))
      UpdateBounds();
    super._wmWindowPosChanged(Message);
    if(Framed && ((Moved || Sized) || (flags & (Windows.SWP_SHOWWINDOW | Windows.SWP_HIDEWINDOW) != 0)))
      InvalidateFrame();
  }

  void _wmWindowPosChanging(TWMWindowPosMsg Message)
  {
    if((ComponentState * [ComponentStates.Reading, ComponentStates.Destroying]).isEmpty)
    {
      var pos = Message.WindowPos;

      if(!pos.flags.and(Windows.SWP_NOSIZE))
      {
        Integer cx = Integer(pos.cx);
        Integer cy = Integer(pos.cy);
        if(!CheckNewSize(cx, cy))
          pos.flags |= Windows.SWP_NOSIZE;
        pos.cx = cx.Value;
        pos.cy = cy.Value;
      }
    }
    super._wmWindowPosChanging(Message);

  }

}

class TGraphicControl extends TCustomControl
{
  TGraphicControl(TComponent AOwner) : super(AOwner)
  {

  }

  void CreateWindowHandle(TCreateParams Params)
  {

    WindowHandle = HWND( canvasElement );
    WindowHandle!.style.position="absolute";
    Canvas.Handle = HCanvasDC(canvasElement);

  }

  void CreateWnd()
  {
    super.CreateWnd();
    Canvas.Handle.init();
  }



}

TClass THintWindowClass = THintWindow.classType;

class THintWindow extends TCustomControl
{


  static TClass get classType => TClass( THintWindow, (AOwner) => THintWindow(AOwner) );

  THintWindow(TComponent AOwner) : super(AOwner)
  {


  }

  String
    get Caption => _getText();
    set Caption(String Value) => _setText(Value);

  bool _activating = false;
  int  _lastActive = 0;

  void CreateParams(TCreateParams Params)
  {
    super.CreateParams(Params);

    Params.Style = Windows.WS_POPUP | Windows.WS_BORDER;

  }

  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HHint();
  }

  void _wmNCHitTest(TMessage Message)
  {
    Message.Result = Windows.HTTRANSPARENT;
  }
  

  bool IsHintMsg(MSG Msg)
  {

    return
      ((Msg.message >= WM_KEYFIRST) && (Msg.message <= WM_KEYLAST)) ||
      ((Msg.message == CM_ACTIVATE) || (Msg.message == CM_DEACTIVATE)) ||

      (Msg.message == WM_COMMAND) || ((Msg.message > WM_MOUSEMOVE) &&
      (Msg.message <= WM_MOUSELAST)) ;
  }

  void ReleaseHandle()
  {
    DestroyHandle();
  }

  void _cmTextChanged(TMessage Message)
  {
    super._cmTextChanged(Message);
    // Avoid flicker when calling ActivateHint
    if(_activating)
      return;
    TRect rect = CalcHintRect(Screen.Width, Caption, null);
    SetSize(rect.width, rect.height);
  }

  void ActivateHint(TRect _rect, String AHint)

  {
    TRect Rect = _rect.copy();
    _activating = true;
    try
    {
      Caption = AHint;

      UpdateBoundsRect(Rect);
      if(Rect.top + Height > Screen.DesktopHeight)
        Rect.top = Screen.DesktopHeight - Height;
      if(Rect.left + Width > Screen.DesktopWidth)
        Rect.left = Screen.DesktopWidth - Width;
      if(Rect.left < Screen.DesktopLeft)
        Rect.left = Screen.DesktopLeft;
      if(Rect.bottom < Screen.DesktopTop)
        Rect.bottom = Screen.DesktopTop;

      Windows.SetWindowPos(Handle, HWND_TOPMOST,
          Rect.left, Rect.top, Width, Height, Windows.SWP_NOACTIVATE);
      if((Windows.GetTickCount() - _lastActive > 250) && (AHint.length < 100) )
      {

      }
      Windows.ShowWindow(Handle, Windows.SW_SHOWNOACTIVATE);

    }
    finally
    {
      _lastActive = Windows.GetTickCount();
      _activating = false;
    }
  }

  ActivateHintData(TRect Rect, String AHint, dynamic AData)
  {
    ActivateHint(Rect, AHint);
  }

  TRect CalcHintRect(int MaxWidth, String AHint, dynamic AData)
  {

    int w = MaxWidth ~/ 4;
    if(w<100) w = 100;

    Element elem = Handle.handle;
    Element? prnt = elem.parent;
    if(prnt==null)
      document.body!.append(elem);

    var rect = RECT();
    elem.invisibilityProc(()
    {
      elem.style.width = null;
      elem.style.height = null;
      elem.style.display = 'inline-block';
      elem.text = AHint;
      rect = elem.borderRect;
      if(rect.width > w)
      {
        elem.width = w;
        rect = elem.borderRect;
      }
    });
    if(prnt==null)
      elem.remove();

    return TRect(0, 0, rect.width+4, rect.height);
  }

  

  /*void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_SHOWWINDOW:
        if(Message.WParam == false && HandleAllocated())
          Handle.handle.remove();
        break;
    }
    super.WndProc(Message);
  }*/
}





class TCustomControl extends TWinControl
{

  TCanvas? _canvas;
  TCanvas get Canvas => _canvas!;


  TCustomControl(TComponent AOwner) : super(AOwner)
  {
    _canvas = TControlCanvas(this);
  }

  final canvasElement = CanvasElement();

  void CreateWindowHandle(TCreateParams Params)
  {
    super.CreateWindowHandle(Params);
    WindowHandle!.handle.append(canvasElement);
    canvasElement.owner = WindowHandle;
    _canvas!.Handle = HCanvasDC(canvasElement);

  }





  void _wmPaint(TWMPaint Message)
  {
    _controlState << ControlStates.CustomPaint;
    Paint();
    _controlState >> ControlStates.CustomPaint;
  }

  void _wmWindowPosChanged(TWMWindowPosMsg Message)
  {
    var rect = ClientRect;
    canvasElement.width = rect.width;
    canvasElement.height = rect.height;
    Windows.InvalidateRect(Handle, null, true);
  }




  void Paint()
  {

  }
}


abstract class TCustomListControl extends TWinControl
{

  TCustomListControl(TComponent AOwner) : super(AOwner)
  {

  }

  int GetCount();
  int GetItemIndex();
  void SetItemIndex(int Value);

  void AddItem(String Item, TObject AObject);
  void Clear();
  void ClearSelection();
  void CopySelection(TCustomListControl Destination);
  void DeleteSelected;
  void SelectAll();
  int get ItemIndex => GetItemIndex();
  void set ItemIndex(int Value) => SetItemIndex(Value);

  void MoveSelection(TCustomListControl Destination)
  {
    CopySelection(Destination);
    DeleteSelected;
  }
}

abstract class TCustomMultiSelectListControl extends TCustomListControl
{
  bool _multiSelect = false;
  int GetSelCount();
  void SetMultiSelect(bool Value);

  bool get MultiSelect => _multiSelect;
  void set MultiSelect(bool Value) => SetMultiSelect(Value);
  int get SelCount => GetSelCount();

  TCustomMultiSelectListControl(TComponent AOwner) : super(AOwner)
  {

  }
}

