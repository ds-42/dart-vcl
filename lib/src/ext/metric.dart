part of vcl;

enum TMetricUnit { Pixel, Percent, }

class TMetric
{
  final num Value;
  final TMetricUnit  Unit;

  TMetric(this.Value, [this.Unit = TMetricUnit.Pixel] );

  static TMetric? tryParse(String data)
  {
    TMetric? parse(String val, TMetricUnit unit)
    {
      int? v = int.tryParse(val);
      if(v==null)
        return null;
      return TMetric(v, unit);
    }

    var list;
    list = data.split('px');
    if(list.length==2 && list[1].isEmpty)
      return parse(list[0], TMetricUnit.Pixel);

    list = data.split('%');
    if(list.length==2 && list[1].isEmpty)
      return parse(list[0], TMetricUnit.Percent);

    return parse(data, TMetricUnit.Pixel);
  }

  String toString()
  {
    String unit = '';
    switch(Unit)
    {
      case TMetricUnit.Pixel: unit = 'px'; break;
      case TMetricUnit.Percent: unit = '%'; break;
      default: break;
    }
    return '$Value$unit';
  }

  int toPixel(num basis)
  {
    switch(Unit)
    {
      case TMetricUnit.Pixel:
        return Value.truncate();

      case TMetricUnit.Percent:
        return basis * Value ~/ 100;

      default:
        return 0;
    }
  }
}
