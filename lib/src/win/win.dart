part of vcl;

abstract class __win
{

  static void send_parent_notify( HWND hwnd, MESSAGE msg )
  {

  }

 // Trigger an update of the window's driver state and surface.
  static void update_window_state( HWND hwnd )
  {

  }

  static WND GetPtr( HWND hwnd ) => hwnd._wnd; 

  // Check whether a given window belongs to the current thread (and return the full handle).
  static HWND? IsCurrentThread( HWND hwnd ) 
  {

    return hwnd;
  }

  static UINT win_get_flags( HWND hwnd ) => win_set_flags( hwnd, 0, 0 );

  // Set the flags of a window and return the previous value.
  static UINT win_set_flags( HWND hwnd, UINT set_mask, UINT clear_mask )
  {
    WND ptr = __win.GetPtr( hwnd );

    if (ptr.isOtherProcess || ptr.isDesktop)
      return 0;

    UINT ret = ptr.flags;
    ptr.flags = (ret & ~clear_mask) | set_mask;
    
    return ret;
  }

  static UINT SetStyle( HWND hwnd, ULONG set_bits, ULONG clear_bits )
  {
    if (hwnd == HWND_DESKTOP)
      return 0;

    bool made_visible = false;
    var style = STYLESTRUCT();
    WND win = GetPtr( hwnd );

    style.styleOld = win.dwStyle;
    style.styleNew = (win.dwStyle | set_bits) & ~clear_bits;
    if (style.styleNew == style.styleOld)
    {

        return style.styleNew;
    }
/*    SERVER_START_REQ( set_window_info ) */

            win.dwStyle = style.styleNew;

/*    SERVER_END_REQ;*/

    if ((style.styleOld ^ style.styleNew).and(Windows.WS_VISIBLE))
    {
        made_visible = (style.styleNew & Windows.WS_VISIBLE) != 0;
        
    }

    USER_Driver.SetWindowStyle( hwnd, Windows.GWL_STYLE, style );
    if (made_visible)
      update_window_state( hwnd );

    return style.styleOld;
  }

  // Get the window and client rectangles.
  static BOOL GetRectangles( HWND hwnd, int relative, RECT? rectWindow, RECT? rectClient ) 
  {
    WND win = __win.GetPtr( hwnd );
    BOOL ret = TRUE;

    BOOL other_process()
    { 
      return ret;
    }

    if (win.isDesktop)
    {
        var rect = RECT();
        rect.left = rect.top = 0;

        rect.right = Screen.Width;   
        rect.bottom = Screen.Height; 

        if (rectWindow!=null) rectWindow.assign(rect);
        if (rectClient!=null) rectClient.assign(rect);
        return TRUE;
    }

    if (!win.isOtherProcess)
    {
      var window_rect = RECT.from(win.window_rect);
      var client_rect = RECT.from(win.client_rect);

      switch (relative)
      {
        case __windows.COORDS_CLIENT:
          var wcr = win.client_rect;
          OffsetRect( window_rect, -wcr.left, -wcr.top );
          OffsetRect( client_rect, -wcr.left, -wcr.top );
          if (win.dwExStyle.and(Windows.WS_EX_LAYOUTRTL))
              __windows.mirror_rect( wcr, window_rect );
          break;

        case __windows.COORDS_WINDOW:
          var wwr = win.client_rect;
          OffsetRect( window_rect, -wwr.left, -wwr.top );
          OffsetRect( client_rect, -wwr.left, -wwr.top );
          if (win.dwExStyle.and(Windows.WS_EX_LAYOUTRTL))
              __windows.mirror_rect( wwr, client_rect );
          break;

        case __windows.COORDS_PARENT:
          if (win.parent != null)
          {
            WND parent = __win.GetPtr( win.parent! );
            if (parent.isDesktop)
              break;
            if (parent.isOtherProcess)
            {
              
              return other_process();
            }
            if (parent.flags.and(__windows.WIN_CHILDREN_MOVED))
            {
              
              return other_process();
            }
            if (parent.dwExStyle.and(Windows.WS_EX_LAYOUTRTL))
            {
              __windows.mirror_rect( parent.client_rect, window_rect );
              __windows.mirror_rect( parent.client_rect, client_rect );
            }
            
          }
          break;

        case __windows.COORDS_SCREEN:
          while (win.parent!=null)
          {
            WND parent = __win.GetPtr( win.parent as HWND );
            if (parent.isDesktop)
              break;
            if (parent.isOtherProcess)
            {
              
              return other_process();
            }

            if (parent.flags.and(__windows.WIN_CHILDREN_MOVED))
            {
              
              return other_process();
            }
            win = parent;
            if (win.parent != null)
            {
              var cr = win.client_rect;
              OffsetRect( window_rect, cr.left, cr.top );
              OffsetRect( client_rect, cr.left, cr.top );
            }
          }
          break;

        default:
          throw UnimplementedError();
      }
      if (rectWindow!=null)
        rectWindow.assign(__sysparams.rect_win_to_thread_dpi( hwnd, window_rect ));
      if (rectClient!=null)
        rectClient.assign(__sysparams.rect_win_to_thread_dpi( hwnd, client_rect ));
      
      return TRUE;
    }

    return other_process();
  }


