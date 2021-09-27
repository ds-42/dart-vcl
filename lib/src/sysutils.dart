part of vcl;

// Date and time record
class TTimeStamp
{
  int Time;      // Number of milliseconds since midnight
  int Date;      // One plus number of days since 1/1/0001
  TTimeStamp(this.Date, this.Time);

  String toString() => 'TTimeStamp(date: $Date, time:$Time)';
}

// String to date/time conversions
enum TDateOrder { MDY, DMY, YMD }

// Exception class

class TException implements Exception
{

  String _message = '';
  String
  get Message => _message;
  set Message(String value) => _message = value;

  String toString() => 'Exception: $_message';

  TException(this._message) : super();

  TException.CreateFmt(String msg, var args)
  {
    _message = SysUtils.Format(msg, args);
  }

  TException.CreateRes(dynamic ident)
  {
    _message = SysUtils.LoadStr(ident);
  }



  TException.CreateResFmt(dynamic Ident, var Args)
  {
    _message = SysUtils.Format(SysUtils.LoadStr(Ident), Args);
  }


}

class EConvertError extends TException
{
  EConvertError.CreateRes(dynamic ident) : super.CreateRes(ident);
  EConvertError.CreateResFmt(dynamic ident, var args) : super.CreateResFmt(ident, args);
}

class EHeapException extends TException
{
  EHeapException(String msg) : super(msg);

}

class EOutOfMemory extends EHeapException
{
  EOutOfMemory(String msg) : super(msg);
}


abstract class SysUtils
{
  static const int MAXLONG      = 0x7fffffff;
  static const int MAXSHORT     = 0x7fff;

  static int? CharToHex(int code)
  {
    if(code>=48 && code<=57)   // '0..9'
      return code-48;
    if(code>=97 && code<=102)  // 'a..f'
      return code-87;
    if(code>=65 && code<=70)   // 'A..F'
      return code-55;

    return null;
  }


  // Units of time

  static const int HoursPerDay   = 24;
  static const int MinsPerDay    = HoursPerDay * 60;
  static const int SecsPerDay    = MinsPerDay * 60;
  static const int MSecsPerDay   = SecsPerDay * 1000;

  static const int DateDelta = 693594;    // Days between 1/1/0001 and 12/31/1899
  static const int UnixDateDelta = 25569; // Days between TDateTime basis (12/31/1899) and Unix time_t basis (1/1/1970)

  static int    DecimalSeparator = CHAR.COMMA;

  static int    DateSeparator = CHAR.DIV;
  static String ShortDateFormat = 'dd/MM/yyyy';
  static String LongDateFormat = 'MMMM d, yyyy';
  static int    TimeSeparator = CHAR.COLON;
  static String TimeAMString = 'am';
  static String TimePMString = 'pm';
  static String ShortTimeFormat = 'h:mm';
  static String LongTimeFormat = 'h:mm:ss';

  static int    TwoDigitYearCenturyWindow = 50;


  static final PathDelim  = '\\'; 
  static final DriveDelim = ':';  
  static final PathSep    = ';';  


/// SameText compares S1 to S2, without case-sensitivity. Returns true if
///  S1 and S2 are the equal, that is, if CompareText would return false

static bool SameText(String S1, String S2)
{
  return S1.toLowerCase() == S2.toLowerCase();
}



  static String LoadStr(dynamic Ident)
  {
    return '${ Ident }';
  }



  /// The Format routine formats the argument list given by the Args parameter
  /// using the format string given by the Format parameter.

  /// Format strings contain two types of objects--plain characters and format
  /// specifiers. Plain characters are copied verbatim to the resulting string.
  /// Format specifiers fetch arguments from the argument list and apply
  /// formatting to them.

  /// Format specifiers have the following form:

  ///   "%" [index ":"] ["-"] [width] ["." prec] type

  /// A format specifier begins with a % character. After the % come the
  /// following, in this order:

  /// -  an optional argument index specifier, [index ":"]
  /// -  an optional left-justification indicator, ["-"]
  /// -  an optional width specifier, [width]
  /// -  an optional precision specifier, ["." prec]
  /// -  the conversion type character, type

  /// The following conversion characters are supported:

  /// d  Decimal. The argument must be an integer value. The value is converted
  ///    to a string of decimal digits. If the format string contains a precision
  ///    specifier, it indicates that the resulting string must contain at least
  ///    the specified number of digits; if the value has less digits, the
  ///    resulting string is left-padded with zeros.

  /// u  Unsigned decimal.  Similar to 'd' but no sign is output.

  /// e  Scientific. The argument must be a floating-point value. The value is
  ///    converted to a string of the form "-d.ddd...E+ddd". The resulting
  ///    string starts with a minus sign if the number is negative, and one digit
  ///    always precedes the decimal point. The total number of digits in the
  ///    resulting string (including the one before the decimal point) is given
  ///    by the precision specifer in the format string--a default precision of
  ///    15 is assumed if no precision specifer is present. The "E" exponent
  ///    character in the resulting string is always followed by a plus or minus
  ///    sign and at least three digits.

  /// f  Fixed. The argument must be a floating-point value. The value is
  ///    converted to a string of the form "-ddd.ddd...". The resulting string
  ///    starts with a minus sign if the number is negative. The number of digits
  ///    after the decimal point is given by the precision specifier in the
  ///    format string--a default of 2 decimal digits is assumed if no precision
  ///    specifier is present.

  /// g  General. The argument must be a floating-point value. The value is
  ///    converted to the shortest possible decimal string using fixed or
  ///    scientific format. The number of significant digits in the resulting
  ///    string is given by the precision specifier in the format string--a
  ///    default precision of 15 is assumed if no precision specifier is present.
  ///    Trailing zeros are removed from the resulting string, and a decimal
  ///    point appears only if necessary. The resulting string uses fixed point
  ///    format if the number of digits to the left of the decimal point in the
  ///    value is less than or equal to the specified precision, and if the
  ///   value is greater than or equal to 0.00001. Otherwise the resulting
  ///    string uses scientific format.

