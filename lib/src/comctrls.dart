part of vcl;



void TabControlError(String s)
{
  throw EListError(s);
}

class TTabStrings extends TStrings
{
  final TCustomTabControl TabControl;

  TTabStrings(this.TabControl) : super();

  dynamic PerformHandle(MESSAGE msg, dynamic wParam, dynamic lParam)
  {
    return TabControl.PerformHandle(msg, wParam, lParam);
  }

  void Clear()
  {
    if(TabControl.HandleAllocated())
      if(PerformHandle(TCM_DELETEALLITEMS, 0, 0) == 0)
        TabControlError(ComStrs.sTabFailClear);
    TabControl.TabsChanged();
  }

  void Delete(int Index)
  {
    if(TabControl.HandleAllocated())
      if(PerformHandle(TCM_DELETEITEM, Index, 0) == 0)
        TabControlError(SysUtils.Format(ComStrs.sTabFailDelete, [Index]));
    TabControl.TabsChanged();
  }

  String Get(int Index)

  {

    return "";
  }

  int GetCount()
  {
    return toIntDef(PerformHandle(TCM_GETITEMCOUNT, 0, 0), 0);
  }

  dynamic GetObject(int Index)
  {
    var TCItem = TTCItem();
    TCItem.mask = TCIF_PARAM;
    if(toIntDef(PerformHandle(TCM_GETITEM, Index, TCItem), 0) == 0)
      TabControlError(SysUtils.Format(ComStrs.sTabFailGetObject, [Index]));
    return TCItem.lParam as TObject;
  }

  void Put(int Index, String S)
  {

    TabControl.TabsChanged();
  }

  void PutObject(int Index, dynamic AObject)
  {
    var TCItem = TTCItem();
    TCItem.mask = TCIF_PARAM;
    TCItem.lParam = AObject;
    if(toIntDef(PerformHandle(TCM_SETITEM, Index, TCItem), 0) == 0)
      TabControlError(SysUtils.Format(ComStrs.sTabFailSetObject, [Index]));
  }

  void Insert(int Index, String S)
  {
/*    RTL: array[Boolean] of LongInt = (0, TCIF_RTLREADING);*/
    var TCItem =  TTCItem();
    TCItem.mask = TCIF_TEXT /*| RTL[FTabControl.UseRightToLeftReading] | TCIF_IMAGE*/;
    TCItem.pszText = S;
/*    TCItem.iImage := FTabControl.GetImageIndex(Index);*/
    if(toIntDef(PerformHandle(TCM_INSERTITEM, Index, TCItem), -1) < 0)
      TabControlError(SysUtils.Format(ComStrs.sTabFailSet, [S, Index]));
    TabControl.TabsChanged();
  }

  void SetUpdateState(bool Updating)
  {
    TabControl._updating = Updating;
    PerformHandle(WM_SETREDRAW, !Updating, 0);
    if(!Updating)
    {
      TabControl.Invalidate();
      TabControl.TabsChanged();
    }
  }

}


class TCustomTabControl extends TWinControl
{

  TStrings? _tabs;
  TStrings get Tabs => _tabs!;
  void set Tabs(TStrings Value) => Tabs.Assign(Value);

  bool _updating = false;


  TCustomTabControl(TComponent AOwner) : super(AOwner)
  {
    Width = 289;
    Height = 193;
    TabStop = true;

    _tabs = TTabStrings(this);

  }



  bool CanChange()
  {
    bool Result = true;
    
    return Result;
  }

  bool CanShowTab(int TabIndex)
  {
    return true;
  }

  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;

  void Change()
  {
    if(_onChange != null)
      OnChange!(this);
  }



  dynamic PerformHandle(MESSAGE msg, dynamic wParam, dynamic lParam)
  {
    return Windows.SendMessage(Handle, msg, wParam, lParam);
  }

  void CreateWnd()
  {
    super.CreateWnd();

  }



  int
    get TabIndex
    {
      if(!HandleAllocated()) // new
        return -1;
      return toIntDef(Windows.SendMessage(Handle, TCM_GETCURSEL, 0, 0), -1);
    }

    set TabIndex(int Value)
    {
      if(HandleAllocated()) // new
        Windows.SendMessage(Handle, TCM_SETCURSEL, Value, 0);
    }



  void TabsChanged()
  {
    if(_updating)
      return;
    if(HandleAllocated())
      Windows.SendMessage(Handle, WM_SIZE, Windows.SIZE_RESTORED, SIZE(Width, Height));
    Realign();
  }


