part of vcl;

class HGroupBox extends HControl
{
  static final GROUPBOX = CLASS_ID('GROUPBOX');
  CLASS_ID get classID => GROUPBOX;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      'position: absolute;'
      'box-sizing: border-box;'
      'border: 2px groove;'
      'overflow:hidden;'
      'margin:0;'
      'padding:5px;');
    rule.add('legend',
      'user-select:none;'
      'padding:0px 3px;');
  }


  final caption = LegendElement();
  final client = DivElement();

  Element getClientHandle() => client;

  HGroupBox() : super( FieldSetElement() )
  {
    handle.append(caption);
    handle.append(client);

    client.style
      ..position='absolute'
      ..left = '1px'
      ..top = '1px'
      ..right = '1px'
      ..bottom = '1px';
    client.owner = this;


  }

  void dispatch(Element elem, TMessage message)
  {
    switch(message.Msg)
    {
      case WM_CREATE:
        var cs = message.LParam as CREATESTRUCT;
        caption.text = cs.lpszName;
        message.Result = 0;
        break;

      case WM_GETTEXT:
        message.Result = caption.text;
        break;

      case WM_SETTEXT:
        caption.text = message.LParam;
        break;

      default:
        super.dispatch(elem, message);
        break;
    }
  }
}
