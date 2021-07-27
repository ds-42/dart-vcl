part of vcl;

class Period
{
  final int  ds;  // days count
  final int  ms;  // months count
  final int  ys;  // years count
  final bool neg; // negative state

  Period._(this.ys, this.ms, this.ds, this.neg);

  Period.zero() : this._(0, 0, 0, false);

  factory Period(int ys, [int ms = 0, int ds = 0, bool neg = false])
  {
    int days = ys*360 + ms*30 + ds;
    return Period.days(neg? -days : days);
  }

  factory Period.days(int val)
  {
    if(val == 0)
      return Period.zero();

    bool neg = false;
    if(val<0)
    {
      neg = true;
      val = -val;
    }

    int ms = val ~/ 30;

    return Period._(ms ~/ 12, ms % 12, val % 30, neg);
  }

  factory Period.dbl(double p) // format: yyyy.mmdd
  {
    bool neg = false;

    int v = (p*10000).round();
    if(v<0)
    {
      neg = true;
      v = -v;
    }
    int ys = v ~/ 10000;
    v %= 10000;
    return Period(ys, v ~/ 100, v % 100, neg);
  }

  factory Period.now()
  {
    var date = DateTime.now();
    return Period(date.year, date.month, date.day);
  }

  factory Period.sysDate(int date)
  {
    if(date == 0)
      return Period.zero();

    Date d = Date.days(date<0? -date : date);
    return Period(d.year, d.month, d.day, date<0);
  }

  Period get inv => Period._(ys, ms, ds, !neg);

  static Period difDays(int start, int end) =>
    SysDate.difDate(start, end);

  int get days
  {
    int res = ys*360 + ms*30 + ds;
    return neg? -res : res;
  }

  String toString() =>
    '${neg? '-$ys':'$ys'}.${ ms.twoDigits }${ ds.twoDigits }';

  Period operator + (Period p) =>
    Period.days(days + p.days);

  Period operator - (Period p) =>
    Period.days(days - p.days);

  double get toDouble
  {
    double res = ys+((ms*100+ds) / 10000.0);
    return neg? -res : res;
  }
}
