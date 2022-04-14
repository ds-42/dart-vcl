part of vcl;

class TTCItem
{
    int mask = 0;

    String? pszText;


    dynamic lParam;
}

class HTabControl extends HCustomControl
{
  static final TABCONTROL = CLASS_ID('TABS');
  CLASS_ID get classID => TABCONTROL;

  static final tab_area = 'tab-area';
  static final tab_client = 'tab-client';
  static final tab_li = 'tab-li';
  static final tab_radio = 'tab-radio';
  static final tab_ul = 'tab-ul';

  void defineClassRule(TWndStyle rule)
  {
    String name = classID.name;
    rule.add('',
      'position: absolute;'
      'box-sizing: border-box;'
      'overflow: hidden;'
      'width: 100%;'
      'height:100%;');
    rule.addRule('.$name .$tab_ul',
      'overflow: hidden;'
      'white-space: nowrap;');
    rule.addRule('.$name .$tab_ul, .$name .$tab_li',
      'margin: 0;'
      'padding: 0;'
      'list-style: none;'
      '${ rule.borderBox}');
    rule.addRule('.$name, .$name .$tab_radio:checked+label',
      'position: relative;');
    rule.addRule('.$name .$tab_li, .$name .$tab_radio+label',
      'display: inline-block;'
      'user-select: none;');
    rule.addRule('.$name .$tab_radio',
      'position: absolute;');
    rule.add('.$tab_li',
      'vertical-align: top;');
    rule.add('.$tab_li:first-child',
      'margin-left: 4px;');
    rule.add('.$tab_radio+label',
      'margin: 0 2px 0 0;'
      'padding: 0 5px;'
      'line-height: 20px;'
      'background: #ccc;'
      'color: gray;'
      'text-align: center;'
      'border-radius: 3px 3px 0 0;'
      'border: 1px solid #999;' 
      '${ rule.borderBox}');
    rule.add('.$tab_radio:checked+label',
      'z-index: 1;'
      'color: black;'
      'background: #ddd;'
      'border-bottom-color: #ddd;'
      'cursor: default;');
    rule.add('.$tab_radio',
      'display: none;');
    rule.add('.$tab_radio:disabled+label',
      'opacity: .5; cursor: no-drop;');
    rule.add('.$tab_area',
      'position: absolute;'
      'inset: 21px 0 0;'
      'border: 1px solid #a0a0a0;');
    rule.add('.$tab_client',
      'position: absolute;'
      'inset: 2px;'
      'overflow: hidden;');
  }

  final tabs = Map<Element, HTabButton>();
  final ul = UListElement();

  final area = DivElement();
  final client = DivElement();

  Element getClientHandle() => client;

  HTabControl() : super()
  {
    props << WindowProp.ChildOwner;

    ul.className = tab_ul;
    handle.append(ul);

    handle.append(area);
    area.className = tab_area;

    area.append(client);
    client.className = tab_client;

    updateTabVisible();
  }

  HTabButton? getTabButton(int ndx)
  {
    if(ndx>=0 && ndx<ul.children.length)
    {
      var elem = ul.children[ndx];
      if(tabs.containsKey(elem))
        return tabs[elem];
    }
    return null;
  }

  int indexOfTabButton(HTabButton tab) =>
    ul.children.indexOf(tab.handle);

  HTabButton insertTab(int ndx, String caption)
  {
    var tab = HTabButton();
    ul.children.insert(ndx, tab.handle);
    tab.caption = caption;
    tab.radio.name = 'tabs-${ hashCode.toString() }';
    tab.radio.onChange.listen((event)
    {
      Windows.SendMessage(this, WM_NOTIFY, 0, NMHDR(null, 0, TCN_SELCHANGING));
      Windows.SendMessage(this, WM_NOTIFY, 0, NMHDR(null, 0, TCN_SELCHANGE));
    });
    tabs[tab.handle] = tab;
    if(tabs.length == 1)
      tab.active = true;
    updateTabVisible();
    return tab;
  }

