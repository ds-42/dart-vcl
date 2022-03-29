part of vcl;

typedef void WNDPROC(Element elem, TMessage msg);

/*
 *   HTML elements as logic window descriptors (HWND)
 */

enum WindowProp {
  ChildOwner, // Object as owner of child elements
}

typedef TWndStyle WND_RULE_BUILDER(CLASS_ID classId);

class TWndStyle
{
  static final _styleHandle = StyleElement();
  static CssStyleSheet? _styleSheet;
  static final _styles = <String>{ };

  late final CssStyleSheet sheet;
  final CLASS_ID classId;

  TWndStyle(this.classId)
  {
    if(_styleSheet==null)
    {
      document.head!.append(_styleHandle);
      _styleSheet = _styleHandle.sheet as CssStyleSheet;
    }

    sheet = _styleSheet!;
  }

  static WND_RULE_BUILDER _create = (cid) => TWndStyle(cid);
  static void use_builder(WND_RULE_BUILDER fnc) => _create = fnc;

  static TWndStyle create(CLASS_ID cid) => _create(cid);


  void add(String ext, String data)
  {
    if(ext.isEmpty)
      sheet.addRule('.$classId', data);
    else
      sheet.addRule('.$classId $ext', data);
  }

  void addRule(String name, String data)
  {
    sheet.addRule(name, data);
  }

  String get block =>
    'display:block;'
    'position:absolute;';

  String get flex =>
    'display:flex;'
    'position:absolute;';

  String get borderBox =>
    '-moz-box-sizing:border-box;'
    '-webkit-box-sizing:border-box;'
    'box-sizing:border-box;';

  String get font =>
    'font-family:${ Windows.sysFontFamily };'
    'font-size:${ Windows.sysFontSize }pt;';

  String get inline =>
    'white-space:nowrap;'
    'overflow:hidden;'
    'text-overflow:ellipsis;';

  String get no_select =>
    'user-select:none;'
    '-webkit-user-select:none;'
    '-moz-user-select:none;'
    '-ms-user-select:none;';

  String get softBorder =>
    'border: 1px solid #A0A0A0;';

  void addFocusStyle([subClass='focus-within'])
  {
    sheet.addRule('.$classId:$subClass',
      'outline: #4D90FE solid 1px;'
      'outline-offset: 0;');

  }

}

class CLASS_ID
{

  final String name;

  CLASS_ID(this.name);

  String toString() => name;

  void defineRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }');
  }
}

class INITSTRUCT
{
  final UINT? exStyle;
  // final String? className;
  final String? windowName;
  final UINT? style;
  final int? x;
  final int? y;
  final int? width;
  final int? height;
  final HWND? parent;
  // final HMENU hMenu;
  // final HINSTANCE hInstance;
  final dynamic param;

  INITSTRUCT({ this.exStyle, this.windowName, this.style,
    this.x, this.y, this.width, this.height, this.parent,
    this.param});
}

class HWINDOW
{
  const HWINDOW();
}

class CWND extends HWINDOW
{
  final int id;
  const CWND(this.id) : super();
}

class HWND extends HWINDOW
{
  static final _elements = Map<Element, HWND>();
  static final _subElements = Map<Element, HWND>();

  static HWND? findWindow(Element elem) =>
    _findWindowDef(elem, null);

  static HWND? _findWindowDef(Element elem, HWND? def)
  {

    HWND findOwnedWindow(HWND hwnd)
    {
      HWND? tmp = hwnd;
      while(tmp!=null)
      {
        hwnd = tmp;
        tmp = _subElements[tmp.handle];
      }
      return hwnd;
    }

    HWND? hwnd = _elements[elem]; // find window by elements
    if(hwnd==null)
      hwnd = _subElements[elem]; // find window by sub-elements

    if(hwnd!=null)
      return findOwnedWindow(hwnd);

    while(true) 
    {
      hwnd = _elements[elem];
      if(hwnd==null)
      {
        if(elem.parent == null)
          break;
        elem = elem.parent!;
      }
      else
      {
        if(hwnd.props.contains(WindowProp.ChildOwner))
          return findOwnedWindow(hwnd); 
        return def;
      }
    }
    return def;
  }

