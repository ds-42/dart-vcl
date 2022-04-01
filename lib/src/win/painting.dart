part of vcl;

abstract class __painting
{

  static HDC? GetDCEx( HWND hwnd, dynamic/*HRGN*/ hrgnClip, UINT flags )
  {

    if (Windows.IsWindow(hwnd) == FALSE)
      return null;

    if(hwnd is HForm) // dummy
    {
      hwnd.canvasNeeded();
      return HCanvasDC(hwnd.canvas!);
    }
    return null;
  }

  
  static HDC? GetDC( HWND? hwnd )
  {
    if (hwnd == null)
      return GetDCEx( HWND_DESKTOP, 0, Windows.DCX_CACHE | Windows.DCX_WINDOW );
    return GetDCEx( hwnd, 0, Windows.DCX_USESTYLE );
  }

}
