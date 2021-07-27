part of vcl;

class HEdit extends HCustomControl
{
  static final EDIT = CLASS_ID('EDIT');
  CLASS_ID get classID => EDIT;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${ rule.block }${ rule.borderBox }'
      'background: white;'
      'border: 1px solid #A0A0A0;'
      'padding: 1px 2px 1px 2px;'
      'white-space: nowrap;');

    rule.add('input',
      'width: 100%;'
      'height: 100%;'
      'border: none;'
      'box-sizing: border-box;'
      'outline: none;'
      'background-color: inherit;'
      'vertical-align: top;');

    rule.add('.prefix',
      'display:inline-block;'
      'padding:1px 0px 1px 2px;'
      'cursor:default;');
  }

  SpanElement? _prefix;
  SpanElement? get prefixHandle => _prefix;

  String
    get prefix => _prefix==null? '' : _prefix!.text!;
    set prefix(String value)
    {
      if(prefix == value)
        return;
      if(value.isEmpty)
      {
        if(_prefix != null)
        {
          _prefix!.remove();
          _prefix = null;
        }
        return;
      }

      if(_prefix == null)
      {
        _prefix = SpanElement();
        _prefix!.className = 'prefix';
        handle.insertBefore(_prefix!, input);
      }
      _prefix!.text = value;
    }


  final input = InputElement();
  HtmlElement getClientHandle() => input;

  HEdit() : super()
  {
    handle.append(input);

    input.spellcheck = false;

    input.owner = this;

    WNDPROC? defproc;
    defproc = Windows.ChangeWindowProc(this, (elem, message)
    { // mainproc
      switch(message.Msg)
      {
        case WM_GETTEXT:
          message.Result = input.value;
          break;

        case WM_SETTEXT:
          input.value = message.LParam;
          break;

        default:
          defproc!(elem, message);
          break;
      }
    });

  }

  void release()
  {
    input.remove();
    super.release();
  }
}
