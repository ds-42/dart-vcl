part of vcl;


class EMenuError extends TException
{
  EMenuError.CreateRes(dynamic ident) : super.CreateRes(ident);
}


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
    

  final _items = <TMenuItem>[];

  late final TItems<TMenuItem> Items;




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



  TMenu(TComponent? AOwner) : super(AOwner)
  {
    Items = TMenuItem(this);

    Items._menu = this;

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


  bool IsRightToLeft()
  {
    return false; 
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


  TPopupMenu(TComponent owner) : super(owner)
  {
    

  }

  void Destroy()
  {
    
    super.Destroy();
  }


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


