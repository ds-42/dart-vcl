part of vcl;

enum TMetricUnit { Pixel, Percent, }

class TMetric
{
  final num Value;
  final TMetricUnit  Unit;

  TMetric(this.Value, [this.Unit = TMetricUnit.Pixel] );

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
