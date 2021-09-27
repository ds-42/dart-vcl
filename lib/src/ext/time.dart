part of vcl;

class Time
{
  final int hour;
  final int minute;
  final int second;
  final int millisecond;

  Time._(this.hour, this.minute, this.second, this.millisecond);

  factory Time(int hour, int minute, [int second=0, int millisecond=0]) =>
    Time.msec(SysTime.getMillisecond(hour, minute, second, millisecond));

  static Time? create(int hour, int minute, [int second=0, int millisecond=0])
  {
    if((hour >= 0 && hour < 24) && (minute >= 0 && minute < 60) &&
        (second>=0 && second < 60) && (millisecond>=0 && millisecond < 1000))
      return Time._(hour, minute, second, millisecond);
    return null;
  }

  factory Time.now()
  {
    var data = DateTime.now();
    return Time._(data.hour, data.minute, data.second, data.millisecond);
  }

  factory Time.system(double time) => Time.msec(SysTime.getStamp(time));

  factory Time.msec(int val)
  {
    int min  = val ~/ 60000;
    int msec = val  % 60000;
    return Time._(min ~/ 60, min % 60, msec ~/ 1000, msec % 1000);
  }

  factory Time.parse(String source)
  {
    var time = tryParse(source);
    if(time == null)
      SysUtils.ConvertErrorFmt(SysConsts.SInvalidDateTime, [source]);
    return time!;
  }

  static Time? tryParse(String source)
  {
    var pos = Integer();
    var time = SysUtils._scan_time(source.codeUnits, pos);
    if(time != null)
      return create(time.hour, time.minute, time.second, time.millisecond);
    return null;
  }

  String toString() =>
      SysUtils._date_time_to_string(SysUtils.LongTimeFormat, value);

  int getMillisecond() =>
      SysTime.getMillisecond(hour, minute, second, millisecond);

  double
      get value =>  getMillisecond() / SysUtils.MSecsPerDay;

  String get hhmm =>
      '${ hour.twoDigits }:${ minute.twoDigits }';

  String get hhmmss =>
      '${ hour.twoDigits }:${ minute.twoDigits }:${ second.twoDigits }';



}