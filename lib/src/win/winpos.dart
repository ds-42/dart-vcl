part of vcl;

typedef BOOL = int;
typedef UINT = int;
typedef ULONG = int;

int get FALSE => 0;
int get TRUE => 1;

abstract class _winpos // WINPOS_
{
  static RECT get_primary_monitor_rect() // display.c
  {
    return RECT(0, 0, Screen.Width, Screen.Height); // Dummy
  }

  static const int SWP_AGG_NOGEOMETRYCHANGE = (Windows.SWP_NOSIZE | Windows.SWP_NOCLIENTSIZE | Windows.SWP_NOZORDER);
  static const int SWP_AGG_NOPOSCHANGE = (Windows.SWP_NOSIZE | Windows.SWP_NOMOVE | Windows.SWP_NOCLIENTSIZE | Windows.SWP_NOCLIENTMOVE | Windows.SWP_NOZORDER);
  static const int SWP_AGG_STATUSFLAGS = (SWP_AGG_NOPOSCHANGE | Windows.SWP_FRAMECHANGED | Windows.SWP_HIDEWINDOW | Windows.SWP_SHOWWINDOW);
  static const int SWP_AGG_NOCLIENTCHANGE = (Windows.SWP_NOCLIENTSIZE | Windows.SWP_NOCLIENTMOVE);

  static bool EMPTYPOINT(POINT pt) => (pt.x == -1 && pt.y == -1);

  static BOOL GetWindowRect( HWND hwnd, RECT rect )
  { 
    return __windows.NtUserGetWindowRect(hwnd, rect);
  }

  static BOOL GetClientRect( HWND? hwnd, RECT rect )
  { 
    return __windows.NtUserGetClientRect(hwnd, rect);
  }

  static int MapWindowPoints( HWND? hwndFrom, HWND? hwndTo, List<POINT> lppt, UINT count )
  { 
    return 0;
  }

  static BOOL IsIconic(HWND hWnd)
  {
    UINT style = Windows.GetWindowLong( hWnd, Windows.GWL_STYLE );
    return style.and(Windows.WS_MINIMIZE)? TRUE : FALSE;
  }

  static BOOL IsZoomed(HWND hWnd)
  {
    UINT style = Windows.GetWindowLong( hWnd, Windows.GWL_STYLE );
    return style.and(Windows.WS_MAXIMIZE)? TRUE : FALSE;
  }

  // Get the work area that a maximized window can cover, depending on style.
  static BOOL get_work_rect( HWND hwnd, RECT rect )
  {
    HMONITOR monitor = Windows.MonitorFromWindow( hwnd, Windows.MONITOR_DEFAULTTOPRIMARY );
    var mon_info = MONITORINFO();

    Windows.GetMonitorInfo( monitor, mon_info );
    rect.assign( mon_info.rcMonitor);

    UINT style = Windows.GetWindowLong( hwnd, Windows.GWL_STYLE );
    if (style.and(Windows.WS_MAXIMIZEBOX))
    {
       if ((style & Windows.WS_CAPTION) == Windows.WS_CAPTION || !(style.and(Windows.WS_CHILD | Windows.WS_POPUP)))
        rect.assign( mon_info.rcWork );
    }
    return TRUE;
  }

