import 'package:vcl/vcl.dart';

void main() async
{
  var form = TForm(Application)
    ..Caption = 'dart-vcl'
    ..Position = TPosition.ScreenCenter
    ..BorderStyle = TFormBorderStyle.Dialog
    ..SetClientSize(300, 120);

  TLabel(form)
    ..SetBounds(10, 25, 100, null)
    ..Caption = 'Your name:'
    ..Parent = form;

  var edit = TEdit(form)
    ..SetBounds(150, 20, 140, null)
    ..Parent = form;

  TButton(form)
    ..Parent = form
    ..MoveTo(120, 90)
    ..Caption = 'OK'
    ..OnClick = (Sender) async
    {
      if(edit.Text.trim().isEmpty)
      {
        await ShowMessage('Enter your name');
        edit.SelectAll();
        edit.SetFocus();
        return;
      }
      await ShowMessage('Hello, ${ edit.Text }. Nice to meet you.');
    };

  await form.ShowModal();
  
  await ShowMessage('see you later');
}
