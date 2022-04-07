part of vcl;

abstract class wingdi_uitools
{

  static int FillRectEx( HDC hdc, num left, num top, num right, num bottom, HBRUSH? hbrush )
  {
    if(hbrush==null || hdc._brush==hbrush)
      hdc.fillRect(left, top, right-left, bottom-top);
    else
    {
      var prev_brush = Windows.SelectObject(hdc, hbrush);
      hdc.fillRect(left, top, right-left, bottom-top);
      Windows.SelectObject(hdc, prev_brush);
    }
    return TRUE;
  }

  static int FillRect( HDC hdc, RECT rect, HBRUSH hbrush )
  {
    return FillRectEx(hdc, rect.left, rect.top, rect.right, rect.bottom, hbrush);

  }

}