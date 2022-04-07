part of vcl;

abstract class HGDIOBJ
{

}

class HFONT extends HGDIOBJ
{
  final TColor color;
  final bool   italic;
  final double size;
  final String name;
  final bool   underline;
  final int    weight;

  HFONT(this.size, this.name, this.weight, this.italic, this.underline, this.color);

  String toString() => 'HFONT(size: $size, name: $name, weight: $weight, italic: $italic, underline: $underline, color: $color)';
}

class HPEN extends HGDIOBJ
{
  final TColor    color;
  final double    width;
  final TPenStyle style;
  final TLineCap  cap;
  final TLineJoin join;

  HPEN(this.color,
      [this.width = 1,
       this.style = TPenStyle.Solid,
       this.cap   = TLineCap.Flat,
       this.join  = TLineJoin.Miter]);

  HPEN.from(HPEN source) : this(source.color, source.width, source.style, source.cap, source.join);

  String toString() => 'HPEN(color: $color, width: $width, style: $style, cap: $cap, join: $join)';
}

class HBRUSH extends HGDIOBJ
{
  final TColor      color;
  final TBrushStyle style;

  HBRUSH(this.color, [this.style = TBrushStyle.Solid]);

  String toString() => 'HBRUSH(color: $color, style: $style)';
}

abstract class wingdi_objects
{

  //Select a Gdi object into a device context.
  static HGDIOBJ SelectObject( HDC hdc, HGDIOBJ obj )
  {
    return hdc.select(obj);

  }

  static HBRUSH CreateSolidBrush( TColor color )
  { 
    return HBRUSH(color);
  }

}