  static MINMAXINFO WINPOS_GetMinMaxInfo( HWND hwnd )
  {
    var rc_work = RECT();
    var MinMax = MINMAXINFO();
    int style = Windows.GetWindowLong( hwnd, Windows.GWL_STYLE );
    int adjustedStyle;

    var rc = RECT();
    WND win;

    /* Compute default values */

    GetWindowRect(hwnd, rc);
    MinMax.ptReserved.x = rc.left;
    MinMax.ptReserved.y = rc.top;

    if ((style & Windows.WS_CAPTION) == Windows.WS_CAPTION)
        adjustedStyle = style & ~Windows.WS_BORDER; /* WS_CAPTION = WS_DLGFRAME | WS_BORDER */
    else
        adjustedStyle = style;

    GetClientRect(__windows.NtUserGetAncestor(hwnd,Windows.GA_PARENT), rc);

    int xinc = -rc.left;
    int yinc = -rc.top;

    MinMax.ptMaxSize.x = rc.right - rc.left;
    MinMax.ptMaxSize.y = rc.bottom - rc.top;
    if (style.and(Windows.WS_DLGFRAME | Windows.WS_BORDER))
    {
      MinMax.ptMinTrackSize.x = GetSystemMetrics(Windows.SM_CXMINTRACK);
      MinMax.ptMinTrackSize.y = GetSystemMetrics(Windows.SM_CYMINTRACK);
    }
    else
    {
      MinMax.ptMinTrackSize.x = 2 * xinc;
      MinMax.ptMinTrackSize.y = 2 * yinc;
    }
    MinMax.ptMaxTrackSize.x = GetSystemMetrics(Windows.SM_CXMAXTRACK);
    MinMax.ptMaxTrackSize.y = GetSystemMetrics(Windows.SM_CYMAXTRACK);
    MinMax.ptMaxPosition.x = -xinc;
    MinMax.ptMaxPosition.y = -yinc;

    win = __win.GetPtr( hwnd );

    if (!win.isDesktop && !win.isOtherProcess)
    {
      if (!EMPTYPOINT(win.max_pos)) MinMax.ptMaxPosition.assign( win.max_pos );

    }

    Windows.SendMessage( hwnd, WM_GETMINMAXINFO, 0, MinMax );

   /* if the app didn't change the values, adapt them for the current monitor */

    if (get_work_rect( hwnd, rc_work ) != 0)
    {
      RECT rc_primary = get_primary_monitor_rect();
      if (MinMax.ptMaxSize.x == (rc_primary.right - rc_primary.left) + 2 * xinc &&
          MinMax.ptMaxSize.y == (rc_primary.bottom - rc_primary.top) + 2 * yinc)
      {
        MinMax.ptMaxSize.x = (rc_work.right - rc_work.left) + 2 * xinc;
        MinMax.ptMaxSize.y = (rc_work.bottom - rc_work.top) + 2 * yinc;
      }
      if (MinMax.ptMaxPosition.x == -xinc && MinMax.ptMaxPosition.y == -yinc)
      {
        MinMax.ptMaxPosition.x = rc_work.left - xinc;
        MinMax.ptMaxPosition.y = rc_work.top - yinc;
      }
    }

    MinMax.ptMaxTrackSize.x = max( MinMax.ptMaxTrackSize.x,
                                   MinMax.ptMinTrackSize.x );
    MinMax.ptMaxTrackSize.y = max( MinMax.ptMaxTrackSize.y,
                                   MinMax.ptMinTrackSize.y );

    return MinMax;
  }

  static POINT get_minimized_pos( HWND hwnd, POINT pt )
  {

    return POINT();
  }

