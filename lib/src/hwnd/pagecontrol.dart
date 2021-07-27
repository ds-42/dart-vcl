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
    rule.addRule('.$name ul, .$name li',
      'margin: 0;'
      'padding: 0;'
      'list-style: none;'
      '${ rule.borderBox}');
    rule.addRule('.$name, .$name input[type="radio"]:checked+label',
      'position: relative;');
    rule.addRule('.$name li, .$name input[type="radio"]+label',
      'display: inline-block;'
      'user-select: none;');
    rule.addRule('.$name li > div, .$name input[type="radio"]',
      'position: absolute;');
    rule.addRule('.$name li > div, .$name input[type="radio"]+label',
      'border: solid 1px #ccc;');
    rule.add('li',
      'vertical-align: top;');
    rule.add('li:first-child',
      'margin-left: 4px;');
    rule.add('li > div',
      'top: 21px;'
      'bottom: 0;'
      'left: 0;'
      'width: 100%;'
      'padding: 4px;'
      'overflow: auto;'
      'border: 1px solid #a0a0a0;'
      '${ rule.borderBox}');
    rule.add('input[type="radio"]+label',
      'margin: 0 2px 0 0;'
      'padding: 0 5px;'
      'line-height: 20px;'
      'background: #ccc;'
      'color: gray;'
      'text-align: center;'
      'border-radius: 3px 3px 0 0;'
      'border: 1px solid #999;' 
      '${ rule.borderBox}');
    rule.add('input[type="radio"]:checked+label',
      'z-index: 1;'
      'color: black;'
      'background: #ddd;'
      'border-bottom-color: #ddd;'
      'cursor: default;');
    rule.add('input[type="radio"]',
      'opacity: 0;');
    rule.add('input[type="radio"]~div',
      'display: none;');
    rule.add('input[type="radio"]:checked:not(:disabled)~div',
      'display: block;');
    rule.add('input[type="radio"]:disabled+label',
    'opacity: .5; cursor: no-drop;');
  }

  final pages = <HTabSheet>[];
  final _ul = UListElement();

  Element getClientHandle() => _ul;
  HPageControl() : super()
  {
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

  DivElement? _client;
  HtmlElement getClientHandle() => _client!;

  HTabSheet() : super.elem(LIElement())
  {
    handle.append(radio);
    radio.name='tabs-';
    radio.id='tabs-'+hashCode.toString();

    label = Element.html('<label for="tabs-${ hashCode.toString() }">...</label>') as LabelElement;
    handle.append(label);

    _client=handle.append(DivElement()) as DivElement;
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