  void Dispatch(TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_NOTIFY: _cnNotify(TWMNotify(Message)); break;
      default:
        super.Dispatch(Message);
        break;
    }

  }

  void _cnNotify(TWMNotify Message)
  {
      switch(Message.NMHdr.code)
      {
        case TCN_SELCHANGE:
          Change();
          break;
        case TCN_SELCHANGING:
          Message.Result = 1;
          if(CanChange())
            Message.Result = 0;
          break;
      }
  }



}

class TTabControl extends TCustomTabControl
{

  TTabControl(TComponent AOwner) : super(AOwner)
  {

  }
}

class TTabSheet extends TWinControl
{

  TPageControl? _pageControl;
  TPageControl?
    get PageControl => _pageControl;
    set PageControl(TPageControl? APageControl)
    {
      if(_pageControl == APageControl)
        return;
      if(_pageControl != null)
        _pageControl!.RemovePage(this);
      Parent = APageControl;
      if(APageControl != null)
        APageControl.InsertPage(this);
    }


  String get Caption => _getText();
  void set Caption(String Value) => _setText(Value);

  TTabSheet(TComponent AOwner) : super(AOwner)
  {
    Align = TAlign.Client;
    ControlStyle << ControlStyles.AcceptsControls << ControlStyles.NoDesignVisible;
    Visible = false;

  }



  void CreateParams(TCreateParams Params)
  {
    super.CreateParams(Params);
    Params.X = null;
    Params.Y = null;
    Params.Width = null;
    Params.Height = null;
    Params.Style |= Windows.WS_VISIBLE;
  }


  void CreateWindowHandle(TCreateParams Params) // new
  {
    var pages = _parent as TPageControl?;
    if(pages == null)
      return;

    var ctrl = pages.WindowHandle as HPageControl;
    var tab = ctrl.findTabSheet(this)!;

    

/*    if(Params.Caption.isNotEmpty)
      tab.label.text = Params.Caption;
    tab.radio.checked = pages.ActivePage == this;*/

    WindowHandle = tab;
    _updateTabStyle();
  }

  void _updateTabStyle()
  {
    (WindowHandle as HTabSheet)
        ..label.style.display = TabVisible? '' : 'none'
        ..label.style.lineHeight = TabVisible? '' : '0'
        .._client.style.top = TabVisible? '' : '0'
        .._client.style.border = TabVisible? '' : '0px';
  }



  void DoHide()
  {

  }

  void DoShow()
  {

  }

  int get PageIndex
  {
    if(_pageControl == null)
      return -1;
    return _pageControl!._pages.indexOf(this);
  }

  int get TabIndex
  {
    int Result = 0;
    if(!_tabShowing)
      Result--;
    else
      for(int i = 0; i<PageIndex; i++)
        if(_pageControl!._pages[i]._tabShowing)
          Result++;
    return Result;
  }


  TRect GetClientRect() // new
  {
    TRect Rect=Parent!.ClientRect;
    if(TabVisible)
    {
      Rect.bottom-=2;
      Rect.right-=2;
      Rect.bottom-=21;

      Rect.left+=2;
      Rect.top+=2;
      Rect.right-=2;
      Rect.bottom-=2;
    }
    return Rect;

  }

  void set PageIndex(int Value)
  {
    if(_pageControl == null)
      return;
    int MaxPageIndex = _pageControl!.PageCount - 1;
    if(Value > MaxPageIndex)
      throw EListError.CreateResFmt(ComStrs.sPageIndexError, [Value, MaxPageIndex]);
    int i = TabIndex;
    _pageControl!._pages.move(PageIndex, Value);
    if(i >= 0)
      _pageControl!.MoveTab(i, TabIndex);
  }

  bool _tabShowing = false;
  bool get TabShowing => _tabShowing;
  void set TabShowing(bool Value)
  {
    if(_tabShowing == Value)
      return;
    if(Value)
    {
      _tabShowing = true;
      _pageControl!.InsertTab(this);
    }
    else
    {
      int Index = TabIndex;
      _tabShowing = false;
      _pageControl!.DeleteTab(this, Index);
    }
  }

  bool _tabVisible = true;
  bool get TabVisible => _tabVisible;
  void set TabVisible(bool Value)
  {
    if(_tabVisible == Value)
      return;
    _tabVisible = Value;



    UpdateTabShowing();


  }

  void UpdateTabShowing()
  {
    TabShowing = (PageControl != null) && _tabVisible;
  }





