library demo;

import 'dart:html';
import 'package:vcl/vcl.dart';

part 'TDataMap.dart';
part 'TFlexDialog.dart';
part 'TExceptionDialog.dart';
part 'TLabelEdit.dart';
part 'TAboutForm.dart';
part 'TMainForm.dart';
part 'TUserDialog.dart';

part 'TTabControls.dart';
part 'TTabDialogs.dart';
part 'TTabFlexControls.dart';
part 'TTabPanels.dart';
part 'TTabDataSet.dart';

void main() async
{
  Locale.select(TLocale.ENGLISH);

  Application.Title = 'dart-vcl';
  Application.TryBlock(() async
  {
    var form = TMainForm()
      ..Caption = 'MainForm'
      ..SetClientSize((Screen.Width*0.6).truncate(), (Screen.Height*0.6).truncate());
    await form.ShowModal();
  });
}
