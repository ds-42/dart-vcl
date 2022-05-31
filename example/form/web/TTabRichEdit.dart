part of demo;

TTabSheet BuildRichEditPage(TPageControl pages)
{
  return TTabRichEdit(pages)
    ..Caption = 'richedit'
    ..PageControl = pages;
}

class TTabRichEdit extends TTabSheet
{
  late final TRichEditTools tools;
  late final TRichEdit richEdit;
  late final TPopupMenu richPopup;

  TTabRichEdit(TPageControl pages) : super(pages)
  {
    tools = TRichEditTools(this)
      ..Align = TAlign.Top
      ..Parent = this;

    TBevel(this)
      ..Align = TAlign.Top
      ..Shape = TBevelShape.TopLine
      ..Height = 5
      ..Parent = this;

    TFlexBox(this)
      ..Align = TAlign.Top
      ..Parent = this
      ..Block((flex) {
        TCheckBox(flex)
          ..Flex.Grow = 1
          ..Caption = 'Using native popup menu'
          ..Parent = flex
          ..OnClick = (Sender) =>
            richEdit.PopupMenu = (Sender as TCheckBox).Checked? null : richPopup;
      });

    richEdit = TRichEdit(this)
      ..Align = TAlign.Client
      ..Parent = this;

    void execRichCommand(String command)
    {
      (richEdit.Handle as HRichEdit).execCommand(command);
    }

    richPopup = TPopupMenu(this)
      ..Items.AddEx('Cut\tCtrl + X', OnClick: (Sender) => execRichCommand('cut'))
      ..Items.AddEx('Copy\tCtrl + C', OnClick: (Sender) => execRichCommand('copy'))
      ..Items.AddEx('Paste\tCtrl + V', OnClick: (Sender) => execRichCommand('paste'))
      ..Items.AddEx('-')
      ..Items.AddEx('Delete\tDel', OnClick: (Sender) => execRichCommand('delete'));

    richEdit.PopupMenu = richPopup;
    tools.RichEdit = richEdit;
  }
}