  void WndProc(TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_GETTEXT:
        if(HandleAllocated())
        {
          Message.Result = (WindowHandle as HTabSheet).caption;
          return;
        }
        break;

      case CM_SHOWINGCHANGED:
        // предотвращаем сокрытие табов
        if(HandleAllocated())
        {
          (WindowHandle as HTabSheet).radio.checked = Showing;
          return;
        }
        return;

    }
    super.WndProc(Message);
  }
}

class TPageControl extends TCustomTabControl
{
  final _pages = <TTabSheet>[];
  late final TItems<TTabSheet> Pages;

  TTabSheet? _activePage;
  TTabSheet?
    get ActivePage => _activePage;
    set ActivePage(TTabSheet? Page)
    {
      if((Page != null) && (Page.PageControl != this))
        return;
      ChangeActivePage(Page);
      if(Page == null)
        TabIndex = -1;
      else
      if(Page == _activePage)
        TabIndex = Page.TabIndex;
    }

  int get PageCount => _pages.length;



  TPageControl(TComponent AOwner) : super(AOwner)
  {
    Pages = TItems<TTabSheet>(
      (ndx) => _pages[ndx],
      ()    => _pages.iterator );


  }

  void Destroy()
  {
    for(var item in _pages)
      item._pageControl = null;

    super.Destroy();
  }

  void AlignControl(TControl? AControl) // new
  { 
    if(AControl==null)
    {
      for(int i=0; i<ControlCount; i++)
      {
        TControl ctrl = Controls[i];
        if(ctrl is TTabSheet)
          ctrl.AlignControl(null);
      }
      return;
    }
    super.AlignControl(AControl);
  }

  void CreateWindowHandle(TCreateParams Params) // new
  {
    var ctrl = HPageControl();
    ctrl._ul.onChange.listen((Sender) => ActivePageIndex = TabIndex ); // new

    WindowHandle = ctrl;

  }





  bool CanShowTab(int TabIndex)
  {
    return _pages[TabIndex].Enabled;
  }

  void Change()
  {
    if(TabIndex >= 0)
      UpdateActivePage();
    if(ComponentState.contains(ComponentStates.Designing))
    {

    }
    super.Change();
  }

  void ChangeActivePage(TTabSheet? Page)
  {
    if(_activePage == Page)
      return;
    TCustomForm? form = ParentForm;
    if((form != null) && (_activePage != null) &&
      _activePage!.ContainsControl(form.ActiveControl))
    {
      form.ActiveControl = _activePage;
      if(form.ActiveControl != _activePage)
      {
        TabIndex = _activePage!.TabIndex;
        return;
      }
    }
    if(Page != null)
    {
      Page.BringToFront();
      Page.Visible = true;
      if((form != null) && (_activePage != null) && (form.ActiveControl == _activePage))
        form.ActiveControl = Page.CanFocus()? Page : this;
    }
    if(_activePage != null)
      _activePage!.Visible = false;
    _activePage = Page;
    if((form != null) && (_activePage != null) &&
      (form.ActiveControl == _activePage))
        _activePage!.SelectFirst();
  }

  void DeleteTab(TTabSheet Page, int Index)
  {
    bool UpdateIndex = Page == ActivePage;
    Tabs.Delete(Index);
    if(UpdateIndex)
    {
      if(Index >= Tabs.Count)
        Index = Tabs.Count - 1;
      TabIndex = Index;
    }
    UpdateActivePage();
  }



  TTabSheet? FindNextPage(TTabSheet? CurPage, bool GoForward, bool CheckTabVisible)
  {
    if(_pages.isEmpty)
      return null;
    int StartIndex = CurPage==null? -1 : _pages.indexOf(CurPage);
    if(StartIndex == -1)
      StartIndex = GoForward? _pages.length - 1 : 0;
    int i = StartIndex;
    do
    {
      if(GoForward)
      {
        i++;
        if(i == _pages.length)
          i = 0;
      }
      else
      {
        if(i == 0)
          i = _pages.length;
        i--;
      }
      TTabSheet Result = _pages[i];
      if(!CheckTabVisible || Result.TabVisible)
        return Result;
    } while(i != StartIndex);
    return null;
  }



  void InsertPage(TTabSheet Page)
  {
    _pages.add(Page);
    Page._pageControl = this;
    Page.UpdateTabShowing();
  }

  void InsertTab(TTabSheet Page)
  {
    Tabs.InsertObject(Page.TabIndex, Page.Caption, Page);
    UpdateActivePage();
  }

  void MoveTab(int CurIndex, int NewIndex)
  {
    Tabs.Move(CurIndex, NewIndex);
  }

