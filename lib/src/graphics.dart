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

  TDIBSection()
  {

  }

  TDIBSection.from(TDIBSection source)
  {
    dsBm.assign(source.dsBm);
  }
}

abstract class TResData
{
  HGDIOBJ? _handle;

  final TGraphicsObject Owner;

  TResData(this.Owner);

  void Invalidate()
  {
    _handle = null;
    Owner.Changed();
  }

  HGDIOBJ get Handle
  {
    if(_handle == null)
      _handle = CreateHandle();
    return _handle!;
  }

  void Assign(TResData Source);

  HGDIOBJ CreateHandle();

  void SelectHandle(HGDIOBJ obj);

}

enum TFontStyle { Bold, Italic, Underline, StrikeOut }

typedef TFontStyles = Set<TFontStyle>;

class TFontData extends TResData
{
  TColor Color = clBlack;
  bool   Italic = false;
  double Size = 10;
  String Name = 'Arial';
  bool   Underline = false;
  int    Weight = Windows.FW_NORMAL;


  TFontData(TGraphicsObject Owner) : super(Owner);

  void SelectHandle(HGDIOBJ obj)
  {
    if(obj is !HFONT)
      return;

    bool upd = false;

    if(Color     != obj.color)     { upd = true; Color = obj.color; }
    if(Italic    != obj.italic)    { upd = true; Italic = obj.italic; }
    if(Size      != obj.size)      { upd = true; Size = obj.size; }
    if(Name      != obj.name)      { upd = true; Name = obj.name; }
    if(Underline != obj.underline) { upd = true; Underline = obj.underline; }
    if(Weight    != obj.weight)    { upd = true; Weight = obj.weight; }

    if(upd)
      Invalidate();
  }

  HGDIOBJ CreateHandle()
  {
    return HFONT(Size, Name, Weight, Italic, Underline, Color);
  }

  void Assign(TResData Source)
  {
    if(Source is TPenData)
      SelectHandle(Source.Handle);
  }

}


class TPenData extends TResData
{
  TColor Color = clBlack;
  double Width = 1;
  TPenStyle Style = TPenStyle.Solid;

  TPenData(TGraphicsObject Owner) : super(Owner);

  void SelectHandle(HGDIOBJ obj)
  {
    if(obj is !HPEN)
      return;

    bool upd = false;

    if(Color != obj.color) { upd = true; Color = obj.color; }
    if(Width != obj.width) { upd = true; Width = obj.width; }
    if(Style != obj.style) { upd = true; Style = obj.style; }

    if(upd)
      Invalidate();
  }

  HGDIOBJ CreateHandle()
  {
    return HPEN(Color, Width, Style);
  }

  void Assign(TResData Source)
  {
    if(Source is TPenData)
      SelectHandle(Source.Handle);
  }

}

enum TLineCap { Round, Square, Flat }

enum TLineJoin { Round, Bevel, Miter }

class TBrushData extends TResData
{
  TColor Color = clWhite;

  TBrushStyle Style = TBrushStyle.Solid;

  TBrushData(TGraphicsObject Owner) : super(Owner);

  void SelectHandle(HGDIOBJ obj)
  {
    if(obj is !HBRUSH)
      return;

    bool upd = false;

    if(Color != obj.color) { upd = true; Color = obj.color; }
    if(Style != obj.style) { upd = true; Style = obj.style; }

    if(upd)
      Invalidate();
  }

  HGDIOBJ CreateHandle()
  {
    return HBRUSH(Color, Style);
  }

  void Assign(TResData Source)
  {
    if(Source is TBrushData)
      SelectHandle(Source.Handle);
  }

}



enum TCanvasStates { HandleValid, FontValid, PenValid, BrushValid }

Set<TCanvasStates> csAllValid = {
  TCanvasStates.HandleValid,
  TCanvasStates.FontValid,
  TCanvasStates.PenValid,
  TCanvasStates.BrushValid };

typedef TCanvasState = Set<TCanvasStates>;



abstract class TGraphicsObject<T extends TResData> extends TPersistent
{
  late T _resource;

  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;

  void Assign(TPersistent Source)
  {
    if(Source is TGraphicsObject)
      _resource.SelectHandle(Source.Handle);
    else
      super.Assign(Source);
  }

  void Changed()
  {
    if(_onChange != null)
      _onChange!(this);
  }

  bool HandleAllocated()
  {
    return _resource._handle != null;
  }

  HGDIOBJ get Handle
  {
    return _resource.Handle;
  }

  void set Handle(HGDIOBJ Value)
  {
    _resource.SelectHandle(Value);
  }

}

class TFont extends TGraphicsObject<TFontData>
{
  String toString()
  {
    return
      'TFont({'
        'name: $Name, '
        'size: $Size, '
        'weight: $Weight, '
        'italic: $Italic, '
        'underline: $Underline'
        ')';
  }