  /// n  Number. The argument must be a floating-point value. The value is
  ///    converted to a string of the form "-d,ddd,ddd.ddd...". The "n" format
  ///    corresponds to the "f" format, except that the resulting string
  ///    contains thousand separators.

  /// m  Money. The argument must be a floating-point value. The value is
  ///    converted to a string that represents a currency amount. The conversion
  ///    is controlled by the CurrencyString, CurrencyFormat, NegCurrFormat,
  ///    ThousandSeparator, DecimalSeparator, and CurrencyDecimals global
  ///    variables, all of which are initialized from locale settings provided
  ///    by the operating system.  For example, Currency Format preferences can be
  ///    set in the International section of the Windows Control Panel. If the format
  ///    string contains a precision specifier, it overrides the value given
  ///    by the CurrencyDecimals global variable.

  /// p  Pointer. The argument must be a pointer value. The value is converted
  ///    to a string of the form "XXXX:YYYY" where XXXX and YYYY are the
  ///    segment and offset parts of the pointer expressed as four hexadecimal
  ///    digits.

  /// s  String. The argument must be a character, a string, or a PChar value.
  ///    The string or character is inserted in place of the format specifier.
  ///    The precision specifier, if present in the format string, specifies the
  ///    maximum length of the resulting string. If the argument is a string
  ///    that is longer than this maximum, the string is truncated.

  /// x  Hexadecimal. The argument must be an integer value. The value is
  ///    converted to a string of hexadecimal digits. If the format string
  ///    contains a precision specifier, it indicates that the resulting string
  ///    must contain at least the specified number of digits; if the value has
  ///    less digits, the resulting string is left-padded with zeros.

  /// Conversion characters may be specified in upper case as well as in lower
  /// case--both produce the same results.

  /// For all floating-point formats, the actual characters used as decimal and
  /// thousand separators are obtained from the DecimalSeparator and
  /// ThousandSeparator global variables.

  /// Index, width, and precision specifiers can be specified directly using
  /// decimal digit string (for example "%10d"), or indirectly using an asterisk
  /// charcater (for example "%*.*f"). When using an asterisk, the next argument
  /// in the argument list (which must be an integer value) becomes the value
  /// that is actually used. For example "Format('%*.*f', [8, 2, 123.456])" is
  /// the same as "Format('%8.2f', [123.456])".

  /// A width specifier sets the minimum field width for a conversion. If the
  /// resulting string is shorter than the minimum field width, it is padded
  /// with blanks to increase the field width. The default is to right-justify
  /// the result by adding blanks in front of the value, but if the format
  /// specifier contains a left-justification indicator (a "-" character
  /// preceding the width specifier), the result is left-justified by adding
  /// blanks after the value.

  /// An index specifier sets the current argument list index to the specified
  /// value. The index of the first argument in the argument list is 0. Using
  /// index specifiers, it is possible to format the same argument multiple
  /// times. For example "Format('%d %d %0:d %d', [10, 20])" produces the string
  /// '10 20 10 20'.

  /// The Format function can be combined with other formatting functions. For
  /// example

  ///   S := Format('Your total was %s on %s', [
  ///     FormatFloat('$#,##0.00;;zero', Total),
  ///     FormatDateTime('mm/dd/yy', Date)]);

  /// which uses the FormatFloat and FormatDateTime functions to customize the
  /// format beyond what is possible with Format.
  static String Format(String format, var args)
  {
    return sprintf(format, args);
  }


  /// The MonthDays array can be used to quickly find the number of
  ///  days in a month:  MonthDays[IsLeapYear(Y), M]
  static List< List<int> > get MonthDays => SysDate.monthDays;

  /// FloatToDateTime will range validate a value to make sure it falls
  /// within the acceptable date range
  static final MinDateTime = TDateTime.native(-657434.0);      // 01/01/0100 12:00:00.000 AM
  static final MaxDateTime = TDateTime.native(2958465.99999);  // 12/31/9999 11:59:59.999 PM


  static final LeadBytes = <int>[];



  static void ConvertError(String ResString)
  {
    throw EConvertError.CreateRes(ResString);
  }

  static void ConvertErrorFmt(dynamic ResString, var args)
  {
    throw EConvertError.CreateResFmt(ResString, args);
  }



  /// AnsiCompareText compares S1 to S2, without case-sensitivity. The compare
  /// operation is controlled by the current user locale. The return value
  /// is the same as for CompareStr.
  static int AnsiCompareText(String S1, String S2)
  {
    return memcmp(S1.toLowerCase(), S2.toLowerCase());

  }


  static String ExtractFileName(String FileName)
  {

    return FileName;
  }



  static int StrLIComp(LPPTR Str1, LPPTR Str2, int MaxLen)
  {
    int e1 = Str1.ptr+MaxLen;
    if(e1>Str1.length) e1 = Str1.length;
    int e2 = Str2.ptr+MaxLen;
    if(e2>Str2.length) e2 = Str2.length;

    String s1 = String.fromCharCodes(Str1.data, Str1.ptr, e1).toLowerCase();
    String s2 = String.fromCharCodes(Str2.data, Str2.ptr, e2).toLowerCase();
    return memcmp(s1, s2, MaxLen);
  }



  static TTimeStamp DateTimeToTimeStamp(TDateTime DateTime)
  {
    double value = DateTime.Val + SysUtils.DateDelta;
    return TTimeStamp(SysDate.getStamp(value), SysTime.getStamp(value));
  }

  static ValidateTimeStamp(TTimeStamp TimeStamp)
  {
    if((TimeStamp.Time < 0) || (TimeStamp.Date <= 0))
      ConvertErrorFmt(SysConsts.SInvalidTimeStamp, [TimeStamp.Date, TimeStamp.Time]);
  }

