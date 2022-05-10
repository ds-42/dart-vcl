part of vcl;


class EMenuError extends TException
{
  EMenuError.CreateRes(dynamic ident) : super.CreateRes(ident);
}


enum TPopupAlignment { Left, Right, Center }


void _menu_error(var ResStr)
{
  throw EMenuError.CreateRes(ResStr);
}



// Menu command managment

final TBits _commandPool = TBits();

int UniqueCommand()
{
  int Result = _commandPool.OpenBit();
  _commandPool.Bits[Result] = true;
  return Result;
}



class TMenuItem extends TComponent
{
  static const cLineCaption = '-';

  String _caption = '';
  String
    get Caption => _caption;
    set Caption(String Value)
    {
      if(_caption == Value)
        return;
      _caption = Value;
      MenuChanged(true);
    }

  HMENU? _handle;
  HMENU get Handle
  {
    if(_handle == null)
    {
      if(Owner is TMainMenu)
        _handle = HMAINMENU();
      else
      if(Owner is TPopupMenu)
        _handle = Windows.CreatePopupMenu();
      else
        _handle = Windows.CreateMenu();

      // new
      _handle!.OnClick = (dynamic id)
      {
        for(int i=0; i<Count; i++)
        {
          TMenuItem item = Items[i];
          if(item.Command == id)
          {
            if(item.OnClick != null)
              item.OnClick!(item);
            break;
          }
        }
      };

      PopulateMenu();
    }
    return _handle!;
  }

  bool _checked = false;
  bool
    get Checked => _checked;
    set Checked(bool Value)
    {
      if(Checked == Value)
        return;
      _checked = Value;
  
      if(Value && _radioItem)
        TurnSiblingsOff();
    }

  bool _enabled=true;
  bool
    get Enabled => _enabled;
    set Enabled(bool Value)
    {
      if(_enabled == Value)
        return;
      _enabled = Value;
  
    }



  bool _radioItem = false;
  bool
    get RadioItem => _radioItem;
    set RadioItem(bool Value)
    {
      if(RadioItem == Value)
        return;
      _radioItem = Value;
      if(Checked && RadioItem)
        TurnSiblingsOff();
      MenuChanged(true);
    }

  bool _visible = true;
  bool
    get Visible => _visible;
    set Visible(bool Value)
    {
      if(_visible == Value)
        return;
      _visible = Value;
      MenuChanged(true);
    }

  int _groupIndex = 0;
  int
    get GroupIndex => _groupIndex;
    set GroupIndex(int Value)
    {
      if(_groupIndex == Value)
        return;

      Parent?.VerifyGroupIndex(Parent!.IndexOf(this), Value);
      _groupIndex = Value;
      if(Checked && _radioItem)
        TurnSiblingsOff();
    }


  int _command = 0;
  int get Command => _command;

  THelpContext _helpContext = 0;
  THelpContext
    get HelpContext => _helpContext;
    set HelpContext(THelpContext Value) => _helpContext = Value;

  String _hint = '';
  String
    get Hint => _hint;
    set Hint(String Value) => _hint = Value;

  final _items = <TMenuItem>[];

  late final TItems<TMenuItem> Items;



  TShortCut _shortCut = TShortCut.None;
  TShortCut
    get ShortCut => _shortCut;
    set ShortCut(TShortCut Value)
    {
      if(_shortCut == Value)
        return;
      _shortCut = Value;
      MenuChanged(true);
    }


  TMenuItem? _parent;
  TMenuItem?
    get Parent => _parent;

  TMenuItem? _merged;

  TMenu? _menu;

  TNotifyEvent? _onClick;
  TNotifyEvent?
    get OnClick => _onClick;
    set OnClick(TNotifyEvent? Value) => _onClick = Value;
    

  int get Count => _items.length;



  TMenuItem(TComponent? AOwner) : super(AOwner)
  {
    Items = TItems<TMenuItem>(
      (int ndx) => _items[ndx],
      ()        => _items.iterator);

    _command = UniqueCommand();

  }

