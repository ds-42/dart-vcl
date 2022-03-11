part of demo;

TTabSheet BuildControlsPage(TPageControl pages)
{
  return TTabControls(pages)
      ..Caption = 'controls'
      ..PageControl = pages;
}

class TTabControls extends TTabSheet
{
  TBevel CreateSeparate(TWinControl prnt)
  {
    return TBevel(prnt)
      ..Flex.BreakBefore = true
      ..Flex.Grow = 1
      ..Height = 5
      ..Shape = TBevelShape.TopLine;
  }

  late final TComboBox comboList;

  TTabControls(TPageControl pages) : super(pages)
  {
    late TEdit edit;
    late TMemo memo;
    late TComboBox combo;
    late TListBox list;

    var flex1 = TFlexBox(this)
      ..Align = TAlign.Left
      ..FlexItems.Grow = 1
      ..Parent = this
      ..Add([

        edit = TEdit(this)
          ..Name = 'Edit'
          ..Text = 'TEdit'
          ..OnMouseDown = _controlMouseDown
          ..OnKeyPress = (Sender, Key)
          {
            if(Key.Code == Windows.VK_RETURN && edit.Text.isNotEmpty)
            {
              memo.Lines.Add(edit.Text);
              edit.Text = '';
            }
          },

        memo = TMemo(this)
          ..Flex.BreakBefore = true
          ..Name = 'Memo'
          ..OnMouseDown = _controlMouseDown
          ..Text = 'TMemo',

        combo = TComboBox(this)
          ..Flex.BreakBefore = true
          ..Name = 'ComboBox'
          ..Text = 'TComboBox'
          ..OnMouseDown = _controlMouseDown
          ..OnSelect = (Sender)
          {
            list.Items.Add(combo.Text);
          },

        list = TListBox(this)
          ..Flex.BreakBefore = true
          ..OnMouseDown = _controlMouseDown
          ..Name = 'ListBox',
      ]);

    for(var i=0; i<10; i++)
      combo.Items.Add('Item $i');

//    list.Items.Add('TListBox');

    var flex2 = TFlexBox(this)
      ..Align = TAlign.Left
      ..FlexItems.Grow = 1
      ..Parent = this
      ..Add([

        TCheckBox(this)
          ..Name = 'CheckBox'
          ..Caption = 'TCheckBox'
          ..OnMouseDown = _controlMouseDown
          ..Checked = true,

//        CreateSeparate(this),

        TRadioButton(this)
          ..Flex.BreakBefore = true
          ..Name = 'RadioButton1'
          ..OnMouseDown = _controlMouseDown
          ..Caption = 'TRadioButton 1',

        TRadioButton(this)
          ..Flex.BreakBefore = true
          ..Name = 'RadioButton2'
          ..OnMouseDown = _controlMouseDown
          ..Caption = 'TRadioButton 2',

        TButton(this)
          ..Flex.BreakBefore = true
          ..Name = 'Button'
          ..OnMouseDown = _controlMouseDown
          ..Caption = 'TButton',

        CreateSeparate(this),

        TGroupBox(this)
          ..Flex.BreakBefore = true
          ..Name = 'GroupBox'
          ..OnMouseDown = _controlMouseDown
          ..Caption = 'TGroupBox',


      ]);

    TWinControl? ItemControl()
    {
      if(comboList.Enabled && comboList.ItemIndex>=0)
        return comboList.ItemObject as TWinControl;
      return null;
    }

    late TCheckBox styleVisible, styleEnabled, styleHint, styleChecked;
    late TEdit styleCaption;
    TFlexBox(this)
      ..Align = TAlign.Client
      ..Parent = this
      ..Color = clBtnFace.tone(-0.1)
      ..AlignItems = TFlexAlignItem.FlexEnd
      ..Add([

        TLabel(this)
          ..Caption = 'Object properties:',

        comboList = TComboBox(this)
          ..Flex.Grow = 1
          ..Flex.MinWidth = TMetric(100)
          ..Flex.MaxWidth = TMetric(200)
          ..SetBounds(10, 50, 120, null),

        CreateSeparate(this),

        styleVisible = TCheckBox(this)
          ..Flex.BreakBefore = true
          ..Caption = 'Visible'
          ..OnClick = (Sender) =>
            ItemControl()?.Visible = !ItemControl()!.Visible,

        styleEnabled = TCheckBox(this)
          ..Flex.BreakBefore = true
          ..Caption = 'Enabled'
          ..OnClick = (Sender) =>
            ItemControl()?.Enabled = !ItemControl()!.Enabled,

        styleHint = TCheckBox(this)
          ..Flex.BreakBefore = true
          ..Caption = 'Show hint'
          ..OnClick = (Sender) =>
            ItemControl()?.ShowHint = !ItemControl()!.ShowHint,

        styleChecked = TCheckBox(this)
          ..Flex.BreakBefore = true
          ..Caption = 'Checked'
          ..OnClick = (Sender)
          {
            var ctrl = ItemControl();
            if(ctrl == null)
              return;
            Windows.SendMessage(ctrl.Handle, CM_SETVALUE, null, styleChecked.Checked? 1 : 0);
          }
      ]);

    comboList.OnSelect = (Sender)
    {
      var ctrl = ItemControl();

      if(ctrl == null)
        return;
      comboList.Enabled = false;
      styleVisible.Checked = ctrl.Visible;
      styleEnabled.Checked = ctrl.Enabled;
      styleHint.Checked = ctrl.ShowHint;
      styleChecked.Enabled = ctrl is TButtonControl;
      if(styleChecked.Enabled)
        styleChecked.Checked = toBoolDef(Windows.SendMessage(ctrl.Handle, CM_GETVALUE), false);

      comboList.Enabled = true;
    };

    void AddObjects(TWinControl ctrl)
    {
      for(var item in ctrl.Controls)
      {
        if(item is TBevel)
          continue;
        comboList.AddItem(item.Name, item);
        item.ShowHint = true;
        item.Hint = item.Name;
      }
    }

    AddObjects(flex1);
    AddObjects(flex2);
  }

  void _controlMouseDown(sender, btn, shift, x, y) => SelectControl(sender);

  void SelectControl(TWinControl ctrl)
  {
    int ndx = comboList.Items.IndexOfObject(ctrl);
    if(ndx>=0)
    {
      comboList.ItemIndex = ndx;
      comboList.OnSelect!(comboList);
    }
  }
}