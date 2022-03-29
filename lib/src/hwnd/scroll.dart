part of vcl;

enum TScrollStyle { None, Horizontal, Vertical, Both }

class SCROLLINFO
{
  final int ScrollCode;
  final int Position;
  SCROLLINFO(this.ScrollCode, this.Position);
}

class TScrollInfo
{
  int nMin;      
  int nMax;      
  int nPage;     
  int nPos;      
  int nTrackPos; 
  TScrollInfo(this.nMin, this.nMax, this.nPage, this.nPos, this.nTrackPos);
  TScrollInfo.info(TScrollInfo src) : this(src.nMin, src.nMax, src.nPage, src.nPos, src.nTrackPos);
}

class TScroll
{
  int GetMin(int code) => 0;
  int GetMax(int code) => 0;
  int GetPos(int code) => 0;
  TScrollInfo GetInfo(int code) => TScrollInfo(0,0,0,0,0);

  bool IsVisible(int code) => GetMin(code) != GetMax(code);

  void Refresh(int code){}

  bool SetInfo(int code, TScrollInfo info) => false;
  bool SetPos(int code, int pos) => false;
  bool SetRange(int code, int min, int max) => false;
}

class _hScrollControl extends TScroll
{
  final HScrollControl Control;
  _hScrollControl(this.Control);

  HScrollBar bar(int kind) => kind == Windows.SB_HORZ? Control.horz : Control.vert;

  int GetMax(int kind) => bar(kind).max;
  int GetPos(int kind) => bar(kind).pos;

  TScrollInfo GetInfo(int kind)
  {
    HScrollBar sb = bar(kind);
    return TScrollInfo(sb.min, sb.max, sb.page, sb.pos, sb.pos);
  }

  bool SetInfo(int kind, TScrollInfo info)
  {
    HScrollBar sb = bar(kind);
    sb.update(info.nPos, info.nMin, info.nMax, info.nPage, null);

    return true;
  }

  bool SetRange(int kind, int min, int max)
  {
    HScrollBar sb = bar(kind);
    sb.update(null, min, max, null, null);
    return true;
  }

  bool SetPos(int kind, int pos)
  {

    if(pos<0)
      return false;
    bar(kind).pos = pos;
    return true;
  }

  void Refresh(int kind)
  {
    bar(kind)._refresh();
  }
}

class HScrollControl extends HCustomControl
{
  final horz = HScrollBar();
  final vert = HScrollBar();
  final Element client;

  Element getClientHandle() => client;

  late final TScroll scroll;

  HScrollControl.ex(this.client, TScrollStyle style) : super()
  {

    handle.style
      ..height = '100%'
      ..width = '100%';
    horz.kind = TScrollBarKind.Horizontal;
    updateScrollBars(style);

    vert.handle.setParent(this.handle);
    horz.handle.setParent(this.handle);

    client.parentWindow = this;
    scroll = _hScrollControl(this);

    horz.handle.owner = this;
    vert.handle.owner = this;

    void ScrollVisibility(dynamic obj)
    {

      int state = 0;
      if(horz.visible) state|=1;
      if(vert.visible) state|=2;

      updateScrollBars(TScrollStyle.values[state]);
      
    }

    horz._onVisible = ScrollVisibility;
    vert._onVisible = ScrollVisibility;


  }

  HScrollControl() : this.ex(DivElement(), TScrollStyle.None);

  void release()
  {
    client.remove();
    horz.release();
    vert.release();
    super.release();
  }