  static bool show_window(HWND hwnd, int cmd)
  {
    WND wndPtr;
    HWND? parent;

    int  style = Windows.GetWindowLong( hwnd, Windows.GWL_STYLE );
    bool wasVisible = (style & Windows.WS_VISIBLE) != 0;
    bool showFlag = true;
    var  newPos = RECT();
    int  new_swp = 0, swp = 0;

    bool done()
    { 
      return wasVisible;
    }

    switch(cmd)
    {
      case Windows.SW_HIDE:
        if (!wasVisible)
          return done();
        showFlag = false;
        swp |= Windows.SWP_HIDEWINDOW | Windows.SWP_NOSIZE | Windows.SWP_NOMOVE;
        if (style.and(Windows.WS_CHILD))
          swp |= Windows.SWP_NOACTIVATE | Windows.SWP_NOZORDER;
        break;

      case Windows.SW_SHOWMINNOACTIVE:
      case Windows.SW_MINIMIZE:
      case Windows.SW_FORCEMINIMIZE: 
      case Windows.SW_SHOWMINIMIZED:
        if(cmd != Windows.SW_SHOWMINIMIZED)
          swp |= Windows.SWP_NOACTIVATE | Windows.SWP_NOZORDER; /* fall through */

        swp |= Windows.SWP_SHOWWINDOW | Windows.SWP_FRAMECHANGED;
        swp |= MinMaximize( hwnd, cmd, newPos );
        if ((style.and(Windows.WS_MINIMIZE)) && wasVisible)
          return done();
        break;

      case Windows.SW_SHOWMAXIMIZED: /* same as SW_MAXIMIZE */
        if (!wasVisible)
          swp |= Windows.SWP_SHOWWINDOW;
        swp |= Windows.SWP_FRAMECHANGED;
        swp |= MinMaximize( hwnd, Windows.SW_MAXIMIZE, newPos );
        if ((style.and(Windows.WS_MAXIMIZE)) && wasVisible)
          return done();
        break;

      case Windows.SW_SHOWNA:
        swp |= Windows.SWP_NOACTIVATE | Windows.SWP_SHOWWINDOW | Windows.SWP_NOSIZE | Windows.SWP_NOMOVE;
        if (style.and(Windows.WS_CHILD)) swp |= Windows.SWP_NOZORDER;
        break;

      case Windows.SW_SHOW:
        if (wasVisible)
          return done();
        swp |= Windows.SWP_SHOWWINDOW | Windows.SWP_NOSIZE | Windows.SWP_NOMOVE;
        if (style.and(Windows.WS_CHILD))
          swp |= Windows.SWP_NOACTIVATE | Windows.SWP_NOZORDER;
        break;

      case Windows.SW_SHOWNOACTIVATE: /* fall through */
      case Windows.SW_RESTORE:  /* fall through */
      case Windows.SW_SHOWNORMAL:  /* same as SW_NORMAL: */
      case Windows.SW_SHOWDEFAULT: /* FIXME: should have its own handler */
        if(cmd==Windows.SW_SHOWNOACTIVATE)
          swp |= Windows.SWP_NOACTIVATE | Windows.SWP_NOZORDER;

        if (!wasVisible) swp |= Windows.SWP_SHOWWINDOW;
        if (style.and(Windows.WS_MINIMIZE | Windows.WS_MAXIMIZE))
        {
          swp |= Windows.SWP_FRAMECHANGED;
          swp |= MinMaximize( hwnd, cmd, newPos );
        }
        else
        {
          if (wasVisible)
            return done();
          swp |= Windows.SWP_NOSIZE | Windows.SWP_NOMOVE;
        }
        if (style.and(Windows.WS_CHILD) && !swp.and(Windows.SWP_STATECHANGED))
          swp |= Windows.SWP_NOACTIVATE | Windows.SWP_NOZORDER;
        break;

        default:
          return done();
    }

    if ((showFlag != wasVisible || cmd == Windows.SW_SHOWNA) && cmd != Windows.SW_SHOWMAXIMIZED && !swp.and(Windows.SWP_STATECHANGED))
    {
        Windows.SendMessage(hwnd, WM_SHOWWINDOW, showFlag, 0);
        if (!Windows.IsWindow( hwnd )) return done();
    }

    if (IsRectEmpty(newPos))
      new_swp = swp;
    else
    if ((new_swp = USER_Driver.ShowWindow( hwnd, cmd, newPos, swp )) == ~0)
    {
      if (Windows.GetWindowLong( hwnd, Windows.GWL_STYLE ).and(Windows.WS_CHILD))
        new_swp = swp;
      else
      if (Windows.IsIconic( hwnd ) && (newPos.left != -32000 || newPos.top != -32000))
      {
          OffsetRect( newPos, -32000 - newPos.left, -32000 - newPos.top );
          new_swp = swp & ~(Windows.SWP_NOMOVE | Windows.SWP_NOCLIENTMOVE);
      }
      else
        new_swp = swp;
    }
    swp = new_swp;

    parent = __windows.NtUserGetAncestor( hwnd, Windows.GA_PARENT );
    if (parent!=null && !Windows.IsWindowVisible( parent ) && !swp.and(Windows.SWP_STATECHANGED))
    {
      /* if parent is not visible simply toggle WS_VISIBLE and return */
      if (showFlag) __win.SetStyle( hwnd, Windows.WS_VISIBLE, 0 );
      else __win.SetStyle( hwnd, 0, Windows.WS_VISIBLE );
    }
    else
      Windows.SetWindowPos( hwnd, HWND_TOP, newPos.left, newPos.top,
                            newPos.width, newPos.height, swp );

    if (cmd == Windows.SW_HIDE)
    { 
        return done();
    }

    wndPtr = __win.GetPtr( hwnd );
    if (wndPtr.isOtherProcess) return done();

    if (wndPtr.flags.and(__windows.WIN_NEED_SIZE))
    {
      /* should happen only in CreateWindowEx() */
      int wParam = Windows.SIZE_RESTORED;
      var client = RECT();

      __win.GetRectangles( hwnd, __windows.COORDS_PARENT, null, client );
      var lParam = SIZE( client.right - client.left, client.bottom - client.top );
      wndPtr.flags &= ~__windows.WIN_NEED_SIZE;
      if (wndPtr.dwStyle.and(Windows.WS_MAXIMIZE))
        wParam = Windows.SIZE_MAXIMIZED;
      else
      if (wndPtr.dwStyle.and(Windows.WS_MINIMIZE))
      {
        wParam = Windows.SIZE_MINIMIZED;
        lParam = SIZE(0, 0);
      }

      Windows.SendMessage( hwnd, WM_SIZE, wParam, lParam );
      Windows.SendMessage( hwnd, WM_MOVE, 0, POINT( client.left, client.top ));
    }

    return done();
  }

  static BOOL GetWindowPlacement( HWND hwnd, WINDOWPLACEMENT wndpl )
  {
     return __windows.get_window_placement(hwnd, wndpl); 
  }

  static void map_dpi_winpos( WINDOWPOS winpos )
  {
    UINT dpi_from = __sysparams.get_thread_dpi();
    UINT dpi_to = __win.GetDpiForWindow( winpos.hwnd );

    if (dpi_from == 0) dpi_from = __sysparams.get_win_monitor_dpi( winpos.hwnd );
    if (dpi_from == dpi_to) return;
    winpos.x  = MulDiv( winpos.x, dpi_to, dpi_from );
    winpos.y  = MulDiv( winpos.y, dpi_to, dpi_from );
    winpos.cx = MulDiv( winpos.cx, dpi_to, dpi_from );
    winpos.cy = MulDiv( winpos.cy, dpi_to, dpi_from );
  }

