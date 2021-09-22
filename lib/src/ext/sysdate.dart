part of vcl;

/// Date is integer value as one plus number of days since 1/1/0001

abstract class SysDate
{

  static int now()
  {
    var date = DateTime.now();
    return encode(date.year, date.month, date.day);
  }

  // unsafe
  static int encode(int year, int month, int day, [List<int>? days])
  {
    days ??= monthDaysOfYear(year);
    month--;
    for(int i = 0; i < month; i++)
      day+=days[i];
    year--;
    return year * 365 + year ~/ 4 - year ~/ 100 + year ~/ 400 + day;
  }

  static int parse(String str)
  {
    var pos = Integer();
    var d = SysUtils._scan_date(str.codeUnits, pos);
    if(d==null)
      return 0;
    return encode(d.year, d.month, d.day);
  }

  static const monthDays = [
    <int>[ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ],
    <int>[ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ],
  ];

  static bool isLeapYear(int year)
  {
    return year%4 == 0 && (year%100 != 0 || year%400 == 0);
  }

  static List<int> monthDaysOfYear(int year)
  {
    return monthDays[ isLeapYear(year)? 1 : 0 ];
  }

  static int daysInYear(int year)
  {
    return isLeapYear(year)? 366 : 365;
  }

  static int daysInMonth(int year, int month)
  {
    return monthDays[ isLeapYear(year)? 1 : 0 ][month-1];
  }

  static int dayOfWeek(int date) => (date - 1) % 7 + 1;

  static int calcDays(int year, int month, int day) =>
      encode(year, month, day);

  static int curYear() => DateTime.now().year;

  static double curDateTime()
  {
    var dt = DateTime.now();
    return SysDate.encode(dt.year, dt.month, dt.day) +
        SysTime.encode(dt.hour, dt.minute, dt.second, dt.millisecond);
  }

  static int alterDate(int date, int dy, int dm, int dd)
  {
    var d = Date.days(date);
    return encode(d.year+dy, d.month+dm, d.day+dd);
  }

  static int getStamp(double dateTime) =>
      dateTime.truncate();

  static String asString(int date) =>
      asShortFormat(date);

  static String asLongFormat(int date) =>
      asFormat(SysUtils.LongDateFormat, date);

  static String asShortFormat(int date) =>
      asFormat(SysUtils.ShortDateFormat, date);

  static String asFormat(String format, int date) =>
      SysUtils._date_time_to_string(format, date.toDouble());


}