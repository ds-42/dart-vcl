part of vcl;

class HGlyph extends HCustomControl
{
  HGlyph() : super()
  {
    style.width='${Width}px';
    style.height='${Height}px';
  }

  String _imageUrl = '';
  String
    get ImageUrl => _imageUrl;
    set ImageUrl(String Value)
    {
      if(_imageUrl == Value)
        return;
      _imageUrl = Value;
      handle.style.backgroundImage = 'url($ImageUrl)';

    }

  void Update(int index, [int? width, int? height] )
  {
    if(width == null)
      width = _width;
    if(height == null)
      height = _height;
    if(_index == index && _width == width && _height == height)
      return;

    if(_width != width || _height != height)
    {
      _width = width;
      _height = height;
      style.width='${Width}px';
      style.height='${Height}px';
    }

    _index = index;
    style.backgroundPosition = '${Width*Index}px 0px';
  }

  int _index = 0;
  int get Index => _index;

  int _width = 20;
  int get Width => _width;

  int _height = 20;
  int get Height => _height;

}