  static BOOL SWP_DoWinPosChanging( WINDOWPOS pWinpos, RECT old_window_rect, RECT old_client_rect,
                                   RECT new_window_rect, RECT new_client_rect )
  {
    /* Send WM_WINDOWPOSCHANGING message */
    if (!(pWinpos.flags.and(Windows.SWP_NOSENDCHANGING))
           && !((pWinpos.flags.and(SWP_AGG_NOCLIENTCHANGE)) && (pWinpos.flags.and(Windows.SWP_SHOWWINDOW))))
        Windows.SendMessage( pWinpos.hwnd, WM_WINDOWPOSCHANGING, 0, pWinpos );

    WND wndPtr = __win.GetPtr(pWinpos.hwnd);
    if (wndPtr.isOtherProcess || wndPtr.isDesktop) return FALSE;

    /* Calculate new position and size */

    __win.GetRectangles( pWinpos.hwnd, __windows.COORDS_PARENT, old_window_rect, old_client_rect );
    new_window_rect.assign(old_window_rect);
    new_client_rect.assign(old_client_rect);

    if (!(pWinpos.flags.and(Windows.SWP_NOSIZE)))
    {
      if (wndPtr.dwStyle.and(Windows.WS_MINIMIZE))
      {
        new_window_rect.right  = new_window_rect.left + Windows.GetSystemMetrics(Windows.SM_CXMINIMIZED);
        new_window_rect.bottom = new_window_rect.top  + Windows.GetSystemMetrics(Windows.SM_CYMINIMIZED);
      }
      else
      {
        new_window_rect.right  = new_window_rect.left + pWinpos.cx;
        new_window_rect.bottom = new_window_rect.top + pWinpos.cy;
      }
    }
    if (!(pWinpos.flags.and(Windows.SWP_NOMOVE)))
    {
      /* If the window is toplevel minimized off-screen, force keep it there */
      if ((wndPtr.dwStyle.and(Windows.WS_MINIMIZE)) &&
           wndPtr.window_rect.left <= -32000 && wndPtr.window_rect.top <= -32000 &&
          (wndPtr.parent==null || wndPtr.parent == Windows.GetDesktopWindow()))
      {
        pWinpos.x = -32000;
        pWinpos.y = -32000;
      }
      new_window_rect.left    = pWinpos.x;
      new_window_rect.top     = pWinpos.y;
      new_window_rect.right  += pWinpos.x - old_window_rect.left;
      new_window_rect.bottom += pWinpos.y - old_window_rect.top;

      OffsetRect( new_client_rect, pWinpos.x - old_window_rect.left,
                                   pWinpos.y - old_window_rect.top );
    }
    pWinpos.flags |= Windows.SWP_NOCLIENTMOVE | Windows.SWP_NOCLIENTSIZE;

    return TRUE;
  }

  // Compute the valid rects from the old and new client rect and WVR_* flags.
  // Helper for WM_NCCALCSIZE handling.
  static void get_valid_rects( RECT old_client, RECT new_client, UINT flags, List<RECT> valid )
  {
    int cx, cy;

    if (flags.and(Windows.WVR_REDRAW))
    {
      SetRectEmpty( valid[0] );
      SetRectEmpty( valid[1] );
      return;
    }

    if (flags.and(Windows.WVR_VALIDRECTS))
    {
      if (IntersectRect( valid[0], valid[0], new_client ) == 0 ||
          IntersectRect( valid[1], valid[1], old_client ) == 0)
      {
        SetRectEmpty( valid[0] );
        SetRectEmpty( valid[1] );
        return;
      }
      flags = Windows.WVR_ALIGNLEFT | Windows.WVR_ALIGNTOP;
    }
    else
    {
      valid[0].assign(new_client);
      valid[1].assign(old_client);
    }

    /* make sure the rectangles have the same size */
    cx = min( valid[0].right - valid[0].left, valid[1].right - valid[1].left );
    cy = min( valid[0].bottom - valid[0].top, valid[1].bottom - valid[1].top );

    if (flags.and(Windows.WVR_ALIGNBOTTOM))
    {
      valid[0].top = valid[0].bottom - cy;
      valid[1].top = valid[1].bottom - cy;
    }
    else
    {
      valid[0].bottom = valid[0].top + cy;
      valid[1].bottom = valid[1].top + cy;
    }
    if (flags.and(Windows.WVR_ALIGNRIGHT))
    {
      valid[0].left = valid[0].right - cx;
      valid[1].left = valid[1].right - cx;
    }
    else
    {
      valid[0].right = valid[0].left + cx;
      valid[1].right = valid[1].left + cx;
    }
  }

  static HWINDOW? SWP_DoOwnedPopups(HWND hwnd, HWINDOW? hwndInsertAfter)
  { 
    return hwndInsertAfter;
  }

