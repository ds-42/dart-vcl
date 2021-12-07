part of vcl;

class COLORREF
{
  final int? _alpha;
  int get alpha => (_alpha ?? 255);

  final int blue;
  final int green;
  final int red;

  const COLORREF(this.red, this.green, this.blue, [this._alpha] );
  const COLORREF.rgb(int value, [int? alpha])  : this((value>>16)&0xff, (value>> 8)&0xff, (value)   &0xff, alpha);
  factory COLORREF.rgba(int? value)
  {
    if(value==null)
      return COLORREF(0, 0, 0, 0);
    return COLORREF((value>>24)&0xff, (value>>16)&0xff, (value>>8)&0xff, value&0xff);
  }

  int get gray => (red*76 + green*150 + blue*29) ~/ 255; // red*0.299 + green*0.587 + blue*0.114

  int get argb => (alpha<<24)+(red<<16)+(green<<8)+(red);
  int get rgba => (red<<24)+(green<<16)+(blue<<8)+(alpha);

  int get rgb => (red<<16)+(green<<8)+blue;

  String toString() => '#${ red.asHex(2) }${ green.asHex(2) }${ blue.asHex(2) }${ _alpha==null? '' : alpha.asHex(2) }';
}

class TColor
{
  final int value;
  final String? name;

  const TColor(this.value, [this.name]);

  factory TColor.mix(TColor clr1, TColor clr2)
  {
    int rgb1 = clr1.rgb ?? 0;
    int rgb2 = clr2.rgb ?? 0;

    int r = (((rgb1&0xff0000) + (rgb2&0xff0000))>>1)&0xff0000;
    int g = (((rgb1&0x00ff00) + (rgb2&0x00ff00))>>1)&0x00ff00;
    int b = (((rgb1&0x0000ff) + (rgb2&0x0000ff))>>1)&0x0000ff;
    return TColor(r | g | b);
  }

  factory TColor.parse(String data) =>
    StrToColor(data) ?? clNone;

  TColor _same(int red, int green, int blue)
  {
    int rgb = (red << 16) + (green << 8) + blue;
    if(this is TAlphaColor)
      return TAlphaColor(rgb, (this as TAlphaColor).alphaBlend);
    return TColor(rgb);
  }

  TColor alpha(int a) => TAlphaColor(value, a, name);

  int? get rgb
  {
    switch(this)
    {
      case cl3DDkShadow:          return 0x696969;
      case cl3DLight:             return 0xe3e3e3;
      case clActiveBorder:        return 0xb4b4b4;
      case clActiveCaption:       return 0xd1b499;
      case clActiveRecord:        return 0x6060ff; //0x000080;
      case clAppWorkSpace:        return 0xababab;
      case clBackground:          return 0x000000;
      case clBtnFace:             return 0xe0e0e0; //0xcccccc;
      case clBtnHighlight:        return 0xffffff;
      case clBtnShadow:           return 0x808080;
      case clBtnText:             return 0x000000;
      case clCaptionText:         return 0x000000;
      case clDefault:             return null;
      case clGrayText:            return 0x6d6d6d;
      case clHighlight:           return 0xd77800;
      case clHighlightText:       return 0xffffff;
      case clInactiveBorder:      return 0xfcf7f4;
      case clInactiveCaption:     return 0xdbcdbf;
      case clInactiveCaptionText: return 0x000000;
      case clInactiveRecord:      return 0x808080;
      case clInfoBk:              return 0xffffe0;
      case clInfoText:            return 0x000000;
      case clLinkBk:              return 0xffffd0;
      case clMenu:                return 0xf0f0f0;
      case clMenuText:            return 0x000000;
      case clNone:                return null;
      case clReadOnly:            return 0xdddddd;
      case clScrollBar:           return 0xc8c8c8;
      case clWindow:              return 0xffffff;
      case clWindowFrame:         return 0x646464;
      case clWindowText:          return 0x000000;
      default:                    return value & 0xffffff;
    }
  }

