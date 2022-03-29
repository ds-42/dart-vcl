part of demo;

class TUserDialog extends TForm
{
  late final TEdit pUserName;
  late final TEdit pPassword;

  String get userName => pUserName.Text;
  String get password => pPassword.Text;

  TUserDialog(TComponent AOwner) : super(AOwner)
  {
    AutoSize = true;
    Position = TPosition.OwnerFormCenter;
    ClientWidth = 250;
    Caption = 'Registration';

    TFlexBox(this)
      ..Parent = this
      ..Width = ClientWidth
      ..Align = TAlign.Top
      ..AlignItems = TFlexAlignItem.FlexEnd
      ..Add([
        TLabel(this)
          ..Flex.Width = TMetric(80)
          ..Caption = 'Login:',

        pUserName = TEdit(this)
          ..Name = 'login'
          ..Flex.Grow = 1,

        TLabel(this)
          ..Flex.BreakBefore = true
          ..Flex.Width = TMetric(80)
          ..Caption = 'Password:',

        pPassword = TEdit(this)
          ..Name = 'password'
          ..PasswordChar = '*'
          ..Flex.Grow = 1,

        TButton(this)
          ..Flex.BreakBefore = true
          ..Flex.Width = TMetric(100, TMetricUnit.Percent)
          ..Flex.Justify = TFlexJustify.Right
          ..Caption = 'OK'
          ..ModalResult = TModalResult.Ok,
      ]);
  }

  Future<void> DoClose(TPointer<TCloseAction> Action) async
  {
    await super.DoClose(Action);
    if(ModalResult == TModalResult.Ok)
    {
      var login = FindComponent('login') as TEdit;
      if(login.Text.trim().isEmpty)
      {
        await ShowMessage('Enter user login');
        login.SetFocus();
        Action.Value = TCloseAction.None;
        return;
      }

      var pass = FindComponent('password') as TEdit;
      if(pass.Text.trim().isEmpty)
      {
        await ShowMessage('Enter user password');
        pass.SetFocus();
        Action.Value = TCloseAction.None;
      }
    }
  }

}