  void RemovePage(TTabSheet Page)
  {
    TTabSheet? NextSheet = FindNextPage(Page, true, !ComponentState.contains(ComponentStates.Designing));
    if(NextSheet == Page)
      NextSheet = null;
    Page.TabShowing = false;
    Page._pageControl = null;
    _pages.remove(Page);
    ActivePage = NextSheet;
  }

  void SelectNextPage(bool GoForward, [bool CheckTabVisible = true] )
  {
    TTabSheet? Page = FindNextPage(ActivePage, GoForward, CheckTabVisible);
    if((Page != null) && (Page != ActivePage) && CanChange())
    {
      ActivePage = Page;
      Change();
    }
  }



  void UpdateTab(TTabSheet Page)
  {
    Tabs.Strings[Page.TabIndex] = Page.Caption;
  }

  void UpdateActivePage()
  {
    int ndx = TabIndex;
    ActivePage = ndx >= 0? Tabs.Objects[ndx] : null;
  }



  int get ActivePageIndex
  {
    return ActivePage==null? -1 : ActivePage!.PageIndex;
  }

  void set ActivePageIndex(int Value)
  {
    if((Value > -1) && (Value < PageCount))
      ActivePage = Pages[Value];
    else
      ActivePage = null;
  }
}


class TStatusPanel extends TCollectionItem
{
  final Handle = HStatusPanel();


  TStatusPanel() : super()
  {
    Handle.style.width = '${Width}px';

  }



  String _text = '';
  String get Text => _text;
  void set Text(String Value)
  {
    if(_text == Value)
      return;
    _text = Value;
    Handle.handle.text = this.Text;
    Changed(false);
  }

  int _width = 50;
  int get Width => _width;
  void set Width(int Value)
  {
    if(_width == Value)
      return;
    _width = Value;
    Handle.style.width = '${Width}px';
    Changed(true);
  }

}

class TStatusPanels  extends TCollection
{
  final TCustomStatusBar StatusBar;


  late final TItems<TStatusPanel> _panels;
  TItems<TStatusPanel> get Items => _panels;

  TStatusPanels(this.StatusBar) :
        super((owner) => TStatusPanel())
  {
    _panels = TItems<TStatusPanel>.from(super.Items);
    
  }

  TStatusPanel Add() => super.Add() as TStatusPanel;


}

class TCustomStatusBar extends TWinControl
{

  late final TStatusPanels Panels; 


  DivElement? _simplePanel;

  TCustomStatusBar(TComponent AOwner) : super(AOwner)
  {
    ControlStyle.assign(
        [ ControlStyles.CaptureMouse, ControlStyles.ClickEvents,
          ControlStyles.DoubleClicks, ControlStyles.Opaque]);

    Height = 19;
    Align = TAlign.Bottom;
    Panels = CreatePanels();

  }

  void Destroy()
  {

    Panels.Destroy();
    super.Destroy();
  }


  void UpdateSimpleText()
  {
    if(HandleAllocated())
      _simplePanel!.text = SimpleText;

  }

  String _simpleText = "";
  String get SimpleText => _simpleText;
  void set SimpleText(String Value)
  {
    if(_simpleText == Value)
      return;
    _simpleText = Value;
    UpdateSimpleText();
  }



  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HStatusBar();

    for(int i=0; i<Panels.Count; i++)
    {
      TStatusPanel p = Panels.Items[i];
      p.Handle.setParent(WindowHandle);
    }

    var sp = DivElement();
    _simplePanel = sp;
    sp.className = HStatusPanel.STATUSPANEL.name;
    sp.style.flex = 'auto';

    sp.style.marginRight = '0';
    if(SimpleText != '')
      sp.text = SimpleText;

    sp.owner = WindowHandle;

    WindowHandle!.handle.append(sp);
  }



  TStatusPanels CreatePanels()
  {
    return TStatusPanels(this);
  }



}



class TCommonCalendar extends TWinControl
{


  TCommonCalendar(TComponent AOwner) : super(AOwner)
  {

    _dateTime = SysUtils.Now();
    
  }



  TDateTime? _dateTime;
  TDateTime get DateTime  => _dateTime!;
  void set DateTime(TDateTime Value)

  {

      _dateTime = Value;

  }


}


class TDateTimePicker extends TCommonCalendar
{



  TDateTimePicker(TComponent AOwner) : super(AOwner)
  {
    
    TabStop = true;
    Width = 186;
    Height = 24; // new

  }





  void CreateWindowHandle(TCreateParams Params) // new
  {
    WindowHandle = HDateTimePick();
  }



}


class TStatusBar extends TCustomStatusBar
{


  TStatusBar(TComponent AOwner) : super(AOwner)
  {

  }

}
