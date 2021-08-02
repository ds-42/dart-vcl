library demo;

import 'package:vcl/vcl.dart';

part 'TMainForm.dart';
part 'TUserDialog.dart';

part 'TTabControls.dart';
part 'TTabDialogs.dart';
part 'TTabPanels.dart';


void main() async
{
/**  var form = TForm(Application);
  form.Position = TPosition.ScreenCenter;
  TPanel p = TPanel(form);
  p.Parent = form;
  p.Width = 100;
  p.Align = TAlign.Left;

  TButton btn = TButton(p);
  btn.Parent = p;
  btn.OnClick = (Sender)
  {
    form.Width -= 50;
  };

  TFlexBox(form)
    ..Align = TAlign.Bottom
    ..Height = 50
    ..JustifyContent = TFlexJustifyContent.SpaceBetween
    ..Add([
      TButton(form)
        ..Caption = 'OK'
        /*..Flex.Justify = TFlexJustify.Center*/,
      TButton(form)
        ..Caption = 'Ignore'
        ..Flex.Width = TMetric(100, TMetricUnit.Pixel)
        ..Flex.Justify = TFlexJustify.Content,
      TButton(form)
        ..Caption = 'Cancel'
        /*..Flex.Justify = TFlexJustify.Center*/,
//        ..Align = TAlign.Bottom
    ])
    ..Parent = form;
  await form.ShowModal();**/
  var form = TMainForm()
    ..Caption = 'MainForm'
    ..SetClientSize((Screen.Width*0.6).truncate(), (Screen.Height*0.6).truncate());
  await form.ShowModal();
}
