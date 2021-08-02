part of vcl;

enum TMetricUnit { Pixel, Percent, }

class TMetric
{
  final num Value;
  final TMetricUnit  Unit;

  TMetric(this.Value, this.Unit);

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