  void updateScrollBars(TScrollStyle style)
  {
    int cx=SysMetric.VScrollCx;
    int cy=SysMetric.HScrollCy;
    switch(style)
    {
      case TScrollStyle.None:
        cx=0;
        cy=0;
        break;
      case TScrollStyle.Horizontal:
        cx=0;
        horz.scroll.style.overflowY = ''; 
        break;
      case TScrollStyle.Vertical:
        vert.scroll.style.overflowX = ''; 
        cy=0;
        break;
      case TScrollStyle.Both:
        vert.scroll.style.overflowX = 'scroll';
        horz.scroll.style.overflowY = 'scroll';
        break;
    }

    vert.style.visibility=cx>0? null : 'hidden';
    horz.style.visibility=cy>0? null : 'hidden';
    client.style
      ..position='absolute'
      ..left = '0'
      ..top = '0'
      ..right = '${cx}px'
      ..bottom = '${cy}px'
      ..overflow = 'hidden';
  }

  int get clientHeight => client.contentHeight;
  int get clientWidth  => client.contentWidth;

  int GetPos(int code)
  {
    if(code == Windows.SB_HORZ || code == Windows.SB_BOTH)
      return horz.pos;
    if(code == Windows.SB_VERT || code == Windows.SB_BOTH)
      return vert.pos;
    return 0;
  }

  void SetPos(int code, int pos)
  {
    if(code == Windows.SB_HORZ || code == Windows.SB_BOTH)
      horz.pos = pos;
    if(code == Windows.SB_VERT || code == Windows.SB_BOTH)
      vert.pos = pos;
  }
}

class _scrollMetric
{
  final HScrollBar owner;
  final int size;
  final int btnSize;

  _scrollMetric(this.owner, this.size, this.btnSize);

  int get logicSize => owner._max - owner._min + (logicPage>0? - logicPage + 1 : 0);
  int get logicPage => owner._page;

  int get area
  {
    int res = size-btnSize*2;
    return res>0? res : 0;
  }

  int get thumbPos
  {
    return MulDiv(area-thumbSize, owner._pos-1, owner._max - owner._min-logicPage+1);
  }

  int get thumbSize
  {
    if(logicSize<=0)
      return btnSize;
    int res = MulDiv(area, logicPage, owner._max - owner._min+1);
    return res>btnSize? res : btnSize;
  }

  int get clientSize
  {
    int res = MulDiv(size, area, thumbSize);
    return res<size? size+1 : res;
  }

  int get maxScroll
  {
    return MulDiv(clientSize,area-thumbSize,area);
  }

  int toClientPos()
  {
    return MulDiv(maxScroll, owner._pos-owner._min, logicSize);
  }

  int toLogicPos(int pos)
  {
    if(workArea.isEmpty())
      CalcMetric();

    return MulDiv(logicSize, pos, maxScroll)+owner._min;
  }

  int logicToScreen(int pos)
  {
    if(workArea.isEmpty())
      CalcMetric();
    int size = owner.kind==TScrollBarKind.Horizontal? workArea.width : workArea.height;


    return MulDiv(size, pos, logicSize);
  }

  TRect frstBtn = TRect();
  TRect scndBtn = TRect();
  TRect workArea = TRect();
  TRect thumbArea = TRect();

  void CalcMetric()
  {
    var r = owner.handle.borderRect;

    frstBtn  = TRect.rect(r);
    scndBtn  = TRect.rect(r);
    workArea = TRect.rect(r);
    thumbArea= TRect.rect(r);

    if(owner.kind==TScrollBarKind.Horizontal)
    {
      scndBtn.right-=owner.scrollDelta;

      frstBtn.right=frstBtn.left+SysMetric.VScrollCx;
      scndBtn.left =scndBtn.right-SysMetric.VScrollCx;

      workArea.left=frstBtn.right;
      workArea.right=scndBtn.left;

      thumbArea.left=workArea.left+thumbPos;
      thumbArea.right=thumbArea.left+thumbSize;
    }
    else
    {
      scndBtn.bottom-=owner.scrollDelta;

      frstBtn.bottom=frstBtn.top+SysMetric.HScrollCy;
      scndBtn.top=scndBtn.bottom-SysMetric.HScrollCy;

      workArea.top=frstBtn.bottom;
      workArea.bottom=scndBtn.top;

      thumbArea.top=workArea.top+thumbPos;
      thumbArea.bottom=thumbArea.top+thumbSize;
    }
  }