  static UINT SWP_DoNCCalcSize( WINDOWPOS pWinpos, RECT old_window_rect, RECT old_client_rect,
                                RECT new_window_rect, RECT new_client_rect, List<RECT> validRects,
                                int parent_x, int parent_y )
  {
    UINT wvrFlags = 0;

    /* Send WM_NCCALCSIZE message to get new client area */
    if( (pWinpos.flags & (Windows.SWP_FRAMECHANGED | Windows.SWP_NOSIZE)) != Windows.SWP_NOSIZE )
    {
      var winposCopy = WINDOWPOS.from(pWinpos);

      var params = NCCALCSIZE_PARAMS(
        new_window_rect,
        old_window_rect,
        old_client_rect,
        winposCopy);

      if (pWinpos.flags.and(Windows.SWP_NOMOVE))
      {
        winposCopy.x = old_window_rect.left;
        winposCopy.y = old_window_rect.top;
      }

      if (pWinpos.flags.and(Windows.SWP_NOSIZE))
      {
        winposCopy.cx = old_window_rect.right - old_window_rect.left;
        winposCopy.cy = old_window_rect.bottom - old_window_rect.top;
      }

      wvrFlags = Windows.SendMessage(pWinpos.hwnd, WM_NCCALCSIZE, TRUE, params );

      new_client_rect.assign(params.rgrc[0]);

      if (new_client_rect.left != old_client_rect.left - parent_x ||
          new_client_rect.top != old_client_rect.top - parent_y)
          pWinpos.flags &= ~Windows.SWP_NOCLIENTMOVE;

      if( (new_client_rect.right - new_client_rect.left !=
            old_client_rect.right - old_client_rect.left))
          pWinpos.flags &= ~Windows.SWP_NOCLIENTSIZE;
      else
          wvrFlags &= ~Windows.WVR_HREDRAW;

      if (new_client_rect.bottom - new_client_rect.top !=
          old_client_rect.bottom - old_client_rect.top)
          pWinpos.flags &= ~Windows.SWP_NOCLIENTSIZE;
      else
           wvrFlags &= ~Windows.WVR_VREDRAW;

       validRects[0].assign( params.rgrc[1] );
       validRects[1].assign( params.rgrc[2] );
    }
    else
    {
      if (!(pWinpos.flags.and(Windows.SWP_NOMOVE)) &&
           (new_client_rect.left != old_client_rect.left - parent_x ||
           new_client_rect.top != old_client_rect.top - parent_y))
           pWinpos.flags &= ~Windows.SWP_NOCLIENTMOVE;
    }

    if (pWinpos.flags.and(Windows.SWP_NOCOPYBITS | Windows.SWP_NOREDRAW | Windows.SWP_SHOWWINDOW | Windows.SWP_HIDEWINDOW))
    {
      SetRectEmpty( validRects[0] );
      SetRectEmpty( validRects[1] );
    }
    else
      get_valid_rects( old_client_rect, new_client_rect, wvrFlags, validRects );

    return wvrFlags;
  }