  static TDateTime TimeStampToDateTime(TTimeStamp TimeStamp)
  {
    ValidateTimeStamp(TimeStamp);
    return TDateTime.native(TimeStamp.Date - SysUtils.DateDelta + TimeStamp.Time / SysUtils.MSecsPerDay);
  }

  static TTimeStamp MSecsToTimeStamp(int MSecs/*: Comp*/)
  {
    return TTimeStamp(MSecs ~/ MSecsPerDay, MSecs % MSecsPerDay);
  }


  static int TimeStampToMSecs(TTimeStamp TimeStamp)
  {
    ValidateTimeStamp(TimeStamp);
    return TimeStamp.Date * MSecsPerDay + TimeStamp.Time;
  }

  /// Time encoding and decoding

  /// Instead of generating errors the following variations of EncodeDate and
  /// EncodeTime simply return False if the parameters given are not valid.
  /// Other than that, these functions are functionally the same as the above
  /// functions.
  static bool TryEncodeTime(int Hour, int Min, int Sec, int MSec, TDateTime ResTime)
  {
    var t = Time.create(Hour, Min, Sec, MSec);
    if(t == null)
      return false;
    ResTime.Val = SysTime.encode(t.hour, t.minute, t.second, t.millisecond);
    return true;
  }

  /// EncodeTime encodes the given hour, minute, second, and millisecond into a
  /// TDateTime value. The hour must be between 0 and 23, the minute must be
  /// between 0 and 59, the second must be between 0 and 59, and the millisecond
  /// must be between 0 and 999. If the specified values are not within range, an
  /// EConvertError exception is raised. The resulting value is a number between
  /// 0 (inclusive) and 1 (not inclusive) that indicates the fractional part of
  /// a day given by the specified time. The value 0 corresponds to midnight,
  /// 0.5 corresponds to noon, 0.75 corresponds to 6:00 pm, etc.
  static TDateTime EncodeTime(int Hour, int Min, int Sec, int MSec)
  {
    var Result = TDateTime();
    if(!TryEncodeTime(Hour, Min, Sec, MSec, Result))
      ConvertError(RTLConsts.STimeEncodeError);
    return Result;
  }

  /// DecodeTime decodes the fractional (time) part of the given TDateTime value
  /// into its corresponding hour, minute, second, and millisecond.
  static void DecodeTime(TDateTime DateTime,
      Integer Hour, Integer Min, Integer Sec, Integer MSec)
  {
    int time = DateTimeToTimeStamp(DateTime).Time;
    int MinCount  = time ~/ 60000;
    int MSecCount = time % 60000;

    Hour.Value = MinCount ~/ 60;
    Min.Value  = MinCount % 60;
    Sec.Value  = MSecCount ~/ 1000;
    MSec.Value = MSecCount % 1000;
  }

  /// Date encoding and decoding

  /// IsLeapYear determines whether the given year is a leap year.
  static bool IsLeapYear(int year)
  {
    return SysDate.isLeapYear(year<0? -year : year);
  }

  static bool TryEncodeDate(int Year, int Month, int Day, TDateTime ResDate)
  {
    var d = Date.create(Year, Month, Day);
    if(d==null)
      return false;
    ResDate.Val = (SysDate.encode(d.year, d.month, d.day) - DateDelta).toDouble();
    return true;
  }

  /// EncodeDate encodes the given year, month, and day into a TDateTime value.
  /// The year must be between 1 and 9999, the month must be between 1 and 12,
  /// and the day must be between 1 and N, where N is the number of days in the
  /// specified month. If the specified values are not within range, an
  /// EConvertError exception is raised. The resulting value is the number of
  /// days between 12/30/1899 and the given date.
  static TDateTime EncodeDate(int Year, int Month, int Day)
  {
    var Result = TDateTime();
    if(!TryEncodeDate(Year, Month, Day, Result))
      ConvertError(Consts.SDateEncodeError);
    return Result;
  }

  /// This variation of DecodeDate works similarly to the above function but
  /// returns more information.  The result value of this function indicates
  /// wither the year decoded is a leap year or not.
  static List<int> DecodeDateFully(TDateTime Value)
  {
    final data = <int>[];
    int val = (Value.Val + DateDelta).truncate();
    Date d = Date.days(val);
    data.add(d.year);
    data.add(d.month);
    data.add(d.day);
    data.add(SysDate.dayOfWeek(val));
    data.add( IsLeapYear(d.year)? 1 : 0 );
    return data;
  }



  /// DecodeDate decodes the integral (date) part of the given TDateTime value
  /// into its corresponding year, month, and day. If the given TDateTime value
  /// is less than or equal to zero, the year, month, and day return parameters
  /// are all set to zero.
  static Date DecodeDate(TDateTime Value) =>
    Date.days((Value.Val + SysUtils.DateDelta).truncate());
    



    /// DayOfWeek returns the day of the week of the given date. The result is an
    /// integer between 1 and 7, corresponding to Sunday through Saturday.
    /// This function is not ISO 8601 compliant, for that see the DateUtils unit.
    static int DayOfWeek(TDateTime DateTime)
    {
      return  DateTimeToTimeStamp(DateTime).Date % 7 + 1;
    }



  static TDateTime Now()
  {
    return TDateTime.CurrentDateTime();

  }





  static void ReplaceTime(TDateTime DateTime, TDateTime NewTime)
  {
    DateTime.Val = DateTime.Val.truncateToDouble();
    if(DateTime.Val >= 0)
      DateTime.Val = DateTime.Val + (NewTime.Val%1.0).abs();
    else
      DateTime.Val = DateTime.Val - (NewTime.Val%1.0).abs();
  }

  static void ReplaceDate(TDateTime DateTime, TDateTime NewDate)
  {
    var Temp = TDateTime(NewDate);
    ReplaceTime(Temp, DateTime);
    DateTime.Val = Temp.Val;
  }

  /// Current year returns the year portion of the date returned by Now
  static int CurrentYear()
  {
    return SysDate.curYear();
  }

  // Date/time to string conversions