  bool deleteTab(int ndx)
  {
    var tab = getTabButton(ndx);
    if(tab == null)
      return false;

    ul.children.remove(tab.handle);
    tabs.remove(tab.handle);

    if(tabs.isNotEmpty)
    { // change active tab
      if(ndx >= tabs.length)
        ndx = tabs.length - 1;
      tab = getTabButton(ndx);
      if(tab != null)
        tab.active = true;
    }
    updateTabVisible();
    return true;
  }

  bool _showTab = true;
  bool
    get showTab => _showTab;
    set showTab(bool state)
    {
      if(_showTab == state)
        return;
      _showTab = state;
      updateTabVisible();
    }

  void updateTabVisible()
  {
    bool state = _showTab && ul.children.isNotEmpty;
    if(ul.visible != state)
    {
      ul.visible = state;
      area.style.top = state? null : '0';
    }
  }

  void dispatch(Element elem, TMessage Message)
  {
//    print(Message);
    switch(Message.Msg)
    {
      case TCM_GETCURSEL:
        int ndx = 0;
        for(var tab in tabs.values)
        {
          if(tab.active)
          {
            Message.Result = indexOfTabButton(tab);
            return;
          }
          ndx++;
        }
        Message.Result=-1;
        break;

      case TCM_SETCURSEL:
        var tab = getTabButton(Message.WParam);
        if(tab == null)
        {
          for(var tab in tabs.values)
            if(tab.active)
            {
              tab.active = false;
              break;
            }
        }
        else
          tab.active = true;
        break;

      case TCM_INSERTITEM:
        TTCItem item = Message.LParam;
        String? caption;
        if(item.mask & TCIF_TEXT == TCIF_TEXT)
          caption = item.pszText;
        var tab = insertTab(Message.WParam, caption ?? '');
        Message.Result = indexOfTabButton(tab);
        break;

      case TCM_GETITEM:
        var tab = getTabButton(Message.WParam);
        if(tab != null)
        {
          TTCItem item = Message.LParam;
          if(item.mask.and(TCIF_TEXT))
            item.pszText = tab.caption;
          if(item.mask.and(TCIF_PARAM))
            item.lParam = tab.tabParam;
          Message.Result = TRUE;
        }
        break;

      case TCM_SETITEM:
        var tab = getTabButton(Message.WParam);
        if(tab != null)
        {
          TTCItem item = Message.LParam;
          if(item.mask.and(TCIF_TEXT) && item.pszText!=null)
            tab.caption = item.pszText!;
          if(item.mask.and(TCIF_PARAM))
            tab.tabParam = item.lParam;
          Message.Result = TRUE;
        }
        break;

      case TCM_DELETEITEM:
        Message.Result = deleteTab(Message.WParam)? TRUE : FALSE;
        return;

      case TCM_ADJUSTRECT:
        var rect = Message.LParam as RECT;
        client.invisibilityProc(()
        {
          var r = client.offsetRect;
          rect.left = 0;
          rect.top = 0;
          rect.width = r.width;
          rect.height = r.height;
        });
        return;

      case WM_LBUTTONDOWN:
        _scrollDown = ul.scrollLeft + (Message.LParam as POINT).x;
        return;

      case WM_LBUTTONUP:
        _scrollDown = null;
        return;

      case WM_MOUSEMOVE:
        int x = (Message.LParam as POINT).x;
        if(_scrollDown != null)
          ul.scrollLeft = _scrollDown! - x;
        return;

      default:
        super.dispatch(elem, Message);
        break;
    }
  }

  int? _scrollDown;
}

class HTabButton
{
  final handle = LIElement();
  final radio = RadioButtonInputElement();
  late final LabelElement label;

  dynamic tabParam;

  HTabButton()
  {
    String name = 'tab-$hashCode';
    handle.className = HTabControl.tab_li;
    handle.append(radio);
    radio.className = HTabControl.tab_radio;
    radio.id=name;

    label = Element.html('<label for="$name">...</label>') as LabelElement;
    handle.append(label);
  }

  bool
    get active => radio.checked ?? false;
    set active(bool state) => radio.checked = state;

  String
    get caption => label.text ?? '';
    set caption(String s) => label.text = s;
}
