part of vcl;

class TLanguage
{
  final String name;
  const TLanguage(this.name);

  static const ENGLISH = TLanguage('english');
  static const RUSSIAN = TLanguage('russian');
}

abstract class TLocal
{
  static void onChange(Type type)
  {
    // append: call application event
  }

  static TLanguage _language = TLanguage.ENGLISH;
  static TLanguage get language => _language;
  static set language(TLanguage lng)
  {
    if(_language == lng)
      return;
    _language = lng;
    onChange(TLanguage);
  }

  static String _dateFormat = DateFormat.YYYYMMDD_m;
  static String get dateFormat => _dateFormat;
  static set dateFormat(String format)
  {
    if(_dateFormat == format)
      return;
    _dateFormat = format;
    onChange(DateFormat);
  }

  static String _dateOrder = DateOrder.ymd;
  static String get dateOrder => _dateOrder;
  static set dateOrder(String order)
  {
    if(_dateOrder == order)
      return;
    _dateOrder = order;
    onChange(DateOrder);
  }

}

typedef TLocalItems<T> = Map<TLanguage, Map<T, String> >;

abstract class TLocalSet
{
  static Map<T, String> GetItems<T>(TLocalItems<T> items, TLanguage language, [TLanguage? defLangage])
  {
    var local = items[language];
    if(local==null)
    {
      if(defLangage!=null && defLangage!=language)
        return GetItems(items, defLangage, null);
      return Map<T, String>();
    }
    return Map<T, String>.from(local);
  }

  static void UpdateLocal<T>(TLocalItems<T> items, TLanguage language, Map<T, String> recs)
  {
    if(items.containsKey(language))
      items[language]!.addAll(recs);
    else
      items[language] = Map<T, String>.from(recs);
  }

  static String? ValueByIdent<T>(TLocalItems<T> items, T ident, [TLanguage? language])
  {
    if(language==null)
    {
      for(var local in items.entries)
      {
        var val = local.value[ident];
        if(val!=null)
          return val;
      }
      return null;
    }

    var local = items[language];
    if(local==null) return null;
    return local[ident];
  }

  static T? _identByValue<T>(Map<T, String> items, String value, TLanguage? language)
  {
    for(var rec in items.entries)
      if(rec.value.toLowerCase() == value)
        return rec.key;
    return null;
  }

  static T? IdentByValue<T>(TLocalItems<T> items, String value, [TLanguage? language])
  {
    value = value.toLowerCase();
    if(language==null)
    {
      for(var local in items.entries)
      {
        var ident = _identByValue<T>(local.value, value, language);
        if(ident!=null)
          return ident;
      }
      return null;
    }

    var local = items[language];
    if(local==null) return null;
    return _identByValue<T>(local, value, language);
  }
}
