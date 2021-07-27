part of vcl;

abstract class SysDate
{
  static const monthDays = [
    <int>[ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ],
    <int>[ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ],
  ];

  static List<int> monthDaysOfYear(int year) =>
      monthDays[ isLeapYear(year)? 1 : 0 ];

  static bool isLeapYear(int year)
  {
    if(year<0) year=-year;
    return year%4 == 0 && (year%100 != 0 || year%400 == 0);
  }

  static int daysInYear(int year) =>
    isLeapYear(year)? 366 : 365;

  static int daysInMonth(int year, int month)
  {
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

    return monthDaysOfYear(year)[month-1];
  }

  static int curYear() => DateTime.now().year;

  static int curDate() => Date.now().days;

  static Date itod(int date) => Date.days(date);

  static int init(int year, int month, int day) =>
      Date(year, month, day).days;

  static int dayOfWeek(int date) => (date - 1) % 7 + 1;

  static int atod(String str, { String? order }) =>
    Date.parse(str, order).days;

  static String dtoa(int days, {String? format} )
  {
    if(days==0)
      return '';
    Date date = Date.days(days);
    return date.as(format ?? DateFormat.DDMMYYYY_d);
  }

  static int alterDate(int date, int dy, int dm, int dd)
  {
    var d = Date.days(date);
    return init(d.year+dy, d.month+dm, d.days+dd);
  }

  static Period difDate(int start, int end)
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
      d2+=daysInMonth(y2, m2);

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
}