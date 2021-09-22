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

  factory Period.difDays(int start, int end)
  {
    bool neg=start>end;
    if(neg){ int t=start; start=end; end=t; }

    var dd1 = Date.days(start);
    var dd2 = Date.days(end);

    int d1=dd1.day, m1=dd1.month, y1=dd1.year;
    int d2=dd2.day, m2=dd2.month, y2=dd2.year;

    d2-=d1;
    if(d2<0)
    {
      if(--m2==0)
      {
        m2 = 12;
        y2--;
      }
      d2+=SysDate.daysInMonth(y2, m2);

      if(d2<0)
      {
        m2--;
        d2+=31;
      }
    }

    m2-=m1;
    if(m2<0)
    {
      m2+=12;
      y1++;
    }

    var res = Period(y2-y1, m2, d2);
    return neg? res.inv : res;
  }  

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
