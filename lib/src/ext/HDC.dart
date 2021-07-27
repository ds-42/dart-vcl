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
    res.textBaseline = 'top';
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

  void beginPath();

  void circle(num x, num y, num r) =>
    ellipse(x, y, r, r, 0, 0, 6.28, false);

  void clear(num x, num y, num width, num height);

  void clip();

  void clipRectangle(num x1, num y1, num x2, num y2)
  {
    beginPath();
    rectangle(x1, y1, x2, y2);
    clip();
  }

  void drawImage(num x, num y, HDC dc);

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

  void fillRect(num x, num y, num w, num h);

  Object?
    get fillStyle;
    set fillStyle(Object? value);

  void fillText(num x, num y, String text);

  void init();

  void lineTo(num x, num y);

  List<num>
    get lineDash;
    set lineDash(List<num> value);

  String
    get lineCap;
    set lineCap(String value);

  num
    get lineWidth;
    set lineWidth(num value);

  HIMAGE?
    get Image => null;
    set Image(HIMAGE? img) => null;

  HIMAGE? getImageData(int x, int y, int width, int height) => null;

  void putImageData(int x, int y, HIMAGE image) => null;

  TextMetrics? measureText(String text);

  void moveTo(num x, num y);

  void polyfill(num x, num y, List<num> pts) =>
    _polypath(x, y, pts, false, false, true);

  void polygon(num x, num y, List<num> pts) =>
    _polypath(x, y, pts, false, true, true);

  void polyline(num x, num y, List<num> pts, [bool lock=false]) =>
    _polypath(x, y, pts, lock, true, false);

  void _polypath(num x, num y, List<num> pts, bool lock, bool _stroke, bool _fill)
  {
    if(pts.isEmpty)
      return;

    beginPath();

    bool first = true;
    num? px, py;

    for(py in pts)
    {
      if(px==null)
        px = py;
      else
      {
        if(first)
        {
          moveTo(x+px, y+py);
          first = false;
        }
        else
          lineTo(x+px, y+py);
        px = null;
      }
    }

    if(_fill)
      lock = px!=pts[0] && py!=pts[1];

    if(lock)
      lineTo(x+pts[0], y+pts[1]);

    if(_fill)
      fill();

    if(_stroke)
      stroke();
  }

  void rect(num x, num y, num w, num h);

  void rectangle(num x1, num y1, num x2, num y2) =>
    rect(x1, y1, x2-x1, y2-y1);

  void restore();

  void save();

  void stroke();

  set strokeColor(TColor clr) =>
    strokeStyle = clr.html;

  void strokeLine(num x1, num y1, num x2, num y2)
  {
    beginPath();
    moveTo(x1, y1);
    lineTo(x2, y2);
    stroke();
  }

  void strokeRect(num x1, num y1, num x2, num y2);

  Object?
    get strokeStyle;
    set strokeStyle(Object? value);

  void selectFont(num size, String name, int weight, bool italic);

  
  String
    get textBaseline => '';
    set textBaseline(String value) { }

  String
    get textAlign => '';
    set textAlign(String value) { }

  
  void circleEx(num x, num y, num r)
  {
    beginPath();
    circle(x, y, r);
    fill();
    stroke();
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

  dynamic get handle => context;

  HCanvasDC._(this.canvas, this.context) : super( );

  factory HCanvasDC( [CanvasElement? elem] )
  {
    if(elem == null)
     elem = CanvasElement();
    return HCanvasDC._(elem, elem.context2D);
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
    context.translate(0.5, 0.5);
    context.textBaseline = 'top'; 

  }

  @override
  void ellipse(num x, num y, num radiusX, num radiusY, num rotation,
      num startAngle, num endAngle, bool anticlockwise) =>
    context.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise);


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
  void lineTo(num x, num y) =>
    context.lineTo(x, y);

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
    context.moveTo(x, y);

  @override
  void rect(num x, num y, num w, num h) =>
    context.rect(x, y, w, h);

  @override
  HIMAGE? get Image
  {
    var image = context.getImageData(0, 0, context.canvas.width??0, context.canvas.height??0);
    return HIMAGEDATA(image);
  }

  @override
  set Image(HIMAGE? image)
  {
    image!.draw(context, 0, 0);
  }

  @override
  HIMAGE? getImageData(int x, int y, int width, int height)
  {
    var image = context.getImageData(x, y, width, height);

    return HIMAGEDATA(image);
  }

  @override
  void putImageData(int x, int y, HIMAGE image)
  {
    image.draw(context, x, y);
  }


  @override
  void restore() =>
    context.restore();

  @override
  void save() =>
    context.save();

  @override
  void selectFont(num size, String name, int weight, bool italic) =>
    context.font = "${italic? 'italic ': ''}${weight==400? '' : '$weight '}${size}pt \"${name}\"";

  @override
  void stroke() =>
    context.stroke();

  @override
  void strokeRect(num x, num y, num w, num h) =>
    context.strokeRect(x, y, w, h);

  @override
  Object? get strokeStyle =>
      context.strokeStyle;

  @override
  set strokeStyle(Object? value) =>
      context.strokeStyle = value;

  
  String get textBaseline =>
    context.textBaseline;

  set textBaseline(String value) =>
    context.textBaseline = value;

  String get textAlign =>
    context.textAlign;

  set textAlign(String value) =>
    context.textAlign = value;

}