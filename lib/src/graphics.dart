part of vcl;

class BITMAP
{
  int        bmType = 0;
  int        bmWidth = 0;
  int        bmHeight = 0;
  int        bmWidthBytes = 0;
  int        bmPlanes = 0;
  int        bmBitsPixel = 0;
  dynamic    bmBits;

  void assign(BITMAP src)
  {
    bmType = src.bmType;
    bmWidth = src.bmWidth;
    bmHeight = src.bmHeight;
    bmWidthBytes = src.bmWidthBytes;
    bmPlanes = src.bmPlanes;
    bmBitsPixel = src.bmBitsPixel;
  }
}

class HBITMAP extends BITMAP
{
  
}

class HPALETTE
{
  
}

class TDIBSection 
{
  final dsBm = BITMAP();


  TDIBSection get copy
  {
    var res = TDIBSection();
    res.dsBm.assign(dsBm);
    return res;
  }
}



enum TFontStyle { Bold, Italic, Underline, StrikeOut }

typedef TFontStyles = Set<TFontStyle>;





class TFontData
{
  int    Alpha = 255;
  TColor Color =clBlack;
  bool   Italic = false;
  double Size = 10;
  String Name = 'Arial';
  bool   Underline = false;
  int    Weight = Windows.FW_NORMAL;
 

  TFontData();

  TFontData.style(this.Size, this.Name, this.Weight, this.Italic, this.Underline, this.Color, this.Alpha);
}



class TPenData
{

  TColor    Color = clBlack;
  double    Width = 1.0;
  TPenStyle Style = psSolid;

  TPenData();

  TPenData.from(TPenData src)
  {
    Color = src.Color;
    Width = src.Width;
    Style = src.Style;
  }

  TPenData.style(this.Color, this.Width, this.Style);
}

enum TBrushStyle { Solid, Clear, Horizontal, Vertical,
                   FDiagonal, BDiagonal, Cross, DiagCross }

class TBrushData
{

  int         Alpha;
  TColor      Color;
  TBrushStyle Style;



  TBrushData() : this.style(clWhite, 255, TBrushStyle.Solid);

  TBrushData.style(this.Color, this.Alpha, this.Style);
}

 

enum TCanvasStates { HandleValid, FontValid, PenValid, BrushValid }

Set<TCanvasStates> csAllValid = {
  TCanvasStates.HandleValid,
  TCanvasStates.FontValid,
  TCanvasStates.PenValid,
  TCanvasStates.BrushValid };




abstract class TGraphicsObject extends TPersistent
{
  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange=Value;



  void Changed()
  {
    if(OnChange != null)
      OnChange!(this);
  }


}

class TFont extends TGraphicsObject
{


  final _fontData = TFontData();

  TFont() : super()
  {

  }

  String toString()
  {
    return '{'
      'name: $Name, '
      'size: $Size, '
      'weight: $Weight, '
      'italic: $Italic, '
      'underline: $Underline'
    '}';
  }


  void Changed()
  {
    super.Changed();

  }

  void Assign(TPersistent Source)
  {
    if(Source is TFont)
    {
      Alpha     = Source.Alpha;
      Color     = Source.Color;
      Italic    = Source.Italic;
      Name      = Source.Name;
      Size      = Source.Size;
      Underline = Source.Underline;
      Weight    = Source.Weight;


      return;
    }
    super.Assign(Source);
  }



  int
    get Alpha => _fontData.Alpha;
    set Alpha(int Value)
    {
      if(Alpha == Value)
        return;
      _fontData.Alpha = Value;
      Changed();
    }

  TColor
    get Color => _fontData.Color;
    set Color(TColor Value)
    {
      if(Color == Value)
        return;
      _fontData.Color = Value;
      Changed();
    }

  String
    get Name => _fontData.Name;
    set Name(String Value)
    {
      if(Name == Value)
        return;
      _fontData.Name = Value;
      Changed();
    }

  double
    get Size => _fontData.Size;
    set Size(double Value)
    {
      if(Size == Value)
        return;
      _fontData.Size = Value;
      Changed();
    }

  int
    get Weight => _fontData.Weight;
    set Weight(int Value)
    {
      if(Weight == Value)
        return;
      _fontData.Weight = Value;
      Changed();
    }

