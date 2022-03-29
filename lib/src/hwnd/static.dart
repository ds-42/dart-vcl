part of vcl;

class HLabel extends HControl
{
  static final LABEL = CLASS_ID('LABEL');
  CLASS_ID get classID => LABEL;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
        '${ rule.block }'
        '${ rule.inline }'
        '${ rule.no_select }');
  }

  HLabel() : super( LabelElement() );

  bool _autoSize = true;
  bool
    get autoSize => _autoSize;
    set autoSize(bool value) => _autoSize = value;

  void set_window_rect(int left, int top, int width, int height)
  {
    if(autoSize)
      handle.updateBounds(left, top, null, null);
    else
      super.set_window_rect(left, top, width, height);
  }

  void dispatch(Element elem, TMessage message)
  {
    switch(message.Msg)
    {
      case WM_NCCREATE:
        CREATESTRUCT cs = message.LParam;
        handle.text = cs.lpszName;
        super.dispatch(elem, message);
        break;

      default:
        super.dispatch(elem, message);
        break;
    }
  }

}

class HHint extends HComponent
{
  static final HINT = CLASS_ID('HINT');
  CLASS_ID get classID => HINT;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
        '${ rule.block }${ rule.font }'
        'padding: 2px; border: 1px outset;'
        'box-shadow: 1px 1px 3px rgba(0,0,0,.25);'
        'box-sizing: border-box;'
        'animation: showBlock 150ms linear;'
        'text-align: center;'
        'background-color: ${ clInfoBk.html };');
    rule.addRule('@keyframes showBlock',
        '0% { opacity: 0; } ');
  }

  HHint() : super( DivElement() );

  void dispatch(Element elem, TMessage message)
  {
    switch(message.Msg)
    {
      case WM_NCCREATE:
        CREATESTRUCT cs = message.LParam;
        handle.text = cs.lpszName;
        super.dispatch(elem, message);
        break;

      default:
        super.dispatch(elem, message);
        break;
    }
    super.dispatch(elem, message);
  }
}