  /* fix redundant flags and values in the WINDOWPOS structure */
  static BOOL fixup_flags( WINDOWPOS winpos, RECT old_window_rect, int parent_x, int parent_y )
  {
    HWND? parent;
    WND wndPtr = __win.GetPtr( winpos.hwnd );
    BOOL ret = TRUE;

    BOOL done()
    { 
      return ret;
    }

    if (wndPtr.isOtherProcess)
    { 
      return FALSE;
    }

    /* Finally make sure that all coordinates are valid */
    if (winpos.x < -32768) winpos.x = -32768;
    else if (winpos.x > 32767) winpos.x = 32767;
    if (winpos.y < -32768) winpos.y = -32768;
    else if (winpos.y > 32767) winpos.y = 32767;

    if (winpos.cx < 0) winpos.cx = 0;
    else if (winpos.cx > 32767) winpos.cx = 32767;
    if (winpos.cy < 0) winpos.cy = 0;
     else if (winpos.cy > 32767) winpos.cy = 32767;

    parent = __windows.NtUserGetAncestor( winpos.hwnd, Windows.GA_PARENT );
    if (parent!=null && !Windows.IsWindowVisible( parent )) winpos.flags |= Windows.SWP_NOREDRAW;

    if (wndPtr.dwStyle.and(Windows.WS_VISIBLE)) winpos.flags &= ~Windows.SWP_SHOWWINDOW;
    else
    {
       winpos.flags &= ~Windows.SWP_HIDEWINDOW;
       if (!(winpos.flags.and(Windows.SWP_SHOWWINDOW))) winpos.flags |= Windows.SWP_NOREDRAW;
    }

    if ((old_window_rect.right - old_window_rect.left == winpos.cx) &&
        (old_window_rect.bottom - old_window_rect.top == winpos.cy))
        winpos.flags |= Windows.SWP_NOSIZE;    /* Already the right size */

    if ((old_window_rect.left - parent_x == winpos.x) && (old_window_rect.top - parent_y == winpos.y))
        winpos.flags |= Windows.SWP_NOMOVE;    /* Already the right position */

    if ((wndPtr.dwStyle & (Windows.WS_POPUP | Windows.WS_CHILD)) != Windows.WS_CHILD)
    {
      if (!(winpos.flags.and(Windows.SWP_NOACTIVATE|Windows.SWP_HIDEWINDOW)) && /* Bring to the top when activating */
           (winpos.flags.and(Windows.SWP_NOZORDER) ||
           (winpos.hwndInsertAfter != HWND_TOPMOST && winpos.hwndInsertAfter != HWND_NOTOPMOST)))
      {
        winpos.flags &= ~Windows.SWP_NOZORDER;
        winpos.hwndInsertAfter = HWND_TOP;
      }
    }

    /* Check hwndInsertAfter */
    if (winpos.flags.and(Windows.SWP_NOZORDER)) return done();

    if (winpos.hwndInsertAfter == HWND_TOP)
    {
      if (__win.GetWindow(winpos.hwnd, Windows.GW_HWNDFIRST) == winpos.hwnd)
        winpos.flags |= Windows.SWP_NOZORDER;
    }
    else
    if (winpos.hwndInsertAfter == HWND_BOTTOM)
    {
      if(!wndPtr.dwExStyle.and(Windows.WS_EX_TOPMOST) && __win.GetWindow(winpos.hwnd, Windows.GW_HWNDLAST) == winpos.hwnd)
        winpos.flags |= Windows.SWP_NOZORDER;
    }
    else
    if (winpos.hwndInsertAfter == HWND_TOPMOST)
    {
      if (wndPtr.dwExStyle.and(Windows.WS_EX_TOPMOST) && __win.GetWindow(winpos.hwnd, Windows.GW_HWNDFIRST) == winpos.hwnd)
          winpos.flags |= Windows.SWP_NOZORDER;
    }
    else
    if (winpos.hwndInsertAfter == HWND_NOTOPMOST)
    {
      if (!wndPtr.dwExStyle.and(Windows.WS_EX_TOPMOST))
           winpos.flags |= Windows.SWP_NOZORDER;
    }
    else
    {
      if ((winpos.hwnd == winpos.hwndInsertAfter) ||
         ((winpos.hwndInsertAfter is HWND) && (winpos.hwnd == __win.GetWindow( winpos.hwndInsertAfter as HWND, Windows.GW_HWNDNEXT ))))
           winpos.flags |= Windows.SWP_NOZORDER;
    }
    return done();
  }

  // Backend implementation of SetWindowPos.
  static BOOL set_window_pos( HWND hwnd, HWINDOW? insert_after, UINT swp_flags,
                              RECT window_rect, RECT client_rect, List<RECT>? valid_rects )
  {
    WND win = __win.GetPtr( hwnd );
    return win.set_window_pos(insert_after, swp_flags, window_rect, client_rect, valid_rects);

  }

