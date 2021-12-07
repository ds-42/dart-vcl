part of vcl;

abstract class HIMAGE
{
  List<int> get bits;
  int get width;
  int get height;
  int get widthBytes => width * 4;

  void draw(CanvasRenderingContext2D ctx, int x, int y, [int dirtyX, int dirtyY, int dirtyWidth, int dirtyHeight]);

  bool isPixelValid(int x, int y) => x>=0 && y>=0 && x<width && y<height;

  int getPixelIndex(int x, int y) => y * widthBytes + x * 4;

  RECT? validRect(int x1, int y1, int x2, int y2)
  {
    // norm rects
    if(x1>x2){ int x=x1; x1=x2; x2=x; }
    if(y1>y2){ int y=y1; y1=y2; y2=y; }

    // cutting off the sides
    int w = width;
    int h = height;

    if(x1<0) x1=0;
    if(y1<0) y1=0;
    if(x2>w) x2=w;
    if(y2>h) y2=h;

    if(x1>=x2 || y1>=y2)
      return null;
    return RECT(x1, y1, x2, y2);
  }

  COLORREF getPixel(int x, int y)
  {
    if(!isPixelValid(x, y))
      return COLORREF(0, 0, 0, 0);
    int ptr = y * widthBytes + x * 4;
    var data = bits;
    return COLORREF(data[ptr++], data[ptr++], data[ptr++], data[ptr++]);
  }

  void setPixel(int x, int y, COLORREF clr)
  {
    if(!isPixelValid(x, y))
      return;
    if(clr.alpha==0)
      return; // transparent color
    setPixelDirect(getPixelIndex(x, y), clr);
  }

  /// unsafe direct change of pixel value
  void setPixelDirect(int ndx, COLORREF clr)
  {
    var data = bits;
    if(clr.alpha==255)
    { // opaque color
      data[ndx++] = clr.red;
      data[ndx++] = clr.green;
      data[ndx++] = clr.blue;
      data[ndx++] = 0xff;
      return;
    }
    if(clr._alpha==null)
    { // alpha channel not set
      data[ndx++] = clr.red;
      data[ndx++] = clr.green;
      data[ndx++] = clr.blue;
      return;
    }
    // mix colors
    int cur = ndx;
    int r = data[cur++];
    int g = data[cur++];
    int b = data[cur++];
    int a = data[cur++];

    if(a==0)
    {
      r = clr.red;
      g = clr.green;
      b = clr.blue;
      a = clr.alpha;
    }
    else
    if(a==clr.alpha)
    {
      r = (r + clr.red) >> 1;
      g = (g + clr.green) >> 1;
      b = (b + clr.blue) >> 1;
    }
    else
    {
      r = (r * a + clr.red   * clr.alpha) >> 8;
      g = (g * a + clr.green * clr.alpha) >> 8;
      b = (b * a + clr.blue  * clr.alpha) >> 8;
      a = (a + clr.alpha) >> 1;
    }

    data[ndx++] = r;
    data[ndx++] = g;
    data[ndx++] = b;
    data[ndx++] = a;
  }

  

  /// draw circle
  void circle(int x0, int y0, int radius, TColor clr)
  {
    var _clr = COLORREF.rgba(clr.rgba);
    int x = 0;
    int y = radius;
    int delta = 1 - 2 * radius;
    int error = 0;
    while(y >= 0)
    {
      setPixel(x0 + x, y0 + y, _clr);
      setPixel(x0 + x, y0 - y, _clr);
      setPixel(x0 - x, y0 + y, _clr);
      setPixel(x0 - x, y0 - y, _clr);
      error = (delta + y) + (delta + y) - 1;
      if(delta < 0 && error <= 0)
      {
        x++;
        delta += 1 + x + x;
        continue;
      }
      error =  (delta - x) + (delta - x) - 1;
      if(delta > 0 && error > 0)
      {
        y--;
        delta += 1 - y - y;
        continue;
      }
      x++;
      delta += (x - y) + (x - y);
      y--;
    }
  }

