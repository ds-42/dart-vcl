part of demo;

TTabSheet BuildFlexControlsPage(TPageControl pages)
{
  return TTabFlexControls(pages)
    ..Caption = 'flex'
    ..PageControl = pages;
}

class TTabFlexControls extends TTabSheet
{
  late final TFlexBox FlexBox;

  late TComboBox AlignItem;
  late TComboBox BreakBeforeItem;
  late TButton DeleteItem;
  late TComboBox JustifyItem;
  late TEdit GrowItem;
  late TEdit MaxWidthItem;
  late TEdit MinWidthItem;
  late TEdit NameItem;

  int ObjectID = 1;

  TTabFlexControls(TPageControl pages) : super(pages)
  {
    OnClick = (Sender) => SelectControl(null);

    late TComboBox combo;

    TFlexBox(this) // tools
      ..Name = 'test'
      ..Align = TAlign.Top
      ..Color = clBtnFace.tone(-0.1)
      ..Parent = this
      ..Add([

        TButton(this)
          ..Caption = 'Clear'
          ..OnClick = (Sender) => Clear(),

        TButton(this)
          ..Caption = 'Refresh'
          ..OnClick = (Sender) => FlexBox.FlexControls(),

        combo = TComboBox(this)
          ..Width = 120
        /**        ..Style = TComboBoxStyle.DropDown **/
            ..Items.AddObject('TButton', TButton)
            ..Items.AddObject('TCheckBox', TCheckBox)
            ..Items.AddObject('TComboBox', TComboBox)
            ..Items.AddObject('TEdit', TEdit)
            ..Items.AddObject('TMemo', TMemo)
            ..Items.AddObject('TPanel', TPanel)
            ..Items.AddObject('TRadioButton', TRadioButton)
            ..ItemObject = TPanel
        ,

        TButton(this)
          ..Caption = 'Create'
          ..OnClick = (Sender) => CreateFlexControl(combo.ItemObject),

        TButton(this)
          ..Caption = 'Create TPanel'
          ..Width = 110
          ..OnClick = (Sender) => CreateFlexControl(TPanel),

        TButton(this)
          ..Caption = 'Create TEdit'
          ..Width = 110
          ..OnClick = (Sender) => CreateFlexControl(TEdit),

      ]);

    var flexPanel = TPanel(this)
      ..Align = TAlign.Client
      ..BevelOuter = TBevelCut.None
      ..Parent = this;

    FlexBox = TFlexBox(flexPanel)
      ..Align = TAlign.Client
      ..FlexItems.Grow = 1
//      ..FlexItems.MaxWidth = TMetric(100)
      ..Parent = flexPanel
      ..Color = clRed.tone(0.8)
      ..OnMouseDown = (sender, btn, shift, x, y) => SelectControl(null);

    var inspector = TFlexBox(this)
      ..Align = TAlign.Right
      ..AlignItems = TFlexAlignItem.FlexEnd
      ..Color = clBtnFace.tone(-0.1)
      ..FlexItems.Grow = 1
      ..Width = 250
      ..Parent = this;

    inspector.Add([
      TLabelGroup(this)
        ..Caption = 'Flex box'
        ..Flex.BreakBefore = true
        ..Alignment = TAlignment.Center,

      InspectCaption('Grow'),
      InspectEdit((val) =>
        FlexBox.FlexItems.Grow = toDoubleDef(val, FlexBox.FlexItems.Grow), allEvent: true )
        ..Text = '${ FlexBox.FlexItems.Grow }',

      InspectCaption('Align'),
      InspectEnum(TAlign.values, (val) =>
      FlexBox.Align = tryToEnum<TAlign>(val) ?? FlexBox.Align, allEvent: true)
        ..ItemObject = FlexBox.Align,

      InspectCaption('FlexDirection'),
      InspectEnum(TFlexDirection.values, (val) =>
        FlexBox.FlexDirection = tryToEnum<TFlexDirection>(val) ?? FlexBox.FlexDirection, allEvent: true)
        ..ItemObject = FlexBox.FlexDirection,

      InspectCaption('JustifyContent'),
      InspectEnum(TFlexJustifyContent.values, (val) =>
        FlexBox.JustifyContent = tryToEnum<TFlexJustifyContent>(val) ?? FlexBox.JustifyContent, allEvent: true)
        ..ItemObject = FlexBox.JustifyContent,

      InspectCaption('AlignItems'),
      InspectEnum(TFlexAlignItem.values, (val) =>
        FlexBox.AlignItems = tryToEnum<TFlexAlignItem>(val) ?? FlexBox.AlignItems, allEvent: true)
        ..ItemObject = FlexBox.AlignItems,

      InspectCaption('AlignContent'),
      InspectEnum(TFlexAlignContent.values, (val) =>
      FlexBox.AlignContent = tryToEnum<TFlexAlignContent>(val) ?? FlexBox.AlignContent, allEvent: true)
        ..ItemObject = FlexBox.AlignContent,

      //----------------------------------------------------------------------
      TLabelGroup(this)
        ..Caption = 'Flex item'
        ..Flex.BreakBefore = true
        ..Flex.MarginBottom = 0
        ..Alignment = TAlignment.Center,

      NameItem = TEdit(this)
        ..Flex.BreakBefore = true
        ..Flex.MarginTop = 0
        ..Flex.Grow = 2
        ..ParentColor = true
        ..ReadOnly = true,

      DeleteItem = TButton(this)
        ..Caption = 'Delete'
        ..Flex.Justify = TFlexJustify.Stretch
        ..OnClick = (Sender)
        {
          var ctrl = ActiveControl!;
          SelectControl(null);
          ctrl.Destroy();
        },

      TBevel(this)
        ..Flex.BreakBefore = true
        ..Flex.MarginTop = 0
        ..Height = 5
        ..Shape = TBevelShape.TopLine,

      InspectCaption('BreakBefore'),
      BreakBeforeItem = InspectLogic((val) =>
        ActiveControl!.Flex.BreakBefore = toBoolDef(val, ActiveControl!.Flex.BreakBefore) ),

      InspectCaption('Grow'),
      GrowItem = InspectEdit((val) =>
        ActiveControl!.Flex.Grow = toDoubleDef(val, ActiveControl!.Flex.Grow) ),

      InspectCaption('MinWidth'),
      MinWidthItem = InspectEdit((val) =>
        ActiveControl!.Flex.MinWidth = val.isEmpty? null : (TMetric.tryParse(val) ?? ActiveControl!.Flex.MinWidth)),

      InspectCaption('MaxWidth'),
      MaxWidthItem = InspectEdit((val) =>
        ActiveControl!.Flex.MaxWidth = val.isEmpty? null : (TMetric.tryParse(val) ?? ActiveControl!.Flex.MaxWidth)),

      InspectCaption('Justify'),
      JustifyItem = InspectEnum(TFlexJustify.values, (val) =>
        ActiveControl!.Flex.Justify = val, nullable: true),

      InspectCaption('Align'),
      AlignItem = InspectEnum(TFlexAlignItem.values, (val) =>
        ActiveControl!.Flex.Align = val, nullable: true),
    ]);

    for(int i=0; i<6; i++)
      CreateFlexControl(TPanel)!
        ..Flex.BreakBefore = i==0 || i==2 || i==5;

    SelectControl(null);
  }