  bool ptInFirst(POINT pt) => PtInRect(frstBtn, pt);
  bool ptInSecond(POINT pt) => PtInRect(scndBtn, pt);
  bool ptInWorkArea(POINT pt) => PtInRect(workArea, pt);
  bool ptInThumbArea(POINT pt) => PtInRect(thumbArea, pt);

  bool ptBeforeThumb(POINT pt)
  {
    TRect r = workArea.copy();
    if(owner.kind==TScrollBarKind.Horizontal)
      r.right = thumbArea.left;
    else
      r.bottom = thumbArea.top;
    return PtInRect(r, pt);
  }

  bool ptAfterThumb(POINT pt)
  {
    TRect r = workArea.copy();
    if(owner.kind==TScrollBarKind.Horizontal)
      r.left = thumbArea.right;
    else
      r.top = thumbArea.bottom;
    return PtInRect(r, pt);
  }
}


class HScrollBar extends HCustomControl  
{
  static final SCROLLBAR = CLASS_ID('SCROLLBAR');
  CLASS_ID get classID => SCROLLBAR;

  final scroll = DivElement();
  final client = DivElement();

  HScrollBar() : super()
  {
    handle.style
      ..display='inline-block';
    props << WindowProp.ChildOwner;

    _update_kind_style();

    handle.append(scroll);
    scroll.append(client);

    var downPos = POINT();
    bool downThumb=false;

    void ScrollEvent()
    {
      _scrollMetric info = metric();
      info.CalcMetric();

      if(info.ptInFirst(downPos))
        GenMessage(Windows.SB_LINEUP);
      else
      if(info.ptInSecond(downPos))
        GenMessage(Windows.SB_LINEDOWN);
      else
      if(info.ptBeforeThumb(downPos))
        GenMessage(Windows.SB_PAGEUP);
      else
      if(info.ptAfterThumb(downPos))
        GenMessage(Windows.SB_PAGEDOWN);
    }

    Timer? timer;
    scroll.onMouseDown.listen( (Event event)
    {
      downPos = Windows.GetCursorPos();

      _scrollMetric info = metric();
      info.CalcMetric();

      downThumb=info.ptInThumbArea(downPos);
      if(downThumb)
        return;

      ScrollEvent();
      timer = Timer.periodic(Duration(milliseconds: 150), (t) => ScrollEvent() );

    });

    scroll.onMouseUp.listen( (Event event)
    {
      if(downThumb)
      {
        _pos = _calcPos();
        GenMessage(Windows.SB_THUMBPOSITION);
        downThumb = false;
      }
      else
        timer!.cancel();
    });

    scroll.onScroll.listen((Event ev)
    {
      if(downThumb)
        GenMessage(Windows.SB_THUMBTRACK);
      else
        _refresh();
    });
  }

  int _calcPos()
  {
    _scrollMetric info = metric();
    info.CalcMetric();
    return info.toLogicPos(kind==TScrollBarKind.Horizontal?  scroll.scrollLeft : scroll.scrollTop);
  }

  bool get visible => handle.style.visibility!='hidden';

  TEvent? _onVisible;
  void visibleChanged()
  {
    if(_onVisible!=null)
      _onVisible!(this);
  }

  void GenMessage(int ScrollCode)
  {
    int position = _pos;
    if(ScrollCode==Windows.SB_THUMBTRACK)
      position = _calcPos();

    if(kind==TScrollBarKind.Horizontal)
      Windows.SendMessage(this, WM_HSCROLL, SCROLLINFO(ScrollCode, position), this);
    else
      Windows.SendMessage(this, WM_VSCROLL, SCROLLINFO(ScrollCode, position), this);
  }

  void release()
  {
    client.remove();
    scroll.remove();
    super.release();
  }

