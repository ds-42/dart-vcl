part of vcl;

abstract class wingdi_dc
{

  static BOOL LineTo( HDC hdc, num x, num y )
  {
    hdc.lineTo(x, y);
    hdc.stroke();
    hdc._ptx = x;
    hdc._pty = y;
    return TRUE;

  }

  static BOOL MoveToEx( HDC hdc, num x, num y, POINT? pt )
  {
    if(pt != null)
    {
      pt.x = hdc._ptx.round();
      pt.y = hdc._pty.round();
    }
    hdc._ptx = x;
    hdc._pty = y;
    hdc.beginPath();
    hdc.moveTo(x, y);
    return TRUE;

  }

  static BOOL Rectangle( HDC hdc, num left, num top, num right, num bottom )
  {
    num w = right-left;
    num h = bottom-top;
    if(hdc.brush.style != TBrushStyle.Clear)
      hdc.fillRect(left, top, w, h);

    hdc.strokeRect(left, top, w-1, h-1);
    return TRUE; 
  }

  static BOOL RoundRect( HDC hdc, num left, num top, num right,
                                  num bottom, num ell_width, num ell_height )
  { 
    return FALSE;

  }

  static BOOL Polyline( HDC hdc, List<POINT> points, int count )
  {
    if(count<0)
      count = points.length;
    else
    if(count>points.length)
      count = points.length;

    if(count<=0)
      return FALSE;

    hdc.beginPath();

    POINT pt = POINT();
    for(int i=0; i<count; i++)
    {
      pt = points[i];
      if(i == 0)
        hdc.moveTo(pt.x, pt.y);
      else
        hdc.lineTo(pt.x, pt.y);
    }
    hdc._ptx = pt.x;
    hdc._pty = pt.y;

    hdc.stroke();
    return TRUE;

  }

  static BOOL PolylineEx(HDC hdc, num x, num y, List<num> pts, bool lock)
  {
    if(pts.length<2)
      return FALSE;

    hdc.beginPath();

    int ndx = 0;
    num px = 0;
    num py = 0;
    for(py in pts)
    {
      if(ndx.isOdd)
      {
        if(ndx == 1) // first
          hdc.moveTo(x+px, y+py);
        else
          hdc.lineTo(x+px, y+py);
      }
      else
        px = py;
      ndx++;
    }

    if(lock)
    {
      px = pts[0];
      py = pts[1];
      hdc.lineTo(x+px, y+py);
      if(hdc.brush.style != TBrushStyle.Clear)
        hdc.fill();
    }
    hdc._ptx = px;
    hdc._pty = py;

    hdc.stroke();

    return TRUE;
  }

}