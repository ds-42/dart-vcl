part of vcl;

class TDateTimeBase
{
  double Val;
  TDateTimeBase(this.Val);

  String toString()
  {
    return SysDate.dtoa(Val.truncate()+SysUtils.DateDelta);
  }

  bool operator == (Object other) => other is TDateTimeBase && Val==other.Val;
}

class TDateTime extends TDateTimeBase
{
  TDateTime( [dynamic Value] ) : super(0.0)
  {
    if(Value == null)
      return;
    if(Value is double)
      Val = Value;
    else
    if(Value is TDateTimeBase)
      Val = Value.Val;
    else
      throw UnsupportedError("Invalid class type");
  }


  TDateTime.empty() : super(0.0);
  TDateTime.double(double Value) : super(Value);
  TDateTime.int(int Value) : super(Value.toDouble());
  TDateTime.system(int Value) : super(Value==0? 0.0 : (Value - SysUtils.DateDelta).toDouble());
  TDateTime.ymd(int year, int month, int day) : this.system(SysDate.init(year, month, day));

  TDateTime.CurrentDate() : this.system(SysDate.curDate());
  TDateTime.CurrentDateTime() : this.system(SysDate.curDate());
  TDateTime.CurrentTime() : this.system(0); // не реализовано

  TDateTime.dd_mm_yyyy(String Value) : this.system(SysDate.atod(Value, order: DateOrder.dmy));
  TDateTime.yyyy_mm_dd(String Value) : this.system(SysDate.atod(Value, order: DateOrder.ymd));

  int
    get AsSystem => Val == 0.0? 0 : Val.truncate() + SysUtils.DateDelta;
    set AsSystem(int Value) => Val = Value==0? 0.0 : Value-SysUtils.DateDelta.toDouble();

  TDate get AsDate => TDate(this);
  DateTime Decode()
  {
    Date date = SysDate.itod(AsSystem);
    /// append time part
    return DateTime(date.year, date.month, date.day);
  }

  DateTime DecodeDate()
  {
    Date date = SysDate.itod(AsSystem);
    return DateTime(date.year, date.month, date.day);
  }

  int get DayOfWeek => SysDate.dayOfWeek(AsSystem);

  bool operator <  (TDateTime other) => Val <  other.Val;
  bool operator <= (TDateTime other) => Val <= other.Val;
  bool operator >  (TDateTime other) => Val >  other.Val;
  bool operator >= (TDateTime other) => Val >= other.Val;

  TDateTime operator - (dynamic other)
  {
    if(other is int)
      return TDateTime(Val - other);
    if(other is TDateTime)
      return TDateTime(Val - other.Val);
    throw UnsupportedError('invalid type');
  }

  TDateTime operator + (dynamic other)
  {
    if(other is int)
      return TDateTime(Val + other);
    if(other is TDateTime)
      return TDateTime(Val + other.Val);
    throw UnsupportedError('invalid type');
  }
}

class TDate extends TDateTime
{
  TDate( [dynamic Value=null] ) : super.empty()
  {
    if(Value==null)
      return;
    if(Value is TDateTimeBase)
    {
      Val = Value.Val.truncateToDouble();
      return;
    }
    throw UnsupportedError('Invalid class type');
  }

  TDate.system(int Value) : super.system(Value);
  TDate.CurrentDate() : super.CurrentDate();
  TDate.dd_mm_yyyy(String Value) : super.dd_mm_yyyy(Value);
  TDate.yyyy_mm_dd(String Value) : super.yyyy_mm_dd(Value);
}

class TTime extends TDateTime
{
  TTime.base(TDateTimeBase Value) : super(Value);
  TTime.CurrentTime() : super.CurrentTime();
}



