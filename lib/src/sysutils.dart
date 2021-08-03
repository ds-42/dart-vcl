part of vcl;

// Date and time record
class TTimeStamp
{
  int Time;      // Number of milliseconds since midnight
  int Date;      // One plus number of days since 1/1/0001
  TTimeStamp(this.Date, this.Time);
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


  static const int DateDelta = 693594;    // Days between 1/1/0001 and 12/31/1899
  static const int UnixDateDelta = 25569; // Days between TDateTime basis (12/31/1899) and Unix time_t basis (1/1/1970)

  static String ShortDateFormat = 'dd.MM.yyyy';

  static String LongTimeFormat = 'hh:mm:ss';


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



  static String Format(String format, var args)
  {
    return sprintf(format, args);
  }


  // The MonthDays array can be used to quickly find the number of
  //  days in a month:  MonthDays[IsLeapYear(Y), M]
  static List get MonthDays => SysDate.monthDays;

  static List MonthDaysOfYear(int year) =>
    MonthDays[ IsLeapYear(year)? 1 : 0 ];

  static int DaysOfMonth(int year, int month) =>
    MonthDays[ IsLeapYear(year)? 1 : 0 ][month-1];

  static final LeadBytes = <int>[];



  static void ConvertErrorFmt(dynamic ResString, var args)
  {
    throw EConvertError.CreateResFmt(ResString, args);
  }


  static String ExtractFileName(String FileName)
  {

    return FileName;
  }



  TTimeStamp DateTimeToTimeStamp(TDateTime DateTime)
  {
    return TTimeStamp(DateTime.Val.truncate()+726464, 0);
  
  }



  // Date encoding and decoding

  // IsLeapYear determines whether the given year is a leap year.
  static bool IsLeapYear(int year) => SysDate.isLeapYear(year);



  static List<int> DecodeDateFully(TDateTime Value)
  {
    final data = <int>[];
    int val = Value.AsSystem;
    Date d = SysDate.itod(val);
    data.add(d.year);
    data.add(d.month);
    data.add(d.day);
    data.add(SysDate.dayOfWeek(val));
    data.add( IsLeapYear(d.year)? 1 : 0 );
    return data;
  }



  static DateTime DecodeDate(TDateTime Value)
  {
    return Value.DecodeDate();
    
  }

  static DateTime DecodeDateTime(TDateTime Value)
  {
    return Value.Decode();
  }



  static TDateTime Now()
  {
    return TDateTime.CurrentDateTime();

  }



  // Date/time to string conversions

  static String DateTimeToString(String Format, TDateTime Value)
  {
    int AppendLevel = 0;
    final Buffer = <int>[];
    DateTime DateTimeValue = DecodeDateTime(Value);
  

    void AppendNumber(int Number, int Digits)
    {
      
      String tmp = Number.toString();
      List<int> buf = tmp.codeUnits;
      while(Digits-->buf.length)
        Buffer.add(48); // '0'
      Buffer.addAll(buf);
      
    }

    void AppendFormat(List<int> FormatSource)
    {
      bool Use12HourClock = false;
      int LastToken = KeyCode.SPACE;
      int Starter = 0;
      int Format = 0;

    

      int GetCount()
      {
        int Symbol = FormatSource[Starter];
        while(Format < FormatSource.length && FormatSource[Format] == Symbol)
          Format++;
        return Format - Starter;
      }
      

      if(FormatSource.isNotEmpty && AppendLevel < 2)
      {
        AppendLevel++;
        for(; Format<FormatSource.length;)
        {
          Starter = Format;
          Format++;
          int Symbol = FormatSource[Starter];
          if(LeadBytes.contains(Symbol))
          {
            LastToken = KeyCode.SPACE;
            continue;
          }
          int Token = Symbol;
          if(Token>=97 && Token<=122) // ['a'..'z']
            Token-=32;
          if(Token>=KeyCode.A && Token<=KeyCode.Z)
          {
            if(Token == KeyCode.M && LastToken == KeyCode.H)
              Token = KeyCode.N;
            LastToken = Token;
          }

          switch(Token)
          {
            case KeyCode.Y:
              int Count = GetCount();
                if(Count <= 2)
                  AppendNumber(DateTimeValue.year % 100, 2);
                else
                  AppendNumber(DateTimeValue.year, 4);
              break;
  
            case KeyCode.M:
              int Count = GetCount();
                switch(Count)
                {
                  case 1:
                  case 2:
                    AppendNumber(DateTimeValue.month, Count);
                    break;
                  case 3:
  
                    break;
                  default:
  
                    break;
                }
              break;

            case KeyCode.D:
              int Count = GetCount();
              switch(Count)
              {
                case 1:
                case 2:
                  AppendNumber(DateTimeValue.day, Count);
                  break;
  
              }
              break;
  
            case KeyCode.C:
              int Count = GetCount();
                AppendFormat(ShortDateFormat.codeUnits);

                if((DateTimeValue.hour != 0) || (DateTimeValue.minute != 0) || (DateTimeValue.second != 0))
                {
                  Buffer.add(KeyCode.SPACE);
                  AppendFormat(LongTimeFormat.codeUnits);
                }
              break;
  
            default:
              Buffer.add(Symbol);
              break;
          }
        }
        AppendLevel--;
      }
    }

    AppendFormat((Format.isEmpty? 'C' : Format).codeUnits);
    return String.fromCharCodes(Buffer);
  }



  bool ScanNumber(String S, Integer Pos, Integer Number, Integer CharCount)
  {
  //  I: Integer;
  //  N: Word;
    bool Result = false;
    CharCount.Value = 0;
  
    return Result;
  }

  

  TDateOrder GetDateOrder(String DateFormat)
  {
    TDateOrder Result = TDateOrder.MDY;
    for(int i = 0; i < DateFormat.length; i++)
    {
      switch(DateFormat[i])
      {
        case 'E': return TDateOrder.YMD;
        case 'Y': return TDateOrder.YMD;
        case 'M': return TDateOrder.MDY;
        case 'D': return TDateOrder.DMY;
      }
      i++;
    }
    return TDateOrder.MDY;
  }

  

  bool ScanDate(String S, Integer Pos, TDateTime Date)
  {
    int v = SysDate.atod(S);
    if(v == 0)
      return false;
    Date.AsSystem = v;
    return true;

  
  }
  

  TDateTime StrToDate(String S)
  {
    TDateTime Result = TDateTime();
    if(TryStrToDate(S, Result))
      return Result;
    throw EConvertError.CreateResFmt(RTLConsts.SInvalidDate, [S]);
  
  }

  TDateTime StrToDateDef(String S, TDateTime Default)
  {
    TDateTime Result = TDateTime();
    if(TryStrToDate(S, Result))
      return Result;
    return Default;
  }

  bool TryStrToDate(String S, TDateTime Value)
  {
    Integer Pos = Integer(1);
    return ScanDate(S, Pos, Value) && (Pos.Value > S.length);
  }

  TDateTime StrToTime(String S)
  {
  
    return TDateTime();
  }

  

  TDateTime StrToDateTime(String S)
  {
  
    return TDateTime();
  }

  

  bool TryStrToDateTime(String S, TDateTime Value)
  {
  
    return false;
  }

}