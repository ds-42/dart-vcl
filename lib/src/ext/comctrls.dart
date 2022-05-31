part of vcl;

class TRichEditTools extends TWinControl
{
  static String ROOT = 'richEdit/tools';
  static TAsset assetFormat = Assets[ROOT]['format'];

  static const ID_BOLD = TUserAction('bold');
  static const ID_ITALIC = TUserAction('italic');
  static const ID_UNDERLINE = TUserAction('underline');

  static const ID_JUSTIFY_LEFT = TUserAction('justifyLeft');
  static const ID_JUSTIFY_CENTER = TUserAction('justifyCenter');
  static const ID_JUSTIFY_RIGHT = TUserAction('justifyRight');
  static const ID_JUSTIFY_FULL = TUserAction('justifyFull');

  static const ID_CUT = TUserAction('cut');
  static const ID_COPY = TUserAction('copy');
  static const ID_PASTE = TUserAction('paste');

  static const ID_UNDO = TUserAction('undo');
  static const ID_REDO = TUserAction('redo');

  late final TFlexBox FormatBand;

  TFlexBox __createBand()
  {
    return TFlexBox(this)
      ..Align = TAlign.Top
      ..FlexItems.SetMargin(0, 1, 0, 1)
      ..Parent = this;
  }

  TBevel __createSeparate()
  {
    return TBevel(this)
      ..Shape = TBevelShape.LeftLine
      ..Flex.Grow = 0
      ..Flex.SetMargin(1, 2, 1, 2)
      ..Flex.BreakBefore = false
      ..Height = 22
      ..Width = 2
    ;
  }

  TSpeedButton __createButton(TUserAction id)
  {
    String key = getShortKey(id);
    if(key.isNotEmpty)
      key = ' ($key)';

    return TSpeedButton(this)
      ..Width = 24
      ..Height = 24
      ..Hint = '${ SysLocale.richEditTools('$id') }$key'
      ..ShowHint = true
      ..Tag = id
      ..Glyph.src = assetFormat[id.name].data
      ..OnClick = (Sender) => DoAction((Sender as TSpeedButton).Tag);
  }

  void DoAction(TUserAction id)
  {
    if(RichEdit!=null && RichEdit!.HandleAllocated())
    {
      var hre = RichEdit!.Handle as HRichEdit;

      hre.execCommand(id.name);
    }
  }

