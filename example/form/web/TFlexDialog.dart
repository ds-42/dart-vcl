part of demo;

class TFlexDialog extends TForm
{
  TFlexDialog(TComponent AOwner) : super(AOwner)
  {
    Caption = 'Flex dialog';
    Position = TPosition.ScreenCenter;
    ClientWidth = 400;
    Constraints.MinWidth = 200;

    TFlexBox(this)
      ..Align = TAlign.Top
      ..Grow = 1
      ..Parent = this
      ..Add([
        TLabelEdit(this)
          ..Caption = 'Surname',

        TLabelEdit(this)
          ..Caption = 'Name',

        TLabelEdit(this)
          ..Caption = 'Patronymic',

        TLabelEdit(this)
          ..Flex.BreakBefore = true
          ..Flex.Width = TMetric(100)
          ..Flex.Grow = 0
          ..Caption = 'Postcode',

        TLabelEdit(this)
          ..Caption = 'Birthplace',

        TLabelEdit(this)
          ..Flex.Width = TMetric(100)
          ..Flex.Grow = 0
          ..Caption = 'Birthdate',
      ]);

    TFlexBox(this)
      ..Align = TAlign.Bottom
      ..JustifyContent = TFlexJustifyContent.FlexEnd
      ..Parent = this
      ..Add([
        TButton(this)
          ..ModalResult = TModalResult.Ok
          ..Caption = 'Save'
,

        TButton(this)
          ..ModalResult = TModalResult.Cancel
          ..Caption = 'Cancel',
      ]);
  }

  bool CanResize(Integer NewWidth, Integer NewHeight)
  {
    NewHeight.Value = Height - ClientHeight;
    for(var ctrl in Controls)
      NewHeight.Value+=ctrl.Height;
    return true;
  }

}