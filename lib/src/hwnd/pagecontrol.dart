part of vcl;

class TTCItem
{
    int mask = 0;

    String? pszText;
/*    int cchTextMax;
    int iImage;**/

    dynamic lParam;
}

class HPageControl extends HCustomControl
{
  static final PAGECONTROL = CLASS_ID('PAGECONTROL');
  CLASS_ID get classID => PAGECONTROL;

  void defineClassRule(TWndStyle rule)
  {
    String name = classID.name;
    rule.add('',
      'position: absolute;'
      'box-sizing: border-box;'
      'width: 100%;'
      'height:100%;');
    rule.addRule('.$name .tab-ul, .$name .tab-li',
      'margin: 0;'
      'padding: 0;'
      'list-style: none;'
      '${ rule.borderBox}');
    rule.addRule('.$name, .$name .tab-radio:checked+label',
      'position: relative;');
    rule.addRule('.$name .tab-li, .$name .tab-radio+label',
      'display: inline-block;'
      'user-select: none;');
    rule.addRule('.$name .tab-li > div, .$name .tab-radio',
      'position: absolute;');
    rule.addRule('.$name .tab-li > div, .$name .tab-radio+label',
      'border: solid 1px #ccc;');
    rule.add('.tab-li',
      'vertical-align: top;');
    rule.add('.tab-li:first-child',
      'margin-left: 4px;');
    rule.add('.tab-li > div',
      'top: 21px;'
      'bottom: 0;'
      'left: 0;'
      'width: 100%;'
      'padding: 4px;'
      'overflow: auto;'
      'border: 1px solid #a0a0a0;'
      '${ rule.borderBox}');
    rule.add('.tab-radio+label',
      'margin: 0 2px 0 0;'
      'padding: 0 5px;'
      'line-height: 20px;'
      'background: #ccc;'
      'color: gray;'
      'text-align: center;'
      'border-radius: 3px 3px 0 0;'
      'border: 1px solid #999;' 
      '${ rule.borderBox}');
    rule.add('.tab-radio:checked+label',
      'z-index: 1;'
      'color: black;'
      'background: #ddd;'
      'border-bottom-color: #ddd;'
      'cursor: default;');
    rule.add('.tab-radio',
      'opacity: 0;');
    rule.add('.tab-radio~div',
      'display: none;');
    rule.add('.tab-radio:checked:not(:disabled)~div',
      'display: block;');
    rule.add('.tab-radio:disabled+label',
    'opacity: .5; cursor: no-drop;');
  }

  final _tabs = Map<Element, HTabSheet>();
  final _ul = UListElement();

  Element getClientHandle() => _ul;
  HPageControl() : super()
  {
    _ul.className='tab-ul';
    handle.append(_ul);
  }

  HTabSheet? getTabSheet(int ndx)
  {
    if(ndx>=0 && ndx<_ul.children.length)
    {
      var elem = _ul.children[ndx];
      if(_tabs.containsKey(elem))
        return _tabs[elem];
    }
    return null;
  }

  HTabSheet? findTabSheet(dynamic param)
  {
    for(var tab in _tabs.values)
      if(tab.tabParam == param)
        return tab;
    return null;
  }

  int indexOfTabSheet(HTabSheet tab) =>
    _ul.children.indexOf(tab.handle);

  HTabSheet insertPage(int ndx, String caption)
  {
    HTabSheet tab = HTabSheet();
    _ul.children.insert(ndx, tab.handle);
//    _ul.append(tab.handle);
    tab.caption = caption;
    tab.radio.name = 'page-${ hashCode.toString() }';
    tab.radio.onChange.listen((event)
    {
      Windows.SendMessage(this, WM_NOTIFY, 0, NMHDR(null, 0, TCN_SELCHANGING));
      Windows.SendMessage(this, WM_NOTIFY, 0, NMHDR(null, 0, TCN_SELCHANGE));
    });
    _tabs[tab.handle] = tab;
    if(_tabs.length == 1)
      tab.radio.checked = true;
    return tab;
  }

  void dispatch(Element elem, TMessage Message)
  {
    switch(Message.Msg)
    {
      case TCM_GETCURSEL:
        int ndx = 0;
        for(var tab in _tabs.values)
        {
          if(tab.radio.checked ?? false)
          {
            Message.Result = indexOfTabSheet(tab);
            return;
          }
          ndx++;
        }
        Message.Result=-1;
        break;

      case TCM_SETCURSEL:
        var tab = getTabSheet(Message.WParam);
        if(tab != null)
          tab.radio.checked = true;
        break;

      case TCM_INSERTITEM:
        TTCItem item = Message.LParam;
        String? caption;
        if(item.mask & TCIF_TEXT == TCIF_TEXT)
          caption = item.pszText;
        var tab = insertPage(Message.WParam, caption ?? '');
        Message.Result = indexOfTabSheet(tab);
        break;

      case TCM_GETITEM:
        var tab = getTabSheet(Message.WParam);
        if(tab != null)
        {
          TTCItem item = Message.LParam;
          if(item.mask.and(TCIF_TEXT))
            item.pszText = tab.caption;
          if(item.mask.and(TCIF_PARAM))
            item.lParam = tab.tabParam;
          Message.Result = 1;
        }
        break;

      case TCM_SETITEM:
        var tab = getTabSheet(Message.WParam);
        if(tab != null)
        {
          TTCItem item = Message.LParam;
          if(item.mask.and(TCIF_TEXT) && item.pszText!=null)
            tab.caption = item.pszText!;
          if(item.mask.and(TCIF_PARAM))
            tab.tabParam = item.lParam;
          Message.Result = 1;
        }
        break;

      default:
        super.dispatch(elem, Message);
        break;
    }
  }
}

class HTabSheet extends HCustomControl
{
  final radio = RadioButtonInputElement();
  late final LabelElement label;

  late final DivElement _client;
  HtmlElement getClientHandle() => _client;

  dynamic tabParam;

  HTabSheet() : super.elem(LIElement())
  {
    handle.className='tab-li';
    handle.append(radio);
    radio.name='tabs-';
    radio.className='tab-radio';
    radio.id='tabs-'+hashCode.toString();

    label = Element.html('<label for="tabs-${ hashCode.toString() }">...</label>') as LabelElement;
    handle.append(label);

    _client=handle.append(DivElement()) as DivElement;
    _client.owner = this;
  }

  String get caption => label.text ?? '';
  set caption(String s) => label.text = s;

  void dispatch(Element elem, TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_WINDOWPOSCHANGING:
        break;

      default:
        super.dispatch(elem, Message);
        break;
    }
  }

  void set_window_rect(int left, int top, int width, int height)
  {
    // client - autosized
  }

}
