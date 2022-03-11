part of demo;

class TFlexDialog extends TForm
{
  TFlexDialog(TComponent AOwner) : super(AOwner)
  {
    Caption = 'Flex dialog [resize for test]';
    Position = TPosition.ScreenCenter;
    ClientWidth = 400;
    Constraints.MinWidth = 200;

    TFlexBox(this)
      ..Align = TAlign.Top
      ..FlexItems.Grow = 1
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
          ..Caption = 'Birthplace',

        TLabelEdit(this)
          ..Flex.Width = TMetric(100)
          ..Flex.Grow = 0
          ..Caption = 'Birthdate',

        TLabelEdit(this)
          ..Flex.BreakBefore = true
          ..Flex.Width = TMetric(100)
          ..Flex.Grow = 0
          ..Caption = 'Postcode',

        TLabelEdit(this)
          ..Flex.Grow = 2
          ..Caption = 'Address',

        TLabelEdit(this)
          ..Flex.BreakBefore = true
          ..Caption = 'Phone',

        TLabelEdit(this)
          ..Caption = 'Email',

        TBevel(this)
           ..Shape = TBevelShape.TopLine
           ..Height = 5,

        TButton(this)
          ..Flex.BreakBefore = true
          ..Flex.Justify = TFlexJustify.Right
          ..ModalResult = TModalResult.Ok
          ..Caption = 'Save',

        TButton(this)
          ..ModalResult = TModalResult.Cancel
          ..Flex.Grow = 0
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