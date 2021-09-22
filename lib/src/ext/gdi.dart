part of vcl;

enum DRAWTEXT  {
CENTER, 
}

void DrawText(HDC hDC,    // device context
    String text,          // text for draw
    RECT rect,            // size of format field
    Set<DRAWTEXT> format) // draw params
{
  int x = rect.left;
  int y = rect.top;
  if(format.contains(DRAWTEXT.CENTER))
  {
    var m = hDC.measureText(text);
    y+=(rect.height-m!.fontBoundingBoxDescent!.toInt()) ~/ 2;
  }
 
  hDC.fillText(x, y, text);
}

class TPenStyle extends TEnum
{
  final List<num>? rule;
  const TPenStyle(String name, this.rule) : super(name);

  List<num>? sizedDash(num size)
  {
    if(rule==null)
      return null;

    var items = List<num>.from(rule!);
    for(int i=0; i<items.length; i++)
      items[i] = (items[i] + (i&1==0? -1 : 1) ) * size;
    return items;
  }

  void preview(CanvasElement cnv, {int size = 3, TColor color = clBlack})
  {
    if(rule==null)
      return;

    var ctx = cnv.context2D;
    int y = cnv.height! ~/ 2 + 1;

    ctx
      ..strokeStyle = color.html
      ..lineCap = 'round'
      ..lineWidth = size;

    if(rule!.isNotEmpty)
      ctx.setLineDash( sizedDash(size)! );

    ctx
      ..beginPath()
      ..moveTo(5, y)
      ..lineTo(cnv.width! - 10, y)
      ..stroke();
  }
}

const TPenStyle psClear            = TPenStyle('psClear', null);
const TPenStyle psSolid            = TPenStyle('psSolid', []);
const TPenStyle psDash             = TPenStyle('psDash', [2,2]);
const TPenStyle psDot              = TPenStyle('psDot', [1,1]);
const TPenStyle psDashDot          = TPenStyle('psDashDot', [2,1,1,1]);
const TPenStyle psDashDotDot       = TPenStyle('psDashDotDot', [2,1,1,1,1,1]);
const TPenStyle psNormalDash       = TPenStyle('psNormalDash', [6, 2]);
const TPenStyle psNormalDashDot    = TPenStyle('psNormalDashDot', [6,1,1,1]);
const TPenStyle psNormalDashDotDot = TPenStyle('psNormalDashDotDot', [6,1,1,1,1,1]);
const TPenStyle psLongDash         = TPenStyle('psLongDash', [21,3]);
const TPenStyle psLongDashDot      = TPenStyle('psLongDashDot', [21,2,1,2]);
const TPenStyle psLongDashDotDot   = TPenStyle('psLongDashDotDot', [21,2,1,1,1,2]);

abstract class PenStyles
{
  static final _items = <TLocale, Map<TPenStyle, String> >
  {
    TLocale.ENGLISH: {
      psClear:           'clear',
      psSolid:            'solid',
      psDash:             'dash',
      psDot:              'dot',
      psDashDot:          'dash dot',
      psDashDotDot:       'dash dot dot',
      psNormalDash:       'normal dash',
      psNormalDashDot:    'normal dash dot',
      psNormalDashDotDot: 'normal dash dot dot',
      psLongDash:         'long dash',
      psLongDashDot:      'long dash dot',
      psLongDashDotDot:   'long dash dot dot',
    },
    TLocale.RUSSIAN: {
      psClear:            'прозрачный',
      psSolid:            'сплошной',
      psDash:             'штриховой',
      psDot:              'пунктирный',
      psDashDot:          'штрихпунктирный',
      psDashDotDot:       'штрих точка точка',
      psNormalDash:       'средний штрих',
      psNormalDashDot:    'средний штрихпунктир',
      psNormalDashDotDot: 'средний штрих точка точка',
      psLongDash:         'длинный штрих',
      psLongDashDot:      'длинный штрихпунктир',
      psLongDashDotDot:   'длинный штрих точка точка',
    },
  };

