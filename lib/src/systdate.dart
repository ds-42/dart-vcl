part of vcl;

class TDateTimeBase
{
	double Val;
	TDateTimeBase(this.Val);

	String toString() => TDateTime(this).toString();

	bool operator == (Object other) => other is TDateTimeBase && Val==other.Val;
}

enum TDateTimeFlag { Date, Time, DateTime }

class TDateTime extends TDateTimeBase
{


	TDateTime([TDateTimeBase? src]) : super(src==null? 0 : src.Val);
	TDateTime.native(double src) : super(src);
	TDateTime.native_i4(int src) : super(src.toDouble());

	TDateTime.system(double src) : this.native(src - SysUtils.DateDelta);
	TDateTime.sysDate(int src) : this.native_i4(src - SysUtils.DateDelta);

	TDateTime.CurrentDate() : this.system(SysDate.now().toDouble());
	TDateTime.CurrentDateTime() : this.system(SysDate.curDateTime());
	TDateTime.CurrentTime() : this.native(SysTime.now());

	factory TDateTime.parse(String src, [TDateTimeFlag flag = TDateTimeFlag.DateTime])
	{
		switch(flag)
		{
			case TDateTimeFlag.DateTime: return SysUtils.StrToDateTime(src);
			case TDateTimeFlag.Date:     return SysUtils.StrToDate(src);
			case TDateTimeFlag.Time:     return SysUtils.StrToTime(src);
		}
	}

	factory TDateTime.date(int year, int month, int day) =>
			SysUtils.EncodeDate(year, month, day);
	factory TDateTime.time(int hour, int min, int sec, int msec) =>
			SysUtils.EncodeTime(hour, min, sec, msec);

	String toString() => DateTimeString();



	TDateTime operator + (dynamic other)
	{
		if(other is int)
			return TDateTime.native(Val + other);
		if(other is double)
			return TDateTime.native(Val + other);
		if(other is TDateTime)
			return TDateTime.native(Val + other.Val);
		throw UnsupportedError('invalid type');
	}

	TDateTime operator - (dynamic other)
	{
		if(other is int)
			return TDateTime.native(Val - other);
		if(other is double)
			return TDateTime.native(Val - other);
		if(other is TDateTime)
			return TDateTime.native(Val - other.Val);
		throw UnsupportedError('invalid type');
	}

	// comparisons

	bool operator >  (TDateTime other) => Val >  other.Val;
	bool operator <  (TDateTime other) => Val <  other.Val;
	bool operator >= (TDateTime other) => Val >= other.Val;
	bool operator <= (TDateTime other) => Val <= other.Val;


	String FormatString(String format) => SysUtils.FormatDateTime(format, this);
	String DateString() => SysUtils.DateToStr(this);
	String TimeString() => SysUtils.TimeToStr(this);
	String DateTimeString() => SysUtils.DateTimeToStr(this);

	double toDouble() => Val;
	int toInt() => Val.toInt();

	int
	  get ValI4 => Val.truncate();
	  set ValI4(int Value) => Val = Value.toDouble();

	int
	  get AsSysDate => (Val + SysUtils.DateDelta).truncate();
	  set AsSysDate(int date) => Val = (date - SysUtils.DateDelta).toDouble();

	int DayOfWeek() => SysUtils.DayOfWeek(this);

}

class TDate extends TDateTime
{
	TDate([TDateTimeBase? src]) : super(src);
	TDate.native(int src) : super.native_i4(src);
	TDate.sysDate(int src) : super.sysDate(src);
	TDate.parse(String src) : super(TDateTime.parse(src, TDateTimeFlag.Date));

	TDate.CurrentDate() : super.CurrentDate();

}

class TTime extends TDateTime
{
	TTime([TDateTimeBase? src]) : super();
}


