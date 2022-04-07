part of vcl;

class TPenStyle extends TEnum
{
  static const TPenStyle Clear            = TPenStyle('psClear', null);
  static const TPenStyle Solid            = TPenStyle('psSolid', []);
  static const TPenStyle Dash             = TPenStyle('psDash', [2,2]);
  static const TPenStyle Dot              = TPenStyle('psDot', [1,1]);
  static const TPenStyle DashDot          = TPenStyle('psDashDot', [2,1,1,1]);
  static const TPenStyle DashDotDot       = TPenStyle('psDashDotDot', [2,1,1,1,1,1]);
  static const TPenStyle NormalDash       = TPenStyle('psNormalDash', [6, 2]);
  static const TPenStyle NormalDashDot    = TPenStyle('psNormalDashDot', [6,1,1,1]);
  static const TPenStyle NormalDashDotDot = TPenStyle('psNormalDashDotDot', [6,1,1,1,1,1]);
  static const TPenStyle LongDash         = TPenStyle('psLongDash', [21,3]);
  static const TPenStyle LongDashDot      = TPenStyle('psLongDashDot', [21,2,1,2]);
  static const TPenStyle LongDashDotDot   = TPenStyle('psLongDashDotDot', [21,2,1,1,1,2]);


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

abstract class PenStyles
{
  static final _items = <TLocale, Map<TPenStyle, String> >
  {
    TLocale.ENGLISH: {
      TPenStyle.Clear:            'clear',
      TPenStyle.Solid:            'solid',
      TPenStyle.Dash:             'dash',
      TPenStyle.Dot:              'dot',
      TPenStyle.DashDot:          'dash dot',
      TPenStyle.DashDotDot:       'dash dot dot',
      TPenStyle.NormalDash:       'normal dash',
      TPenStyle.NormalDashDot:    'normal dash dot',
      TPenStyle.NormalDashDotDot: 'normal dash dot dot',
      TPenStyle.LongDash:         'long dash',
      TPenStyle.LongDashDot:      'long dash dot',
      TPenStyle.LongDashDotDot:   'long dash dot dot',
    },

    TLocale.RUSSIAN: {
      TPenStyle.Clear:            'прозрачный',
      TPenStyle.Solid:            'сплошной',
      TPenStyle.Dash:             'штриховой',
      TPenStyle.Dot:              'пунктирный',
      TPenStyle.DashDot:          'штрихпунктирный',
      TPenStyle.DashDotDot:       'штрих точка точка',
      TPenStyle.NormalDash:       'средний штрих',
      TPenStyle.NormalDashDot:    'средний штрихпунктир',
      TPenStyle.NormalDashDotDot: 'средний штрих точка точка',
      TPenStyle.LongDash:         'длинный штрих',
      TPenStyle.LongDashDot:      'длинный штрихпунктир',
      TPenStyle.LongDashDotDot:   'длинный штрих точка точка',
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


class TBrushStyle extends TEnum
{
  const TBrushStyle(String name) : super(name);

  static const TBrushStyle Solid      = TBrushStyle('Solid');
  static const TBrushStyle Clear      = TBrushStyle('Clear');
  static const TBrushStyle Horizontal = TMaskBrushStyle('Horizontal', [0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00]);
  static const TBrushStyle Vertical   = TMaskBrushStyle('Vertical',   [0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20]);
  static const TBrushStyle FDiagonal  = TMaskBrushStyle('FDiagonal',  [0x20, 0x40, 0x80, 0x01, 0x02, 0x04, 0x08, 0x10]);
  static const TBrushStyle BDiagonal  = TMaskBrushStyle('BDiagonal',  [0x20, 0x10, 0x08, 0x04, 0x02, 0x01, 0x80, 0x40]);
  static const TBrushStyle Cross      = TMaskBrushStyle('Cross',      [0x20, 0x20, 0xff, 0x20, 0x20, 0x20, 0x20, 0x20]);
  static const TBrushStyle DiagCross  = TMaskBrushStyle('DiagCross',  [0x81, 0x42, 0x24, 0x18, 0x18, 0x24, 0x42, 0x81]);
}

abstract class TPatternBrushStyle extends TBrushStyle
{
  const TPatternBrushStyle(String name) : super(name);

  CanvasPattern getPattern(TColor? color);
}

class TMaskBrushStyle extends TPatternBrushStyle
{
  final List<int> mask;
  const TMaskBrushStyle(String name, this.mask) : super(name);

  CanvasPattern getPattern(TColor? color)
  {
    if(color==null)
      color=clBlack;

    var cnv = OffscreenCanvas(8, mask.length);
    var ctx = cnv.getContext('2d') as OffscreenCanvasRenderingContext2D;
    var img = ctx.createImageData(8, mask.length);

    var rgba = color.rgba ?? 0;

    int alpha = rgba       & 0xff;
    int red   = (rgba>>24) & 0xff;
    int green = (rgba>>16) & 0xff;
    int blue  = (rgba>> 8) & 0xff;
    for(int ndx=0, j=0; j<img.height; j++)
    {
      int bits = mask[j];
      for(int i=0; i<img.width; i++, ndx+=4)
      {
        if(bits&(1<<i) == 0)
          img.data[ndx+3] = 0;
        else
        {
          img.data[ndx+0] = red;
          img.data[ndx+1] = green;
          img.data[ndx+2] = blue;
          img.data[ndx+3] = alpha;
        }
      }
    }
    ctx.putImageData(img, 0, 0);
    return ctx.createPattern(cnv, 'repeat')!;
  }
}


abstract class BrushStyles
{
  static final _items = <TLocale, Map<TBrushStyle, String> >
  {
    TLocale.ENGLISH: {
      TBrushStyle.Clear:       'clear',
      TBrushStyle.Solid:       'solid',
      TBrushStyle.Horizontal:  'horizontal',
      TBrushStyle.Vertical:    'vertical',
      TBrushStyle.FDiagonal:   'forward diagonal',
      TBrushStyle.BDiagonal:   'backward diagonal',
      TBrushStyle.Cross:       'crossing lines',
      TBrushStyle.DiagCross:   'crossing diagonal',
    },

    TLocale.RUSSIAN: {
      TBrushStyle.Clear:       'прозрачная',
      TBrushStyle.Solid:       'сплошная',
      TBrushStyle.Horizontal:  'горизонтальная',
      TBrushStyle.Vertical:    'вертикальная',
      TBrushStyle.FDiagonal:   'прямая диагональ',
      TBrushStyle.BDiagonal:   'обратная диагональ',
      TBrushStyle.Cross:       'пересечение линий',
      TBrushStyle.DiagCross:   'диагональное пересечение',
    },
  };

  static Map<TBrushStyle, String> GetStyles([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<TBrushStyle, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String StyleToStr(TBrushStyle style, [TLocale? locale]) =>
      TLocaleSet.ValueByIdent(BrushStyles._items, style, locale) ?? style.name;

  static TBrushStyle? StringToStyle(String value, [TLocale? locale]) =>
      TLocaleSet.IdentByValue<TBrushStyle>(BrushStyles._items, value, locale);
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