  int? get rgba
  {
    var tmp = rgb;
    if(tmp!=null)
      tmp = (tmp<<8)+0xff;
    return tmp;
  }

  /// Color to html format
  String get html
  {
    var tmp = rgb;
    if(tmp==null)
      return '';
    String clr=tmp.toRadixString(16);
    while(clr.length<6)
      clr='0'+clr;
    return "#$clr";

  }

  String alpha_s(int a)
  {
    a = a & 0xFF;
    String alf=a.toRadixString(16);
    if(a<16)
      alf = '0$alf';
    return '$html$alf';
  }

  String toString()
  {
    return name ?? '0x${value.toRadixString(16)}';
  }

  COLORREF? toColorRef()
  {
    var clr = rgb;
    if(clr==null)
      return null;
    return COLORREF.rgb(clr);
  }

  TColor mixWith(TColor clr) => TColor.mix(this, clr);

  TColor grayScale()
  {
    var clr = toColorRef();
    if(clr == null)
      return clDefault;

    return _same(clr.gray, clr.gray, clr.gray);
  }

  TColor tone(double val)
  {
    if(val == 0)
    {
      if(this is TAlphaColor)
        return TAlphaColor(value, (this as TAlphaColor).alphaBlend);
      return TColor(value);
    }
    var clr = toColorRef();
    if(clr == null)
      return clDefault;

    int red = clr.red;
    int green = clr.green;
    int blue = clr.blue;
    if(val>0)
    {
      if(val>1.0)
        val = 1.0;
      red = 255 - red;
      green = 255 - green;
      blue = 255 - blue;
    }
    else
    if(val<-1.0)
      val = -1.0;

    return _same(clr.red + (red * val).round(),
                 clr.green + (green * val).round(),
                 clr.blue + (blue * val).round());
  }

}

class TAlphaColor extends TColor
{
  final int alphaBlend;
  const TAlphaColor(int value, this.alphaBlend, [String? name]) : super(value, name);

  COLORREF? toColorRef()
  {
    var clr = rgb;
    if(clr==null)
      return null;
    return COLORREF.rgb(clr, alphaBlend);
  }

  int? get rgba
  {
    var tmp = rgb;
    if(tmp!=null)
      tmp = (tmp<<8)+(alphaBlend & 0xff);
    return tmp;
  }

  String get html
  {
    int a = alphaBlend & 0xFF;
    String alf=a.toRadixString(16);
    if(a<16)
      alf = '0$alf';
    return '${super.html}$alf';
  }

}

const TColor clNone       = TColor(0x1fffffff, 'clNone');
const TColor clDefault    = TColor(0x20000000, 'clDefault');

const TColor clAqua         = TColor(0x33cccc, 'clAqua');
const TColor clBlack        = TColor(0x000000, 'clBlack');
const TColor clBlue         = TColor(0x0000ff, 'clBlue');
const TColor clGold         = TColor(0xffcc00, 'clGold');
const TColor clGray         = TColor(0x808080, 'clGray');
const TColor clGreen        = TColor(0x008000, 'clGreen');
const TColor clFuchsia      = TColor(0xff00ff, 'clFuchsia');
const TColor clLightBlue    = TColor(0x3366ff, 'clLightBlue');
const TColor clLightOrange  = TColor(0xff9900, 'clLightOrange');
const TColor clLime         = TColor(0x99cc00, 'clLime');
const TColor clMaroon       = TColor(0x800000, 'clMaroon');
const TColor clNavy         = TColor(0x000080, 'clNavy');
const TColor clOlive        = TColor(0x808000, 'clOlive');
const TColor clPink         = TColor(0xff00ff, 'clPink');
const TColor clPlum         = TColor(0x993366, 'clPlum');
const TColor clPurple       = TColor(0x800080, 'clPurple');
const TColor clRed          = TColor(0xff0000, 'clRed');
const TColor clSilver       = TColor(0xc0c0c0, 'clSilver');
const TColor clTeal         = TColor(0x008080, 'clTeal');
const TColor clWhite        = TColor(0xffffff, 'clWhite');
const TColor clYellow       = TColor(0xffff00, 'clYellow');