  TFont() : super()
  {
    _resource = TFontData(this);

  }

  TColor
    get Color => _resource.Color;
    set Color(TColor Value)
    {
      if(_resource.Color == Value)
        return;
      _resource.Color = Value;
      _resource.Invalidate();
    }



  String
    get Name => _resource.Name;
    set Name(String Value)
    {
      if(_resource.Name == Value)
        return;
      _resource.Name = Value;
      _resource.Invalidate();
    }

  double
    get Size => _resource.Size; 
    set Size(double Value)
    {
      if(_resource.Size == Value)
        return;
      _resource.Size = Value; 
      _resource.Invalidate();
    }

  int
    get Weight => _resource.Weight;
    set Weight(int Value)
    {
      if(_resource.Weight == Value)
        return;
      _resource.Weight = Value;
      _resource.Invalidate();
    }

  bool
    get Bold => Weight>=Windows.FW_BOLD;
    set Bold(bool Value) => Weight = Value? Windows.FW_BOLD : Windows.FW_NORMAL;

  bool
    get Italic => _resource.Italic;
    set Italic(bool Value)
    {
      if(_resource.Italic == Value)
        return;
      _resource.Italic = Value;
      _resource.Invalidate();
    }

  bool
    get Underline => _resource.Underline;
    set Underline(bool Value)
    {
      if(_resource.Underline == Value)
        return;
      _resource.Underline = Value;
      _resource.Invalidate();
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
    _resource.SelectHandle(HFONT(
        Size,
        Name,
        Value.contains(TFontStyle.Bold)? Windows.FW_BOLD : Windows.FW_NORMAL,
        Value.contains(TFontStyle.Italic),
        Value.contains(TFontStyle.Underline),
        Color ));
  }


}

class TPen extends TGraphicsObject<TPenData>
{


  TPen() : super()
  {
    _resource = TPenData(this);

  }

  TColor
    get Color => _resource.Color;
    set Color(TColor Value)
    {
      if(_resource.Color == Value)
        return;
      _resource.Color = Value;
      _resource.Invalidate();
    }



  TPenStyle
    get Style => _resource.Style;
    set Style(TPenStyle Value)
    {
      if(_resource.Style == Value)
        return;
      _resource.Style = Value;
      _resource.Invalidate();
    }

  double
    get Width => _resource.Width;
    set Width(double Value)
    {
      if(Value < 0)
        return;

      if(_resource.Width == Width)
        return;
      _resource.Width = Value;
      _resource.Invalidate();
    }
}


class TBrush extends TGraphicsObject<TBrushData>
{
  TBrush()
  {
    _resource = TBrushData(this);
  }

  TColor
    get Color => _resource.Color;
    set Color(TColor Value)
    {
      if(_resource.Color == Value)
        return;
      _resource.Color = Value;
      _resource.Invalidate();
    }

  TBrushStyle
    get Style => _resource.Style;
    set Style(TBrushStyle Value)
    {
      if(_resource.Style == Value)
        return;
      _resource.Style = Value;
      _resource.Invalidate();
    }

}



class TCanvas extends TPersistent
{
  HDC? _handle;
  HDC
    get Handle => GetHandle();
    set Handle(HDC? Value) => SetHandle(Value);

  final State = Set<TCanvasStates>();

  final _font = TFont();
  TFont
    get Font => _font;
    set Font(TFont Value) => _font.Assign(Value);

  final _pen = TPen();
  TPen
    get Pen => _pen;
    set Pen(TPen Value) => _pen.Assign(Value);

  final _brush = TBrush();
  TBrush
    get Brush => _brush;
    set Brush(TBrush Value) => _brush.Assign(Value);

  int _textFlags = 0;
  int
    get TextFlags => _textFlags;
    set TextFlags(int Value) => _textFlags = Value;

  int _lockCount = 0;
  int get LockCount => _lockCount;

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