  final Element handle; /// using html element

  final props = <WindowProp>{ };

  Element getClientHandle() => handle;
  Element get clientHandle => getClientHandle();

  late final WND _wnd;

  HWND._(this.handle)
  {
    if(HWND._elements.containsKey(handle))
      throw UnsupportedError('duplicate handles');

    if(HWND._elements.isEmpty)
      Windows._start();

    var cid = classID;
    if(cid.name.isNotEmpty)
    { // class registry
      if(TWndStyle._styles.add(cid.name))
      {
        var rule = TWndStyle.create(cid);
        defineClassRule(rule);
      }
      handle.className = cid.name;
    }

    HWND._elements[handle] = this;

    _wnd = WND(this);
  }

  factory HWND(Element? elem)
  {
    if(elem == null)
      elem = document.body;

    var hwnd = HWND._elements[elem];
    if(hwnd == null)
      hwnd = HWND._(elem!); // window registry

    return hwnd;
  }

  void release()
  {
    if(handle.parent != null)
      handle.remove();

    HWND._elements.remove(handle);
    HWND._subElements.removeWhere((item, val) => val==handle);
  }

  CLASS_ID get classID => CLASS_ID('');

  void defineClassRule(TWndStyle rule)
  {
    rule.classId.defineRule(rule);
  }

  CssStyleDeclaration get style => handle.style;
  CssStyleDeclaration get clientStyle => clientHandle.style;

  void dispatch(Element elem, TMessage message)
  {
    _default_element_proc(elem, message);
  }

  set owner(HWND? hwnd)
  {
    if(hwnd == null)
      HWND._subElements.remove(handle);
    else
      HWND._subElements[handle] = hwnd;
  }

  HWND? getParent()
  {
    if(handle.parent==null)
      return null;
    return HWND.findWindow(handle.parent!);
  }

  void setParent(HWND? hWndNewParent)
  {
    if(hWndNewParent == null)
      handle.remove();
    else
    if(!hWndNewParent.clientHandle.children.contains(handle))
      hWndNewParent.clientHandle.append(handle);
  }

  void setColor(TColor clr)
  {
    style.backgroundColor = clr.html;
  
  }

  bool
    get enabled => handle.enabled;
    set enabled(bool state) => handle.enabled = state;

  bool
    get visible => handle.visible;

  void show() => _wnd.visible = true;
  void hide() => _wnd.visible = false;

  bool get_border_size(SIZE size)
  {
    return toBoolDef(handle.invisibilityProc(()
    {
      if(handle.offsetParent != null)
      {
        var bs = handle.borderSize;
        size.cx = bs.cx;
        size.cy = bs.cy;
        return true;
      }
      return false;
    }), false);
  }

  void set_window_rect(int left, int top, int width, int height)
  {
    handle.updateBounds(left, top, width, height);
  }
}