  static BOOL USER_SetWindowPos( WINDOWPOS winpos, int parent_x, int parent_y )
  {
    var old_window_rect = RECT();
    var old_client_rect = RECT();
    var new_window_rect = RECT();
    var new_client_rect = RECT();
    var valid_rects = [ RECT(), RECT() ];
    UINT orig_flags = winpos.flags;
    BOOL ret = FALSE;

    BOOL done()
    { 
      return ret;
    }

    /* First, check z-order arguments.  */
    if (!(winpos.flags.and(Windows.SWP_NOZORDER)))
    {
      /* fix sign extension */
       if (winpos.hwndInsertAfter == HWND_BROADCAST)
         winpos.hwndInsertAfter = HWND_TOPMOST;
       else
       if (winpos.hwndInsertAfter == HWND_FFFE)
         winpos.hwndInsertAfter = HWND_NOTOPMOST;

      if (!(winpos.hwndInsertAfter == HWND_TOP ||
            winpos.hwndInsertAfter == HWND_BOTTOM ||
            winpos.hwndInsertAfter == HWND_TOPMOST ||
            winpos.hwndInsertAfter == HWND_NOTOPMOST))
      {
        var parent = __windows.NtUserGetAncestor( winpos.hwnd, Windows.GA_PARENT );
        var insertafter_parent = __windows.NtUserGetAncestor( winpos.hwndInsertAfter, Windows.GA_PARENT );

        /* hwndInsertAfter must be a sibling of the window */
        if (insertafter_parent == null) return FALSE;
        if (insertafter_parent != parent) return TRUE;
      }
    }

    /* Make sure that coordinates are valid for WM_WINDOWPOSCHANGING */
    if (!(winpos.flags.and(Windows.SWP_NOMOVE)))
    {
      if (winpos.x < -32768) winpos.x = -32768;
      else if (winpos.x > 32767) winpos.x = 32767;
      if (winpos.y < -32768) winpos.y = -32768;
      else if (winpos.y > 32767) winpos.y = 32767;
    }

    if (!(winpos.flags.and(Windows.SWP_NOSIZE)))
    {
      if (winpos.cx < 0) winpos.cx = 0;
      else if (winpos.cx > 32767) winpos.cx = 32767;
      if (winpos.cy < 0) winpos.cy = 0;
      else if (winpos.cy > 32767) winpos.cy = 32767;
    }

    if (SWP_DoWinPosChanging( winpos, old_window_rect, old_client_rect,
                              new_window_rect, new_client_rect ) == 0) return done();

    /* Fix redundant flags */
    if (fixup_flags( winpos, old_window_rect, parent_x, parent_y ) == 0)
      return done();

    if((winpos.flags & (Windows.SWP_NOZORDER | Windows.SWP_HIDEWINDOW | Windows.SWP_SHOWWINDOW)) != Windows.SWP_NOZORDER)
    {
      if (__windows.NtUserGetAncestor( winpos.hwnd, Windows.GA_PARENT ) == Windows.GetDesktopWindow())
        winpos.hwndInsertAfter = SWP_DoOwnedPopups( winpos.hwnd, winpos.hwndInsertAfter );
    }

    /* Common operations */

    SWP_DoNCCalcSize( winpos, old_window_rect, old_client_rect,
                      new_window_rect, new_client_rect, valid_rects, parent_x, parent_y );

    if (set_window_pos( winpos.hwnd, winpos.hwndInsertAfter, winpos.flags,
                        new_window_rect, new_client_rect, valid_rects ) == 0)
        return done();

    if( winpos.flags.and(Windows.SWP_HIDEWINDOW) )
      Windows.HideCaret(winpos.hwnd);
    else
    if( winpos.flags.and(Windows.SWP_SHOWWINDOW) )
      Windows.ShowCaret(winpos.hwnd);

    if (!(winpos.flags.and(Windows.SWP_NOACTIVATE|Windows.SWP_HIDEWINDOW)))
    {
      /* child windows get WM_CHILDACTIVATE message */
      if((Windows.GetWindowLong( winpos.hwnd, Windows.GWL_STYLE ) & (Windows.WS_CHILD | Windows.WS_POPUP)) == Windows.WS_CHILD)
        Windows.SendMessage( winpos.hwnd, WM_CHILDACTIVATE, 0, 0 );
      else
        Windows.SetForegroundWindow( winpos.hwnd );
    }

    if(!(orig_flags.and(Windows.SWP_DEFERERASE)))
    {
      /* erase parent when hiding or resizing child */
      if ((orig_flags.and(Windows.SWP_HIDEWINDOW)) ||
       (!(orig_flags.and(Windows.SWP_SHOWWINDOW)) &&
        (winpos.flags & SWP_AGG_STATUSFLAGS) != SWP_AGG_NOGEOMETRYCHANGE))
      {
        var parent = __windows.NtUserGetAncestor( winpos.hwnd, Windows.GA_PARENT );
        if (parent!=null || parent == Windows.GetDesktopWindow()) parent = winpos.hwnd;
        __windows.erase_now( parent, 0 );
      }

      /* Give newly shown windows a chance to redraw */
      if(((winpos.flags & SWP_AGG_STATUSFLAGS) != SWP_AGG_NOPOSCHANGE) &&
         !(orig_flags.and(SWP_AGG_NOCLIENTCHANGE)) && (orig_flags.and(Windows.SWP_SHOWWINDOW)))
      {
        __windows.erase_now(winpos.hwnd, 0);
      }
    }

    /* And last, send the WM_WINDOWPOSCHANGED message */

    if (((winpos.flags & SWP_AGG_STATUSFLAGS) != SWP_AGG_NOPOSCHANGE) &&
       !((orig_flags.and(SWP_AGG_NOCLIENTCHANGE)) && (orig_flags.and(Windows.SWP_SHOWWINDOW))))
    {
        // WM_WINDOWPOSCHANGED is sent even if SWP_NOSENDCHANGING is set
        // and always contains final window position. 
        winpos.x  = new_window_rect.left;
        winpos.y  = new_window_rect.top;
        winpos.cx = new_window_rect.right - new_window_rect.left;
        winpos.cy = new_window_rect.bottom - new_window_rect.top;
        Windows.SendMessage( winpos.hwnd, WM_WINDOWPOSCHANGED, 0, winpos );
    }
    ret = TRUE;

    return done();
  }

  static BOOL SetWindowPos( HWND hwnd, HWINDOW? hwndInsertAfter,
                     int x, int y, int cx, int cy, UINT flags )
  { 
    var winpos = WINDOWPOS(
      hwnd, 
      hwndInsertAfter, 
      x, y, cx, cy, flags);

    map_dpi_winpos( winpos );

    if (__win.IsCurrentThread( hwnd ) != null)
      return USER_SetWindowPos( winpos, 0, 0 );

    return FALSE;
  }