  /// DateTimeToString converts the date and time value given by DateTime using
  /// the format string given by Format into the string variable given by Result.
  /// For further details, see the description of the FormatDateTime function.
  static String DateTimeToString(String Format, TDateTime Value)
  {
    return _date_time_to_string(Format, Value.Val + SysUtils.DateDelta);
  }

  static String _date_time_to_string(String format, double sysDateTime)
  {
    var dateStamp = SysDate.getStamp(sysDateTime);
    var timeStamp = SysTime.getStamp(sysDateTime);

    var date = Date.days(dateStamp);
    var time = Time.msec(timeStamp);
    int weekday = SysDate.dayOfWeek(dateStamp);

    int AppendLevel = 0;
    final Buffer = <int>[];

    void AppendChars(LPPTR P, int Count)
    {
      int i = P.ptr;
      int e = i + Count;
      if(e>P.length)
        e=P.length;
      while(i<e)
        Buffer.add(P.data[i++]);
    }

    void AppendString(String S)
    {
      Buffer.addAll(S.codeUnits);
    }

    void AppendNumber(int Number, int Digits)
    {
      
      String tmp = Number.toString();
      while(Digits-->tmp.length)
        Buffer.add(CHAR.ZERO); // '0'
      Buffer.addAll(tmp.codeUnits);
      
    }

    void AppendFormat(LPPTR Format)
    {
      int LastToken = 0;
      int Starter = 0;
      int Token = 0;
      int Count = 0;
      bool BetweenQuotes = false;
      bool Use12HourClock = false;
      int H = 0;


      void GetCount()
      {
        var P = Format.ptr;
        while(Format.code == Starter)
          Format.ptr++;
        Count = Format.ptr - P + 1;
      }



      String ConvertEraString(int Count)

      {
        String Result = '';


        String FormatStr = 'gg';

        return Result;
      }




      if(Format.isNotEmpty && AppendLevel < 2)
      {
        AppendLevel++;
        LastToken = CHAR.SPACE;
        Use12HourClock = false;
        while(!Format.eof)
        {
          Starter = Format.code;
          Format.ptr++; // Format := StrNextChar(Format);
          if(LeadBytes.contains(Starter))
          {
            LastToken = CHAR.SPACE;
            continue;
          }
          Token = Starter;
          if(Token.beetwen(CHAR.a, CHAR.z)) // ['a'..'z']
            Token-=CHAR.SPACE;
          if(Token.beetwen(CHAR.A, CHAR.Z))
          {
            if((Token == CHAR.M) && (LastToken == CHAR.H))
              Token = CHAR.N;
            LastToken = Token;
          }

          switch(Token)
          {
            case CHAR.Y:
              GetCount();
              if(Count <= 2)
                AppendNumber(date.year % 100, 2);
              else
                AppendNumber(date.year, 4);
              break;

            case CHAR.G:
              GetCount();
              AppendString(ConvertEraString(Count));
              break;


            case CHAR.M:
              GetCount();
              // GetDate();
              switch(Count)
              {
                case 1:
                case 2:
                  AppendNumber(date.month, Count);
                  break;
                case 3:
                  AppendString(ShortMonthNames.MonthToStr(date.month, Locale.active));
                  break;
                default:
                  AppendString(LongMonthNames.MonthToStr(date.month, Locale.active));
                  break;
              }
              break;

            case CHAR.D:
              GetCount();
              switch(Count)
              {
                case 1:
                case 2:
                  AppendNumber(date.day, Count);
                  break;
                case 3:
                  AppendString(ShortDayNames.WeekdayToStr(weekday, Locale.active));
                  break;
                case 4:
                  AppendString(LongDayNames.WeekdayToStr(weekday, Locale.active));
                  break;
                case 5:
                  AppendFormat(LPPTR(ShortDateFormat));
                  break;
                default:
                  AppendFormat(LPPTR(LongDateFormat));
                  break;
              }
              break;

            case CHAR.H:
              GetCount();
              BetweenQuotes = false;
              var P = LPPTR(Format);
              while(!P.eof)
              {
                if(LeadBytes.contains(P.code))
                {
                  P.ptr++; // P := StrNextChar(P);
                  continue;
                }
                switch(P.code)
                {
                  case CHAR.A:
                  case CHAR.a:
                    if(BetweenQuotes)
                      break;
                    if ( (StrLIComp(P, LPPTR('AM/PM'), 5) == 0) ||
                         (StrLIComp(P, LPPTR('A/P'),   3) == 0) ||
                         (StrLIComp(P, LPPTR('AMPM'),  4) == 0) )
                        Use12HourClock = true;
                    return;

                  case CHAR.H:
                  case CHAR.h:
                    break;

                  case CHAR.APOS:
                  case CHAR.QUOT:
                    BetweenQuotes = !BetweenQuotes;
                    break;
                }
                P.ptr++;
              }
              H = time.hour;
              if(Use12HourClock)
                if(H == 0)
                  H = 12;
                else
                if(H > 12)
                  H-=12;
              if(Count > 2)
                Count = 2;
              AppendNumber(H, Count);
            break;

            case CHAR.N:
              GetCount();
              if(Count > 2)
                Count = 2;
              AppendNumber(time.minute, Count);
              break;

            case CHAR.S:
              GetCount();
              if(Count > 2)
                Count = 2;
              AppendNumber(time.second, Count);
              break;

            case CHAR.T:
              GetCount();
              if(Count == 1)
                AppendFormat(LPPTR(ShortTimeFormat));
              else
                AppendFormat(LPPTR(LongTimeFormat));
              break;

            case CHAR.Z:
              GetCount();
              if(Count > 3)
                Count = 3;
              AppendNumber(time.millisecond, Count);
              break;

            case CHAR.A:
              var P = LPPTR(Format, -1);
              if(StrLIComp(P, LPPTR('AM/PM'), 5) == 0)
              {
                if(time.hour >= 12)
                  P.ptr+=3;
                AppendChars(P, 2);
                Format.ptr+=4;
                Use12HourClock = true;
              }
              else
              if(StrLIComp(P, LPPTR('A/P'), 3) == 0)
              {
                if(time.hour >= 12)
                  P.ptr+=2;
                AppendChars(P, 1);
                Format.ptr+=2;
                Use12HourClock = true;
              }
              else
              if(StrLIComp(P, LPPTR('AMPM'), 4) == 0)
              {
                if(time.hour < 12)
                  AppendString(TimeAMString);
                else
                  AppendString(TimePMString);
                Format.ptr+=3;
                Use12HourClock = true;
              }
              else
              if(StrLIComp(P, LPPTR('AAAA'), 4) == 0)
              {
                AppendString(LongDayNames.WeekdayToStr(weekday));
                Format.ptr+=3;
              }
              else
              if(StrLIComp(P, LPPTR('AAA'), 3) == 0)
              {
                AppendString(ShortDayNames.WeekdayToStr(weekday));
                Format.ptr+=2;
              }
              else
                Buffer.add(Starter);
              break;

            case CHAR.C:
              GetCount();
              AppendFormat(LPPTR(ShortDateFormat));
              if((time.hour != 0) || (time.minute != 0) || (time.second != 0))
              {
                Buffer.add(CHAR.SPACE);
                AppendFormat(LPPTR(LongTimeFormat));
              };
              break;

            case CHAR.DIV:
              if(DateSeparator != 0)
                Buffer.add(DateSeparator);
              break;

            case CHAR.COLON:
              if(TimeSeparator != 0)
                Buffer.add(TimeSeparator);
              break;

            case CHAR.APOS:
            case CHAR.QUOT:
              var P = LPPTR(Format);
              while((!Format.eof) && (Format.code != Starter))
              {
                if(LeadBytes.contains(Format.code))
                  Format.ptr++; // Format := StrNextChar(Format)
                else
                  Format.ptr++;
              }
              AppendChars(P, Format.ptr - P.ptr);
              if(!Format.eof)
                Format.ptr++;
              break;

            default:
              Buffer.add(Starter);
              break;
          }
        }
        AppendLevel--;
      }
    }

    AppendFormat(LPPTR(format.isEmpty? 'C' : format));
    return String.fromCharCodes(Buffer);
  }