const TColor clGray05       = TColor(0xF3F3F3, 'clGray05');
const TColor clGray10       = TColor(0xE6E6E6, 'clGray10');
const TColor clGray15       = TColor(0xD9D9D9, 'clGray15');
const TColor clGray20       = TColor(0xCCCCCC, 'clGray20');
const TColor clGray25       = TColor(0xC0C0C0, 'clGray25');
const TColor clGray30       = TColor(0xB3B3B3, 'clGray30');
const TColor clGray35       = TColor(0xA6A6A6, 'clGray35');
const TColor clGray40       = TColor(0x999999, 'clGray40');
const TColor clGray45       = TColor(0x8C8C8C, 'clGray45');
const TColor clGray50       = TColor(0x808080, 'clGray50');
const TColor clGray55       = TColor(0x737373, 'clGray55');
const TColor clGray60       = TColor(0x666666, 'clGray60');
const TColor clGray65       = TColor(0x595959, 'clGray65');
const TColor clGray70       = TColor(0x4C4C4C, 'clGray70');
const TColor clGray75       = TColor(0x404040, 'clGray75');
const TColor clGray80       = TColor(0x333333, 'clGray80');
const TColor clGray85       = TColor(0x262626, 'clGray85');
const TColor clGray90       = TColor(0x191919, 'clGray90');
const TColor clGray95       = TColor(0x0C0C0C, 'clGray95');


const TColor clScrollBar           = TColor(0x80000000, 'clScrollBar');
const TColor clBackground          = TColor(0x80000001, 'clBackground');
const TColor clActiveCaption       = TColor(0x80000002, 'clActiveCaption');
const TColor clInactiveCaption     = TColor(0x80000003, 'clInactiveCaption');
const TColor clMenu                = TColor(0x80000004, 'clMenu');
const TColor clWindow              = TColor(0x80000005, 'clWindow');
const TColor clWindowFrame         = TColor(0x80000006, 'clWindowFrame');
const TColor clMenuText            = TColor(0x80000007, 'clMenuText');
const TColor clWindowText          = TColor(0x80000008, 'clWindowText');
const TColor clCaptionText         = TColor(0x80000009, 'clCaptionText');
const TColor clActiveBorder        = TColor(0x8000000a, 'clActiveBorder');
const TColor clInactiveBorder      = TColor(0x8000000b, 'clInactiveBorder');
const TColor clAppWorkSpace        = TColor(0x8000000c, 'clAppWorkSpace');
const TColor clHighlight           = TColor(0x8000000d, 'clHighlight');
const TColor clHighlightText       = TColor(0x8000000e, 'clHighlightText');
const TColor clBtnFace             = TColor(0x8000000f, 'clBtnFace');
const TColor clBtnShadow           = TColor(0x80000010, 'clBtnShadow');
const TColor clGrayText            = TColor(0x80000011, 'clGrayText');
const TColor clBtnText             = TColor(0x80000012, 'clBtnText');
const TColor clInactiveCaptionText = TColor(0x80000013, 'clInactiveCaptionText');
const TColor clBtnHighlight        = TColor(0x80000014, 'clBtnHighlight');
const TColor cl3DDkShadow          = TColor(0x80000015, 'cl3DDkShadow');
const TColor cl3DLight             = TColor(0x80000016, 'cl3DLight');
const TColor clInfoText            = TColor(0x80000017, 'clInfoText');
const TColor clInfoBk              = TColor(0x80000018, 'clInfoBk');

// new
const TColor clReadOnly            = TColor(0x80001000, 'clReadOnly');
const TColor clActiveRecord        = TColor(0x80001001, 'clActiveRecord');
const TColor clInactiveRecord      = TColor(0x80001002, 'clInactiveRecord');
const TColor clLinkBk              = TColor(0x80001003, 'clLinkBk');

