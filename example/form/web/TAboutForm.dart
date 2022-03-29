part of demo;

class TAboutForm extends TForm
{
  TLabel Note(String note, [bool left = true])
  {
    return TLabel(this)
      ..Flex.BreakBefore = left
      ..Flex.Justify = left? TFlexJustify.Right : TFlexJustify.Left
      ..Flex.Grow = left? 1 : 3
      ..Caption = note;
  }

  TAboutForm(TComponent? AOwner) : super(AOwner)
  {
    AutoSize = true;
    Caption = 'About dart-vcl';
    BorderStyle = TBorderStyle.Dialog;
    Position = TPosition.ScreenCenter;
    ClientWidth = 320;

    TFlexBox(this)
      ..Parent = this
      ..Width = ClientWidth
      ..FlexItems.Grow = 1
      ..Align = TAlign.Top
      ..Add([
        Note('author:'), Note('Aliaksei Liulis', false),
        Note('email:'), Note('lai@tut.by', false),
        Note('repository:'), Note('https://github.com/ds-42/dart-vcl', false),
        Note('version:'), Note('$vcl_lib_version, ${vcl_lib_date.year}', false),

        TBevel(this)
          ..Flex.BreakBefore = true
          ..Shape = TBevelShape.TopLine
          ..Height = 5,

        TButton(this)
          ..Flex.BreakBefore = true
          ..Flex.Justify = TFlexJustify.Center
          ..Caption = 'OK'
          ..ModalResult = TModalResult.Ok,
      ]);

  }
}