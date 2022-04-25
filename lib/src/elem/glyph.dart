part of vcl;

class TImageInfo
{
  final int width;
  final int height;

  TImageInfo(this.width, this.height);

  TImageInfo.from(TImageInfo src) : this(src.width, src.height);

  TImageInfo.empty() : this(0, 0);
}

class HGlyphElement extends HElement
{
  static final cid_glyph = CLASS_ID('glyph');
  CLASS_ID get tagId => cid_glyph;

  void defineRule(TElementStyle rule)
  {
    rule.add('',
      'background-repeat:no-repeat;'
      'display:inline-block');
  }

  TImageInfo _info = TImageInfo.empty();
  TImageInfo get info => _info;

  bool _isReady = true;
  bool get isReady => isReady;

  HGlyphElement();

  void assign(HElement elem)
  {
    if(elem is !HGlyphElement)
      return;

    _info = TImageInfo.from(elem._info);
    _glyphNum = elem._glyphNum;
    _numGlyphs = SIZE.from(elem._numGlyphs);
    if(elem._isReady)
    {
      _isReady = true;
      style.backgroundImage = elem.style.backgroundImage;
      _update();
    }
    else
      src = elem.src;
  }

  String
    get src => handle.style.backgroundImage.replaceAll('url("','').replaceAll('")','');
    set src(String val)
    {
      _isReady = false;
      style.backgroundImage = "url('$val')";

      var img = ImageElement();
      img.src = val;
      img.onLoad.listen((event)
      {
        _info = TImageInfo(img.width ?? 0, img.height ?? 0);
        _isReady = true;
        _update(); 
      });

      img.onError.listen((event)
      {
        _info = TImageInfo(0, 0);
        _isReady = true; 
      });
    }

  int _glyphNum = 0;
  int
    get glyphNum => _glyphNum;
    set glyphNum(int val)
    {
      if(val<0 || val==_glyphNum)
        return;
      _glyphNum = val;
      _update();
    }

  SIZE _numGlyphs = SIZE(1, 1);
  SIZE
    get numGlyphs =>SIZE(_numGlyphs.cx==0? 1 : _numGlyphs.cx, _numGlyphs.cy);
    set numGlyphs(SIZE val)
    {
      if(val.cx == 0)
      {
        _numGlyphs.cx = 0; // auto detect glyph count;
        _update();
        return;
      }

      int cx = val.cx<1? 1 : val.cx;
      int cy = val.cy<1? 1 : val.cy;
      if(cx==_numGlyphs.cx && cy==_numGlyphs.cy)
        return;
      _numGlyphs.cx = cx;
      _numGlyphs.cy = cy;
      _update();
    }

  void _update()
  {
    if(_isReady==false)
      return;

    if(_numGlyphs.cx==0)
    { // auto detect glyph count;
      if(info.height!=0)
      {
        int k = info.width ~/ info.height;
        if(k * info.height == info.width)
        {
          _numGlyphs.cx = k;
          _numGlyphs.cy = 1;
        }
      }

      if(_numGlyphs.cx == 0)
      {
        _numGlyphs.cx=1;
        _numGlyphs.cy=1;
      }
    }

    int width  = info.width ~/ _numGlyphs.cx;
    int height = info.height ~/ _numGlyphs.cy;
    int ny = glyphNum ~/ _numGlyphs.cx;
    int nx = glyphNum - ny * _numGlyphs.cx;

    style
      ..width = '${width}px'
      ..height = '${height}px'
      ..backgroundPosition = (nx>0||ny>0)? '${-width*nx}px ${-height*ny}px' : null;
  }
}