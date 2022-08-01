part of vcl;

class Theme
{
//  static TColor get ActiveCaption => _active.GetColor(clActiveCaption);
//  static TColor get BtnFace => _active.GetColor(clBtnFace);

//  TColor GetColor(TColor color) => color;

  int? getColorRGB(TColor color)
  {
    switch(color)
    {
      case cl3DDkShadow:          return 0x696969;
      case cl3DLight:             return 0xe3e3e3;
      case clActiveBorder:        return 0x808080;
      case clActiveCaption:       return 0x6060ff; // 0xd1b499;
      case clActiveRecord:        return 0x6060ff; // 0x000080;
      case clAppWorkSpace:        return 0xababab;
      case clBackground:          return 0x000000;
      case clBtnFace:             return 0xe0e0e0; // 0xcccccc;
      case clBtnHighlight:        return 0xffffff;
      case clBtnShadow:           return 0x808080;
      case clBtnText:             return 0x000000;
      case clCaptionText:         return 0xffffff;
      case clDefault:             return null;
      case clGrayText:            return 0x6d6d6d;
      case clHighlight:           return 0xd77800;
      case clHighlightText:       return 0xffffff;
      case clInactiveBorder:      return 0x808080; //0xfcf7f4;
      case clInactiveCaption:     return 0x808080;
      case clInactiveCaptionText: return 0xffffff;
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
      default:                    return color.value & 0xffffff;
    }
  }


  static Theme _active = Theme();
  static Theme get Active => _active;
  static set Active(Theme theme)
  {
    if(_active == theme)
      return;

    _active = theme;
  }
}