  static UINT MinMaximize( HWND hwnd, UINT cmd, RECT rect ) 
  {
    UINT swpFlags = 0;
    int old_style;
    var minmax = MINMAXINFO();
    var wpl = WINDOWPLACEMENT();

    GetWindowPlacement( hwnd, wpl );

    if (Windows.IsIconic( hwnd ))
    {
      switch (cmd)
      {
        case Windows.SW_SHOWMINNOACTIVE:
        case Windows.SW_SHOWMINIMIZED:
        case Windows.SW_FORCEMINIMIZE:
        case Windows.SW_MINIMIZE:
          wpl.ptMinPosition = get_minimized_pos( hwnd, wpl.ptMinPosition );

          SetRect( rect, wpl.ptMinPosition.x, wpl.ptMinPosition.y,
                   wpl.ptMinPosition.x + GetSystemMetrics(Windows.SM_CXMINIMIZED),
                   wpl.ptMinPosition.y + GetSystemMetrics(Windows.SM_CYMINIMIZED) );
          return Windows.SWP_NOSIZE | Windows.SWP_NOMOVE;
      }

      swpFlags |= Windows.SWP_NOCOPYBITS;
    }

    switch( cmd )
    {
      case Windows.SW_SHOWMINNOACTIVE:
      case Windows.SW_SHOWMINIMIZED:
      case Windows.SW_FORCEMINIMIZE:
      case Windows.SW_MINIMIZE:
        if (Windows.IsZoomed( hwnd ))
          __win.win_set_flags( hwnd, __windows.WIN_RESTORE_MAX, 0 );
        else
          __win.win_set_flags( hwnd, 0, __windows.WIN_RESTORE_MAX );

        old_style = __win.SetStyle( hwnd, Windows.WS_MINIMIZE, Windows.WS_MAXIMIZE );

        wpl.ptMinPosition = get_minimized_pos( hwnd, wpl.ptMinPosition );

        if (!old_style.and(Windows.WS_MINIMIZE)) swpFlags |= Windows.SWP_STATECHANGED;
        SetRect( rect, wpl.ptMinPosition.x, wpl.ptMinPosition.y,
                 wpl.ptMinPosition.x + GetSystemMetrics(Windows.SM_CXMINIMIZED),
                 wpl.ptMinPosition.y + GetSystemMetrics(Windows.SM_CYMINIMIZED) );
        swpFlags |= Windows.SWP_NOCOPYBITS;
        break;

      case Windows.SW_MAXIMIZE:
        old_style = Windows.GetWindowLong( hwnd, Windows.GWL_STYLE );
        if (old_style.and(Windows.WS_MAXIMIZE) && old_style.and(Windows.WS_VISIBLE))
          return Windows.SWP_NOSIZE | Windows.SWP_NOMOVE;

        minmax = WINPOS_GetMinMaxInfo( hwnd );

        old_style = __win.SetStyle( hwnd, Windows.WS_MAXIMIZE, Windows.WS_MINIMIZE );
        if (old_style.and(Windows.WS_MINIMIZE))
            __win.win_set_flags( hwnd, __windows.WIN_RESTORE_MAX, 0 );

        if (!old_style.and(Windows.WS_MAXIMIZE))
          swpFlags |= Windows.SWP_STATECHANGED;

        SetRect( rect, minmax.ptMaxPosition.x, minmax.ptMaxPosition.y,
                  minmax.ptMaxPosition.x + minmax.ptMaxSize.x, minmax.ptMaxPosition.y + minmax.ptMaxSize.y );
        break;

      case Windows.SW_SHOWNOACTIVATE:
      case Windows.SW_SHOWNORMAL:
      case Windows.SW_RESTORE:
      case Windows.SW_SHOWDEFAULT: 
       if(cmd == Windows.SW_SHOWNOACTIVATE)
         __win.win_set_flags( hwnd, 0, __windows.WIN_RESTORE_MAX ); /* fall through */

       old_style = __win.SetStyle( hwnd, 0, Windows.WS_MINIMIZE | Windows.WS_MAXIMIZE );
       if (old_style.and(Windows.WS_MINIMIZE))
       {
         if (__win.win_get_flags( hwnd ).and(__windows.WIN_RESTORE_MAX))
         {
           /* Restore to maximized position */
           minmax = WINPOS_GetMinMaxInfo( hwnd );
           __win.SetStyle( hwnd, Windows.WS_MAXIMIZE, 0 );
           swpFlags |= Windows.SWP_STATECHANGED;
           SetRect( rect, minmax.ptMaxPosition.x, minmax.ptMaxPosition.y,
                    minmax.ptMaxPosition.x + minmax.ptMaxSize.x, minmax.ptMaxPosition.y + minmax.ptMaxSize.y );
           break;
         }
       }
       else
       if(!old_style.and(Windows.WS_MAXIMIZE))
         break;

       swpFlags |= Windows.SWP_STATECHANGED;

       /* Restore to normal position */

       rect.assign(wpl.rcNormalPosition);
       break;

      default:
        throw UnimplementedError(); 
    }
    return swpFlags;
  }

}