  static Map<TPenStyle, String> GetStyles([TLocale? locale]) =>
    TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<TPenStyle, String> recs) =>
    TLocaleSet.Update(_items, locale, recs);

  static String StyleToStr(TPenStyle style, [TLocale? locale]) =>
    TLocaleSet.ValueByIdent(PenStyles._items, style, locale) ?? style.name;

  static TPenStyle? StringToStyle(String value, [TLocale? locale]) =>
    TLocaleSet.IdentByValue<TPenStyle>(PenStyles._items, value, locale);
}

typedef void ENUM_FONT_FAMILY_PROC(String name);
void EnumFontFamilies(ENUM_FONT_FAMILY_PROC enumProc)
{
  for(var font in FONT_NAMES)
    if(document.fonts!.check('12px "${font}"'))
      enumProc(font);

}


final FONT_NAMES = [
  'American Typewriter', // iOS
  'Andale Mono', // iOS
  'Arial',
  'Arial Black',
  'Arial Narrow', // iOS
  'Arial Rounded MT Bold', // iOS
  'Arial Unicode MS', // iOS
  'Avenir', // iOS
  'Avenir Next', // iOS
  'Avenir Next Condensed', // iOS
  'Baskerville', // iOS
  'Bahnschrift',
  'Big Caslon', // iOS
  'Bodoni 72', // iOS
  'Bodoni 72 Oldstyle', // iOS
  'Bodoni 72 Smallcaps', // iOS
  'Bradley Hand', // iOS
  'Brush Script MT', // iOS
  'Calibri',
  'Cambria',
  'Cambria Math',
  'Candara',
  'Chalkboard', // iOS
  'Chalkboard SE', // iOS
  'Chalkduster', // iOS
  'Charter', // iOS
  'Cochin', // iOS
  'Comic Sans MS',
  'Copperplate', // iOS
  'Consolas',
  'Constantia',
  'Corbel',
  'Courier', // iOS
  'Courier New',
  'Didot', // iOS
  'DIN Alternate', // iOS
  'DIN Condensed', // iOS
  'Ebrima',
  'Franklin Gothic Medium',
  'Futura', // iOS
  'Gabriola',
  'Gadugi',
  'Geneva', // iOS
  'Georgia',
  'Gill Sans', // iOS
  'Helvetica', // iOS
  'Helvetica Neue', // iOS
  'Herculanum', // iOS
  'Hoefler Text', // iOS
  'HoloLens MDL2 Assets',
  'Impact',
  'Ink Free',
  'Javanese Text',
  'Leelawadee UI',
  'Lucida Console',
  'Lucida Grande', // iOS
  'Lucida Sans Unicode',
  'Luminari', // iOS
  'Malgun Gothic',
  'Marker Felt', // iOS
  'Marlett',
  'Menlo', // iOS
  'Microsoft Himalaya',
  'Microsoft JhengHei',
  'Microsoft New Tai Lue',
  'Microsoft PhagsPa',
  'Microsoft Sans Serif',
  'Microsoft Tai Le',
  'Microsoft YaHei',
  'Microsoft Yi Baiti',
  'MingLiU-ExtB',
  'Monaco', // iOS
  'Mongolian Baiti',
  'MS Gothic',
  'MV Boli',
  'Myanmar Text',
  'Nirmala UI',
  'Noteworthy', // iOS
  'Optima', // iOS
  'Palatino', // iOS
  'Palatino Linotype',
  'Papyrus', // iOS
  'Phosphate', // iOS
  'Rockwell', // iOS
  'Segoe MDL2 Assets',
  'Segoe Print',
  'Segoe Script',
  'Segoe UI',
  'Segoe UI Historic',
  'Segoe UI Emoji',
  'Segoe UI Symbol',
  'Savoye LET', // iOS
  'SignPainter', // iOS
  'SimSun',
  'Sitka',
  'Skia', // iOS
  'Snell Roundhand', // iOS
  'Sylfaen',
  'Symbol',
  'Tahoma',
  'Times', // iOS
  'Times New Roman',
  'Trattatello', // iOS
  'Trebuchet MS',
  'Verdana',
  'Webdings',
  'Wingdings',
  'Yu Gothic',
  'Zapfino',
];