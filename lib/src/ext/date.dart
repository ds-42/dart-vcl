part of vcl;

abstract class DateFormat
{
  static const DDMMYYYY_d = 'dd.mm.yyyy';
  static const YYYYMMDD_m = 'yyyy-mm-dd';
  static const YYYYMMDD_s = 'yyyy/mm/dd';
}

abstract class DateOrder
{
  static const ymd = 'ymd';
  static const dmy = 'dmy';
  static const mdy = 'mdy';
}

class Date
{
  final int year;
  final int month;
  final int day;

  Date._(this.year, this.month, this.day);

  factory Date(int year, [int month=1, int day=1])
  {
    // norm month
    while(month<1)
    {
      month+=12;
      year--;
    }

    while(month>12)
    {
      month-=12;
      year++;
    }


    var days = SysDate.monthDaysOfYear(year);

    // norm days by month
    while(day<=0)
    {
      if(--month<1)
      {
        month+=12;
        days = SysDate.monthDaysOfYear(--year);
      }
      day+=days[month-1];
    }

    int md = days[month-1];
    while(day>md)
    {
      if(++month>12)
      {
        month-=12;
        days = SysDate.monthDaysOfYear(++year);
      }
      day-=md;
      md = days[month-1];
    }

    return Date._(year, month, day);
  }

  factory Date.parse(String data, [String? order] )
  {
    var p = data.split(RegExp(r'[-\\/.]'));

    if(p.length==1 && p[0].length==8)
    {
      String data = p[0];
      switch(TLocal.dateOrder)
      {
        case DateOrder.ymd:

          p.add(data.substring(4, 6));
          p.add(data.substring(6, 8));
          p[0] =data.substring(0, 4);
          break;
      }
    }

    while(p.length<3)
      p.add('0');

    int yy = int.parse(p[0]);
    int mm = int.parse(p[1]);
    int dd = int.parse(p[2]);

    switch(order ?? TLocal.dateOrder)
    {
      case DateOrder.dmy:
        return Date(dd, mm, yy);
      case DateOrder.ymd:
        return Date(yy, mm, dd);
    }
    throw UnsupportedError('Unsupported date format: $data');
  }

  factory Date.now()
  {
    var date = DateTime.now();
    return Date._(date.year, date.month, date.day);
  }

  factory Date.days(int date)
  {
    if(date == 0)
      return Date(0, 0, 0);

    const d1 = 365;
    const d4 = d1 * 4 + 1;
    const d100 = d4 * 25 - 1;
    const d400 = d100 * 4 + 1;

    int d = date;
    d--;
    int y = 1;
    while(d >= d400)
    {
      d-=d400;
      y+=400;
    }

    int i;
    i = d ~/ d100;
    d = d % d100;
    if(i == 4)
    {
      i--;
      d+=d100;
    }
    y+=i * 100;

    i = d ~/ d4;
    d = d % d4;
    y+=i * 4;

    i = d ~/ d1;
    d = d % d1;
    if(i == 4)
    {
      i--;
      d+=d1;
    }
    y+=i;

    var days = SysDate.monthDaysOfYear(y);

    int m=0;
    for(; m<11; m++)
    {
      if(d<days[m])
        break;
      d-=days[m];
    }
    return Date._(y, m+1, d+1);
  }

  String toString() => as(TLocal.dateFormat);

  String get yyyymmdd =>
    '${ year.fourDigits }-${ month.twoDigits }-${ day.twoDigits }';

  String get yyyymmdd_s =>
      '${ year.fourDigits }/${ month.twoDigits }/${ day.twoDigits }';

  String get ddmmyyyy =>
    '${day.twoDigits}.${month.twoDigits}.${year.fourDigits}';

  String as(String format)
  {
    switch(format)
    {
      case DateFormat.YYYYMMDD_m: return yyyymmdd;
      case DateFormat.DDMMYYYY_d: return ddmmyyyy;
      case DateFormat.YYYYMMDD_s: return yyyymmdd_s;
      default:                    return ddmmyyyy;
    }
  }

  int get days
  {
    if(year==0 && month==0 && day==0)
      return 0;

    int d = day;
    int m = month;
    int y = year;
    while(m<1){  y--; m+=12; }
    while(m>12){ y++; m-=12; }

    bool neg = y<0;
    if(neg) y = -y;

    var days = SysDate.monthDaysOfYear(y);
    for(int i = 0; i<m-1; i++)
      d+=days[i];
    y--;
    d+= y * 365 + y ~/ 4 - y ~/ 100 + y ~/ 400;
    return neg? -d : d;
  }

  bool operator < (Date other) => year < other.year && month < other.month && day < other.day;
  bool operator > (Date other) => year > other.year && month > other.month && day > other.day;

  bool operator <= (Date other) => !(this > other);
  bool operator >= (Date other) => !(this < other);

  Period operator - (Date date) => SysDate.difDate(date.days, days);
}