  static bool TryFloatToDateTime(double Value, TDateTime AResult)
  {
    if((Value < MinDateTime.Val) || (Value >= (MaxDateTime.Val + 1.0)))
      return false;
    AResult.Val = Value;
    return true;
  }

  static TDateTime FloatToDateTime(double Value)
  {
    var Result = TDateTime();
    if(!TryFloatToDateTime(Value, Result))
      ConvertErrorFmt(SysConsts.SInvalidDateTimeFloat, [Value]);
    return Result;
  }

  /// DateToStr converts the date part of the given TDateTime value to a string.
  /// The conversion uses the format specified by the ShortDateFormat global
  /// variable.
  static String DateToStr(TDateTime DateTime) =>
    DateTimeToString(ShortDateFormat, DateTime);

  /// TimeToStr converts the time part of the given TDateTime value to a string.
  /// The conversion uses the format specified by the LongTimeFormat global
  /// variable.
  static String TimeToStr(TDateTime DateTime) =>
    DateTimeToString(LongTimeFormat, DateTime);

  /// DateTimeToStr converts the given date and time to a string. The resulting
  /// string consists of a date and time formatted using the ShortDateFormat and
  /// LongTimeFormat global variables. Time information is included in the
  /// resulting string only if the fractional part of the given date and time
  /// value is non-zero.
  static String DateTimeToStr(TDateTime DateTime) =>
    DateTimeToString('', DateTime);

  /// FormatDateTime formats the date-and-time value given by DateTime using the
  /// format given by Format. The following format specifiers are supported:

  /// c       Displays the date using the format given by the ShortDateFormat
  ///         global variable, followed by the time using the format given by
  ///         the LongTimeFormat global variable. The time is not displayed if
  ///         the fractional part of the DateTime value is zero.

  /// d       Displays the day as a number without a leading zero (1-31).

  /// dd      Displays the day as a number with a leading zero (01-31).

  /// ddd     Displays the day as an abbreviation (Sun-Sat) using the strings
  ///         given by the ShortDayNames global variable.

  /// dddd    Displays the day as a full name (Sunday-Saturday) using the strings
  ///         given by the LongDayNames global variable.

  /// ddddd   Displays the date using the format given by the ShortDateFormat
  ///         global variable.

  /// dddddd  Displays the date using the format given by the LongDateFormat
  ///         global variable.

  /// g       Displays the period/era as an abbreviation (Japanese and
  ///         Taiwanese locales only).

  /// gg      Displays the period/era as a full name.

  /// e       Displays the year in the current period/era as a number without
  ///         a leading zero (Japanese, Korean and Taiwanese locales only).

  /// ee      Displays the year in the current period/era as a number with
  ///         a leading zero (Japanese, Korean and Taiwanese locales only).

  /// m       Displays the month as a number without a leading zero (1-12). If
  ///         the m specifier immediately follows an h or hh specifier, the
  ///         minute rather than the month is displayed.

  /// mm      Displays the month as a number with a leading zero (01-12). If
  ///         the mm specifier immediately follows an h or hh specifier, the
  ///         minute rather than the month is displayed.

  /// mmm     Displays the month as an abbreviation (Jan-Dec) using the strings
  ///         given by the ShortMonthNames global variable.

  /// mmmm    Displays the month as a full name (January-December) using the
  ///         strings given by the LongMonthNames global variable.

  /// yy      Displays the year as a two-digit number (00-99).

  /// yyyy    Displays the year as a four-digit number (0000-9999).

  /// h       Displays the hour without a leading zero (0-23).

  /// hh      Displays the hour with a leading zero (00-23).

  /// n       Displays the minute without a leading zero (0-59).

  /// nn      Displays the minute with a leading zero (00-59).

