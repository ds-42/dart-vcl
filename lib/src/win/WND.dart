part of vcl;

class WND
{
  HWND hwnd;

  late WNDPROC mainProc;

  dynamic createParam;

  WND(this.hwnd)
  {
    mainProc = (elem, message) => hwnd.dispatch(elem, message);
  }

  void init(INITSTRUCT params)
  {
    int pStyle = params.style ?? (Windows.WS_VISIBLE);

    int pExStyle = params.exStyle ?? 0;

    var pParent = params.parent;
    if(pStyle.and(Windows.WS_POPUP))
      pParent = HWND_DESKTOP;

    var elem = hwnd.handle;
    var elemStyle = elem.style;
    // temporary hide element for stay in nodes tree
    elemStyle.undefVisibility();

    // set element parent for nodes tree
    hwnd.setParent(pParent);

    elem.updateBounds(params.x, params.y, params.width, params.height);

    var rect = elem.offsetRect;

    __win.InitWindowEx(this, CREATESTRUCT(
        pExStyle, '', params.windowName??'', pStyle,
        params.x ?? rect.left,
        params.y ?? rect.top,
        params.width ?? rect.width,
        params.height ?? rect.height,
        params.parent, null, null, params.param));

    // update visible state
    elemStyle.defVisibility(dwStyle.and(Windows.WS_VISIBLE));
  }

  WNDPROC setWndProc(WNDPROC proc)
  {
    WNDPROC last = mainProc;
    mainProc = proc;
    return last;
  }

  dynamic perform(MESSAGE message, dynamic wParam, dynamic lParam)
  {
    dispatch( MSG(hwnd, message, wParam, lParam) );
  }

  dynamic dispatch(MSG msg)
  {
    TMessage Message = TMessage(msg.message);
    Message.WParam=msg.wParam;
    Message.LParam=msg.lParam;
    mainProc(hwnd.handle, Message);
    return Message.Result;
  }

  HWND? get parent
  {
    Element? elem = hwnd.handle.parent;
    if(elem == null)
      return null;
    return HWND.findWindow(elem);
  }

  set visible(bool value)
  {
    if(value) dwStyle|= Windows.WS_VISIBLE;
    else      dwStyle&=~Windows.WS_VISIBLE;

    hwnd.handle.visible = value;
  }

  bool get isDesktop => hwnd == HWND_DESKTOP;
  bool get isOtherProcess => false;

  UINT dwStyle = 0;
  UINT dwExStyle = 0;

  dynamic getWindowLong(int nIndex)
  {
    switch(nIndex)
    {
      case Windows.GWL_HWNDPARENT: return hwnd.getParent();
      case Windows.GWL_STYLE:  return dwStyle;
      case Windows.GWL_EXSTYLE: return dwExStyle;
      case Windows.GWL_USERDATA: return createParam;

      default:
        throw UnimplementedError();
    }
  }

  int flags = __windows.WIN_NEED_METRIC;

  var border_size = SIZE();

  var window_rect = RECT();

  void set_window_rect(int left, int top, int width, int height)
  {
    window_rect.left = left;
    window_rect.top = top;
    window_rect.right = left + width;
    window_rect.bottom = top + height;

    if(flags.and(__windows.WIN_NEED_METRIC))
    {
      var bs = SIZE();
      if(hwnd.get_border_size(bs))
      {
        border_size.cx = bs.cx;
        border_size.cy = bs.cy;
        flags &= ~__windows.WIN_NEED_METRIC;
      }
    }

    hwnd.set_window_rect(left-border_size.cx, top-border_size.cy, width, height);
  }

  RECT get client_rect
  {
    if(hwnd.clientHandle.offsetParent == null)
      return window_rect;
    return hwnd.clientHandle.offsetRect;
  }

  POINT min_pos = POINT();

  POINT max_pos = POINT();

  RECT normal_rect = RECT();

  BOOL set_window_pos(HWINDOW? insert_after, UINT swp_flags,
      RECT winRect, RECT client_rect, List<RECT>? valid_rects )
  {
    switch(insert_after)
    {
      case HWND_TOP: hwnd.style.zIndex = '9999'; break;
    }

    int px = window_rect.left;
    int py = window_rect.top;
    int cx = window_rect.width;
    int cy = window_rect.height;

    bool moved = false;
    bool sized = false;
    if(!swp_flags.and(Windows.SWP_NOMOVE))
    {
      if(px!=winRect.left)
      {
        moved = true;
        px=winRect.left;
      }
      if(py!=winRect.top)
      {
        moved = true;
        py=winRect.top;
      }
    }

    if(!swp_flags.and(Windows.SWP_NOSIZE))
    {
      if(cx!=winRect.width)
      {
        sized = true;
        cx=winRect.width;
      }
      if(cy!=winRect.height)
      {
        sized = true;
        cy=winRect.height;
      }
    }

    if(moved || sized)
    {
      set_window_rect(px, py, cx, cy);

      if(!flags.and(__windows.WIN_NEED_SIZE))
      {
        if(sized)
          Windows.SendMessage(hwnd, WM_SIZE, Windows.SIZE_RESTORED, SIZE(cx, cy));
        if(moved)
          Windows.SendMessage(hwnd, WM_MOVE, null, POINT(px, py));
      }
    }

    if(swp_flags.and(Windows.SWP_SHOWWINDOW|Windows.SWP_HIDEWINDOW))
    {
      var pos = WINDOWPOS(hwnd, null, 0, 0, 0, 0,
          Windows.SWP_NOMOVE | Windows.SWP_NOSIZE | Windows.SWP_NOZORDER | Windows.SWP_SHOWWINDOW);

      Windows.SendMessage(hwnd, WM_WINDOWPOSCHANGING, null, pos);

      if(swp_flags.and(Windows.SWP_SHOWWINDOW))
        hwnd.show();
      else
      if(swp_flags.and(Windows.SWP_HIDEWINDOW))
        hwnd.hide();
    }

    return TRUE;
  }
}