  TRichEditTools(TComponent? AOwner) : super(AOwner)
  {
    AutoSize = true;
    if(assetFormat.isEmpty)
    {
      assetFormat['$ID_BOLD']      = 'data:image/gif;base64,R0lGODlhEAAQAJH/AP///wAAAP///wAAACH/C0FET0JFOklSMS4wAt7tACH5BAEAAAIALAAAAAAQABAAAAIglI+py60BI2zR1HXvm0In6X1ceGTcFlgnApLOC8fyUQAAOw==';
      assetFormat['$ID_ITALIC']    = 'data:image/gif;base64,R0lGODlhEAAQAJH/AICAgAAAAP///wAAACH/C0FET0JFOklSMS4wAt7tACH5BAEAAAIALAAAAAAQABAAAAIblI+py+0BoTMQTAHkrTeHK3CTB4pNFIHqyoIFADs=';
      assetFormat['$ID_UNDERLINE'] = 'data:image/gif;base64,R0lGODlhEAAQAIABAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIhjI+py70AQYjy1XkVPJt13Hyfdo2JmJGRY6zs21IUTDMFADs=';

      assetFormat['$ID_JUSTIFY_LEFT']   = 'data:image/gif;base64,R0lGODlhEAAQAIABAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIZjI+pm+APIZshSoqr3Vlt11GfFSJjiaZKAQA7';
      assetFormat['$ID_JUSTIFY_CENTER'] = 'data:image/gif;base64,R0lGODlhEAAQAIABAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIYjI+pm+APIZsoPoqtBpjuPm0WyHzkiSoFADs=';
      assetFormat['$ID_JUSTIFY_RIGHT']  = 'data:image/gif;base64,R0lGODlhEAAQAIABAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIZjI+pm+APIZsqSrqsBrhv3jXfFTJfiaZIAQA7';
      assetFormat['$ID_JUSTIFY_FULL']   = 'data:image/gif;base64,R0lGODlhEAAQAIAAAAAAAP///yH5BAEAAAEALAAAAAAQABAAAAIajI+pm+APIZsh2kfZvXlt2ylfFDYjVqbqUQAAOw==';

      assetFormat['$ID_CUT']    = 'data:image/gif;base64,R0lGODlhEAAQAJECAAEAfgAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIolI+pcazoRHyy0cbCpPlC7UHhAYAjIJVXiaKV4rbGZsSvm9jpio9hAQA7';
      assetFormat['$ID_COPY']   = 'data:image/gif;base64,R0lGODlhEAAQAJEDAAEAfgAAAP///////yH5BAEAAAMALAAAAAAQABAAAAI5nI85wa0YhBTsmThjsFqDD0KTBIzf0THlVALXKJSBHHoAA5MLTN/t0rhheA/bjPJYERWg5skCjSYKADs=';
      assetFormat['$ID_PASTE']  = 'data:image/gif;base64,R0lGODlhEAAQAKIHAP/zvcDAwAEAfv//AP///wAAAIKCgv///yH5BAEAAAcALAAAAAAQABAAAANCeLrcXrA4FeEYVVLDC7AFZ2jhGJxoSXYZ1G1iHK+zYN+0KBA8b8O6no8gOJSCNyJOthP2BEfO7pYstpxPB25bnHgTADs=';

      assetFormat['$ID_UNDO']   = 'data:image/gif;base64,R0lGODlhEAAQAJECAAAAgICAgAAAAAAAACH5BAEAAAIALAAAAAAQABAAAAIglI+py+2vgAQhgSMR1fdG7n3YtITClGkVFJjQC8dyUwAAOw==';
      assetFormat['$ID_REDO']   = 'data:image/gif;base64,R0lGODlhEAAQAJECAAAAgICAgAAAAAAAACH5BAEAAAIALAAAAAAQABAAAAIglI+py+0vApjASTRP1atm3n3GllBkdApmCgTQC8fyjBQAOw==';
    }

    Width = 200;
    Height = 30;

    FormatBand = __createBand()
      ..Height = 26
      ..Add([
        __createButton(ID_BOLD),
        __createButton(ID_ITALIC),
        __createButton(ID_UNDERLINE),

        __createSeparate(),

        __createButton(ID_JUSTIFY_LEFT),
        __createButton(ID_JUSTIFY_CENTER),
        __createButton(ID_JUSTIFY_RIGHT),
        __createButton(ID_JUSTIFY_FULL),

        __createSeparate(),

        __createButton(ID_CUT),
        __createButton(ID_COPY),
        __createButton(ID_PASTE),

        __createSeparate(),

        __createButton(ID_UNDO),
        __createButton(ID_REDO),
      ]);
  }

  String getShortKey(TUserAction id)
  {
    switch(id)
    {
      case ID_BOLD: return 'Ctrl+B';
      case ID_ITALIC: return 'Ctrl+I';
      case ID_UNDERLINE: return 'Ctrl+U';

      case ID_CUT: return 'Ctrl+X';
      case ID_COPY: return 'Ctrl+C';
      case ID_PASTE: return 'Ctrl+V';

      case ID_UNDO: return 'Ctrl+Z';
      case ID_REDO: return 'Ctrl+Y';
      default: return '';
    }
  }

  TRichEdit? _richEdit;
  TRichEdit?
    get RichEdit => _richEdit;
    set RichEdit(TRichEdit? value) => _richEdit = value;
}