  /// s       Displays the second without a leading zero (0-59).

  /// ss      Displays the second with a leading zero (00-59).

  /// z       Displays the millisecond without a leading zero (0-999).

  /// zzz     Displays the millisecond with a leading zero (000-999).

  /// t       Displays the time using the format given by the ShortTimeFormat
  ///         global variable.

  /// tt      Displays the time using the format given by the LongTimeFormat
  ///         global variable.

  /// am/pm   Uses the 12-hour clock for the preceding h or hh specifier, and
  ///         displays 'am' for any hour before noon, and 'pm' for any hour
  ///         after noon. The am/pm specifier can use lower, upper, or mixed
  ///         case, and the result is displayed accordingly.

  /// a/p     Uses the 12-hour clock for the preceding h or hh specifier, and
  ///         displays 'a' for any hour before noon, and 'p' for any hour after
  ///         noon. The a/p specifier can use lower, upper, or mixed case, and
  ///         the result is displayed accordingly.

  /// ampm    Uses the 12-hour clock for the preceding h or hh specifier, and
  ///         displays the contents of the TimeAMString global variable for any
  ///         hour before noon, and the contents of the TimePMString global
  ///         variable for any hour after noon.

  /// /       Displays the date separator character given by the DateSeparator
  ///         global variable.

  /// :       Displays the time separator character given by the TimeSeparator
  ///         global variable.

  /// 'xx'    Characters enclosed in single or double quotes are displayed as-is,
  /// "xx"    and do not affect formatting.

  /// Format specifiers may be written in upper case as well as in lower case
  /// letters--both produce the same result.

  /// If the string given by the Format parameter is empty, the date and time
  /// value is formatted as if a 'c' format specifier had been given.

  /// The following example:

  ///   S := FormatDateTime('"The meeting is on" dddd, mmmm d, yyyy, ' +
  ///     '"at" hh:mm AM/PM', StrToDateTime('2/15/95 10:30am'));

  /// assigns 'The meeting is on Wednesday, February 15, 1995 at 10:30 AM' to
  /// the string variable S.

  static String FormatDateTime(String Format, TDateTime DateTime) =>
    DateTimeToString(Format, DateTime);

  static void _scan_blanks(List<int> data, Integer Pos)
  {
    int i = Pos.Value;
    while((i < data.length) && (data[i] == CHAR.SPACE))
      i++;
    Pos.Value = i;
  }

//  static void ScanBlanks(String S, Integer Pos) =>
//    _scan_blanks(S.codeUnits, Pos);

  static bool _scan_number(List<int> data, Integer Pos, Integer Number, Integer CharCount)
  {
    CharCount.Value = 0;
    _scan_blanks(data, Pos);
    int i = Pos.Value;
    int n = 0;
    while((i < data.length) && (data[i].beetwen(CHAR.ZERO, CHAR.NINE)) && (n < 1000))
    {
      n = n * 10 + data[i] - CHAR.ZERO;
      i++;
    }
    if(i > Pos.Value)
    {
      CharCount.Value = i - Pos.Value;
      Pos.Value = i;
      Number.Value = n;
      return true;
    }
    return false;
  }

//  static bool ScanNumber(String S, Integer Pos, Integer Number, Integer CharCount) =>
//    _scan_number(S.codeUnits, Pos, Number, CharCount);

  static bool _scan_string(List<int> data, Integer Pos, String Symbol)
  {
    if(Symbol != '')
    {
      _scan_blanks(data, Pos);
      int end = Pos.Value+Symbol.length;
      if(end>data.length)
        end = data.length;
      if(AnsiCompareText(Symbol, String.fromCharCodes(data, Pos.Value, end)) == 0)
      {
        Pos.Value+=Symbol.length;
        return true;
      }
    }
    return false;
  }

//  static bool ScanString(String S, Integer Pos, String Symbol) =>
//      _scan_string(S.codeUnits, Pos, Symbol);

  static bool _scan_char(List<int> data, Integer Pos, int Ch)
  {
    bool Result = false;
    _scan_blanks(data, Pos);
    if((Pos.Value < data.length) && (data[Pos.Value] == Ch))
    {
      Pos.Value++;
      Result = true;
    }
    return Result;
  }

//  static bool ScanChar(String S, Integer Pos, int Ch) =>
//      _scan_char(S.codeUnits, Pos, Ch);


  static TDateOrder GetDateOrder(String DateFormat)
  {
    for(var s in DateFormat.codeUnits)
    {
      switch(s)
      {
        case CHAR.E: case CHAR.e:
          return TDateOrder.YMD;
        case CHAR.Y: case CHAR.y:
          return TDateOrder.YMD;
        case CHAR.M: case CHAR.m:
          return TDateOrder.MDY;
        case CHAR.D: case CHAR.d:
          return TDateOrder.DMY;
      }
    }
    return TDateOrder.MDY;
  }

  