  TWinControl? CreateFlexControl(Type t)
  {
    late TWinControl ctrl;
    String name = 'Object ${ObjectID++}';
    switch(t)
    {
      case TButton: ctrl = TButton(FlexBox)..Caption = name; break;
      case TCheckBox: ctrl = TCheckBox(FlexBox)..Caption = name; break;
      case TComboBox: ctrl = TComboBox(FlexBox)..Text = name; break;
      case TEdit: ctrl = TEdit(FlexBox)..Text = name ..ReadOnly = true; break;
      case TMemo: ctrl = TMemo(FlexBox)..Text = name ..ReadOnly = true; break;
      case TPanel: ctrl = TPanel(FlexBox)..Caption = name; break;
      case TRadioButton: ctrl = TRadioButton(FlexBox)..Caption = name; break;
      default:
        ObjectID--;
        return null;
    }

    ctrl.Parent = FlexBox;
    ctrl.Name = name;
    ctrl.OnMouseDown = (Sender, btn, shift, x, y) =>
      SelectControl(Sender as TWinControl?);
    SelectControl(ctrl);
    return ctrl;
  }

  TWinControl? ActiveControl;
  void SelectControl(TWinControl? ctrl)
  {
    if(ActiveControl == ctrl)
      return;
    ActiveControl = ctrl;

    EnableInspectControls(ctrl != null);
    if(ActiveControl == null)
    {
      LockEvents = true;
      AlignItem.ItemIndex = -1;
      BreakBeforeItem.ItemIndex = -1;
      GrowItem.Text = '';
      JustifyItem.ItemIndex = -1;
      MaxWidthItem.Text = '';
      MinWidthItem.Text = '';
      NameItem.Text = '';
      LockEvents = false;
      return;
    }

/**    if(!ActiveControl!.CanFocus())
      GetParentForm(FlexBox)!.ActiveControl = null;**/

    LockEvents = true;
    var flex = ActiveControl!.Flex;
    NameItem.Text = ActiveControl!.Name;
    BreakBeforeItem.ItemObject = flex.BreakBefore;
    AlignItem.ItemObject = flex.Align;
    JustifyItem.ItemObject = flex.Justify;
    GrowItem.Text = '${ flex.Grow }';
    MaxWidthItem.Text = '${ flex.MaxWidth ?? '' }';
    MinWidthItem.Text = '${ flex.MinWidth ?? '' }';
    LockEvents = false;
  }

