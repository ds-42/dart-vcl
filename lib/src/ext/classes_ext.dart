part of vcl;

int MAKELONG(int a, int b) => (a & 0xffff) | ((b & 0xffff) << 16);
int LOWORD(int l) => l & 0xffff;
int HIWORD(int l) => l >> 16;

int MulDiv(int nNumber, int nNumerator, int nDenominator)
{
  if(nDenominator==0)
    return -1;
  return (nNumber * nNumerator / nDenominator).round();
}

class TEnum
{
  final String? _name;
  String get name => _name ?? runtimeType.toString();

  const TEnum(this._name);

  String toString() => name;
}

class TKeyCode
{
  int? Code;
  TKeyCode(this.Code);

  String toString()
  {
    if(Code == null)
      return 'keyCode: null';

    return 'keyCode: $Code, Symbol: ${ String.fromCharCode(Code!) }';
  }
}

class Integer
{
  int Value;

  Integer( [this.Value = 0] );

  Integer Copy() => Integer(Value);



  bool operator == (Object other)
  {
    if(other is Integer) return Value == other.Value;
    if(other is int) return Value == other;
    return false;
  }

  bool operator > (Integer other) => Value > other.Value;
  bool operator < (Integer other) => Value < other.Value;
  bool operator >= (Integer other) => Value >= other.Value;
  bool operator <= (Integer other) => Value <= other.Value;

  int get hashCode => Value.hashCode;

  String toString() => Value.toString();

  
}

class POINT
{
  int x;
  int y;

  POINT( [this.x = 0, this.y = 0] );

  String toString() => 'POINT($x, $y)';

  void assign(POINT pt)
  {
    x = pt.x;
    y = pt.y;
  }

  double DistanceTo(POINT pt)
  {
    return sqrt((x-pt.x)*(x-pt.x)+(y-pt.y)*(y-pt.y));
  }
}

class TPoint extends POINT
{

  TPoint( [int x = 0, int y = 0] ) : super(x, y);

  TPoint.from(POINT pt) : super(pt.x, pt.y);

  String toString()
  {
    return 'TPoint($x, $y)';
  }

  TPoint copy([ int dx=0, int dy=0 ])
  {
    return TPoint(x+dx, y+dy);
  }
}

class SIZE
{
  int cx;
  int cy;

  SIZE( [ this.cx = 0, this.cy = 0] );

  String toString() => 'SIZE($cx, $cy)';
}

class TSize extends SIZE
{

  TSize( [ int cx = 0, int cy = 0] ) : super(cx, cy);

  String toString()
  {
    return 'TSize($cx, $cy)';
  }

  void assign(TSize size)
  {
    cx = size.cx;
    cy = size.cy;
  }

  TSize copy([ int dx=0, int dy=0 ])
  {
    return TSize(cx+dx, cy+dy);
  }

}

class RECT
{
  int left;
  int top;
  int right;
  int bottom;

  int
    get height => bottom - top;
    set height(int value) => bottom = top + value;

  int
    get width => right - left;
    set width(int value) => right = left + value;

  RECT( [this.left=0, this.top=0, this.right=0, this.bottom=0] );

  RECT.from(RECT src) : this(src.left, src.top, src.right, src.bottom);

  String toString()
  {
    return 'RECT($left, $top, $right, $bottom) $width x $height';
  }

  void assign(RECT r)
  {
    left = r.left;
    top = r.top;
    right = r.right;
    bottom = r.bottom;
  }

  List<POINT> get pts => [POINT(left, top), POINT(right, bottom)];

  void assign_pts(List<POINT> pts)
  {
    if(pts.length<2)
      return;

    left = pts[0].x;
    top = pts[0].y;

    right = pts[1].x;
    bottom = pts[1].y;
  }

}

class TRect extends RECT
{
  int
    get Left => left;
    set Left(int val) => left = val;

  int
    get Top => top;
    set Top(int val) => top = val;

  int
    get Right => right;
    set Right(int val) => right = val;

  int
    get Bottom => bottom;
    set Bottom(int val) => bottom = val;

  int get Width => width;
  int get Height => height;

  TPoint
    get TopLeft => TPoint(left, top);
    set TopLeft(TPoint pt)
    {
      left = pt.x;
      top  = pt.y;
    }

  TPoint
    get BottomRight => TPoint(right, bottom);
    set BottomRight(TPoint pt)
    {
      right = pt.x;
      bottom = pt.y;
    }

  TRect([int lft=0, int top=0, int rgh=0, int btm=0]) :
    super(lft, top, rgh, btm);

  TRect.size(int lft, int top, int width, int height) :
    super(lft, top, lft + width, lft + height);

  TRect.rect(RECT r) :
    super(r.left, r.top, r.right, r.bottom);

  TRect.pts(TPoint p1, TPoint p2) :
    super(p1.x, p1.y, p2.x, p2.y);

  void init()
  {
    left = 0;
    top = 0;
    right = 0;
    bottom = 0;
  }

  TRect copy()
  {
    return TRect(left, top, right, bottom);
  }

