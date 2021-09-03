part of vcl;

class HMemo extends HCustomControl 
{
  static final MEMO = CLASS_ID('MEMO');
  CLASS_ID get classID => MEMO;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();

    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      'background: white;'
      'border: 1px solid #A0A0A0;'
      'padding: 1px 2px 1px 2px;'
      'whiteSpace: nowrap;');
    rule.add('textarea',
      'width: 100%;'
      'height: 100%;'
      'border: none;'
      'box-sizing: border-box;'
      'outline: none;'
      'background-color: inherit;'
      'resize: none');
  }

  final textArea = TextAreaElement();
  HtmlElement getClientHandle() => textArea;

  HMemo() : super()
  {
    handle.append(textArea);

    textArea.owner = this;


    WNDPROC? defproc;
    defproc = Windows.ChangeWindowProc(this, (elem, message)
    { // mainproc
      switch(message.Msg)
      {
        case WM_GETTEXT:
          message.Result = textArea.value;
          break;

        case WM_SETTEXT:
          textArea.value = message.LParam;
          break;

        default:
          defproc!(elem, message);
          break;
      }
    });

  }

  void release()
  {
    textArea.remove();
    super.release();
  }
}