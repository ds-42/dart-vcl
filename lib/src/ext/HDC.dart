part of vcl;

class DEVCAPS
{
  HDC _ctx;
  int get technology  => _ctx.technology;
  int get xResolution => _ctx.xResolution;
  int get yResolution => _ctx.yResolution;

  DEVCAPS(this._ctx);
  
}

HDC CreateCompatibleDC(HDC? dc)
{
  if(dc==null)
  {
    var res = HCanvasDC();
    res.init();
    return res;
  }

  throw UnsupportedError('CreateCompatibleDC');
}


abstract class HDC
{
  final int technology;
  final int xResolution;
  final int yResolution;

  late final DEVCAPS caps;

  dynamic get handle => null;

  HDC( { this.technology = Windows.DT_RASDISPLAY,
         this.xResolution = 96,
         this.yResolution = 96 })
  {
    caps = DEVCAPS(this);
  }

  num _ptx = 0;
  num _pty = 0;

  HFONT _font = HFONT(10, 'Arial', Windows.FW_NORMAL, false, false, clBlack);
  HFONT get font => _font;
  HFONT selectFont({double? size, String? name, int? weight, bool? italic, bool? underline, TColor? color})
  {
    return select(HFONT(
      size ?? font.size,
      name ?? font.name,
      weight ?? font.weight,
      italic ?? font.italic,
      underline ?? font.underline,
      color ?? font.color)) as HFONT;
  }

  HBRUSH _brush = HBRUSH(clWhite);
  HBRUSH get brush => _brush;
  HBRUSH selectBrush({TColor? color, TBrushStyle? style})
  {
    return select(HBRUSH(
      color ?? brush.color,
      style ?? brush.style)) as HBRUSH;
  }

  HPEN _pen = HPEN(clBlack);
  HPEN get pen => _pen;
  HPEN selectPen({TColor? color, double? width, TPenStyle? style, TLineCap? cap, TLineJoin? join})
  {
    return select(HPEN(
      color ?? pen.color,
      width ?? pen.width,
      style ?? pen.style,
      cap   ?? pen.cap,
      join  ?? pen.join)) as HPEN;
  }

  HGDIOBJ select(HGDIOBJ obj)
  {
    if(obj is HFONT)
    {
      if(_font == obj)
        return obj;
      var ret = _font;
      _font = obj;
      updateFont(obj);
      return ret;
    }

    if(obj is HPEN)
    {
      if(_pen == obj)
        return obj;
      var ret = _pen;
      _pen = obj;
      updatePen(obj);
      return ret;
    }

    if(obj is HBRUSH)
    {
      if(_brush == obj)
        return obj;
      var ret = _brush;
      _brush = obj;
      updateBrush(obj);
      return ret;
    }

    throw UnsupportedError('Invalid gdi object: $obj');
  }

  void updateFont(HFONT font)
  {
    fontStyle =
      "${font.italic? 'italic ': ''}"
      "${font.weight==400? '' : '${font.weight} '}"
      "${font.size}pt "
      "\"${font.name}\"";
  }

  void updateBrush(HBRUSH brush)
  {
    if(brush.style is TPatternBrushStyle)
      fillStyle = (brush.style as TPatternBrushStyle).getPattern(brush.color);
    else
    if(brush.style == TBrushStyle.Clear)
      fillStyle = '#00000000';
    else
      fillStyle = brush.color.html;
  }

  void updatePen(HPEN pen)
  {
    strokeStyle = pen.color.html;
    lineWidth = pen.width;
    var dash = pen.style.sizedDash(pen.width);
    if(dash!=null)
      lineDash = dash;

    switch(pen.cap)
    {
      case TLineCap.Round:  lineCap = 'round';  break;
      case TLineCap.Square: lineCap = 'square'; break;
      case TLineCap.Flat:   lineCap = 'butt';   break;
    }

    switch(pen.join)
    {
      case TLineJoin.Round: lineJoin = 'round'; break;
      case TLineJoin.Bevel: lineJoin = 'bevel'; break;
      case TLineJoin.Miter: lineJoin = 'miter'; break;
    }
  }

  void beginPath();

  void circle(num x, num y, num r) =>
    ellipse(x, y, r, r, 0, 0, pi*2, false);

