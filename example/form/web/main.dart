library demo;

import 'package:vcl/vcl.dart';

part 'TMainForm.dart';


void main() async
{
  var form = TMainForm()
    ..Caption = 'MainForm'
    ..SetClientSize((Screen.Width*0.6).truncate(), (Screen.Height*0.6).truncate());
  await form.ShowModal();
/*  var form = TForm(Application)
    ..Caption = 'MainForm'
    ..SetClientSize(640, 480)
    ..Position = TPosition.ScreenCenter;

  var menu = TMainMenu(form);
  form.Menu = menu;
  menu
//  TStatusBar(form)
//    ..Parent = form;

  await form.ShowModal();*/
/*  var form = TForm(Application)
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
  
  await ShowMessage('see you later');**/
}