  bool
    get Bold => Weight>=Windows.FW_BOLD;
    set Bold(bool Value) => Weight = Value? Windows.FW_BOLD : Windows.FW_NORMAL;

  bool
    get Italic => _fontData.Italic;
    set Italic(bool Value)
    {
      if(Italic == Value)
        return;
      _fontData.Italic = Value;
      Changed();
    }

  bool
    get Underline => _fontData.Underline;
    set Underline(bool Value)
    {
      if(Underline == Value)
        return;
      _fontData.Underline = Value;
      Changed();
    }

  TFontStyles get Style
  {
    TFontStyles style = TFontStyles();
    if(Bold)
      style<<TFontStyle.Bold;
    if(Italic)
      style<<TFontStyle.Italic;
    if(Underline)
      style<<TFontStyle.Underline;
    return style;
  }

  void set Style(TFontStyles Value)
  {
    Bold = Value.contains(TFontStyle.Bold);

  }


}


class TPen extends TGraphicsObject
{


  final _penData = TPenData();

  TPenData save() => TPenData.from(_penData);

  void restore(TPenData data)
  {
    Color = data.Color;
    Width = data.Width;
    Style = data.Style;
  }



  TColor
    get Color => _penData.Color;

    set Color(TColor Value)
    {
      if(_penData.Color == Value)
        return;
      _penData.Color = Value;
      Changed();
    }



  TPenStyle get Style => _penData.Style;

  void set Style(TPenStyle Value)
  {
    if(_penData.Style == Value)
      return;
    _penData.Style = Value;
    Changed();
  }

  double get Width => _penData.Width;
  void set Width(double Value)
  {
    if(Value<=0 || _penData.Width==Value)
      return;
    _penData.Width = Value;
    Changed();
  }
}
 

class TBrush extends TGraphicsObject
{


  final _brushData = TBrushData();


  int
    get Alpha => _brushData.Alpha;
    set Alpha(int Value)
    {
      if(_brushData.Alpha==Value)
        return;
      _brushData.Alpha=Value;
      Changed();
    }

  TColor
    get Color => _brushData.Color;
    set Color(TColor Value)
    {
      if(_brushData.Color==Value)
        return;
      _brushData.Color=Value;
      Changed();
    }



  TBrushStyle
    get Style => _brushData.Style;
    set Style(TBrushStyle Value)
    {
      if(_brushData.Style==Value)
        return;
      _brushData.Style=Value;
      if(_brushData.Style == TBrushStyle.Clear)
        _brushData.Color = clWhite;
      Changed();
    }


}





class TCanvas extends TPersistent
{


  int _lockCount = 0;
  int get LockCount => _lockCount;

  final _pen = TPen();
  TPen get Pen => _pen;
  

  final _brush = TBrush();
  TBrush get Brush => _brush;
  

  final _font = TFont();
  TFont
    get Font => _font;
    set Font(TFont Value) => _font.Assign(Value);

  final State = Set<TCanvasStates>();

  HDC? _handle;
  HDC
    get Handle => GetHandle();
    set Handle(HDC? Value) => SetHandle(Value);

  TCanvas() : super()
  {

    _font.OnChange = (Sender)
    {
      if(State.contains(TCanvasStates.FontValid))
      {
        State.remove(TCanvasStates.FontValid);

      }
    };

    _pen.OnChange = (Sender)
    {
      if(State.contains(TCanvasStates.PenValid))
      {
        State.remove(TCanvasStates.PenValid);

      }
    };

    _brush.OnChange = (Sender)
    {
      if(State.contains(TCanvasStates.BrushValid))
      {
        State.remove(TCanvasStates.BrushValid);

      }
    };

  }

  void Init()
  {
    _handle!.init();
  }



  void Draw(int X, int Y, TGraphic Graphic)
  {
    if(/*(Graphic != null) &&*/ !Graphic.Empty)
    {
      Changing();
      RequiredState( { TCanvasStates.HandleValid } );

      Graphic.Draw(this, TRect(X, Y, X + Graphic.Width, Y + Graphic.Height));
      Changed();
    }
  }



