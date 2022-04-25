part of vcl;

class TNodeStyle
{
  static final _styleHandle = StyleElement();
  static CssStyleSheet? _styleSheet;
  static final _styles = <String>{ };

  CssStyleSheet get sheet => _styleSheet!;
  final CLASS_ID classId;

  String get prefix => '';

  TNodeStyle(this.classId)
  {
    if(_styleSheet==null)
    {
      document.head!.append(_styleHandle);
      _styleSheet = _styleHandle.sheet as CssStyleSheet;
    }
  }

  void add(String ext, String data)
  {
    if(ext.isEmpty)
      sheet.addRule('$prefix$classId', data);
    else
      sheet.addRule('$prefix$classId $ext', data);
  }

  void addRule(String name, String data)
  {
    sheet.addRule(name, data);
  }

  String get block =>
    'display:block;'
    'position:absolute;';

  String get flex =>
    'display:flex;'
    'position:absolute;';

  String get borderBox =>
    '-moz-box-sizing:border-box;'
    '-webkit-box-sizing:border-box;'
    'box-sizing:border-box;';

  String get font =>
    'font-family:${ Windows.sysFontFamily };'
    'font-size:${ Windows.sysFontSize }pt;';

  String get inline =>
    'white-space:nowrap;'
    'overflow:hidden;'
    'text-overflow:ellipsis;';

  String get no_select =>
    'user-select:none;'
    '-webkit-user-select:none;'
    '-moz-user-select:none;'
    '-ms-user-select:none;';

  String get softBorder =>
    'border: 1px solid #A0A0A0;';

  void addFocusStyle([subClass='focus-within'])
  {
    sheet.addRule('$prefix$classId:$subClass',
      'outline: #4D90FE solid 1px;'
      'outline-offset: 0;');

  }

}
