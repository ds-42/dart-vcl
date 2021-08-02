part of demo;

TTabSheet BuildControlsPage(TPageControl pages)
{
  return TTabControls(pages)
      ..Caption = 'controls'
      ..PageControl = pages;
}

class TTabControls extends TTabSheet
{
  TTabControls(TPageControl pages) : super(pages)
  {
    TEdit(this)
      ..SetBounds(10, 20, 120, null)
      ..Text = 'TEdit'
      ..Parent = this;

    var combo = TComboBox(this)
      ..SetBounds(10, 50, 120, null)
      ..Text = 'TComboBox'
      ..Parent = this;
    for(var i=0; i<10; i++)
      combo.Items.Add('Item $i');

    TCheckBox(this)
      ..SetBounds(210, 20, 120, null)
      ..Caption = 'TCheckBox'
      ..Checked = true
      ..Parent = this;

    TRadioButton(this)
      ..SetBounds(210, 40, 120, null)
      ..Caption = 'TRadioButton 1'
      ..Parent = this;

    TRadioButton(this)
      ..SetBounds(210, 60, 120, null)
      ..Caption = 'TRadioButton 2'
      ..Parent = this;

  }
}