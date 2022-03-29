part of vcl;

abstract class __windows
{
  /* WND flags values */
  static const int WIN_RESTORE_MAX           = 0x0001; /* Maximize when restoring */
  static const int WIN_NEED_SIZE             = 0x0002; /* Internal WM_SIZE is needed */

  static const int WIN_CHILDREN_MOVED        = 0x0040; /* children may have moved, ignore stored positions */

  static const int WIN_NEED_METRIC           = 0x0100; /* Need window metric */ // new

  static const int COORDS_CLIENT = 0;
  static const int COORDS_WINDOW = 1;
  static const int COORDS_PARENT = 2;
  static const int COORDS_SCREEN = 3;

  static void erase_now( HWND? hwnd, UINT rdw_flags )  // from unit painting.c
  {
    // dummy
  }

  static HWND get_desktop_window() // from unit winstation.c
  {
    return HWND_DESKTOP; // dummy
  }

  // Convert a possibly truncated window handle to a full 32-bit handle.
  static HWND get_full_window_handle( HWND hwnd )
  {

    return hwnd;
  }


  static WND get_win_ptr( HWND hwnd )
  {

    return hwnd._wnd;
  }


  static HWND? get_window_relative( HWND hwnd, UINT rel )
  {
    HWND? retval;


    return retval;
  }

  static HWND? NtUserGetAncestor( HWINDOW? hwnd, UINT type )
  {
    if(hwnd is !HWND)
    {
      // SetLastError( ERROR_INVALID_WINDOW_HANDLE );
      return null;
    }

    HWND? ret;

    switch(type)
    {
      case Windows.GA_PARENT:
        WND win = get_win_ptr( hwnd);

        if (win.isDesktop)
          return null;

        if (!win.isOtherProcess)
        {
            ret = win.parent;

        }

        break;

      default:
        throw UnimplementedError();
    }
    return ret;
  }


  static UINT get_dpi_for_window( HWND hwnd )
  {

    return __sysparams.get_thread_dpi(); // dummy
  }

  static dynamic get_window_long_size( HWND hwnd, int offset, UINT size, BOOL ansi )
  {
    dynamic retval = 0;
    WND win;

    if (offset == Windows.GWLP_HWNDPARENT)
    {
        var parent = NtUserGetAncestor( hwnd, Windows.GA_PARENT );
        if (parent == get_desktop_window())
            parent = get_window_relative( hwnd, Windows.GW_OWNER );
        return parent;
    }

    win = get_win_ptr( hwnd );

    if (win.isDesktop)
    {
      switch (offset)
      {
        case Windows.GWL_STYLE:
          retval = Windows.WS_POPUP | Windows.WS_CLIPSIBLINGS | Windows.WS_CLIPCHILDREN; /* message parent is not visible */
          if (get_full_window_handle( hwnd ) == get_desktop_window())
            retval |= Windows.WS_VISIBLE;
          return retval;
        case Windows.GWL_EXSTYLE:
        case Windows.GWLP_USERDATA:
        case Windows.GWLP_ID:
        case Windows.GWLP_HINSTANCE:
          return null;
        case Windows.GWLP_WNDPROC:
          /*SetLastError( ERROR_ACCESS_DENIED );*/
          return null;
       }
       /*SetLastError( ERROR_INVALID_INDEX ); */
       return null;
    }

    if (win.isOtherProcess)
    {

      return retval;
    }

    /* now we have a valid win */

    if (offset >= 0)
    { 
      return retval;
    }

    switch(offset)
    {
      case Windows.GWL_STYLE:      retval = win.dwStyle; break;
      case Windows.GWL_EXSTYLE:    retval = win.dwExStyle; break;

    }
    
    return retval;
  }

  static dynamic get_window_long( HWND hwnd, int offset )
  {
    return get_window_long_size( hwnd, offset, 4/*sizeof(LONG)*/, FALSE );
  }

  static void mirror_rect( RECT window_rect, RECT rect )
  {
    int width = window_rect.right - window_rect.left;
    int tmp = rect.left;
    rect.left = width - rect.right;
    rect.right = width - tmp;
  }