abstract class Colors
{
  static final _items = <TLocale, Map<TColor, String> >
  {
    TLocale.ENGLISH: {
      clBlack:   'black',
      clWhite:   'white',
      clMaroon:  'maroon',
      clGreen:   'green',
      clOlive:   'olive',
      clNavy:    'navy',
      clPurple:  'purple',
      clTeal:    'teal',
      clGray:    'gray',
      clSilver:  'silver',
      clRed:     'red',
      clLime:    'lime',
      clYellow:  'yellow',
      clBlue:    'blue',
      clFuchsia: 'fuchsia',
      clAqua:    'aqua',
    },
    TLocale.RUSSIAN: {
      clBlack:   'черный',
      clWhite:   'белый',
      clMaroon:  'коричневый',
      clGreen:   'зеленый',
      clOlive:   'оливковый',
      clNavy:    'синий',
      clPurple:  'пурпурный',
      clTeal:    'чайный',
      clGray:    'серый',
      clSilver:  'серебрянный',
      clRed:     'красный',
      clLime:    'салатовый',
      clYellow:  'желтый',
      clBlue:    'голубой',
      clFuchsia: 'розовый',
      clAqua:    'бирюзовый',
    },
  };

  static Map<TColor, String> GetColors([TLocale? locale]) =>
      TLocaleSet.GetItems(_items, locale ?? Locale.active, TLocale.ENGLISH);

  static void UpdateLocale(TLocale locale, Map<TColor, String> recs) =>
      TLocaleSet.Update(_items, locale, recs);

  static String ColorToStr(TColor color, [TLocale? locale]) =>
      TLocaleSet.ValueByIdent(Colors._items, color, locale) ?? color.html;

  static TColor? StringToColor(String value, [TLocale? locale])
  {
    return TLocaleSet.IdentByValue<TColor>(Colors._items, value, locale);
  }

  static TColor IntToColor(int val)
  {
    for(var local in _items.entries)
    {
      for(var clr in local.value.keys)
        if(clr.value==val)
          return clr;
    }
    return TColor(val);
  }
}

String ColorToStr(TColor color, [TLocale? lng] ) =>
  Colors.ColorToStr(color, lng);

TColor? StrToColor(String data, [TColor? def = clBlack, TLocale? lng] )
{
  if(data.isEmpty)
    return def;

  data = data.toLowerCase().trim();
  var tmp = data.split('(');
  if(tmp.length==2 && tmp[1].isNotEmpty) // rgb(r,g,b) || rgba(r,g,b,a)
  {
    var rgba = tmp[1].substring(0, tmp[1].length-1).split(',');
    if(tmp[0]=='rgb' && rgba.length==3 || tmp[0]=='rgba' && rgba.length==4)
    {
      int val = 0;
      for(int i=0; i<3; i++)
        val = val + (int.parse(rgba[i])<<((2-i)*8));

      double alpha = 1;
      if(rgba.length==4)
        alpha = double.parse(rgba[3]);
      if(alpha==1.0)
        return Colors.IntToColor(val);
      return TAlphaColor(val, (alpha*255).round());
    }
  }


  LPPTR src = LPPTR(data);

  if(src[0]==CHAR.HASH || src[1]==CHAR.x)
  {
    var res = 0;
    var inv = src.code!=CHAR.HASH;

    src.ptr+= src.code==CHAR.HASH? 1 : 2;
    if(src.eof)
      return def;

    int ptr = src.ptr;
    do
    {
      int? val = SysUtils.CharToHex(src.code);
      if(val==null)
        return def;
      res<<=4;
      res+=val;
    }
    while(src.next());
    if(src.ptr-ptr==3)  // expand 24 bit
      res = ((res&0x0f00)<<12) + ((res&0x0f00)<<8)+
            ((res&0x00f0)<<8)  + ((res&0xf0)<<4)+
            ((res&0x0f)<<4)    + (res&0x0f);
    if(inv)
      res = ((res&0xff)<<16) + (res&0xff00) + ((res&0xff0000)>>16);

    return Colors.IntToColor(res);
  }

  return Colors.StringToColor(data, lng) ?? def;
}
