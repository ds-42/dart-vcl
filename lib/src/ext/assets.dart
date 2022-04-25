part of vcl;

class TAssetItem
{
  final _items = Map<String, TAsset>();

  String toString()
  {
    var buf = StringBuffer();
    bool sep = false;
    buf.writeCharCode(CHAR.LB);

    _items.forEach((key, value)
    {
      if(sep)
        buf.write(', ');
      buf.write(key);
      if(value.data!=null)
      {
        buf.write(': ');
        buf.write(value.data);
      }
      sep = true;
    });

    buf.writeCharCode(CHAR.RB);
    return buf.toString();
  }

  bool contains(String name) =>
    _items.keys.contains(name);

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  TAsset operator [](String path)
  {
    TAssetItem item = this;
    var data = path.split('/');
    for(var name in data)
    {
      var asset = item._items[name];
      if(asset == null)
      {
        asset = TAsset(null);
        item._items[name] = asset;
      }
      item = asset;
    }
    return item as TAsset;
  }

  void operator []=(String name, dynamic value)
  {
    _items[name] = TAsset(value);
  }
}

class TAsset extends TAssetItem
{
  final dynamic data;

  TAsset(this.data);
}

class TAssets extends TAssetItem
{
}

final TAssets Assets = TAssets();