  static Date? _scan_date(List<int> data, Integer pos, [TDateOrder? dateOrder, int? separator])
  {
    if(dateOrder==null)
      dateOrder = GetDateOrder(ShortDateFormat);
    if(separator==null)
      separator = DateSeparator;
    var n1 = Integer();
    var n2 = Integer();
    var n3 = Integer();
    var l1 = Integer();
    var l2 = Integer();
    var l3 = Integer();
    int CenturyBase;


    int EraToYear(int Year)
    {

      return Year;
    }

    int y = 0;
    int m = 0;
    int d = 0;
    int YearLen = 0;
    int EraYearOffset = 0;
/*    if(ShortDateFormat[1] == 'g')  // skip over prefix text
    {
      ScanToNumber(S, Pos);
      EraName := Trim(Copy(S, 1, Pos-1));
      EraYearOffset := GetEraYearOffset(EraName);
    }
    else
    if(AnsiPos('e', ShortDateFormat) > 0))
      EraYearOffset = EraYearOffsets[1];*/
    if( !(_scan_number(data, pos, n1, l1) && _scan_char(data, pos, separator) &&
      _scan_number(data, pos, n2, l2)))
        return null;
    if(_scan_char(data, pos, separator))
    {
      if(!_scan_number(data, pos, n3, l3))
        return null;
      switch(dateOrder)
      {
        case TDateOrder.MDY:
          y = n3.Value; YearLen = l3.Value; m = n1.Value; d = n2.Value;
          break;
        case TDateOrder.DMY:
          y = n3.Value; YearLen = l3.Value; m = n2.Value; d = n1.Value;
          break;
        case TDateOrder.YMD:
          y = n1.Value; YearLen = l1.Value; m = n2.Value; d = n3.Value;
          break;
      }
      if(EraYearOffset > 0)
        y = EraToYear(y);
      else
      if(YearLen <= 2)
      {
        CenturyBase = CurrentYear() - TwoDigitYearCenturyWindow;
        y+=CenturyBase ~/ 100 * 100;
        if((TwoDigitYearCenturyWindow > 0) && (y < CenturyBase))
          y+=100;
      }
    }
    else
    {
      y = CurrentYear();
      if(dateOrder == TDateOrder.DMY)
      {
        d = n1.Value;
        m = n2.Value;
      }
      else
      {
        m = n1.Value;
        d = n2.Value;
      }
    }
    _scan_char(data, pos, separator);
    _scan_blanks(data, pos);
/*    if SysLocale.FarEast and (System.Pos('ddd', ShortDateFormat) <> 0) then
    begin     // ignore trailing text
      if ShortTimeFormat[1] in ['0'..'9'] then  // stop at time digit
        ScanToNumber(S, Pos)
      else  // stop at time prefix
        repeat
          while (Pos <= Length(S)) and (S[Pos] <> ' ') do Inc(Pos);
          ScanBlanks(S, Pos);
        until (Pos > Length(S)) or
          (AnsiCompareText(TimeAMString, Copy(S, Pos, Length(TimeAMString))) = 0) or
          (AnsiCompareText(TimePMString, Copy(S, Pos, Length(TimePMString))) = 0);
    end;**/
    return Date._(y, m, d);
  }

  static bool _scanDate(String S, Integer Pos, TDateTime Date)
  {
    var d = _scan_date(S.codeUnits, Pos);
    if(d==null)
      return false;
    return TryEncodeDate(d.year, d.month, d.day, Date);
  }

  static Time? _scan_time(List<int> data, Integer Pos)
  {
    var Hour = Integer();
    var Min = Integer();
    var Sec = Integer();
    var MSec = Integer();
    var Junk = Integer();
    int BaseHour = -1;
    if(_scan_string(data, Pos, TimeAMString) || _scan_string(data, Pos, 'AM'))
      BaseHour = 0;
    else
    if(_scan_string(data, Pos, TimePMString) || _scan_string(data, Pos, 'PM'))
      BaseHour = 12;
    if(BaseHour >= 0)
      _scan_blanks(data, Pos);
    if(!_scan_number(data, Pos, Hour, Junk))
      return null;
    if(_scan_char(data, Pos, TimeSeparator))
    {
      Min.Value = 0;
      Sec.Value = 0;
      MSec.Value = 0;
      if(!_scan_number(data, Pos, Min, Junk))
        return null;
      if(_scan_char(data, Pos, TimeSeparator))
      {
        if(!_scan_number(data, Pos, Sec, Junk))
          return null;
        if(_scan_char(data, Pos, DecimalSeparator))
          if(!_scan_number(data, Pos, MSec, Junk))
            return null;
      }
      if(BaseHour < 0)
        if(_scan_string(data, Pos, TimeAMString) || _scan_string(data, Pos, 'AM'))
          BaseHour = 0;
        else
        if(_scan_string(data, Pos, TimePMString) || _scan_string(data, Pos, 'PM'))
          BaseHour = 12;
      if(BaseHour >= 0)
      {
        if((Hour.Value == 0) || (Hour.Value > 12))
          return null;
        if(Hour.Value == 12)
          Hour.Value = 0;
        Hour.Value+=BaseHour;
      }
      _scan_blanks(data, Pos);
      return Time._(Hour.Value, Min.Value, Sec.Value, MSec.Value);
    }
    return null;
  }

  static bool _scanTime(String S, Integer Pos, TDateTime Time)
  {
    var t = _scan_time(S.codeUnits, Pos);
    if(t==null)
      return false;
    return TryEncodeTime(t.hour, t.minute, t.second, t.millisecond, Time);
  }

  /// StrToDate converts the given string to a date value. The string must
  /// consist of two or three numbers, separated by the character defined by
  /// the DateSeparator global variable. The order for month, day, and year is
  /// determined by the ShortDateFormat global variable--possible combinations
  /// are m/d/y, d/m/y, and y/m/d. If the string contains only two numbers, it
  /// is interpreted as a date (m/d or d/m) in the current year. Year values
  /// between 0 and 99 are assumed to be in the current century. If the given
  /// string does not contain a valid date, an EConvertError exception is
  ///raised.
  static TDateTime StrToDate(String S)
  {
    TDateTime Result = TDateTime();
    if(TryStrToDate(S, Result))
      return Result;
    throw EConvertError.CreateResFmt(RTLConsts.SInvalidDate, [S]);
  }

  static TDateTime StrToDateDef(String S, TDateTime Default)
  {
    TDateTime Result = TDateTime();
    if(TryStrToDate(S, Result))
      return Result;
    return Default;
  }

  static bool TryStrToDate(String S, TDateTime Value)
  {
    Integer Pos = Integer();
    return _scanDate(S, Pos, Value) && (Pos.Value >= S.length);
  }