  /// fill rect
  void fill(int x1, int y1, int x2, int y2, TColor clr)
  {
    var r = validRect(x1, y1, x2, y2);
    if(r==null)
      return;

    var _clr = COLORREF.rgba(clr.rgba);

    int wb = widthBytes;
    int ndx = getPixelIndex(r.left, r.top);
    int end = ndx + r.width * 4;

    for(int y=r.top; y<r.bottom; y++, ndx+=wb, end+=wb)
      for(int x = ndx; x<end; x+=4)
        setPixelDirect(x, _clr);
  }

  /// invert rect
  void invert(int x1, int y1, int x2, int y2)
  {
    var r = validRect(x1, y1, x2, y2);
    if(r==null)
      return;

    int wb = widthBytes;
    int ndx = getPixelIndex(r.left, r.top);
    int end = ndx + r.width * 4;
    var data = bits;

    for(int y=r.top; y<r.bottom; y++, ndx+=wb, end+=wb)
      for(int x = ndx; x<end; x++)
      {
        bits[x] = 255 - bits[x++];
        bits[x] = 255 - bits[x++];
        bits[x] = 255 - bits[x++];
      }
  }

  /// invert cross in point
  void invertCross(int x, int y)
  {
    int w = width;
    int h = height;
    if(x<0 || x>=w || y<0 || y>=w)
      return;

    int wb = widthBytes;
    int ndx = x * 4;
    int end = ndx + h * wb;
    var data = bits;

    // draw vert ray
    for(; ndx < end; ndx+=wb)
    {
      if(data[ndx+3]==0)
        data[ndx+3] = 255;
      else
      {
        int y = ndx;
        data[y] = 255 - data[y++];
        data[y] = 255 - data[y++];
        data[y] = 255 - data[y++];
        data[y] = 255;
      }
    }

    ndx = y * wb;
    end = ndx + wb;

    // draw horz ray
    for(; ndx < end;)
    {
      if(data[ndx+3]==0)
      {
        ndx+=4;
        data[ndx-1] = 255;
      }
      else
      {
        data[ndx] = 255 - data[ndx++];
        data[ndx] = 255 - data[ndx++];
        data[ndx] = 255 - data[ndx++];
        data[ndx++] = 255;
      }
    }
  }

  /// draw line
  void line(int x1, int y1, int x2, int y2, TColor clr)
  {
    var _clr = COLORREF.rgba(clr.rgba);
    int deltaX = (x2 - x1).abs();
    int deltaY = (y2 - y1).abs();
    int signX = x1 < x2 ? 1 : -1;
    int signY = y1 < y2 ? 1 : -1;
    int error = deltaX - deltaY;
    while(x1 != x2 || y1 != y2)
    {
      setPixel(x1, y1, _clr);
      int error2 = error + error;
      if(error2 > -deltaY)
      {
        error -= deltaY;
        x1 += signX;
      }

      if(error2 < deltaX)
      {
        error += deltaX;
        y1 += signY;
      }
    }
  }

  void polyline(int x, int y, List<int> pts, TColor clr)
  {
    int? x1, y1;
    int? x2, y2;
    for(y2 in pts)
    {
      if(x2==null)
        x2 = y2;
      else
      {
        if(x1!=null)
          line(x+x1, y+y1!, x+x2, y+y2, clr);
        x1 = x2;
        y1 = y2;
        x2 = null;
      }
    }
  }

  void rect(int x1, int y1, int x2, int y2, TColor clr)
  {
    var _clr = COLORREF.rgba(clr.rgba);
    var r = validRect(x1, y1, x2, y2);
    if(r==null)
      return;

    horz(y1, r.left, r.right,  clr);
    vert(x2, r.top,  r.bottom, clr);
    horz(y2, r.left, r.right,  clr);
    vert(x1, r.top,  r.bottom, clr);
  }

