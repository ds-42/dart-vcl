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
    TFlexBox(this)
      ..Align = TAlign.Left
      ..Parent = this
      ..FlexDirection = TFlexDirection.Column
      ..JustifyContent = TFlexJustifyContent.FlexStart
      ..AlignItems = TFlexAlignItem.Stretch
      ..Add([

        TButton(this)
          ..Caption = 'Simple form'
          ..Width = 150
          ..OnClick = (Sender) {
            TForm(this)
              ..Position = TPosition.ScreenCenter
              ..Show();
          },

        TButton(this)
          ..Caption = 'Modal form'
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
          },

        TButton(this)
          ..Caption = 'Show message'
          ..OnClick = (Sender) {
            ShowMessage('Simple message');
          },

        TButton(this)
          ..Caption = 'Input box'
          ..OnClick = (Sender) async {
            var name = await InputBox('Input box', 'Enter your name', '');
            if(name.isNotEmpty)
              await ShowMessage('Hello, $name');
          },

        TButton(this)
          ..Caption = 'User dialog'
          ..OnClick = (Sender) async {
            var dlg = TUserDialog(this);
            if(await dlg.ShowModal() == TModalResult.Ok)
              ShowMessage('Hello, ${ dlg.userName} ');
            else
              ShowMessage('See you later');
          },

        TButton(this)
          ..Caption = 'Flex dialog'
          ..OnClick = (Sender) {
            TFlexDialog(this)
              ..ShowModal();
          },

        TButton(this)
          ..Caption = 'Exception'
          ..OnClick = (Sender)
          {
            TExceptionDialog(Application)
                ..Position = TPosition.ScreenCenter
                ..ShowModal();
          }
      ]);
  }
}