  void Destroy()
  {

    super.Destroy();
  }


  Element? _itemHandle;
  Element? get ItemHandle => _itemHandle; // new

  bool _rightAlign = false;
  bool
    get RightAlign => _rightAlign;
    set RightAlign(bool Value)
    {
      if(_rightAlign == Value)
        return;
      _rightAlign = Value;
      if(ItemHandle!=null)
        _updateRightAlign();
    }

  _updateRightAlign()
  {
    ItemHandle!.style.float = RightAlign? 'right' : '';
    Handle.handle.style
      ..left = RightAlign? 'unset' : null
      ..right = RightAlign? '-1px' : null;
  }

  void AppendTo(HMENU Menu, bool ARightToLeft)
  {

    if(_visible)
    {
      String Caption = _caption;

        if(Count > 0)
          _itemHandle = Menu.append(Caption, submenu: Handle); 
        else
          _itemHandle = Menu.append(Caption, value: Command, enabled: Enabled); 


      if(_itemHandle!=null && RightAlign) 
        _updateRightAlign();

    }
  }

  void PopulateMenu()
  {
    bool MenuRightToLeft = false;

    bool AddIn(TMenuItem MenuItem)
    {
      MenuItem.AppendTo(_handle!, MenuRightToLeft);
      return false;
    }

    if((_menu != null) && (_menu is TMainMenu))
    {
      
    }

    // all menu items use BiDiMode of their root menu
    MenuRightToLeft = (_menu != null) && _menu!.IsRightToLeft();
    _iterateMenus(AddIn, _merged, this);
  }



  void RebuildHandle()
  {

  }

  void VerifyGroupIndex(int Position, int Value)
  {
    for(int i = 0;  i<Count; i++)
      if(i < Position)
      {
        if(_items[i].GroupIndex > Value)
          _menu_error(Consts.SGroupIndexTooLow);
      }
      else  // Ripple change to menu items at Position and after
      if(_items[i].GroupIndex < Value)
        _items[i].GroupIndex = Value;
  }


  void TurnSiblingsOff()
  {
    if(_parent != null)
      for(int i = 0; i<_parent!.Count; i++)
      {
        TMenuItem Item = _parent!.Items[i];
        if((Item != this) && Item._radioItem && (Item.GroupIndex == GroupIndex))
          Item.Checked = false;
      }
  }


  void Insert(int Index, TMenuItem Item)
  {
    if(Item._parent != null)
      _menu_error(Consts.SMenuReinserted);
    if((Index - 1 >= 0) && (Index - 1 < _items.length))
      if(Item.GroupIndex < _items[Index - 1].GroupIndex)
        Item.GroupIndex = _items[Index - 1].GroupIndex;
    
    _items.insert(Index, Item);
    Item._parent = this;
    
    if(_handle != null)
      RebuildHandle();
    MenuChanged(Count == 1);
  }

  void Delete(int Index)
  {
    if((Index < 0) || (Index >= Count))
      _menu_error(Consts.SMenuIndexError);
    TMenuItem cur = _items[Index];
    _items.removeAt(Index);
    cur._parent = null;
    
    if(_handle != null)
      RebuildHandle();
    MenuChanged(Count == 0);
  }



  int IndexOf(TMenuItem Item) => _items.indexOf(Item);

  void Add(TMenuItem Item)
  {
    Insert(Count, Item);
  }

  TMenuItem AddEx(String Caption, {int Index=-1, TNotifyEvent? OnClick, bool enabled = true, dynamic tag } )
  {
    TMenuItem item = TMenuItem(this);
    if(Index == -1)
      Add(item);
    else
      Insert(Index, item);
    item.Caption = Caption;
    item.Enabled = enabled;
    item.OnClick = OnClick;
    if(tag!=null)
      item.Tag = tag;
    return item;
  }

  void Remove(TMenuItem Item)
  {
    int i = IndexOf(Item);
    if(i == -1)
      _menu_error(Consts.SMenuNotFound);
    Delete(i);
  }