  // Get the window and client rectangles.
  static BOOL get_window_rects( HWND? hwnd, int relative, RECT? window_rect,
                                RECT? client_rect, UINT dpi )
  {
    if(hwnd == null)
    {
      // SetLastError( ERROR_INVALID_WINDOW_HANDLE );
      return FALSE;
    }

    WND win = get_win_ptr( hwnd );
    BOOL ret = TRUE;

    BOOL other_process()
    { 
      return ret;
    }

    if (win.isDesktop)
    { 
      var rect = RECT(0, 0, Screen.DesktopWidth, Screen.DesktopHeight);

      if (window_rect != null) window_rect.assign( rect );
      if (client_rect != null) client_rect.assign( rect );
      return TRUE;
    }

    if (!win.isOtherProcess)
    {
      UINT window_dpi = get_dpi_for_window( hwnd );
      RECT window = win.window_rect;
      RECT client = win.client_rect;

      switch (relative)
      {
        case COORDS_CLIENT:
          OffsetRect( window, -win.client_rect.left, -win.client_rect.top );
          OffsetRect( client, -win.client_rect.left, -win.client_rect.top );
          if (win.dwExStyle.and(Windows.WS_EX_LAYOUTRTL))
            mirror_rect( win.client_rect, window );
          break;
        case COORDS_WINDOW:
          OffsetRect( window, -win.window_rect.left, -win.window_rect.top );
          OffsetRect( client, -win.window_rect.left, -win.window_rect.top );
          if (win.dwExStyle.and(Windows.WS_EX_LAYOUTRTL))
            mirror_rect( win.window_rect, client );
          break;
        case COORDS_PARENT:
          if(win.parent != null)
          {
            WND parent = get_win_ptr( win.parent! );
            if (parent.isDesktop)
              break;
            if (parent.isOtherProcess)
            { 
              return other_process();
            }

            if (parent.flags.and(WIN_CHILDREN_MOVED))
            { 
              return other_process();
            }

            if (parent.dwExStyle.and(Windows.WS_EX_LAYOUTRTL))
            {
              mirror_rect( parent.client_rect, window );
              mirror_rect( parent.client_rect, client );
            }

          }
          break;

        case COORDS_SCREEN:
          while (win.parent is HWND)
          {
            WND parent = get_win_ptr( win.parent as HWND );
            if (parent.isDesktop)
              break;
            if (parent.isOtherProcess)
            { 
              return other_process();
            }

            if (parent.flags.and(WIN_CHILDREN_MOVED))
            { 
              return other_process();
            }

            win = parent;
            if (win.parent != null)
            {
              var crt = win.client_rect;
              OffsetRect( window, crt.left, crt.top );
              OffsetRect( client, crt.left, crt.top );
            }
          }
          break;

        default:
          throw UnimplementedError();
      }
      if (window_rect != null) window_rect.assign( __sysparams.map_dpi_rect( window, window_dpi, dpi ) );
      if (client_rect != null) client_rect.assign( __sysparams.map_dpi_rect( client, window_dpi, dpi ) );

      return TRUE;
    }

    return ret;
  }

  static BOOL get_window_rect( HWND? hwnd, RECT rect, UINT dpi )
  {
    return get_window_rects( hwnd, COORDS_SCREEN, rect, null, dpi );
  }

  static BOOL get_client_rect( HWND? hwnd, RECT rect )
  {
    return get_window_rects( hwnd, COORDS_CLIENT, null, rect, __sysparams.get_thread_dpi() );
  }

 // Get the work area that a maximized window can cover, depending on style.
  static BOOL get_work_rect( HWND hwnd, RECT rect )
  {
    HMONITOR monitor = __sysparams.monitor_from_window( hwnd, Windows.MONITOR_DEFAULTTOPRIMARY, __sysparams.get_thread_dpi() );
    var mon_info = MONITORINFO();

    __sysparams.get_monitor_info( monitor, mon_info );
    rect.assign(mon_info.rcMonitor);

    UINT style = get_window_long( hwnd, Windows.GWL_STYLE );
    if (style.and(Windows.WS_MAXIMIZEBOX))
    {
      if ((style & Windows.WS_CAPTION) == Windows.WS_CAPTION || !(style.and(Windows.WS_CHILD | Windows.WS_POPUP)))
        rect.assign(mon_info.rcWork);
    }
    return TRUE;
  }

