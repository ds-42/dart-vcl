part of vcl;

class SysLocale extends TLocaleRoot
{
  static const DIALOGS = 'dialogs';
  static const RESULTS = 'results';
  static const RICH_EDIT = 'richEdit';
  static const SYSTEM = 'system';
  static const TOOLS = 'tools';

  static final root = SysLocale();

  static final system = TLocaleTree(SYSTEM, root);

  static final dialogs = TLocaleTree(DIALOGS, system);
  static final dialogResults = TLocaleTree(RESULTS, dialogs);

  static final richEdit = TLocaleTree(RICH_EDIT, system);
  static final richEditTools = TLocaleTree(TOOLS, richEdit);

  Map _init()
  {
    if(_data == null)
      _data = locale_en_EN;
    return _data!;
  }

  static void init()
  {
    switch(Locale.active)
    {
      case TLocale.RUSSIAN:
        root.select(locale_ru_RU);
        break;

      default:
        root.select(locale_en_EN);
        break;
    }
  }
}

abstract class SysLocaleDialogs
{
  static const ERROR = 'error';
  static const WARNING = 'warning';

  static final error = SysLocale.dialogs(ERROR);
  static final warning = SysLocale.dialogs(WARNING);

  static TLocaleItem result(TModalResult res) =>
      SysLocale.dialogResults('$res');
}