  void triangle(int x1, int y1, int x2, int y2, int x3, int y3, TColor clr)
  {
    var _clr = COLORREF.rgba(clr.rgba);
    int h = height;
    int w = width * 255;

    int t;
    // sort points p1(x1, y1), p2(x2, y2), p3(x3, y3)
    if(y2 < y1)
    {
      t=x1; x1=x2; x2=t;
      t=y1; y1=y2; y2=t;
    }

    if(y3 < y1)
    {
      t=x1; x1=x3; x3=t;
      t=y1; y1=y3; y3=t;
    }

    if(y2 > y3)
    {
      t=x2; x2=x3; x3=t;
      t=y2; y2=y3; y3=t;
    }


    // calc delta
    int dx13 = y3 == y1? 0 : (x3 - x1) * 256 ~/ (y3 - y1);
    int dx12 = y2 == y1? 0 : (x2 - x1) * 256 ~/ (y2 - y1);
    int dx23 = y3 == y2? 0 : (x3 - x2) * 256 ~/ (y3 - y2);

    // "work points" on the top
    int wx1 = x1 * 256;
    int wx2 = wx1;

    int _dx13 = dx13;

    if (dx13 > dx12)
    {
      var t = dx13; dx13 = dx12; dx12 = t;
    }

    // draw upper half triangle
    for(int y = y1; y < y2; y++)
    {
      // draw horz line between work points
      int px1 = wx1;
      int px2 = wx2;
      if(px1<0) px1 = 0;
      if(px2>w) px2 = w;

      if(px1<px2 && y>0 && y<h)
      {
        px1 = px1 >> 8;
        px2 = px2 >> 8;

        int ndx = getPixelIndex(px1, y);
        int end = ndx + (px2 - px1) * 4;
        _horzDirect(ndx, end, _clr);
      }

      wx1 += dx13;
      wx2 += dx12;
    }

    // case: upper half triangle undef
    if (y1 == y2)
    {
      wx1 = x1;
      wx2 = x2;
    }

    dx13 = _dx13;
    if (dx13 < dx23)
    {
      var t = dx13; dx13=dx23; dx23 = t;
    }

    // draw down half triangle
    for(int y = y2; y <= y3; y++)
    {
      // draw horz line between work points
      int px1 = wx1;
      int px2 = wx2;
      if(px1<0) px1 = 0;
      if(px2>w) px2 = w;

      if(px1 < px2 && y>0 && y<h)
      {
        px1 = px1 >> 8;
        px2 = px2 >> 8;

        int ndx = getPixelIndex(px1, y);
        int end = ndx + (px2 - px1)*4;
        _horzDirect(ndx, end, _clr );
      }
      wx1 += dx13;
      wx2 += dx23;
    }
  }
    /// draw vert ray
  void xRay(int x, TColor clr)
  {
    if(x<0 || x>=width)
      return;

    var _clr = COLORREF.rgba(clr.rgba);

    int wb = widthBytes;
    int ndx = x * 4;
    int end = ndx + height * wb;

    for(; ndx < end; ndx+=wb)
      setPixelDirect(ndx, _clr);
  }

  /// draw vert line
  void vert(int x, int y1, int y2, TColor clr)
  {
    var r = validRect(x, y1, x+1, y2);
    if(r==null)
      return;

    var _clr = COLORREF.rgba(clr.rgba);

    int wb = widthBytes;
    int ndx = getPixelIndex(r.left, r.top);
    int end = ndx + r.height * wb;

    for(; ndx < end; ndx+=wb)
      setPixelDirect(ndx, _clr);
  }

  /// draw horz ray
  void yRay(int y, TColor clr)
  {
    if(y<0 || y>=height)
      return;

    var _clr = COLORREF.rgba(clr.rgba);

    int wb = widthBytes;
    int ndx = y * wb;
    int end = ndx + wb;

    for(; ndx < end; ndx+=4)
      setPixelDirect(ndx, _clr);
  }

  /// draw horz line
  void horz(int y, int x1, int x2, TColor clr)
  {
    var r = validRect(x1, y, x2, y+1);
    if(r==null)
      return;

    int ndx = getPixelIndex(r.left, r.top);
    int end = ndx + r.width*4;

    _horzDirect(ndx, end, COLORREF.rgba(clr.rgba) );

  }

  void _horzDirect(int ndx, int end, COLORREF clr)
  {
    for(; ndx<end; ndx+=4)
      setPixelDirect(ndx, clr);
  }
}

class HIMAGEDATA extends HIMAGE
{
  final ImageData handle;

  HIMAGEDATA(this.handle);

  List<int> get bits => handle.data;
  int get width => handle.width;
  int get height => handle.height;

  void draw(CanvasRenderingContext2D ctx, int x, int y, [int? dirtyX, int? dirtyY, int? dirtyWidth, int? dirtyHeight])
  {
    ctx.putImageData(handle, x, y, dirtyX, dirtyY, dirtyWidth, dirtyHeight);
  }
}