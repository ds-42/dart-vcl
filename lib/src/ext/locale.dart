part of vcl;

class TLocale
{
  final String name;
  const TLocale(this.name);

  static const ENGLISH = TLocale('english');
  static const RUSSIAN = TLocale('russian');
}

abstract class Locale
{
  static TLocale? _active;

  static TLocale get active
  {
    if(_active == null)
      select(def ?? TLocale.ENGLISH);
    return _active!;
  }

  static set active(TLocale locale) =>
    select(locale);

  static TLocale? get def
  {
    var t = window.navigator.language.split('-');
    if(t.isEmpty)
      return null;
    return {
      'en': TLocale.ENGLISH,
      'ru': TLocale.RUSSIAN,
    } [t[0].toLowerCase()];
  }

  static bool selectDef()
  {
    var lng = def;
    if(lng==null)
      return false;
    return select(lng);
  }

  static bool select(TLocale locale)
  {
    if(_active == locale)
      return false;
    _active = locale;
    return update();
  }

  static bool update()
  {
    switch(active)
    {
      case TLocale.RUSSIAN:
        SysUtils.DecimalSeparator = CHAR.DOT;
        SysUtils.DateSeparator = CHAR.DOT;
        SysUtils.ShortDateFormat = 'dd.MM.yyyy';
        SysUtils.LongDateFormat = 'd MMMM yyyy \'г.\'';
        SysUtils.TimeSeparator = CHAR.COLON;
        SysUtils.TimeAMString = '';
        SysUtils.TimePMString = '';
        SysUtils.ShortTimeFormat = 'h:mm';
        SysUtils.LongTimeFormat = 'h:mm:ss';
        return true;

      default:
        SysUtils.DecimalSeparator = CHAR.COMMA;
        SysUtils.DateSeparator = CHAR.DIV;
        SysUtils.ShortDateFormat = 'dd/MM/yyyy';
        SysUtils.LongDateFormat = 'MMMM d, yyyy';
        SysUtils.TimeSeparator = CHAR.COLON;
        SysUtils.TimeAMString = 'am';
        SysUtils.TimePMString = 'pm';
        SysUtils.ShortTimeFormat = 'h:mm tt';
        SysUtils.LongTimeFormat = 'h:mm:ss tt';
        return active == TLocale.ENGLISH;
    }
  }

}

typedef TLocaleItems<T> = Map<TLocale, Map<T, String> >;

abstract class TLocaleSet
{
  static Map<T, String> GetItems<T>(TLocaleItems<T> items, TLocale type, [TLocale? defLocale])
  {
    var locale = items[type];
    if(locale == null)
    {
      if(defLocale!=null && defLocale!=type)
        return GetItems(items, defLocale, null);
      return Map<T, String>();
    }
    return Map<T, String>.from(locale);
  }

  static void Update<T>(TLocaleItems<T> items, TLocale locale, Map<T, String> recs)
  {
    if(items.containsKey(locale))
      items[locale]!.addAll(recs);
    else
      items[locale] = Map<T, String>.from(recs);
  }

  static String? ValueByIdent<T>(TLocaleItems<T> items, T ident, [TLocale? locale])
  {
    if(locale==null)
    {
      for(var data in items.entries)
      {
        var val = data.value[ident];
        if(val != null)
          return val;
      }
      return null;
    }

    var data = items[locale];
    if(data == null)
      return null;
    return data[ident];
  }

  static T? _identByValue<T>(Map<T, String> items, String value)
  {
    for(var rec in items.entries)
      if(rec.value.toLowerCase() == value)
        return rec.key;
    return null;
  }

  static T? IdentByValue<T>(TLocaleItems<T> items, String value, [TLocale? locale])
  {
    value = value.toLowerCase();
    if(locale == null)
    {
      for(var local in items.entries)
      {
        var ident = _identByValue<T>(local.value, value);
        if(ident!=null)
          return ident;
      }
      return null;
    }

    var data = items[locale];
    if(data == null)
      return null;
    return _identByValue<T>(data, value);
  }
}


class TLocaleText
{
  final String text;

  const TLocaleText(this.text);

  String toString() => SysLocale.text(this);

  String format(var args) => sprintf(text, args);
}

abstract class SysLocale
{
  static final _items = <TLocale, Map<TLocaleText, String> >
  {
    TLocale.RUSSIAN: {
      Error:   'Ошибка',
      Warning: 'Внимание',
    },
  };

  static Map<TLocaleText, String> GetData([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<int, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String text(TLocaleText key, [TLocale? locale]) =>
      TLocaleSet.ValueByIdent(SysLocale._items, key, locale ?? Locale.active) ?? key.text;

  static const Error = TLocaleText('Error');
  static const Warning = TLocaleText('Warning');
}




