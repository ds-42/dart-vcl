part of vcl;

abstract class __sysparams
{

  /* System parameters storage */
  static const UINT system_dpi = 96;


  static RECT get_virtual_screen_rect()
  {

    return RECT(0, 0, Screen.Width, Screen.Height); // dummy
  }

  static int GetSystemMetrics( int index )
  {
    //   return NtUserCallOneParam( index, NtUserGetSystemMetrics );
    switch(index)
    {

      case Windows.SM_CXMINIMIZED: return SysMetric.MinimizedCx;
      case Windows.SM_CYMINIMIZED: return SysMetric.MinimizedCy;
      default:
        throw UnimplementedError();
    }
  }

  static UINT get_win_monitor_dpi( HWND hwnd )
  { 
    return system_dpi;
  }

  static UINT get_thread_dpi()
  {

    return 96; // dummy
  }

  static POINT map_dpi_point( POINT pt, UINT dpi_from, UINT dpi_to )
  {
    if (dpi_from != 0 && dpi_to != 0 && dpi_from != dpi_to)
    {
      pt.x = MulDiv( pt.x, dpi_to, dpi_from );
      pt.y = MulDiv( pt.y, dpi_to, dpi_from );
    }
    return pt;
  }


  static RECT map_dpi_rect( RECT rect, UINT dpi_from, UINT dpi_to )
  {

    return RECT.from(rect); // dummy
  }

  static RECT rect_win_to_thread_dpi( HWND hwnd, RECT rect )
  {

    return RECT.from(rect);
  }

  static RECT get_primary_monitor_rect( UINT dpi )
  {
    var info = MONITORINFO();
    get_monitor_info( null, info );
    return RECT.from(info.rcMonitor);

  }

  static BOOL get_monitor_info( HMONITOR handle, MONITORINFO info )
  {
    if(handle == null)
    {
      info.rcMonitor
        ..left = 0
        ..top = 0
        ..right = window.innerWidth ?? 0
        ..bottom = window.innerHeight ?? 0;
      return TRUE;
    }

    return FALSE;
  }

  static HMONITOR monitor_from_window( HWND? hwnd, UINT flags, UINT dpi ) 
  {

    return null; // dummy
  }

}