void _default_element_proc(Element elem, TMessage Message)
{

  if(Message.Msg is COMBOBOX_MESSAGE || Message.Msg is LISTBOX_MESSAGE)
  {
    _default_select_proc(elem as SelectElement, Message);
    return;
  }

  if(Message.Msg is EDIT_MESSAGE)
  {
    _default_text_area_proc(elem as TextAreaElement, Message);
    return;
  }

  switch(Message.Msg)
  {
    case WM_NCCREATE:
      Message.Result = 1;
      break;

    case WM_CREATE:
      Message.Result = 0;
      break;

    case WM_NCCALCSIZE:
      Message.Result = 0;
      break;

    case WM_GETTEXT:
      if(elem is InputElement)
        Message.Result = elem.value;
      else
      if(elem is TextAreaElement)
        Message.Result = elem.value;
      else
        Message.Result = elem.text;
      break;

    case WM_SETTEXT:
      if(elem is InputElement)
        elem.value = Message.LParam;
      else
      if(elem is TextAreaElement)
        elem.value = Message.LParam;
      else
        elem.text = Message.LParam;
      break;

    case WM_ENABLE:
      bool state = toBoolDef(Message.WParam, false);
      elem.style.pointerEvents = state? '' : 'none';
      if(elem is ButtonElement)
        elem.disabled = !state;
      break;

    case WM_NCHITTEST:
      if(!HWND._elements.containsKey(elem))
      { // unregistered element
        if(elem is DivElement || elem is SpanElement)
        { // skip overlay elements
          Message.Result = Windows.HTNOWHERE;
          return;
        }
      }

      POINT pt = Message.LParam;

      Rectangle rect = elem.getBoundingClientRect();
      if(pt.x>=rect.left && pt.x<=rect.right && pt.y>=rect.top && pt.y<=rect.bottom)
        Message.Result = Windows.HTCLIENT;
      else
        Message.Result = Windows.HTNOWHERE;
      return;

    case WM_LBUTTONUP:
      var wnd = HWND.findWindow(elem);
      if(wnd!=null)
      {
        if(wnd is HButtonControl) 
        {
          Element? prnt = wnd.handle.parent;
          if(prnt != null)
          {
            var pWnd = HWND.findWindow(prnt);
            if(pWnd!=null)
              Windows.SendMessage(pWnd, WM_COMMAND, TCommand(0, 0), wnd);
          }
        }
      }
      return;

    case WM_GETDLGCODE:  
      Message.Result = Windows.DLGC_WANTARROWS | Windows.DLGC_WANTALLKEYS;
      break;
  }
}

void _default_select_proc(SelectElement elem, TMessage Message)
{
  int SHIFT()
  { 
    if(elem.length==0)
      return 0;
    OptionElement item = elem.options[0];
    return (item.value=='null' && item.hidden && item.disabled)? 1 : 0;
  }

  if(Message.Msg == CB_RESETCONTENT)
  {
    OptionElement? empty = SHIFT()>0? elem.options[0] : null;
    elem.innerText='';
    if(empty!=null)
    {
      elem.children.add(empty);
      elem.selectedIndex=0;
    }
    else
      elem.selectedIndex=-1;
    return;
  }

  if(Message.Msg == CB_GETCURSEL)
  {
    Message.Result = elem.selectedIndex!-SHIFT();
    return;
  }

  if(Message.Msg == CB_SETCURSEL)
  {
    elem.selectedIndex=Message.WParam+SHIFT();
    return;
  }

  if(Message.Msg == LB_GETCOUNT || Message.Msg == CB_GETCOUNT)
  {
    Message.Result = elem.length!-SHIFT();
    return;
  }

  if(Message.Msg == CB_GETLBTEXT)
  {
    OptionElement item = elem.options[Message.WParam+SHIFT()];
    Message.Result = item.text;
    return;
  }

  if(Message.Msg == LB_ADDSTRING || Message.Msg == CB_ADDSTRING)
  {
    OptionElement option = OptionElement(data: Message.LParam);
    elem.children.add(option);
    Message.Result = elem.length!-1-SHIFT();
    return;
  }

  

  throw UnsupportedError('Unknown message: $Message');
}

void _default_text_area_proc(TextAreaElement elem, TMessage Message)
{
  switch(Message.Msg)
  {
    case EM_GETLINE:
      List<String> lst = elem.value!.split('\n');
      Message.Result = lst[Message.WParam];
      return;

    case EM_GETLINECOUNT:
      Message.Result = elem.value!.split('\n').length;
      return;

    case EM_LINEINDEX:
      List<String> lst = elem.value!.split('\n');
      int ndx = Message.WParam;
      int res = 0;
      for(String s in lst)
      {
        if(ndx-- == 0)
          break;
        res+=s.length+1;
      }
      Message.Result = res;
      return;

    case EM_LINELENGTH:
      List<String> lst = elem.value!.split('\n');
      Message.Result = lst[Message.WParam].length;
      return;

    case EM_REPLACESEL:
      elem.setRangeText(Message.LParam);
      return;

    case EM_SETSEL:
      elem.setSelectionRange(Message.WParam, Message.LParam);
      return;

    case EM_LIMITTEXT:
      return;

    default:
      throw UnsupportedError('Unknown message: $Message');
  }
}