  void MenuChanged(bool Rebuild)
  {
    TMenuItem? Source;
    if((Parent == null) && (Owner is TMenu))
      Source = null;
    else
      Source = this;

  }



  TMenu? GetParentMenu()
  {
    TMenuItem MenuItem = this;
    while(MenuItem.Parent != null)
      MenuItem = MenuItem.Parent!;
    return MenuItem._menu;
  }



}


class TMenu extends TComponent
{
  HMENU get Handle => GetHandle();

  HMENU GetHandle() => Items.Handle;

  late final TMenuItem Items;

  HForm? _windowHandle;
  HForm?
    get WindowHandle => _windowHandle;
    set WindowHandle(HForm? Value)
    {
      _windowHandle = Value;
      
      //  When menus are created, if BiDiMode does not follow the parent,
      //  main menu headers are displayed in reversed order. Changing BiDiMode
      //  twice fixes this.
      
    }



    bool _parentBiDiMode = true;
    bool
      get ParentBiDiMode => _parentBiDiMode;
      set ParentBiDiMode(bool Value)
      {
        if(_parentBiDiMode == Value)
          return;

        _parentBiDiMode = Value;
        ParentBiDiModeChanged();
      }

  TMenu(TComponent? AOwner) : super(AOwner)
  {
    Items = TMenuItem(this);

    Items._menu = this;

    ParentBiDiModeChanged();
  }

  void Destroy()
  {

    super.Destroy();
  }

  TMenuItem AddEx(String Caption, [int Index=-1])
  {
    TMenuItem item = TMenuItem(this);
    if(Index == -1)
      Items.Add(item);
    else
      Items.Insert(Index, item);
    item.Caption = Caption;
    //ret->OnClick=ev;
    return item;
  }



  void DoBiDiModeChanged()
  {

  }

  bool IsRightToLeft()
  {
    return false; 
  }



  TBiDiMode _biDiMode = TBiDiMode.LeftToRight;
  TBiDiMode
    get BiDiMode => _biDiMode;
    set BiDiMode(TBiDiMode Value)
    {
      if(_biDiMode == Value)
        return;
      _biDiMode = Value;
      _parentBiDiMode = false;
      DoBiDiModeChanged();
    }

  void ParentBiDiModeChanged()
  {
    if(!_parentBiDiMode)
      return;
    var AForm = FindControl(WindowHandle);
    if(AForm != null)
    {
      BiDiMode = AForm.BiDiMode;
      _parentBiDiMode = true;
    }
  }

  void ParentBiDiModeChangedEx(TObject AControl) // changed name
  {
    if(!_parentBiDiMode)
      return;
    BiDiMode = (AControl as TControl).BiDiMode;
    _parentBiDiMode = true;
  }


}


class TMainMenu extends TMenu
{

  bool _autoMerge = false;
  bool
    get AutoMerge => _autoMerge;
    set AutoMerge(bool Value)
    {
      if(_autoMerge == Value)
        return;
      _autoMerge = Value;
      if(_windowHandle != null)
        Windows.SendMessage(_windowHandle!, CM_MENUCHANGED, null, null);
    }


  TMainMenu(TComponent? owner) : super(owner)
  {

  }


  HMENU GetHandle()
  {

    return super.GetHandle();
  }


}


class TPopupMenu extends TMenu
{

  TPoint _popupPoint = TPoint(-1, -1);
  TPoint get PopupPoint => _popupPoint;

  TPopupAlignment  _alignment = TPopupAlignment.Left;
  TPopupAlignment
    get Alignment => _alignment;
    set Alignment(TPopupAlignment Value) => _alignment = Value;

  bool _autoPopup = true;
  bool
    get AutoPopup => _autoPopup;
    set AutoPopup(bool Value) => _autoPopup = Value;

  TComponent? _popupComponent;
  TComponent?
    get PopupComponent => _popupComponent;
    set PopupComponent(TComponent? Value) => _popupComponent = Value;

