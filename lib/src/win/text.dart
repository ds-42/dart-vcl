part of vcl;

abstract class wingdi_text
{

  static int DrawText( HDC hdc, String str, int count, RECT rect, UINT flags )
  {
    int x = rect.left;
    int y = rect.top;
    if(flags.and(Windows.DT_CENTER))
    {
      var m = hdc.measureText(str);
      y+=(rect.height-m!.fontBoundingBoxDescent!.toInt()) ~/ 2;
    }
    
    hdc.textOut(x, y, str);

    return TRUE; // ???

  }

  static BOOL ExtTextOut( HDC hdc, num x, num y, UINT flags, RECT? rect,
                          String str, int count, Integer? dx )
  {
    if(flags.and(Windows.ETO_OPAQUE))
    {
      if(rect == null)
        return FALSE;
      wingdi_uitools.FillRectEx(hdc, rect.left, rect.top, rect.right, rect.bottom, null);
      return TRUE;
    }

    hdc.textOut(x, y, str);

    return TRUE; 
  }

  static BOOL GetTextExtentPoint32( HDC hdc, String str, int count, SIZE size )
  {
    var m = hdc.measureText(str);
    if(m == null)
      return FALSE;
    size.cx = m.width!.round();
    size.cy = FontMetric.calc_height(hdc.font.name, hdc.font.size, hdc.font.weight, hdc.font.italic).round();
    return TRUE; 
  }

}