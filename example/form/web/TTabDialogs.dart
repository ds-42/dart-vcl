part of demo;

TTabSheet BuildDialogsPage(TPageControl pages)
{
  return TTabDialogs(pages)
    ..Caption = 'dialogs'
    ..PageControl = pages;
}

class TTabDialogs extends TTabSheet
{
  TTabDialogs(TPageControl pages) : super(pages)
  {
    TButton(this)
      ..Caption = 'Simple form'
      ..SetBounds(10, 10, 150, null)
      ..Parent = this
      ..OnClick = (Sender) {
        TForm(this)
          ..Position = TPosition.ScreenCenter
          ..Show();
      };

    TButton(this)
      ..Caption = 'Modal form'
      ..SetBounds(10, 40, 150, null)
      ..Parent = this
      ..OnClick = (Sender) async {
        var form = TForm(this);
        form.Position = TPosition.ScreenCenter;
        form.OnClose = (Sender, Action) async
        {
          if(await ShowQuestionMessage('Close the form?') != Windows.ID_YES)
            Action.Value = TCloseAction.None;
        };
        await form.ShowModal();
        await ShowMessage('The modal form was closed');
      };

    TButton(this)
      ..Caption = 'Show message'
      ..SetBounds(10, 70, 150, null)
      ..Parent = this
      ..OnClick = (Sender) {
        ShowMessage('Simple message');
      };

    TButton(this)
      ..Caption = 'Input box'
      ..SetBounds(10, 100, 150, null)
      ..Parent = this
      ..OnClick = (Sender) async {
        var name = await InputBox('Input box', 'Enter your name', '');
        if(name.isNotEmpty)
          await ShowMessage('Hello, $name');
      };

    TButton(this)
      ..Caption = 'User dialog'
      ..SetBounds(10, 130, 150, null)
      ..Parent = this
      ..OnClick = (Sender) async {
        var dlg = TUserDialog(this);
        if(await dlg.ShowModal() == TModalResult.Ok)
          ShowMessage('Hello, ${ dlg.userName} ');
        else
          ShowMessage('See you later');
      };
  }
}