  _refresh( {int defSize=0} )
  {
    if(enabled == false)
    {
      client.style.width='1px';
      client.style.height='1px';
    }
    else
    {
      _scrollMetric info = metric(defSize);
      String val = '${info.clientSize}px';
      int p = info.toClientPos();

      if(kind == TScrollBarKind.Horizontal)
      {
        if(client.style.width != val || scroll.scrollLeft != p)
        {

          client.style.width = val;
          scroll.scrollLeft = p;
        }
      }
      else
      {
        if(client.style.height!=val || scroll.scrollTop!=p)
        {

          client.style.height = val;
          scroll.scrollTop = p;
        }
      }
    }
  }

  int get scrollDelta
  {
    if(kind == TScrollBarKind.Horizontal)
    {
      if(scroll.style.overflowY == 'scroll')
        return SysMetric.VScrollCx;
    }
    else
    {
      if(scroll.style.overflowX == 'scroll')
        return SysMetric.HScrollCy;
    }
    return 0;
  }

  _scrollMetric metric([int defSize = 0])
  {
    var rect = scroll.contentRect;

    if(kind == TScrollBarKind.Horizontal)
    {
      int size = rect.width;
      if(size==0)
        size = defSize;
      if(scroll.style.overflowY == 'scroll')
        size-=SysMetric.VScrollCx;
      return _scrollMetric(this, size, SysMetric.VScrollCx);
    }
    else
    {
      int size = rect.height;
      if(size==0)
        size = defSize;
      if(scroll.style.overflowX == 'scroll')
        size-=SysMetric.HScrollCy;
      return _scrollMetric(this, size, SysMetric.HScrollCy);
    }
  }

  TScrollBarKind _kind = TScrollBarKind.Vertical;

  TScrollBarKind get kind =>_kind;

  void set kind(TScrollBarKind val)
  {
    if(_kind == val)
      return;
    _kind = val;
    _update_kind_style();
  }

  _update_kind_style()
  {
    bool vert = kind == TScrollBarKind.Vertical;
    handle.style
      ..height=vert? '100%' : null
      ..width=vert? null : '100%'
      ..bottom=vert? null : '0'
      ..right=vert? '0' : null;
    scroll.style
      ..height=vert? '100%' : null
      ..width=vert? null : '100%'
      ..overflowY=vert? 'scroll' : 'hidden' 
      ..overflowX=vert? 'hidden': 'scroll';
    client.style
      ..height='1px'
      ..width='1px';
    _refresh();
  }

  bool _enabled = true; 
  bool get enabled => _enabled;
  void set enabled(bool v)
  {
    if(_enabled == v)
      return;
    _enabled = v;
    _refresh();
  }

  int _page = 0;
  int get page => _page;
  void set page(int v)
  {
    if(_page == v)
      return;
    _page = v;
    _refresh();
  }

  int _pos = 0;
  int get pos => _pos;
  void set pos(int v)
  {
    if(_pos == v)
      return;
    _pos = v;
    _refresh();
  }

  int _min = 0;
  int get min => _min;
  void set min(int v)
  {
    if(_min == v)
      return;
    _min = v;
    _refresh();

  }

  int _max = 100;
  int get max => _max;
  void set max(int v)
  {
    if(_max == v)
      return;
    _max = v;
    _refresh();
  }

  void update([int? pos, int? min, int? max, int? page, bool? enabled])
  {

    if(pos == null)  pos = _pos;
    if(min == null)  min = _min;
    if(max == null)  max = _max;
    if(page == null) page = _page;
    if(enabled == null)
      enabled = _enabled;
    if(pos != _pos || min != _min || max != _max || page != _page || enabled != _enabled)
    {
      _pos = pos;
      _min = min;
      _max = max;
      _page = page;
      _enabled = enabled;

      bool vis = min!=0 || max!=0;
      if(visible!=vis)
      {
        handle.style.visibility=vis? null : 'hidden';
        visibleChanged();
      }
      _refresh();
    }
  }

}
