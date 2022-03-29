part of demo;

class TExceptionDialog extends TForm
{
  int ActiveMode = 0;

  TExceptionDialog(TComponent AOwner) : super(AOwner)
  {
    AutoSize = true;
    ClientWidth = 400;
    Caption = 'Select mode';
    var flex = TFlexBox(this)
        ..Width = ClientWidth
        ..Align = TAlign.Top
        ..FlexItems.Grow = 1
        ..Parent = this
        ..Add([

          CreateRadioButton(0, 'Hide exception')..Checked=true,
          CreateRadioButton(1, 'Show application message (user exception)'),
          CreateRadioButton(2, 'Show application message (system exception)'),
          CreateRadioButton(3, 'Show user message (user exception)'),
          CreateRadioButton(4, 'Show user message (system exception)'),

          TBevel(this)
            ..Flex.BreakBefore = true
            ..Shape = TBevelShape.TopLine
            ..Height = 5,

          TButton(this)
            ..Flex.BreakBefore = true
            ..Flex.Justify = TFlexJustify.Stretch
            ..Height = 40
            ..Caption = 'throw exception for call: [][0]'
            ..OnClick = (Sender) => ThrowException(),
        ]);

    flex.Resize();
    ClientHeight = flex.Height;
  }

  TRadioButton CreateRadioButton(int mode, String caption)
  {
    return TRadioButton(this)
        ..Flex.BreakBefore = true
        ..Caption = caption
        ..OnClick = (Sender)
        {
          ActiveMode = mode;
          Caption = 'Select mode [ $ActiveMode ]';
        };
  }

  void ThrowException() async
  {
    try
    {
      await Application.TryBlock(() async
      {
        [][0]; // throw exception
      },
      (E) async
      {
        switch(ActiveMode)
        {
          case 0: // hide exception
            break;
          case 1: // show user exception
            return Future.error(TException('User exception'));
          case 2: // show system exception
            return Future.error(E);
          case 3: // throw user exception
            return TException('User exception');
          case 4: // throw system exception
            return E;
        }
        // call custom exception
      });
    }
    catch(E)
    {
      await ShowErrorMessage('Catch exception:\n$E');
    }
  }
}