  TNotifyEvent? _onPopup;
  TNotifyEvent?
    get OnPopup => _onPopup;
    set OnPopup(TNotifyEvent? Value) => _onPopup = Value;



  TPopupMenu(TComponent owner) : super(owner)
  {
    Items.OnClick = DoPopup; 
  }

  void Destroy()
  { 
    super.Destroy();
  }

  void DoPopup(TObject Sender)
  {
    if(_onPopup!=null) _onPopup!(Sender);
  }



  void Popup(int X, int Y)
  {


    _popupPoint = TPoint(X, Y);

    DoPopup(this);

    Windows.TrackPopupMenu(Items.Handle, 0/*AFlags*/, X, Y, 0 /* reserved */, HWND_DESKTOP/*PopupList.Window*/, null);
  }
}

// Menu building functions

void InitMenuItems(TMenu AMenu, List<TMenuItem> Items)
{

}

TMainMenu NewMenu(TComponent Owner, String AName, List<TMenuItem> Items)
{
  var Result = TMainMenu(Owner);
  Result.Name = AName;
  InitMenuItems(Result, Items);
  return Result;
}

TPopupMenu NewPopupMenu(TComponent Owner, String AName, TPopupAlignment Alignment, bool AutoPopup, List<TMenuItem> Items)
{
  var Result = TPopupMenu(Owner);
  Result.Name = AName;
  Result.AutoPopup = AutoPopup;
  Result.Alignment = Alignment;
  InitMenuItems(Result, Items);
  return Result;
}

TMenuItem NewSubMenu(String ACaption, THelpContext hCtx, String AName, List<TMenuItem> Items, bool AEnabled)
{
  var Result = TMenuItem(null);
  for(var item in Items)
    Result.Add(item);
  Result.Caption = ACaption;
  Result.HelpContext = hCtx;
  Result.Name = AName;
  Result.Enabled = AEnabled;
  return Result;
}

TMenuItem NewItem(String ACaption, TShortCut AShortCut, bool AChecked, bool AEnabled, TNotifyEvent AOnClick, THelpContext hCtx, String AName)
{
  return TMenuItem(null)
    ..Caption = ACaption
    ..ShortCut = AShortCut
    ..OnClick = AOnClick
    ..HelpContext = hCtx
    ..Checked = AChecked
    ..Enabled = AEnabled
    ..Name = AName;
}

TMenuItem NewLine()
{
  return TMenuItem(null)
    ..Caption = TMenuItem.cLineCaption;
}




// Used to populate or merge menus

void _iterateMenus(Function Func, TMenuItem? Menu1, TMenuItem? Menu2)
{
  int IIndex=0, JIndex;

  bool iterate(int i, TMenuItem? MenuItem, Function AFunc)
  {
    if(MenuItem == null)
      return false;

    bool Result = false;
    while(!Result && (i < MenuItem.Count))
    {
      TMenuItem Item = MenuItem.Items[i];
      if(Item.GroupIndex > IIndex)
        break;
      Result = AFunc(Item);
      i++;
    }
    return Result;
  }

  int i = 0;
  int j = 0;
  int Menu1Size = Menu1 == null? 0 : Menu1.Count;
  int Menu2Size = Menu2 == null? 0 : Menu2.Count;
  bool done = false;
  while(!done && ((i < Menu1Size) || (j < Menu2Size)))
  {
    IIndex = 255; 
    JIndex = 255; 
    if((i < Menu1Size))
      IIndex = Menu1!.Items[i].GroupIndex;
    if((j < Menu2Size))
      JIndex = Menu2!.Items[j].GroupIndex;
    if(IIndex <= JIndex)
      done = iterate(i, Menu1, Func);
    else
    {
      IIndex = JIndex;
      done = iterate(j, Menu2, Func);
    }
    while((i < Menu1Size) && (Menu1!.Items[i].GroupIndex <= IIndex))
      i++;
    while((j < Menu2Size) && (Menu2!.Items[j].GroupIndex <= IIndex))
      j++;
  }
}


