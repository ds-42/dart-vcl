part of demo;

class TUserDialog extends TForm
{
  late final TEdit pUserName;
  late final TEdit pPassword;

  String get userName => pUserName.Text;
  String get password => pPassword.Text;

  TUserDialog(TComponent AOwner) : super(AOwner)
  {
    Position = TPosition.ScreenCenter;
    BorderStyle = TFormBorderStyle.Dialog;
    SetClientSize(300, 120);

    TLabel(this)
      ..SetBounds(10, 25, 100, null)
      ..Caption = 'Login:'
      ..Parent = this;

    pUserName = TEdit(this)
      ..SetBounds(100, 20, 190, null)
      ..Parent = this;

    TLabel(this)
      ..SetBounds(10, 55, 100, null)
      ..Caption = 'Password:'
      ..Parent = this;

    pPassword = TEdit(this)
      ..SetBounds(100, 50, 190, null)
      ..PasswordChar = '*'
      ..Parent = this;

    TButton(this)
      ..Caption = 'OK'
      ..MoveTo(215, 90)
      ..ModalResult = TModalResult.Ok
      ..Parent = this;
  }
}