  void FillRectangle(int X1, int Y1, int X2, int Y2)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.BrushValid } );
    _handle!.fillRect(X1-0.5, Y1-0.5, X2-X1, Y2-Y1);
    Changed();
  }

  void FillRect(TRect Rect)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.BrushValid } );
    _handle!.fillRect(Rect.left-0.5, Rect.top-0.5, Rect.width, Rect.height);
    Changed();
  }



  bool HandleAllocated() {
    return _handle != null;
  }

  void Line(num X1, num Y1, num X2, num Y2)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid } );
    _handle!
      ..beginPath()
      ..moveTo(X1, Y1)
      ..lineTo(X2, Y2)
      ..stroke();
    Changed();
  }

  void LineTo(num X, num Y)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid } );
    _handle!
      ..beginPath()
      ..lineTo(X, Y)
      ..stroke();
    Changed();
  }

  void Lock()
  {

    _lockCount++;

  }

  void MoveTo(int X, int Y)
  {
    RequiredState( { TCanvasStates.HandleValid } );
    _handle!.moveTo(X, Y);
  }



  void Polygon1(List<TPoint> pts)
  {
    if(pts.isEmpty)
      return;

    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid, TCanvasStates.BrushValid } );
    _handle!.beginPath();
    for(var pt in pts)
    {
      if(pt==pts.first)
        _handle!.moveTo(pt.x, pt.y);
      else
        _handle!.lineTo(pt.x, pt.y);
    }
    _handle!.lineTo(pts.first.x, pts.first.y);
    if(Brush.Style == TBrushStyle.Solid)
      _handle!.fill();
    _handle!.stroke();
    Changed();
  }

  void polyline(num X, num Y, List<num> pts, [bool lock=false] )
  {
    if(pts.isEmpty)
      return;

    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid, TCanvasStates.BrushValid } );

    
    _handle!.beginPath();

    bool first = true;
    num? x;
    for(var y in pts)
    {
      if(x==null)
        x = y;
      else
      {
        if(first)
        {
          _handle!.moveTo(X+x, Y+y);
          first = false;
        }
        else
          _handle!.lineTo(X+x, Y+y);

        x = null;
      }
    }
    if(lock)
    {
      _handle!.lineTo(X+pts[0], Y+pts[1]);
      if(Brush.Style == TBrushStyle.Solid)
        _handle!.fill();
    }
    _handle!.stroke();
    Changed();
  }

  void Polyline(List<TPoint> pts)
  {
    if(pts.isEmpty)
      return;

    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid/*, TCanvasStates.BrushValid*/ } );
    _handle!.beginPath();
    for(var pt in pts)
    {
      if(pt==pts.first)
        _handle!.moveTo(pt.x, pt.y);
      else
        _handle!.lineTo(pt.x, pt.y);
    }
    _handle!.stroke();
    Changed();
  }

  

  void StrokeRectangle(int X1, int Y1, int X2, int Y2)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid } );
    _handle!
      ..beginPath()
      ..rect(X1, Y1, X2-X1, Y2-Y1)
      ..stroke();
    Changed();
  }

  void Rectangle(int X1, int Y1, int X2, int Y2)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.BrushValid, TCanvasStates.PenValid } );
    _handle!
      ..beginPath()
      ..rect(X1, Y1, X2-X1, Y2-Y1)
      ..fill()
      ..stroke();
    Changed();
  }





  void RoundRect(num X1, num Y1, num X2, num Y2, num X3, num Y3)
  {
    Changing();


    Changed();
  }



  void StrokeText(int X, int Y, String Text)
  {
    Changing();
    
    
    _handle!.fillText(X, Y, Text);
    Changed();
  }

  void TextOut(int X, int Y, String Text)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.FontValid} );

    _handle!.fillText(X, Y, Text);
    Changed();
  }



  TSize TextExtent(String text) => TSize(TextWidth(text), TextHeight(text));

  int TextWidth(String text) => TextWidthR8(text).round();

  num TextWidthR8(String text)
  {
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.FontValid } );
    var m = _handle!.measureText(text);
    if(m == null)
      return 0;
    return m.width ?? 0;
  }

  int TextHeight(String text) => TextHeightR8(text).round();

  double TextHeightR8(String text)
  {
    return FontMetric.calc_height(Font.Name, Font.Size, Font.Weight, Font.Italic);
  }



  void Unlock()
  {

    _lockCount--;

  }



  HDC GetHandle()
  {
    Changing();
    RequiredState(csAllValid);
    if(_handle==null)
      throw UnsupportedError('Handle create error');
    return _handle!;
  }



  void CreateHandle()
  {

  }

  SetHandle(HDC? Value)
  {
    if(_handle == Value)
      return;
    if(_handle !=null)
    {

      _handle = null;
      State.remove(TCanvasStates.HandleValid);
    }
    if(Value != null)
    {
      State.add(TCanvasStates.HandleValid);
      _handle = Value;

    }
  }

  void RequiredState(Set<TCanvasStates> ReqState)
  {
    Set<TCanvasStates> NeededState = ReqState.difference(State);
    if(NeededState.isNotEmpty)
    {
      if(NeededState.contains(TCanvasStates.HandleValid))
      {
        CreateHandle();
        if(_handle == null)
          throw EInvalidOperation.CreateRes(Consts.SNoCanvasHandle);
      }
      if(NeededState.contains(TCanvasStates.FontValid))
        CreateFont();
      if(NeededState.contains(TCanvasStates.PenValid))
        CreatePen();
      if(NeededState.contains(TCanvasStates.BrushValid))
        CreateBrush();
      State.addAll(NeededState);
    }
  }

  void Changing()
  {

  }

  void Changed()
  {

  }

  void CreateFont()
  {
    if(Brush.Color!=Font.Color || Brush.Alpha!=Font.Alpha)
      Brush.Changed();

    _handle!.selectFont(Font.Size, Font.Name, Font.Weight, Font.Italic);
    _handle!.fillColor = Font.Color;
    if(Font.Alpha!=255)
      _handle!.fillStyle = Font.Color.alpha_s(Font.Alpha);
    else
      _handle!.fillColor = Font.Color;


  }

  void CreatePen()

  {
    _handle!.strokeColor = Pen.Color;
    _handle!.lineWidth = Pen.Width;

  }

  void CreateBrush()
  {
    if(Font.Color!=Brush.Color || Font.Alpha!=Brush.Alpha)
      Font.Changed();

    if(Brush.Alpha!=255)
      _handle!.fillStyle = Brush.Color.alpha_s(Brush.Alpha);
    else
      _handle!.fillColor = Brush.Color;


  }

}


