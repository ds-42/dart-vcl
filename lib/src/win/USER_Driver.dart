part of vcl;

typedef window_surface = dynamic;

abstract class USER_Driver
{

  static void SetWindowStyle( HWND hwnd, int offset, STYLESTRUCT style ) // dummy
  {

    int changed = style.styleNew ^ style.styleOld; 

    if(changed.and(Windows.WS_MAXIMIZE) && hwnd is HForm)
    {
      hwnd.bounds.visible = !style.styleNew.and(Windows.WS_MAXIMIZE);
    }


  }

  static void DestroyWindow( HWND hwnd )
  {
    hwnd.release();

  }

  static BOOL CreateWindow( HWND hwnd ) // dummy
  {

    return TRUE;
  }

  static UINT ShowWindow( HWND hwnd, int cmd, RECT rect, UINT swp ) // dummy
  {

    return swp;
  }


}