  static RECT get_maximized_work_rect( HWND hwnd )
  {
    RECT work_rect = RECT();

    if ((get_window_long( hwnd, Windows.GWL_STYLE ) & (Windows.WS_MINIMIZE | Windows.WS_MAXIMIZE)) == Windows.WS_MAXIMIZE)
    {
      if (get_work_rect( hwnd, work_rect ) == 0)
        work_rect = __sysparams.get_primary_monitor_rect( __sysparams.get_thread_dpi() );
    }
    return work_rect;
  }
 
  static void update_maximized_pos( WND wnd, RECT work_rect )
  {
    if (wnd.parent != null && wnd.parent != get_desktop_window())
      return;

    if (wnd.dwStyle.and(Windows.WS_MAXIMIZE))
    {
      if (wnd.window_rect.left  <= work_rect.left  && wnd.window_rect.top    <= work_rect.top &&
          wnd.window_rect.right >= work_rect.right && wnd.window_rect.bottom >= work_rect.bottom)
          wnd.max_pos.x = wnd.max_pos.y = -1;
    }
    else
      wnd.max_pos.x = wnd.max_pos.y = -1;
  }

  static BOOL empty_point( POINT pt )
  {
    return (pt.x == -1 && pt.y == -1) ? TRUE : FALSE;
  }

  static BOOL get_window_placement( HWND hwnd, WINDOWPLACEMENT placement )
  {
    RECT work_rect = get_maximized_work_rect( hwnd );
    WND win = get_win_ptr( hwnd );
    UINT win_dpi;

    if (win.isDesktop)
    { 
      placement.showCmd = Windows.SW_SHOWNORMAL;
      placement.flags = 0;
      placement.ptMinPosition.x = -1;
      placement.ptMinPosition.y = -1;
      placement.ptMaxPosition.x = -1;
      placement.ptMaxPosition.y = -1;
      get_window_rect( hwnd, placement.rcNormalPosition, __sysparams.get_thread_dpi() );
      return TRUE;
    }

    if (win.isOtherProcess)
    {

      return FALSE;
    }

    /* update the placement according to the current style */
    if (win.dwStyle.and(Windows.WS_MINIMIZE))
    {
      win.min_pos.x = win.window_rect.left;
      win.min_pos.y = win.window_rect.top;
    }
    else
    if (win.dwStyle.and(Windows.WS_MAXIMIZE))
    {
      win.max_pos.x = win.window_rect.left;
      win.max_pos.y = win.window_rect.top;
    }
    else
    {
      win.normal_rect = win.window_rect;
    }
    update_maximized_pos( win, work_rect );

    if (win.dwStyle.and(Windows.WS_MINIMIZE))
      placement.showCmd = Windows.SW_SHOWMINIMIZED;
    else
      placement.showCmd = ( win.dwStyle.and(Windows.WS_MAXIMIZE) ) ? Windows.SW_SHOWMAXIMIZED : Windows.SW_SHOWNORMAL ;
    if (win.flags.and( WIN_RESTORE_MAX) )
      placement.flags = Windows.WPF_RESTORETOMAXIMIZED;
    else
      placement.flags = 0;
    win_dpi = get_dpi_for_window( hwnd );
    placement.ptMinPosition = empty_point(win.min_pos) == TRUE ? win.min_pos : __sysparams.map_dpi_point( win.min_pos, win_dpi, __sysparams.get_thread_dpi() );
    placement.ptMaxPosition = empty_point(win.max_pos) == TRUE ? win.max_pos : __sysparams.map_dpi_point( win.max_pos, win_dpi, __sysparams.get_thread_dpi() );
    placement.rcNormalPosition = __sysparams.map_dpi_rect( win.normal_rect, win_dpi, __sysparams.get_thread_dpi() );

    return TRUE;
  }

  static BOOL NtUserGetClientRect( HWND? hwnd, RECT rect ) =>
    get_client_rect( hwnd, rect );

  static BOOL NtUserGetWindowRect( HWND? hwnd, RECT rect ) =>
    get_window_rect( hwnd, rect, __sysparams.get_thread_dpi() );

}