  void expand()
  {
    left--;
    top--;
    right++;
    bottom++;
  }

  void offset(int dx, int dy) => OffsetRect(this, dx, dy);

  bool isEmpty() => IsRectEmpty(this);

  bool isEqual(TRect r) => EqualRect(this, r);

  TRect? intersect(TRect rect)
  {
    int l = left > rect.left? left : rect.left;
    int r = right < rect.right? right : rect.right;
    int t = top > rect.top? top : rect.top;
    int b = bottom < rect.bottom? bottom : rect.bottom;
    if(l>r || t>b)
      return null;
    return TRect(l, t, r, b);
  }

  bool accept(int x, int y) => PtInRect(this, POINT(x, y));

  bool get isValid => left <= right && top <= bottom;

  void valid()
  {
    if(left>right)
    {
      int t = left;
      left = right;
      right = t;
    }

    if(top>bottom)
    {
      int t = top;
      top = bottom;
      bottom = t;
    }
  }

  void clip(int left, int top, int right, int bottom)
  {
    if(this.left < left)
      this.left  = left;

    if(this.top < top)
      this.top   = top;

    if(this.right > right)
      this.right = right;

    if(this.bottom > bottom)
      this.bottom= bottom;
  }

}


bool SetRectEmpty(RECT rect)
{
  rect.left = rect.right = rect.top = rect.bottom = 0;
  return true;
}

bool SetRect(RECT rc, int xLeft, int yTop, int xRight, int yBottom)
{
  rc.left = xLeft;
  rc.top = yTop;
  rc.right = xRight;
  rc.bottom = yBottom;
  return true;
}

void OffsetRect(RECT rect, int dx, int dy)
{
  rect.left+=dx;
  rect.top+=dy;
  rect.right+=dx;
  rect.bottom+=dy;
}

bool IntersectRect(RECT dest, RECT src1, RECT src2)
{
  if (IsRectEmpty(src1) || IsRectEmpty(src2) ||
     (src1.left >= src2.right) || (src2.left >= src1.right) ||
     (src1.top >= src2.bottom) || (src2.top >= src1.bottom))
  {
    SetRectEmpty( dest );
    return false;
  }
  dest.left   = max( src1.left,   src2.left );
  dest.right  = min( src1.right,  src2.right );
  dest.top    = max( src1.top,    src2.top );
  dest.bottom = min( src1.bottom, src2.bottom );
  return true;
}

bool PtInRect(RECT rect, POINT pt)
{
  return ((pt.x >= rect.left) && (pt.x < rect.right) &&
          (pt.y >= rect.top) && (pt.y < rect.bottom));
}

bool IsRectEmpty(RECT rect)
{
  return ((rect.left >= rect.right) || (rect.top >= rect.bottom));
}

bool EqualRect(RECT rc1, RECT rc2)
{
  return rc1.left == rc2.left && rc1.right  == rc2.right &&
         rc1.top  == rc2.top  && rc1.bottom == rc2.bottom;
}


class XFORM
{
  final double   eM11;
  final double   eM12;
  final double   eM21;
  final double   eM22;
  final double   eDx;
  final double   eDy;

  XFORM(this.eM11, this.eM12, this.eM21, this.eM22, [this.eDx = 0.0, this.eDy = 0.0] );

  void transform_i4(List<int> pts)
  {
    for(int i=0; i<pts.length; )
    {
      int x = pts[i];
      int y = pts[i+1];
      pts[i++] = (x * eM11 + y * eM21 + eDx).truncate();
      pts[i++] = (x * eM12 + y * eM22 + eDy).truncate();
    }
  }

  void transform_r8(List<double> pts)
  {
    for(int i=0; i<pts.length; )
    {
      double x = pts[i];
      double y = pts[i+1];
      pts[i++] = x * eM11 + y * eM21 + eDx;
      pts[i++] = x * eM12 + y * eM22 + eDy;
    }
  }

  void transform_pt(POINT pt)
  {
    int x = pt.x;
    int y = pt.y;
    pt.x = (x * eM11 + y * eM21 + eDx).truncate();
    pt.y = (x * eM12 + y * eM22 + eDy).truncate();
  }

  void transform_rect(RECT rect)
  {
    POINT pt;
    pt = POINT(rect.left, rect.top);
    transform_pt(pt);
    rect.left = pt.x;
    rect.top  = pt.y;

    pt = POINT(rect.right, rect.bottom);
    transform_pt(pt);
    rect.right  = pt.x;
    rect.bottom = pt.y;
  }

}



class TItems<T> extends Iterable<T>
{

  final Function  _getter;  // getter
  final Function  _igetter; // iterator
  final Function? _setter;  // setter

  TItems(this._getter, this._igetter, [this._setter]);
  TItems.from(TItems other) : this(other._getter, other._igetter, other._setter);

  T operator [](int index) => _getter(index);
  void operator []=(int index, T value) => _setter!(index, value);

  @override
  Iterator<T> get iterator => _igetter();
}

class TPointer<T>
{
  T _value;
  T get Value => _value;
  set Value(T val) => _value = val;

  TPointer(this._value);
}