  // Fix the coordinates - Helper for WIN_CreateWindowEx.
  // returns default show mode in sw.
  static void FixCoordinates( CREATESTRUCT cs, Integer sw) 
  {
    bool IS_DEFAULT(int x) => ((x) == Windows.CW_USEDEFAULT || (x) == 0x8000);

    var pos = [ POINT(), POINT() ];

    if (cs.style.and(Windows.WS_CHILD | Windows.WS_POPUP))
    {
      if (cs.dwExStyle.and(Windows.WS_EX_MDICHILD))
      {
        if (IS_DEFAULT(cs.x))
        {
          cs.x = pos[0].x;
          cs.y = pos[0].y;
        }
        if (IS_DEFAULT(cs.cx) || cs.cx==0) cs.cx = pos[1].x;
        if (IS_DEFAULT(cs.cy) || cs.cy==0) cs.cy = pos[1].y;
      }
      else
      {
        if (IS_DEFAULT(cs.x))  cs.x = cs.y = 0;
        if (IS_DEFAULT(cs.cx)) cs.cx = cs.cy = 0;
      }
    }
    else  /* overlapped window */
    {
      HMONITOR monitor;
      MONITORINFO mon_info = MONITORINFO();


      if (!IS_DEFAULT(cs.x) && !IS_DEFAULT(cs.cx) && !IS_DEFAULT(cs.cy)) return;

       monitor = Windows.MonitorFromWindow( cs.hwndParent, Windows.MONITOR_DEFAULTTOPRIMARY );

       Windows.GetMonitorInfo( monitor, mon_info );

      if (IS_DEFAULT(cs.x))
      {
        if (!IS_DEFAULT(cs.y)) sw.Value = cs.y;
        cs.x = mon_info.rcWork.left;
        cs.y = mon_info.rcWork.top;
      }

      if (IS_DEFAULT(cs.cx))
      {

          cs.cx = (mon_info.rcWork.right - mon_info.rcWork.left) * 3 ~/ 4 - cs.x;
          cs.cy = (mon_info.rcWork.bottom - mon_info.rcWork.top) * 3 ~/ 4 - cs.y;

      }

      /* neither x nor cx are default. Check the y values .
       * In the trace we see Outlook and Outlook Express using
       * cy set to CW_USEDEFAULT when opening the address book.
       */
      else
      if (IS_DEFAULT(cs.cy))
      { 
        cs.cy = (mon_info.rcWork.bottom - mon_info.rcWork.top) * 3 ~/ 4 - cs.y;
      }
    }
  }


