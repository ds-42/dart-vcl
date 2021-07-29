part of vcl;

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

  final pages = <HTabSheet>[];
  final _ul = UListElement();

  Element getClientHandle() => _ul;
  HPageControl() : super()
  {
    _ul.className='tab-ul';
    handle.append(_ul);
  }

  HTabSheet appendPage(String caption)
  {
    HTabSheet tab=HTabSheet();
    _ul.append(tab.handle);
    tab.caption=caption;
    tab.radio.name = "page-${ hashCode.toString() }";
    pages.add(tab);
    if(pages.length == 1)
      tab.radio.checked=true;
    return tab;
  }

  void dispatch(Element elem, TMessage Message)
  {
    switch(Message.Msg)
    {
      case TCM_GETCURSEL:
        int ndx = 0;
        for(HTabSheet item in pages)
        {
          if(item.radio.checked ?? false)
          {
            Message.Result=ndx;
            return;
          }
          ndx++;
        }
        Message.Result=-1;
        break;

      case TCM_SETCURSEL:
        int ndx = Message.WParam;
        if(ndx>=0 && ndx<pages.length)
          pages[ndx].radio.checked = true;
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

}