  /// StrToTime converts the given string to a time value. The string must
  /// consist of two or three numbers, separated by the character defined by
  /// the TimeSeparator global variable, optionally followed by an AM or PM
  /// indicator. The numbers represent hour, minute, and (optionally) second,
  /// in that order. If the time is followed by AM or PM, it is assumed to be
  /// in 12-hour clock format. If no AM or PM indicator is included, the time
  /// is assumed to be in 24-hour clock format. If the given string does not
  /// contain a valid time, an EConvertError exception is raised.
  static TDateTime StrToTime(String S)
  {
    var Result = TDateTime();
    if(!TryStrToTime(S, Result))
      ConvertErrorFmt(SysConsts.SInvalidTime, [S]);
    return Result;
  }

  static TDateTime StrToTimeDef(String S, TDateTime Default)
  {
    var Result = TDateTime();
    if(!TryStrToTime(S, Result))
      Result.Val = Default.Val;
    return Result;
  }

  static bool TryStrToTime(String S, TDateTime Value)
  {
    var Pos = Integer();
    return _scanTime(S, Pos, Value) && (Pos.Value >= S.length);
  }

  /// StrToDateTime converts the given string to a date and time value. The
  /// string must contain a date optionally followed by a time. The date and
  /// time parts of the string must follow the formats described for the
  /// StrToDate and StrToTime functions.
  static TDateTime StrToDateTime(String S)
  {
    var Result = TDateTime();
    if(!TryStrToDateTime(S, Result))
      ConvertErrorFmt(SysConsts.SInvalidDateTime, [S]);
    return Result;
  }

  TDateTime StrToDateTimeDef(String S, TDateTime Default)
  {
    var Result = TDateTime();
    if(!TryStrToDateTime(S, Result))
      Result.Val = Default.Val;
    return Result;
  }

  static bool TryStrToDateTime(String S, TDateTime Value)
  {
    var Pos = Integer();
    var Date = TDateTime();
    var Time = TDateTime();
    if(!_scanDate(S, Pos, Date) ||
       !((Pos.Value >= S.length) || _scanTime(S, Pos, Time)))
         return TryStrToTime(S, Value); // Try time only
    else
    if(Date.Val >= 0)
      Value.Val = Date.Val + Time.Val;
    else
      Value.Val = Date.Val - Time.Val;
    return true;
  }


}



abstract class ShortMonthNames
{
  static final _items = <TLocale, Map<int, String> >
  {
    TLocale.ENGLISH: {
      1: 'jan',  2: 'feb',  3: 'mar',  4: 'apr',  5: 'may',  6: 'jun',
      7: 'jul',  8: 'aug',  9: 'sep', 10: 'oct', 11: 'nov', 12: 'dec',
    },
    TLocale.RUSSIAN: {
      1: 'янв',  2: 'фев',  3: 'мар',  4: 'апр',  5: 'май',  6: 'июн',
      7: 'июл',  8: 'авг',  9: 'сен', 10: 'окт', 11: 'ноя', 12: 'дек',
    },
  };

  static Map<int, String> GetItems([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<int, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String MonthToStr(int no, [TLocale? locale]) =>
      TLocaleSet.ValueByIdent(ShortMonthNames._items, no, locale) ?? '';

  static int? StringToMonth(String value, [TLocale? locale]) =>
      TLocaleSet.IdentByValue<int>(ShortMonthNames._items, value, locale);
}

abstract class LongMonthNames
{
  static final _items = <TLocale, Map<int, String> >
  {
    TLocale.ENGLISH: {
       1: 'January',  2: 'February',  3: 'March',
       4: 'April',    5: 'May',       6: 'June',
       7: 'July',     8: 'August',    9: 'September',
      10: 'October', 11: 'November', 12: 'December',
    },
    TLocale.RUSSIAN: {
       1: 'Январь',   2: 'Февраль',   3: 'Март',
       4: 'Апрель',   5: 'Май',       6: 'Июнь',
       7: 'Июль',     8: 'Август',    9: 'Сентябрь',
      10: 'Октябрь', 11: 'Ноябрь',   12: 'Декабрь',
    },
  };

  static Map<int, String> GetItems([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<int, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String MonthToStr(int no, [TLocale? locale]) =>
      TLocaleSet.ValueByIdent(LongMonthNames._items, no, locale) ?? '';

  static int? StringToMonth(String value, [TLocale? locale]) =>
      TLocaleSet.IdentByValue<int>(LongMonthNames._items, value, locale);
}

abstract class ShortDayNames
{
  static final _items = <TLocale, Map<int, String> >
  {
    TLocale.ENGLISH: {
      1: 'Sun',  2: 'Mon',  3: 'Tue',
      4: 'Wed',  5: 'Thu',  6: 'Fri',  7: 'Sat',
    },
    TLocale.RUSSIAN: {
      1: 'Вс',   2: 'Пн',   3: 'Вт',
      4: 'Ср',   5: 'Чт',   6: 'Пт',   7: 'Сб',
    },
  };

  static Map<int, String> GetItems([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<int, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String WeekdayToStr(int no, [TLocale? locale]) =>
      TLocaleSet.ValueByIdent(ShortDayNames._items, no, locale) ?? '';

  static int? StringToWeekday(String value, [TLocale? locale]) =>
      TLocaleSet.IdentByValue<int>(ShortDayNames._items, value, locale);
}

abstract class LongDayNames
{
  static final _items = <TLocale, Map<int, String> >
  {
    TLocale.ENGLISH: {
      1: 'Sunday',      2: 'Monday',      3: 'Tuesday',   4: 'Wednesday',
      5: 'Thursday',    6: 'Friday',      7: 'Saturday',
    },
    TLocale.RUSSIAN: {
      1: 'Воскресенье', 2: 'Понедельник', 3: 'Вторник',   4: 'Среда',
      5: 'Четверг',     6: 'Пятница',     7: 'Суббота',
    },
  };

  static Map<int, String> GetItems([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<int, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String WeekdayToStr(int no, [TLocale? locale]) =>
      TLocaleSet.ValueByIdent(LongDayNames._items, no, locale) ?? '';

  static int? StringToWeekday(String value, [TLocale? locale]) =>
      TLocaleSet.IdentByValue<int>(LongDayNames._items, value, locale);
}