abstract class TGraphic extends TInterfacedPersistent 
{


  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;

  void Draw(TCanvas ACanvas, TRect Rect);

  bool get Empty => GetEmpty();
  bool GetEmpty();

  int get Height => GetHeight();
  int GetHeight();

  set Height(int Value) => SetHeight(Value);
  void SetHeight(int Value);


  int get Width => GetWidth();
  int GetWidth();

  set Width(int Value) => SetWidth(Value);
  void SetWidth(int Value);

  void Changed(TObject Sender)
  {
    _modified = true;
    if(OnChange!=null)
      OnChange!(this);
  }



  bool _modified = false;
  bool
    get Modified => _modified;
    set Modified(bool Value)
    {
      if(Value)
        Changed(this);
      else
        _modified = false;
    }


}


/// TBitmapCanvas
/// Create a canvas that gets its DC from the memory DC cache

class TBitmapCanvas extends TCanvas
{


  final TBitmap Bitmap;

  TBitmapCanvas(this.Bitmap) : super();



  void FreeContext()
  {

  }

  void CreateHandle()
  {
    Lock();
    try
    {
      Bitmap.HandleNeeded();

      HDC H = CreateCompatibleDC(null);

      Handle = H;
      UpdateSize();

    }
    finally
    {
      Unlock();
    }
  }

  void UpdateSize()
  {

    if(_handle is HCanvasDC)
    {
      HCanvasDC dc = _handle as HCanvasDC;
      dc.canvas.width = Bitmap.Width;
      dc.canvas.height = Bitmap.Height;
      dc.init();

    }
  }

}


abstract class TSharedImage
{
  int _refCount = 0;
  int get RefCount => _refCount;

  void FreeHandle();

  void Reference()
  {
    _refCount++;
  }

  void Release()
  {
    _refCount--;
    if(RefCount == 0)
    {
      FreeHandle();

    }
  }
}

class TBitmapImage extends TSharedImage
{
  HBITMAP? _handle;     // DDB or DIB handle, used for drawing

  HPALETTE? _palette;
  TDIBSection _DIB = TDIBSection();
  HBITMAP? _DIBHandle; // DIB handle corresponding to TDIBSection
  TMemoryStream? _saveStream; // Save original RLE stream until image is modified**/
  bool _OS2Format = false;  // Write BMP file header, color table in OS/2 format