  void clear(num x, num y, num width, num height);

  void clip();

  void clipRectangle(num x1, num y1, num x2, num y2)
  {
    beginPath();
    rectangle(x1, y1, x2, y2);
    clip();
  }

  void drawCircle(num x, num y, num r)
  {
    beginPath();
    circle(x, y, r);
    fill();
    stroke();
  }

  void drawImage(num x, num y, HDC dc);

  void drawLine(num x1, num y1, num x2, num y2) =>
    strokeLine(x1, y1, x2, y2);

  void drawPolygon(num x, num y, List<num> pts) =>
    drawPolyline(x, y, pts, true);

  void drawPolyline(num x, num y, List<num> pts, [bool lock = false])
  {
    beginPath();
    polyline(x, y, pts, lock);
    fill();
    stroke();
  }

  void drawRect(num x, num y, num w, num h)
  {
    fillRect(x, y, w, h);
    strokeRect(x, y, w, h);
  }

  void drawRectangle(num x1, num y1, num x2, num y2) =>
    drawRect(x1, y1, x2-x1, y2-y1);

  void ellipse(num x, num y, num radiusX, num radiusY, num rotation,
               num startAngle, num endAngle, bool anticlockwise);

  void fill();

  set fillColor(TColor clr) =>
    fillStyle = clr.html;

  void fillPolygon(num x, num y, List<num> pts) =>
    fillPolyline(x, y, pts);

  void fillPolyline(num x, num y, List<num> pts)
  {
    beginPath();
    polyline(x, y, pts, true);
    fill();
  }

  void fillRect(num x, num y, num w, num h);

  void fillRectangle(num x1, num y1, num x2, num y2) =>
      fillRect(x1, y1, x2-x1, y2-y1);

  Object?
    get fillStyle;
    set fillStyle(Object? value);

  void fillText(num x, num y, String text);

  String
    get fontStyle;
    set fontStyle(String value);

  void init()
  {
    _ptx = 0;
    _pty = 0;
    textBaseline = 'top';
  }

  void lineTo(num x, num y);

  List<num>
    get lineDash;
    set lineDash(List<num> value);

  String
    get lineJoin;
    set lineJoin(String value);

  String
    get lineCap;
    set lineCap(String value);

  num
    get lineWidth;
    set lineWidth(num value);

  HIMAGE? getImageData(int x, int y, int width, int height) => null;

  void putImageData(int x, int y, HIMAGE image) => null;

  TextMetrics? measureText(String text);

  void moveTo(num x, num y);



  void polyline(num x, num y, List<num> pts, [bool lock = false])
  {
    if(pts.length<2)
      return;

    int ndx = 0;
    num px = 0;
    for(var py in pts)
    {
      if(ndx.isOdd)
      {
        if(ndx == 1) // first
          moveTo(x+px, y+py);
        else
          lineTo(x+px, y+py);
      }
      else
        px = py;
      ndx++;
    }

    if(lock)
      lineTo(x+pts[0], y+pts[1]);
  }

  void rect(num x, num y, num w, num h);

  void rectangle(num x1, num y1, num x2, num y2) =>
    rect(x1, y1, x2-x1, y2-y1);

  void restore();

  void save();

  void stroke();

  void strokeCircle(num x, num y, num r)
  {
    beginPath();
    circle(x, y, r);
    stroke();
  }

  set strokeColor(TColor clr) =>
    strokeStyle = clr.html;

  void strokeLine(num x1, num y1, num x2, num y2)
  {
    beginPath();
    moveTo(x1, y1);
    lineTo(x2, y2);
    stroke();
  }

  void strokeRect(num x, num y, num w, num h);

  void strokeText(num x, num y, String text);

  Object?
    get strokeStyle;
    set strokeStyle(Object? value);

  String
    get textBaseline => '';
    set textBaseline(String value) { }

  String
    get textAlign => '';
    set textAlign(String value) { }

  void textOut(num x, num y, String text)
  {
    var mem = fillStyle;
    fillStyle = font.color.html;
    fillText(x, y, text);
    fillStyle = mem;

  }

  // printer
  bool startDoc() => false;

  bool startPage() => false;

  bool newPage() => false;

  bool endPage() => false;

