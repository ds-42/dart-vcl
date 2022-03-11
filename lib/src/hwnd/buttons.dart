part of vcl;

class HButton extends HControl
{
  static final BUTTON = CLASS_ID('BUTTON');
  CLASS_ID get classID => BUTTON;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle('focus');
    rule.add('',
      '${rule.block}${rule.inline}');
  }

  HButton() : super(ButtonElement());
}

class HSpeedButton extends HControl
{
  static final SPEEDBUTTON = CLASS_ID('SPEEDBUTTON');
  CLASS_ID get classID => SPEEDBUTTON;

  void defineClassRule(TWndStyle rule)
  {
    final name = classID.name;

    rule.add('',
      'position: absolute;'
      'box-sizing: border-box;'
      'border: 1px solid #e0e0e0;'
      'background-color: inherit;'
      'outline:none;'
      'overflow: hidden;');
    rule.addRule('.$name:hover',
      'border: 1px outset;');
    rule.addRule(".$name[state='down']",
      'border: 1px inset;');
    rule.addRule(".$name[state='exclusive']",
      'border: 1px inset;');
    
  }

  HSpeedButton() : super( ButtonElement() );
}

class HButtonControl extends HControl
{
  HButtonControl(Element elem) : super(elem);
}

class HCheckBox extends HButtonControl
{
  static final CHECKBOX = CLASS_ID('CHECKBOX');
  CLASS_ID get classID => CHECKBOX;

  void defineClassRule(TWndStyle rule)
  {
    final name = classID;
    rule.addFocusStyle();
    rule.add('',
      '${rule.block}${rule.inline}${rule.borderBox}'
      'padding-top: 1px;');
    rule.add('input',
      'margin:0 2px;'
      'outline:none');
    rule.addRule(".$name span",
      'vertical-align:2px;'
      'padding-left:2px');
    rule.addRule(".$name[disabled]",
      'pointer-events:none');
    rule.addRule(".$name[disabled] input",
      'filter:grayscale(1) opacity(0.5)');
    rule.addRule(".$name[disabled] span",
      'text-shadow: 1px 1px 0px white;color:gray;');
  }

  final check = CheckboxInputElement();
  final caption = SpanElement();

  Element getClientHandle() => check;

  HCheckBox() : super( LabelElement() )
  {
    handle.append(check);
    handle.append(caption);

    check.owner = this;
    caption.owner = this;

    
    handle.onClick.listen((e) =>  e.preventDefault() );

    WNDPROC? defproc;
    defproc = Windows.ChangeWindowProc(this, (elem, message)
    { // mainproc
      switch(message.Msg)
      {
        case BM_GETCHECK:
          message.Result = check.checked!? TCheckBoxState.Checked : TCheckBoxState.Unchecked;
          break;

        case BM_SETCHECK:
          check.checked = message.WParam == TCheckBoxState.Checked;
          break;
      }

      switch(message.Msg)
      {
        case WM_GETTEXT:
          message.Result = caption.text;
          break;

        case WM_SETTEXT:
          caption.text = message.LParam;
          break;

        default:
          defproc!(elem, message);
          break;
      }
    });
  }
}

class HRadioButton extends HButtonControl
{
  static final RADIOBUTTON = CLASS_ID('RADIOBUTTON');
  CLASS_ID get classID => RADIOBUTTON;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${rule.block}${rule.inline}${rule.borderBox}'
      'padding-top: 1px;');
    rule.add('input',
      'margin: 0 2px;'
      'outline: none;');
    rule.add('span',
      'vertical-align: 2px;');
  }

  final radio = RadioButtonInputElement();
  final caption = SpanElement();

  Element getClientHandle() => radio;

  HRadioButton() : super( LabelElement() )
  {
    handle.append(radio);
    handle.append(caption);

    radio.owner = this;
    caption.owner = this;

    WNDPROC? defproc;
    defproc = Windows.ChangeWindowProc(this, (elem, message)
    { // mainproc
      switch(message.Msg)
      {
        case BM_GETCHECK:
          message.Result = radio.checked!? 1 : 0;
          break;

        case BM_SETCHECK:
          radio.checked = message.WParam == 1;
          break;
      }

      switch(message.Msg)
      {
        case WM_GETTEXT:
          message.Result = caption.text;
          break;

        case WM_SETTEXT:
          caption.text = message.LParam;
          break;

        default:
          defproc!(elem, message);
          break;
      }
    });
  }
}
