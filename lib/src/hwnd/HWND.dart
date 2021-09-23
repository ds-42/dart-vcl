part of vcl;

typedef void WNDPROC(Element elem, TMessage msg);



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
  static final _classes = <String>{ };

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

class _HWND { }

class HWND extends _HWND
{
  static final _elements = Map<Element, HWND>();
  static final _subElements = Map<Element, HWND>();

  final Element handle; /// using html element

  final props = <WindowProp>{ };

  Element getClientHandle() => handle;
  Element get clientHandle => getClientHandle();

  WNDPROC _mainProc = _default_element_proc;

  HWND._(this.handle)
  {
    if(_elements.isEmpty)
      Windows._start();

    if(_elements.containsKey(handle))
      throw UnsupportedError('duplicate handles');

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

    _elements[handle] = this;

    _mainProc = (elem, message) =>
      dispatch(elem, message);
  }

  factory HWND(Element? elem)
  {
    if(elem == null)
      elem = document.body;

    HWND? hwnd = _elements[elem];
    if(hwnd==null)
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

  static final DESKTOP = HWND( document.body );

  static final BOTTOM    = _HWND();
  static final NOTOPMOST = _HWND();
  static final TOP       = _HWND();
  static final TOPMOST   = _HWND();

  set owner(HWND? hwnd)
  {
    if(hwnd == null)
      _subElements.remove(handle);
    else
      _subElements[handle] = hwnd;
  }

  void setParent(HWND? hWndNewParent)
  {
    if(hWndNewParent == null)
      handle.remove();
    else
      hWndNewParent.clientHandle.append(handle);
  }

  void setColor(TColor clr)
  {
    style.backgroundColor = clr.html;
  
  }




  /// init window
  static void _init_window(HWND hwnd, HWND? prnt, int? x, int? y, int? cx, int? cy)
  {
    hwnd.setParent(prnt);
    // emulate messages after create window
    

    var r1 = hwnd.handle.borderEdge;
    if(x!=null || y!=null || cx!=null || cy!=null)
      Windows.SetWindowPos(hwnd, null, x, y, cx, cy, 0);

    var r2 = hwnd.handle.borderEdge;
    if(r1.width==r2.width || r1.height==r2.height)
    {
      
      Windows.SendMessage(hwnd, WM_SIZE, null, TPoint(r2.width.round(), r2.height.round()));
    }
  }

  static HWND? findWindow(Element elem) =>
    HWND._findWindowDef(elem, null);

  static HWND? _findWindowDef(Element elem, HWND? def)
  {

    HWND findOwnedWindow(HWND hwnd)
    {
      HWND? tmp = hwnd;
      while(tmp!=null)
      {
        hwnd = tmp;
        tmp = HWND._subElements[tmp.handle];
      }
      return hwnd;
    }

    HWND? hwnd = HWND._elements[elem]; // find window by elements
    if(hwnd==null)
      hwnd = HWND._subElements[elem]; // find window by sub-elements

    
    if(hwnd!=null)
      return findOwnedWindow(hwnd);

    while(true) 
    {
      hwnd = HWND._elements[elem];
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
}

void _default_element_proc(Element elem, TMessage Message)
{

  void wmWindowPosChanging(TWindowPos pos)
  {


    Rectangle b = elem.borderEdge;
    Rectangle m = elem.marginEdge;

    String? left, top, width, height;

    String valPx(int val) => val==0? '0' : '${val}px';

    if(pos.x!=null)
      left = valPx(pos.x!-b.left.toInt()+m.left.toInt());
    if(pos.y!=null)
      top = valPx(pos.y!-b.top.toInt()+m.top.toInt());
    if(pos.cx!=null)
      width = valPx(pos.cx!);
    if(pos.cy!=null)
      height = valPx(pos.cy!);

    bool moved = false;
    if(left!=null && left!=elem.style.left)
    {
      elem.style.left = left;
      moved = true;
    }

    if(top!=null && top!=elem.style.top)
    {
      elem.style.top = top;
      moved = true;
    }

    bool sized = false;
    if(width!=null && width!=elem.style.width)
    {
      elem.style.width = width;
      sized = true;
    }

    if(height!=null && height!=elem.style.height)
    {
      elem.style.height = height;
      sized = true;
    }

    if(elem.parent!=null && (moved || sized))
    {
      var hWnd = HWND.findWindow(elem);
      if(hWnd==null)
        return;

      Rectangle rect = elem.offset;
      if(moved)
        Windows.SendMessage(hWnd, WM_MOVE, null, TPoint(rect.left.toInt(), rect.top.toInt()));
      if(sized)
        Windows.SendMessage(hWnd, WM_SIZE, null, TPoint(rect.width.toInt(), rect.height.toInt()));
    }
  }

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

    case WM_SHOWWINDOW:
      elem.style.display = Message.WParam ? null : 'none';
  
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

      TPoint pt = Message.LParam;

      Rectangle rect = elem.getBoundingClientRect();
      if(pt.x>=rect.left && pt.x<=rect.right && pt.y>=rect.top && pt.y<=rect.bottom)
        Message.Result = Windows.HTCLIENT;
      else
        Message.Result = Windows.HTNOWHERE;
      return;

    case WM_LBUTTONUP:
      HWND? wnd = HWND.findWindow(elem);
      if(wnd!=null)
      {
        
        if(wnd is HButtonControl)
        {
          Element? prnt = wnd.handle.parent;
          if(prnt != null)
          {
            HWND? pWnd = HWND.findWindow(prnt);
            if(pWnd!=null)
              Windows.SendMessage(pWnd, WM_COMMAND, TCommand(0, 0), wnd);
          }
        }
      }
      return;

    case WM_WINDOWPOSCHANGING:
      wmWindowPosChanging(Message.LParam);
      break;

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