  void FreeHandle()
  {

  }

}

/// TBitmap


HBITMAP CopyBitmap(HBITMAP? Handle, HPALETTE? OldPalette, HPALETTE? NewPalette,
  TDIBSection DIB, TCanvas? Canvas)
{
  return HBITMAP(); // заглушка

}



class TBitmap extends TGraphic
{


  TBitmapImage _image = TBitmapImage();

  TBitmap() : super()
  {

    _image.Reference();

  }



  void CopyImage(HBITMAP? AHandle, HPALETTE? APalette, TDIBSection DIB)
  {
    FreeContext();
    try
    {
      HPALETTE? NewPalette;

      HBITMAP NewHandle = CopyBitmap(AHandle, APalette, NewPalette, DIB, _canvas);
      NewImage(NewHandle, NewPalette, DIB, _image._OS2Format);
    }
    catch(e)
    {
      
    }
  }

  // Called by the FCanvas whenever an operation is going to be performed on the
  //  bitmap that would modify it.  Since modifications should only affect this
  //  TBitmap, the handle needs to be 'cloned' if it is being refered to by more
  //  than one TBitmap
  void Changing(TObject Sender)
  {

  }

  void Changed(TObject Sender)
  {

    super.Changed(Sender);
  }



  void Draw(TCanvas ACanvas, TRect Rect)
  {
    ACanvas.Handle.drawImage(Rect.left, Rect.top, Canvas.Handle);

  }



  bool GetEmpty()
  {
    return (_image._handle == null) && (_image._DIBHandle == null);
  }

  TCanvas? _canvas;
  TCanvas get Canvas => GetCanvas();

  TCanvas GetCanvas()
  {
    if(_canvas == null)
    {
      HandleNeeded();
      if(_canvas == null)    // possible recursion
      {
        _canvas = TBitmapCanvas(this);

      }
    }
    return _canvas!;
  }

  dynamic 
    get Handle => GetHandle();
    set Handle(dynamic Value) => SetHandle(Value);

  // Since the user might modify the contents of the HBITMAP it must not be
  //  shared by another TBitmap when given to the user nor should it be selected
  //  into a DC.
  dynamic GetHandle()
  {
    FreeContext();
    HandleNeeded();
    Changing(this);
    return _image._handle;
  }



  int GetHeight()
  {
    return _image._DIB.dsBm.bmHeight.abs();
  }



  int GetWidth()
  {
    return _image._DIB.dsBm.bmWidth;
  }



  void FreeContext()
  {
    if(_canvas != null)
      (_canvas as TBitmapCanvas).FreeContext();
  }

  void HandleNeeded()
  {


    if(_image._handle == null)
      _image._handle = _image._DIBHandle;
  }



  void NewImage(HBITMAP NewHandle, HPALETTE? NewPalette, TDIBSection NewDIB, bool OS2Format, [TStream? RLEStream] )
  {
    var Image = TBitmapImage();
    try
    {
      Image._handle = NewHandle;
      Image._palette = NewPalette;
      Image._DIB = NewDIB.copy;
      Image._OS2Format = OS2Format;
      if(Image._DIB.dsBm.bmBits != null)
        Image._DIBHandle = Image._handle;
      Image._saveStream = RLEStream as TMemoryStream?;
    }
    catch(e)
    {

      throw e;
    }

    try
    {
      _image.Release();
      _image = Image;
      _image.Reference();
    }
    finally
    {

    }
    
  }



  void SetHandle(dynamic Value) 
  {

  }



  void SetHeight(int Value)
  {
      if(_image._DIB.dsBm.bmHeight == Value)
        return;
      HandleNeeded();
      TDIBSection DIB = _image._DIB.copy;
      DIB.dsBm.bmHeight = Value;
      (Canvas as TBitmapCanvas).UpdateSize(); // new

      CopyImage(_image._handle, _image._palette, DIB);
      Changed(this);
  }



  void SetWidth(int Value)
  {
    if(_image._DIB.dsBm.bmWidth == Value)
      return;
    HandleNeeded();
    TDIBSection DIB = _image._DIB.copy;
    DIB.dsBm.bmWidth = Value;
    (Canvas as TBitmapCanvas).UpdateSize(); // new

    CopyImage(_image._handle, _image._palette, DIB);
    Changed(this);
  }



}
