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