  Future<bool> endDoc() async => false;

}

class HCanvasDC extends HDC
{
  final CanvasElement            canvas;
  final CanvasRenderingContext2D context;

  static const num DD = 0.5;

  dynamic get handle => context;

  HCanvasDC._(this.canvas, this.context) : super( );

  factory HCanvasDC( [CanvasElement? elem] )
  {
    if(elem == null)
     elem = CanvasElement();
    return HCanvasDC._(elem, elem.context2D);
  }

  void resize(int width, int height)
  {
    if(canvas.width == width && canvas.height == height)
      return;
    canvas.width = width;
    canvas.height = height;
    updateBrush(_brush);
    updatePen(_pen);
    updateFont(_font);
  }

  @override
  void beginPath() =>
    context.beginPath();

  @override
  void clip() =>
    context.clip();

  @override
  void init()
  {
    super.init();
    context.imageSmoothingEnabled = false;
  }

  @override
  void ellipse(num x, num y, num radiusX, num radiusY, num rotation,
      num startAngle, num endAngle, bool anticlockwise) =>
    context.ellipse(x+DD, y+DD, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise);

  @override
  void clear(num x, num y, num width, num height) =>
    context.clearRect(x, y, width, height);

  @override
  void drawImage(num x, num y, HDC dc)
  {
    if(dc is HCanvasDC)
      context.drawImage(dc.canvas, x, y);
  }

  @override
  void fill() =>
    context.fill();

  @override
  void fillRect(num x, num y, num w, num h) =>
    context.fillRect(x, y, w, h);

  @override
  Object? get fillStyle =>
    context.fillStyle;

  @override
  set fillStyle(Object? value) =>
    context.fillStyle = value;

  @override
  void fillText(num x, num y, String text) =>
      context.fillText(text, x, y);

  @override
  String get fontStyle =>
    context.font;

  @override
  set fontStyle(String value) =>
    context.font = value;

  @override
  void lineTo(num x, num y) =>
    context.lineTo(x+DD, y+DD);

  @override
  String get lineCap =>
    context.lineCap;

  @override
  set lineCap(String value) =>
    context.lineCap = value;

  @override
  List<num> get lineDash =>
    context.getLineDash();

  @override
  set lineDash(List<num> value) =>
    context.setLineDash(value);

  @override
  String get lineJoin =>
    context.lineJoin;

  @override
  set lineJoin(String value) =>
    context.lineJoin = value;

  @override
  num get lineWidth =>
    context.lineWidth;

  @override
  set lineWidth(num value) =>
    context.lineWidth = value;

  @override
  TextMetrics? measureText(String text) =>
    context.measureText(text);

  @override
  void moveTo(num x, num y) =>
    context.moveTo(x+DD, y+DD);

  @override
  void rect(num x, num y, num w, num h) =>
    context.rect(x+DD, y+DD, w+DD, h+DD);

  @override
  HIMAGE? getImageData(int x, int y, int width, int height)
  {
    var image = context.getImageData(x, y, width, height);

    return HIMAGEDATA(image);
  }

  @override
  void putImageData(int x, int y, HIMAGE image) =>
    image.draw(context, x, y);

  @override
  void restore() =>
    context.restore();

  @override
  void save() =>
    context.save();

  @override
  void stroke() =>
    context.stroke();

  @override
  void strokeRect(num x, num y, num w, num h) =>
    context.strokeRect(x+DD, y+DD, w, h);

  @override
  Object? get strokeStyle =>
    context.strokeStyle;

  @override
  set strokeStyle(Object? value) =>
    context.strokeStyle = value;

  @override
  void strokeText(num x, num y, String text) =>
    context.strokeText(text, x+DD, y+DD);

  @override
  String get textBaseline =>
    context.textBaseline;

  @override
  set textBaseline(String value) =>
    context.textBaseline = value;

  @override
  String get textAlign =>
    context.textAlign;

  @override
  set textAlign(String value) =>
    context.textAlign = value;
}

class HDummyDC extends HCanvasDC
{
  static final dummyCanvas = CanvasElement();

  HDummyDC() : super._(dummyCanvas, dummyCanvas.context2D);

  void resize(int width, int height)
  {
    // dummy
  }

}
