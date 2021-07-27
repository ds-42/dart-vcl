part of vcl;

String make_font_line(num? size, String? name, int? weight, bool? italic)
{
  return
    "${weight==null? '':'$weight '}"
    "${italic==null || italic==false? '':'italic '}"
    "${size==null? '' : (size<0? '${-size}px ':'${size}pt ')}"
    "${name==null? '' : name}";
}

abstract class FontMetric
{
  static final _meter = DivElement();
  static final _meter_text = SpanElement();
  static final _meter_block = DivElement();
  static final _canvas = CanvasElement();

  static CanvasRenderingContext2D? _context;

  static double _ascent = 0;
  static double get ascent => _ascent;

  static double _descent = 0;
  static double get descent => _descent;

  static double _height = 0;
  static double get height => _height;

  static double _leading = 0;
  static double get leading => _leading;

  static void _init()
  {
    if(_context == null)
    { // init elements
      _meter_text.text = 'Hg1';

      _meter_block.style
        ..display = 'inline-block'
        ..verticalAlign = 'baseLine'
        ..height = '0'
        ..width = '1px';

      _meter.style.visibility = 'hidden';

      _meter.append(_meter_text);
      _meter.append(_meter_block);

      _context = _canvas.getContext('2d') as CanvasRenderingContext2D;
    }
  }

  static void _update_meter_text(String? font, double? size, int? weight, bool? italic)
  {
    if(font==null) font = 'Serif';
    if(size==null) size = 10;
    if(weight==null) weight = 400;
    if(italic==null) italic = false;

    _meter_text.style
      ..fontFamily = font
      ..fontWeight = '$weight'
      ..fontStyle  = '${italic==true? 'italic': null}'
      ..fontSize   = size<0? '${-size}px' : '${size}pt';
  }

  static double calc_height(String font, num size, int weight, bool italic)
  {
    _init();

    return 0;
  }

  static void calc(String font, double size, [int weight=400, bool italic=false])
  {
    _init();

    _update_meter_text(font, size, weight, italic);


    _context!.font = make_font_line(size*10, font, weight, italic);

    document.body!.append(_meter);

    double k = 7200 / 96;

    TextMetrics m = _context!.measureText('Hg1');


    int a = ((_meter_block.offset.top-_meter_text.offset.top)*10*k).round();
    _ascent = a / 1000;
    _descent = (m.actualBoundingBoxDescent! * k).round() / 1000;
    _leading = (a - m.actualBoundingBoxAscent! * k).round() / 1000;
    _height  = _ascent+_descent;



    _meter.remove();
  }

  static List<double> getWidths(String str, String font, double size, [int weight=400, bool italic=false])
  {
    _init();

    final widths = <double>[];


    _context!.font = make_font_line(size, font, weight, italic);

    String data = '';
    int width = 0;
    for(int i=0; i<str.length; i++)
    {
      data+=str[i];
      int w = (_context!.measureText(data).width!*100).round();
      widths.add((w-width) / 100);
      width = w;
    }
    return widths;
  }

  static int getScaledWidths(List<int> dest, int Numerator, int Denominator, String str, int pos, int len, String font, double size, int weight, bool italic)
  {
    _init();

    _context!.font = make_font_line(size, font, weight, italic);

    int end = pos+len;
    String data = '';
    int width = 0;

    for(; pos<end; pos++)
    {
      data+=str[pos];
      int w = _context!.measureText(data).width! * Numerator ~/ Denominator;
      dest[pos] = w-width;
      width = w;
    }
    return width;
  }


}