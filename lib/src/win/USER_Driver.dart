part of vcl;

typedef window_surface = dynamic;

abstract class USER_Driver
{

  static void SetWindowStyle( HWND hwnd, int offset, STYLESTRUCT style ) // dummy
  {

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
