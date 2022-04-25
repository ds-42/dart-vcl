part of vcl;

class TRichEditTools extends TWinControl
{
  static String ROOT = 'richedit/tools';
  static TAsset assetFormat = Assets[ROOT]['format'];

  static TEnum ID_BOLD = TEnum('bold');
  static TEnum ID_ITALIC = TEnum('italic');
  static TEnum ID_UNDERLINE = TEnum('underline');

  static TEnum ID_JUSTIFY_LEFT = TEnum('justifyleft');
  static TEnum ID_JUSTIFY_CENTER = TEnum('justifycenter');
  static TEnum ID_JUSTIFY_RIGHT = TEnum('justifyright');
  static TEnum ID_JUSTIFY_FULL = TEnum('justifyFull');

  late final TFlexBox FormatBand;

  TFlexBox __createBand()
  {
    return TFlexBox(this)
      ..Align = TAlign.Top
      ..FlexItems.SetMargin(0, 1, 0, 1)
      ..Parent = this;
  }

  TSpeedButton __createButton(TEnum id, String hint)
  {
    return TSpeedButton(this)
      ..Width = 24
      ..Height = 24
      ..Hint = hint
      ..ShowHint = true
      ..Tag = id
      ..Glyph.src = assetFormat[id.name].data
      ..OnClick = (Sender) => DoAction((Sender as TSpeedButton).Tag);
  }

  void DoAction(TEnum id)
  {
    if(RichEdit!=null && RichEdit!.HandleAllocated())
    {
      var hre = RichEdit!.Handle as HRichEdit;
      hre.execCommand(id.name);
    }
  }

  TRichEditTools(TComponent? AOwner) : super(AOwner)
  {
    if(assetFormat.isEmpty)
    {
      assetFormat[ID_BOLD.name]      = 'data:image/gif;base64,R0lGODlhFgAWAID/AMDAwAAAACH5BAEAAAAALAAAAAAWABYAQAInhI+pa+H9mJy0LhdgtrxzDG5WGFVk6aXqyk6Y9kXvKKNuLbb6zgMFADs=';
      assetFormat[ID_ITALIC.name]    = 'data:image/gif;base64,R0lGODlhFgAWAKEDAAAAAF9vj5WIbf///yH5BAEAAAMALAAAAAAWABYAAAIjnI+py+0Po5x0gXvruEKHrF2BB1YiCWgbMFIYpsbyTNd2UwAAOw==';
      assetFormat[ID_UNDERLINE.name] = 'data:image/gif;base64,R0lGODlhFgAWAKECAAAAAF9vj////////yH5BAEAAAIALAAAAAAWABYAAAIrlI+py+0Po5zUgAsEzvEeL4Ea15EiJJ5PSqJmuwKBEKgxVuXWtun+DwxCCgA7';

      assetFormat[ID_JUSTIFY_LEFT.name]   = 'data:image/gif;base64,R0lGODlhEAAQAIABAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIZjI+pm+APIZshSoqr3Vlt11GfFSJjiaZKAQA7';
      assetFormat[ID_JUSTIFY_CENTER.name] = 'data:image/gif;base64,R0lGODlhEAAQAIABAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIYjI+pm+APIZsoPoqtBpjuPm0WyHzkiSoFADs=';
      assetFormat[ID_JUSTIFY_RIGHT.name]  = 'data:image/gif;base64,R0lGODlhEAAQAIABAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIZjI+pm+APIZsqSrqsBrhv3jXfFTJfiaZIAQA7';
      assetFormat[ID_JUSTIFY_FULL.name]   = 'data:image/gif;base64,R0lGODlhEAAQAIAAAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIajI+pm+APIZsh2kfZvXlt2ylfFDYjVqbqUQAAOw==';
    }

    Width = 200;
    Height = 30;

    FormatBand = __createBand()
      ..Add([
        __createButton(ID_BOLD,      'Выделенный'),
        __createButton(ID_ITALIC,    'Наклонный'),
        __createButton(ID_UNDERLINE, 'Подчеркнутый'),

        __createButton(ID_JUSTIFY_LEFT, 'По левому краю'),
        __createButton(ID_JUSTIFY_CENTER, 'По центру'),
        __createButton(ID_JUSTIFY_RIGHT, 'По правому краю'),
        __createButton(ID_JUSTIFY_FULL,  'По ширине'),
      ]);
  }

  TRichEdit? _richEdit;
  TRichEdit?
    get RichEdit => _richEdit;
    set RichEdit(TRichEdit? value) => _richEdit = value;
}