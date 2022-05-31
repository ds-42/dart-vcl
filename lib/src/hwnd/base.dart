part of vcl;

class HInput extends HControl 
{
  static final INPUT = CLASS_ID('INPUT');
  CLASS_ID get classID => INPUT;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      '${ rule.softBorder }');
  }

  HInput() : super( InputElement() );
}

class HTextArea extends HControl 
{
  static final TEXTAREA = CLASS_ID('TEXTAREA');
  CLASS_ID get classID => TEXTAREA;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      '${ rule.softBorder }'
      'resize: none;');
  }

  HTextArea() : super( TextAreaElement() );

  bool
    get wrap => (handle as TextAreaElement).wrap != 'off';
    set wrap(bool state) {
      (handle as TextAreaElement).wrap = state? 'soft' : 'off';
    }

}

class HSelect extends HControl 
{
  static final SELECT = CLASS_ID('SELECT');
  CLASS_ID get classID => SELECT;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      '${ rule.softBorder }');
    rule.add('option',
      'user-select: none;');
  }

  HSelect() : super( SelectElement() );

  void dispatch(Element elem, TMessage message)
  {
    switch(message.Msg)
    {
      case WM_CREATE:
//        var cs = message.LParam as CREATESTRUCT;
//        if(cs.style.and(Windows.WS_DISABLED))
//          handle.setAttribute('disabled', '');
        message.Result = 0;
        break;

      case LB_GETCURSEL:
        var select = handle as SelectElement;
        message.Result = select.selectedIndex ?? -1;
        break;

      case LB_GETTEXTLEN:
        String text = getText(message.WParam);
        message.Result = text.length;
        break;

      case LB_GETTEXT:
        message.Result = getText(message.WParam);
        break;

      default:
        super.dispatch(elem, message);
        break;
    }
  }

  String getText(int ndx)
  {
    var select = handle as SelectElement;
    int cnt = select.length ?? 0;
    if(ndx>=0 && ndx<=cnt)
      return select.options[ndx].label ?? '';
    return '';
  }
}

class HDateTimePick extends HControl 
{
  static final DATETIMEPICK = CLASS_ID('DATETIMEPICK');
  CLASS_ID get classID => DATETIMEPICK;

  HDateTimePick() : super( InputElement() )
  {
    (handle as InputElement).type = 'datetime-local';
  }
}