  static UINT fix_exstyle( UINT style, UINT exstyle )
  {
     if ((exstyle.and(Windows.WS_EX_DLGMODALFRAME)) ||
             (!(exstyle.and(Windows.WS_EX_STATICEDGE)) &&
              (style.and(Windows.WS_DLGFRAME | Windows.WS_THICKFRAME))))
         exstyle |= Windows.WS_EX_WINDOWEDGE;
     else
         exstyle &= ~Windows.WS_EX_WINDOWEDGE;
     return exstyle;
  }

//  HWND WIN_CreateWindowEx( CREATESTRUCTW *cs, LPCWSTR className, HINSTANCE module, BOOL unicode )
  static HWND? InitWindowEx(WND wndPtr, CREATESTRUCT cs)
  {
    int cx = 0, cy = 0, style = 0, ex_style = 0, sw = Windows.SW_SHOW;
    dynamic result;
    var rect = RECT();

    late HWND hwnd;

    HWND? parent;
    HWND? owner;

    HWND? failed()
    { 
      return null;
    }

    /* Find the parent window */

    parent = cs.hwndParent;

    if (cs.hwndParent != null)
    {
      if ((cs.style & (Windows.WS_CHILD|Windows.WS_POPUP)) != Windows.WS_CHILD)
      {
        parent = Windows.GetDesktopWindow();
        owner = cs.hwndParent;
      }
      else
      {
        UINT parent_style = Windows.GetWindowLong( parent!, Windows.GWL_EXSTYLE );
        if (parent_style.and(Windows.WS_EX_LAYOUTRTL) && !parent_style.and(Windows.WS_EX_NOINHERITLAYOUT))
          cs.dwExStyle |= Windows.WS_EX_LAYOUTRTL;
      }
    }
    else
    {
      if ((cs.style & (Windows.WS_CHILD|Windows.WS_POPUP)) == Windows.WS_CHILD)
      {
        Windows.WARN('No parent for child window\n');
        
        return null;  /* WS_CHILD needs a parent, but WS_POPUP doesn't */
      }

    }

    cs.dwExStyle = fix_exstyle(cs.style, cs.dwExStyle);

    /* Create the window structure */

    style = cs.style & ~Windows.WS_VISIBLE;
    ex_style = cs.dwExStyle & ~Windows.WS_EX_LAYERED;


    wndPtr.set_window_rect(cs.x, cs.y, cs.cx, cs.cy); // new

    hwnd = wndPtr.hwnd;

    /* Fill the window structure */

    wndPtr.dwStyle        = style;
    wndPtr.dwExStyle      = ex_style;

    /*
     * Correct the window styles.
     *
     * It affects only the style loaded into the WIN structure.
     */

    if ((wndPtr.dwStyle & (Windows.WS_CHILD | Windows.WS_POPUP)) != Windows.WS_CHILD)
    {
        wndPtr.dwStyle |= Windows.WS_CLIPSIBLINGS;
        if (!wndPtr.dwStyle.and(Windows.WS_POPUP))
            wndPtr.dwStyle |= Windows.WS_CAPTION;
    }

    wndPtr.dwExStyle = cs.dwExStyle;
    /* WS_EX_WINDOWEDGE depends on some other styles */
    if ((wndPtr.dwStyle.and(Windows.WS_DLGFRAME | Windows.WS_THICKFRAME)) &&
            !(wndPtr.dwStyle.and(Windows.WS_CHILD | Windows.WS_POPUP)))
        wndPtr.dwExStyle |= Windows.WS_EX_WINDOWEDGE;

    if (!(wndPtr.dwStyle.and(Windows.WS_CHILD | Windows.WS_POPUP)))
        wndPtr.flags |= __windows.WIN_NEED_SIZE;

    /* send WM_NCCREATE */

    result = Windows.SendMessage( hwnd, WM_NCCREATE, 0, cs );
    if (!toBoolDef(result, false))
    {
        Windows.WARN( '%s: aborted by WM_NCCREATE\n', [ hwnd.runtimeType ] );
        return failed();
    }

    wndPtr.createParam = cs.lpCreateParams; // new

    /* send WM_CREATE */

    result = Windows.SendMessage( hwnd, WM_CREATE, 0, cs );
    if (toIntDef(result,-1) == -1)
      return failed();

    /* call the driver */

    if(USER_Driver.CreateWindow( hwnd ) == FALSE)
      return failed();


    /* send the size messages */

    if (!(win_get_flags( hwnd ).and(__windows.WIN_NEED_SIZE)))
    {
      __win.GetRectangles( hwnd, __windows.COORDS_PARENT, null, rect );
      Windows.SendMessage( hwnd, WM_SIZE, Windows.SIZE_RESTORED,
                    SIZE(rect.right-rect.left, rect.bottom-rect.top));
      Windows.SendMessage( hwnd, WM_MOVE, 0, POINT( rect.left, rect.top ) );
    }

    /* Show the window, maximizing or minimizing if needed */

    style = __win.SetStyle( hwnd, 0, Windows.WS_MAXIMIZE | Windows.WS_MINIMIZE );
    if (style.and(Windows.WS_MINIMIZE | Windows.WS_MAXIMIZE))
    {
        RECT newPos = RECT();
        UINT swFlag = style.and(Windows.WS_MINIMIZE) ? Windows.SW_MINIMIZE : Windows.SW_MAXIMIZE;

        swFlag = _winpos.MinMaximize( hwnd, swFlag, newPos );
        swFlag |= Windows.SWP_FRAMECHANGED; /* Frame always gets changed */
        if (!style.and(Windows.WS_VISIBLE) || style.and(Windows.WS_CHILD) || Windows.GetActiveWindow()!=null)
          swFlag |= Windows.SWP_NOACTIVATE;
        Windows.SetWindowPos( hwnd, null, newPos.left, newPos.top, newPos.right - newPos.left,
                             newPos.bottom - newPos.top, swFlag );
    }

    /* Notify the parent window only */

    send_parent_notify( hwnd, WM_CREATE );
    if (!Windows.IsWindow( hwnd ))
    { 
      return null;
    }

    if (parent == Windows.GetDesktopWindow())
      Windows.PostMessage( parent!, WM_PARENTNOTIFY, WM_CREATE, hwnd );

    if (cs.style.and(Windows.WS_VISIBLE))
    {
      if (cs.style.and(Windows.WS_MAXIMIZE))
        sw = Windows.SW_SHOW;
      else
      if (cs.style.and(Windows.WS_MINIMIZE))
        sw = Windows.SW_SHOWMINIMIZED;

      Windows.ShowWindow( hwnd, sw );

    }

  }

  static UINT GetDpiForWindow( HWND hwnd )
  {
    return __windows.get_dpi_for_window(hwnd); 
 }

  static HWND? GetWindow( HWND hwnd, UINT rel )
  {
    switch(rel)
    {
      case Windows.GW_HWNDFIRST: return hwnd; // dummy
      case Windows.GW_HWNDLAST:  return hwnd; // dummy
      case Windows.GW_HWNDNEXT:  return hwnd; // dummy
      default:
        throw UnimplementedError();
    }
    
  }

}