  void FillRectangle(num X1, num Y1, num X2, num Y2) // new
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.BrushValid } );
    Windows.FillRectEx(_handle!, X1, Y1, X2, Y2, Brush.Handle as HBRUSH);
    Changed();
  }

  void FillRect(TRect Rect)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.BrushValid } );
    Windows.FillRect(_handle!, Rect, Brush.Handle as HBRUSH);
    Changed();
  }



  bool HandleAllocated()
  {
    return _handle != null;
  }


  void LineTo(num X, num Y)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid/*, TCanvasStates.BrushValid*/ } );
    Windows.LineTo(_handle!, X, Y);
    Changed();
  }

  void Lock()
  { 
    _lockCount++;
    
  }

  void MoveTo(int X, int Y)
  {
    RequiredState( { TCanvasStates.HandleValid } );
    Windows.MoveToEx(_handle!, X, Y, null);
  }

  void PolylineEx(num X, num Y, List<num> pts, [bool lock=false] ) // new
  {
    if(pts.isEmpty)
      return;

    Changing();

    if(lock)
      RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid, TCanvasStates.BrushValid } );
    else
      RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid } );

    Windows.PolylineEx(_handle!, X, Y, pts, lock);
    Changed();
  }

  void Polyline(List<TPoint> pts)
  {
    if(pts.isEmpty)
      return;

    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.PenValid} );
    Windows.Polyline(_handle!, pts, pts.length);
    Changed();
  }

  void Rectangle(int X1, int Y1, int X2, int Y2)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.BrushValid, TCanvasStates.PenValid } );
    Windows.Rectangle(_handle!, X1, Y1, X2, Y2);
    Changed();
  }

  void RoundRect(num X1, num Y1, num X2, num Y2, num X3, num Y3)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.BrushValid, TCanvasStates.PenValid } );
    Windows.RoundRect(_handle!, X1, Y1, X2, Y2, X3, Y3);
    Changed();
  }

  void TextOut(int X, int Y, String Text)
  {
    Changing();
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.FontValid} );

    Windows.ExtTextOut(_handle!, X, Y, _textFlags, null, Text, Text.length, null);
    MoveTo(X + TextWidth(Text), Y);
    Changed();
  }

  TSize TextExtent(String Text)
  {
    RequiredState( { TCanvasStates.HandleValid, TCanvasStates.FontValid } );
    var Result = TSize();
    Windows.GetTextExtentPoint32(_handle!, Text, Text.length, Result);
    return Result;
  }

  int TextWidth(String Text)
  {
    return TextExtent(Text).cx;
  }

  int TextHeight(String Text)
  {
    return TextExtent(Text).cy;
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

    if(_handle != null)
    { 
      _handle = null;
      State >> TCanvasStates.HandleValid;
    }
    if(Value != null)
    {
      State << TCanvasStates.HandleValid;
      _handle = Value;

    }
  }

  void RequiredState(TCanvasState ReqState)
  {
    TCanvasState NeededState = ReqState - State;
    if(NeededState.isNotEmpty)
    {
      if(NeededState.contains(TCanvasStates.HandleValid))
      {
        CreateHandle();
        if(_handle == null)
          throw EInvalidOperation.CreateRes(Consts.SNoCanvasHandle);
      }
      if(NeededState.contains(TCanvasStates.FontValid))
        _createFont();
      if(NeededState.contains(TCanvasStates.PenValid))
        _createPen();
      if(NeededState.contains(TCanvasStates.BrushValid))
        _createBrush();
      State.addAll(NeededState);
    }
  }

  void Changing()
  { 
  }

  void Changed()
  { 
  }

  void _createFont()
  {
    Windows.SelectObject(_handle!, Font.Handle);

  }

  void _createPen()
  { 
    Windows.SelectObject(_handle!, Pen.Handle);

  }

  void _createBrush()
  { 
    Windows.SelectObject(_handle!, Brush.Handle);

  }

}

abstract class TGraphic extends TInterfacedPersistent
{
  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? Value) => _onChange = Value;

  void Changed(TObject Sender)
  {
    _modified = true;
    if(OnChange!=null)
      OnChange!(this);
  }

  void Draw(TCanvas ACanvas, TRect Rect);

  bool get Empty => GetEmpty();
  bool GetEmpty();

  int get Height => GetHeight();
  int GetHeight();

  set Height(int Value) => SetHeight(Value);
  void SetHeight(int Value);

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

  int get Width => GetWidth();
  int GetWidth();

  set Width(int Value) => SetWidth(Value);
  void SetWidth(int Value);

}

// TBitmapCanvas
// Create a canvas that gets its DC from the memory DC cache
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
      (_handle as HCanvasDC).resize(Bitmap.Width, Bitmap.Height);
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

HBITMAP CopyBitmap(HBITMAP? Handle, HPALETTE? OldPalette, HPALETTE? NewPalette,
    TDIBSection DIB, TCanvas? Canvas)
{
  return HBITMAP(); // dummy

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
  // bitmap that would modify it.  Since modifications should only affect this
  // TBitmap, the handle needs to be 'cloned' if it is being refered to by more
  // than one TBitmap
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
      Image._DIB = TDIBSection.from(NewDIB);
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
    var DIB = TDIBSection.from(_image._DIB);
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
    var DIB = TDIBSection.from(_image._DIB);
    DIB.dsBm.bmWidth = Value;
    (Canvas as TBitmapCanvas).UpdateSize(); // new

    CopyImage(_image._handle, _image._palette, DIB);
    Changed(this);
  }

}