  void EnableInspectControls(bool state)
  {
    BreakBeforeItem.Enabled = state;
    DeleteItem.Enabled = state;
    GrowItem.Enabled = state;
  }

  int _lock = 0;
  bool
    get LockEvents => ActiveControl==null || _lock > 0;
    set LockEvents(bool state) =>
      _lock+=(state? 1 : -1);

  TLabel InspectCaption(String caption)
  {
    return TLabel(this)
        ..Caption = '$caption:'
        ..Flex.Grow = 0.75
        ..Flex.BreakBefore =true;
  }

  TEdit InspectEdit(TEvent event, {bool allEvent=false})
  {
    return TEdit(this)
      ..OnKeyPress = (Sender, Key)
      {
        if(Key.Code == Windows.VK_RETURN)
        {
          if(!LockEvents || allEvent)
            event((Sender as TEdit).Text.trim());
          (Sender as TEdit).SelectAll();
        }
      };
  }

  TComboBox InspectEnum(List items, TEvent event, {bool nullable=false, bool allEvent=false})
  {
    var combo = TComboBox(this);
    if(nullable)
      combo.Items.AddObject('', null);
    for(var item in items)
    {
      String name = '$item'.split('.')[1];
      combo.Items.AddObject(name, item);
    }
    combo.OnSelect = (Sender)
    {
      if(!LockEvents || allEvent)
        event(combo.ItemObject);
    };
    return combo;
  }

  TComboBox InspectLogic(TEvent event, {bool nullable=false, bool allEvent=false})
  {
    var combo = TComboBox(this);
    if(nullable)
      combo.Items.AddObject('', null);

    combo.Items.AddObject('On', true);
    combo.Items.AddObject('Off', false);

    combo.OnSelect = (Sender)
    {
      if(!LockEvents || allEvent)
        event(combo.ItemObject);
    };
    return combo;

  }

  void Clear()
  {
    SelectControl(null);
    while(FlexBox.ControlCount > 0)
      FlexBox.Controls[0].Destroy();
  }

}