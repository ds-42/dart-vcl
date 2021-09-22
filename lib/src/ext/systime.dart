part of vcl;

abstract class SysTime
{
  static double now()
  {
    var time = DateTime.now();
    return encode(time.hour, time.minute, time.second, time.millisecond);
  }

  static double encode(int hour, int min, int sec, int msec)
  {
    return getMillisecond(hour, min, sec, msec) / SysUtils.MSecsPerDay;
  }

  static double parse(String str)
  {
    var pos = Integer();
    var t = SysUtils._scan_time(str.codeUnits, pos);
    if(t==null)
      return 0;
    return encode(t.hour, t.minute, t.second, t.millisecond);
  }

  static int getMillisecond(int hour, int min, int sec, int msec)
  {
    return hour * 3600000 + min * 60000 + sec * 1000 + msec;
  }

  /// Number of milliseconds since midnight
  static int getStamp(double time)
  {
    return ((time % 1) * SysUtils.MSecsPerDay).round();
  }

  static String asString(double time) =>
      asLongFormat(time);

  static String asLongFormat(double time) =>
      asFormat(SysUtils.LongTimeFormat, time);

  static String asShortFormat(double time) =>
      asFormat(SysUtils.ShortTimeFormat, time);

  static String asFormat(String format, double time) =>
    SysUtils._date_time_to_string(format, time);
}