part of vcl;

class TCommand
{
  final int ID;
  final int Notify;
  TCommand(this.ID, this.Notify);

  String toString() => 'TCommand(ID: $ID, Notify: $Notify)';
}

class MESSAGE extends TEnum
{
  final int id;
  const MESSAGE( this.id, [ String name='' ] ) : super(name);

  bool operator >  (Object other) => other is MESSAGE && id>other.id;
  bool operator <  (Object other) => other is MESSAGE && id<other.id;

  bool operator >= (Object other) => other is MESSAGE && id>=other.id;
  bool operator <= (Object other) => other is MESSAGE && id<=other.id;
}

class MSG
{
  HWND    hwnd;
  MESSAGE message;
  dynamic wParam;
  dynamic lParam;

  MSG(this.hwnd, this.message, this.wParam, this.lParam);

	String toString() => 'msg: $message (0x${message.id.asHex(4)}), wParam: $wParam, lParam: $lParam';
}

class TMessage
{
  MESSAGE Msg;
  dynamic WParam;
  dynamic LParam;
  dynamic Result;

  TMessage(this.Msg, [this.WParam, this.LParam, this.Result]);

  String toString() => 'msg: $Msg (0x${Msg.id.asHex(4)}), wParam: $WParam, lParam: $LParam, Result: $Result';
}

class TCustomMessage
{

  final TMessage handle;

  MESSAGE get Msg => handle.Msg;

  dynamic get WParam => handle.WParam;
  dynamic get LParam => handle.LParam;

  dynamic get Result => handle.Result;
  void set Result(dynamic Value) => handle.Result = Value;

  TCustomMessage(this.handle);
  String toString() => 'type: $runtimeType, msg: $Msg, wParam: $WParam, lParam: $LParam';
}

/*
struct TWMNoParams
{
	unsigned Msg;
	Word Unused[4];
	int Result;
} ;
#pragma pack(pop)
**/
class TWMKey extends TCustomMessage
{
  int get CharCode => WParam;
  TShiftState get ShiftState => LParam;
  TWMKey(TMessage message) : super(message);
}

class TWMMouse extends TCustomMessage
{
  TShiftState get Shift => WParam;
  int get XPos => (LParam as POINT).x;
  int get YPos => (LParam as POINT).y;
  TPoint get Pos => TPoint.from(LParam);
  TWMMouse(TMessage message) : super(message);
}

class TWMMouseWheel extends TCustomMessage
{
  TShiftState get ShiftState => (WParam as TWheelInfo).ShiftState;
  int get WheelDelta => (WParam as TWheelInfo).WhellDelta;
  TPoint get Pos => LParam;

  TWMMouseWheel(TMessage message) : super(message);
}


class TWMWindowPosMsg extends TCustomMessage
{
  WINDOWPOS get WindowPos => (LParam as WINDOWPOS);
  TWMWindowPosMsg(TMessage message) : super(message);
}

class TWMCommand extends TCustomMessage
{
  int   get ItemID => (WParam as TCommand).ID;
  int   get NotifyCode => (WParam as TCommand).Notify;
  HWND? get Ctl => LParam;

  TWMCommand(TMessage message) : super(message);
}

class TWMGetMinMaxInfo extends TCustomMessage
{
  MINMAXINFO get MinMaxInfo => LParam;
  TWMGetMinMaxInfo(TMessage message) : super(message);
}

class TWMMove extends TCustomMessage
{
  int get XPos => (LParam as POINT).x;
  int get YPos => (LParam as POINT).y;
  TWMMove(TMessage message) : super(message);
}

class TWMNotify extends TCustomMessage
{
  int get IDCtrl => WParam as int;
  NMHDR get NMHdr => LParam as NMHDR;
  TWMNotify(TMessage message) : super(message);
}

class TWMPaint extends TCustomMessage
{
  TWMPaint(TMessage message) : super(message);
}

class TWMShowWindow extends TCustomMessage
{
  BOOL get Show => WParam as int;
  int  get Status => LParam as int;
  TWMShowWindow(TMessage message) : super(message);
}

class TWMSize extends TCustomMessage
{
  int get Width => (LParam as SIZE).cx;
  int get Height => (LParam as SIZE).cy;
  int get SizeType => WParam as int;
  TWMSize(TMessage message) : super(message);
}



class NMHDR
{
  final HWND?     hwndFrom;
  final int       idFrom;
  final int       code;         // NM_ code

  NMHDR(this.hwndFrom, this.idFrom, this.code);
}

class TWheelInfo
{
  int WhellDelta;
  TShiftState ShiftState;

  TWheelInfo(this.WhellDelta, this.ShiftState);
}

const MESSAGE WM_CREATE              = MESSAGE(0x0001, 'WM_CREATE');
const MESSAGE WM_MOVE                = MESSAGE(0x0003, 'WM_MOVE'); // wParam: null, lParam: POINT
const MESSAGE WM_SIZE                = MESSAGE(0x0005, 'WM_SIZE'); // wParam: int, lParam: SIZE
const MESSAGE WM_ACTIVATE            = MESSAGE(0x0006, 'WM_ACTIVATE'); //wParamHi: active, wParamLo: minimized, lParam: prevElem
const MESSAGE WM_SETFOCUS            = MESSAGE(0x0007, 'WM_SETFOCUS'); // wParam: node
const MESSAGE WM_KILLFOCUS           = MESSAGE(0x0008, 'WM_KILLFOCUS'); // wParam: node
const MESSAGE WM_ENABLE              = MESSAGE(0x000A, 'WM_ENABLE'); // wParam: (int) state
const MESSAGE WM_SETREDRAW           = MESSAGE(0x000B, 'WM_SETREDRAW');
const MESSAGE WM_SETTEXT             = MESSAGE(0x000C, 'WM_SETTEXT');
const MESSAGE WM_GETTEXT             = MESSAGE(0x000D, 'WM_GETTEXT');
const MESSAGE WM_PAINT               = MESSAGE(0x000F, 'WM_PAINT');
const MESSAGE WM_SHOWWINDOW          = MESSAGE(0x0018, 'WM_SHOWWINDOW');
const MESSAGE WM_SETCURSOR           = MESSAGE(0x0020, 'WM_SETCURSOR');
const MESSAGE WM_CHILDACTIVATE       = MESSAGE(0x0022, 'WM_CHILDACTIVATE');
const MESSAGE WM_GETMINMAXINFO       = MESSAGE(0x0024, 'WM_GETMINMAXINFO');
const MESSAGE WM_SETFONT             = MESSAGE(0x0030, 'WM_SETFONT');

const MESSAGE WM_WINDOWPOSCHANGING   = MESSAGE(0x0046, 'WM_WINDOWPOSCHANGING'); // wParam: null, lParam TElementPos
const MESSAGE WM_WINDOWPOSCHANGED    = MESSAGE(0x0047, 'WM_WINDOWPOSCHANGED'); // wParam: null, lParam TElementPos
const MESSAGE WM_NOTIFY              = MESSAGE(0x004E, 'WM_NOTIFY');
const MESSAGE WM_NCCREATE            = MESSAGE(0x0081, 'WM_NCCREATE');
const MESSAGE WM_NCCALCSIZE          = MESSAGE(0x0083, 'WM_NCCALCSIZE');
const MESSAGE WM_NCHITTEST           = MESSAGE(0x0084, 'WM_NCHITTEST');
const MESSAGE WM_GETDLGCODE          = MESSAGE(0x0087, 'WM_GETDLGCODE');

const MESSAGE WM_KEYFIRST            = WM_KEYDOWN;
const MESSAGE WM_KEYDOWN             = MESSAGE(0x0100, 'WM_KEYDOWN'); // wParam: code, lParam: TShiftState
const MESSAGE WM_KEYUP               = MESSAGE(0x0101, 'WM_KEYUP'); // wParam: code, lParam: TShiftState
const MESSAGE WM_CHAR                = MESSAGE(0x0102, 'WM_CHAR'); // wParam: code, lParam: TShiftState
const MESSAGE WM_UNICHAR             = MESSAGE(0x0109, 'WM_UNICHAR');
const MESSAGE WM_KEYLAST             = WM_UNICHAR;

const MESSAGE WM_COMMAND             = MESSAGE(0x0111, 'WM_COMMAND');
const MESSAGE WM_HSCROLL             = MESSAGE(0x0114, 'WM_HSCROLL'); // wParam: SCROLLPOS, lParam: null
const MESSAGE WM_VSCROLL             = MESSAGE(0x0115, 'WM_VSCROLL'); // wParam: SCROLLPOS, lParam: null
const MESSAGE WM_MOUSEDOWN           = MESSAGE(0x01FE, 'WM_MOUSEDOWN'); // wParam: MouseEvent, lParam: POINT(x, y)

const MESSAGE WM_MOUSEFIRST          = WM_MOUSEMOVE;
const MESSAGE WM_MOUSEMOVE           = MESSAGE(0x0200, 'WM_MOUSEMOVE'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_LBUTTONDOWN         = MESSAGE(0x0201, 'WM_LBUTTONDOWN'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_LBUTTONUP           = MESSAGE(0x0202, 'WM_LBUTTONUP'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_LBUTTONDBLCLK       = MESSAGE(0x0203, 'WM_LBUTTONDBLCLK'); // wParam: TShiftSate, lParam: POINT(x, y)

const MESSAGE WM_RBUTTONDOWN         = MESSAGE(0x0204, 'WM_RBUTTONDOWN'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_RBUTTONUP           = MESSAGE(0x0205, 'WM_RBUTTONUP'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_RBUTTONDBLCLK       = MESSAGE(0x0206, 'WM_RBUTTONDBLCLK'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_MBUTTONDOWN         = MESSAGE(0x0207, 'WM_MBUTTONDOWN'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_MBUTTONUP           = MESSAGE(0x0208, 'WM_MBUTTONUP'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_MBUTTONDBLCLK       = MESSAGE(0x0209, 'WM_MBUTTONDBLCLK'); // wParam: TShiftSate, lParam: POINT(x, y)
const MESSAGE WM_MOUSEWHEEL          = MESSAGE(0x020A, 'WM_MOUSEWHEEL'); // wParam: TWhellInfo, lParam: POINT
const MESSAGE WM_MOUSELAST           = WM_MOUSEWHEEL;

const MESSAGE WM_PARENTNOTIFY        = MESSAGE(0x0210, 'WM_PARENTNOTIFY'); // wParam: MESSAGE, lParam: HWND

const MESSAGE WM_COPY                = MESSAGE(0x0301, 'WM_COPY');  // wParam: DataTransfer, lParam ClipboardEvent
const MESSAGE WM_CUT                 = MESSAGE(0x0301, 'WM_CUT');   // wParam: DataTransfer, lParam ClipboardEvent
const MESSAGE WM_PASTE               = MESSAGE(0x0302, 'WM_PASTE'); // wParam: DataTransfer, lParam ClipboardEvent

const MESSAGE WM_EVENT               = MESSAGE(0x03FF, 'WM_EVENT'); // wParam: target, lParam: Event
const int WHEEL_DELTA                    = 100; // 120;


class EDIT_MESSAGE extends MESSAGE
{
  const EDIT_MESSAGE(int code, String name) : super(code, name);
}

const MESSAGE EM_FIRSTMESSAGE        = EDIT_MESSAGE(0x00B0, 'EM_FIRSTMESSAGE');

const MESSAGE EM_SETSEL              = EDIT_MESSAGE(0x00B1, 'EM_SETSEL');

const MESSAGE EM_GETLINECOUNT        = EDIT_MESSAGE(0x00BA, 'EM_GETLINECOUNT');
const MESSAGE EM_LINEINDEX           = EDIT_MESSAGE(0x00BB, 'EM_LINEINDEX');

const MESSAGE EM_LINELENGTH          = EDIT_MESSAGE(0x00C1, 'EM_LINELENGTH');
const MESSAGE EM_REPLACESEL          = EDIT_MESSAGE(0x00C2, 'EM_REPLACESEL');
const MESSAGE EM_GETLINE             = EDIT_MESSAGE(0x00C4, 'EM_GETLINE');
const MESSAGE EM_LIMITTEXT           = EDIT_MESSAGE(0x00C5, 'EM_LIMITTEXT');

const MESSAGE EM_SETREADONLY         = EDIT_MESSAGE(0x00CF, 'EM_SETREADONLY');

const MESSAGE EM_LASTMESSAGE         = EDIT_MESSAGE(0x00D9, 'EM_LASTMESSAGE');

class BUTTON_MESSAGE extends MESSAGE
{
  const BUTTON_MESSAGE(int code, String name) : super(code, name);
}

const MESSAGE BM_GETCHECK            = BUTTON_MESSAGE(0x00F0, 'BM_GETCHECK');
const MESSAGE BM_SETCHECK            = BUTTON_MESSAGE(0x00F1, 'BM_SETCHECK');
const MESSAGE BM_GETSTATE            = BUTTON_MESSAGE(0x00F2, 'BM_GETSTATE');
const MESSAGE BM_SETSTATE            = BUTTON_MESSAGE(0x00F3, 'BM_SETSTATE');
const MESSAGE BM_SETSTYLE            = BUTTON_MESSAGE(0x00F4, 'BM_SETSTYLE');


class COMBOBOX_MESSAGE extends MESSAGE
{
  const COMBOBOX_MESSAGE(int code, String name) : super(code, name);
}


const MESSAGE CB_SETEDITSEL          = COMBOBOX_MESSAGE(0x0142, 'CB_SETEDITSEL');
const MESSAGE CB_ADDSTRING           = COMBOBOX_MESSAGE(0x0143, 'CB_ADDSTRING');
const MESSAGE CB_DELETESTRING        = COMBOBOX_MESSAGE(0x0144, 'CB_DELETESTRING');

const MESSAGE CB_GETCOUNT            = COMBOBOX_MESSAGE(0x0146, 'CB_GETCOUNT');
const MESSAGE CB_GETCURSEL           = COMBOBOX_MESSAGE(0x0147, 'CB_GETCURSEL');
const MESSAGE CB_GETLBTEXT           = COMBOBOX_MESSAGE(0x0148, 'CB_GETLBTEXT');

const MESSAGE CB_INSERTSTRING        = COMBOBOX_MESSAGE(0x014A, 'CB_INSERTSTRING');
const MESSAGE CB_RESETCONTENT        = COMBOBOX_MESSAGE(0x014B, 'CB_RESETCONTENT');

const MESSAGE CB_SETCURSEL           = COMBOBOX_MESSAGE(0x014E, 'CB_SETCURSEL');

const MESSAGE CB_GETITEMDATA         = COMBOBOX_MESSAGE(0x0150, 'CB_GETITEMDATA');
const MESSAGE CB_SETITEMDATA         = COMBOBOX_MESSAGE(0x0151, 'CB_SETITEMDATA');

const MESSAGE CB_FINDSTRINGEXACT     = COMBOBOX_MESSAGE(0x0158, 'CB_FINDSTRINGEXACT');

const MESSAGE CB_SETDROPPEDWIDTH     = COMBOBOX_MESSAGE(0x0160, 'CB_SETDROPPEDWIDTH');

const MESSAGE CB_CREATEITEM          = COMBOBOX_MESSAGE(0x0162, 'CB_CREATEITEM'); // new
const MESSAGE CB_UPDATEITEM          = COMBOBOX_MESSAGE(0x0163, 'CB_UPDATEITEM'); // new
const MESSAGE CB_LASTMESSAGE         = COMBOBOX_MESSAGE(0x0163, 'CB_LASTMESSAGE');


class LISTBOX_MESSAGE extends MESSAGE
{
  const LISTBOX_MESSAGE(int code, String name) : super(code, name);
}

const MESSAGE LB_ADDSTRING           = LISTBOX_MESSAGE(0x0180, 'LB_ADDSTRING');
const MESSAGE LB_INSERTSTRING        = LISTBOX_MESSAGE(0x0181, 'LB_INSERTSTRING');
const MESSAGE LB_DELETESTRING        = LISTBOX_MESSAGE(0x0182, 'LB_DELETESTRING');

const MESSAGE LB_RESETCONTENT        = LISTBOX_MESSAGE(0x0184, 'LB_RESETCONTENT');
const MESSAGE LB_SETSEL              = LISTBOX_MESSAGE(0x0185, 'LB_SETSEL');
const MESSAGE LB_SETCURSEL           = LISTBOX_MESSAGE(0x0186, 'LB_SETCURSEL');
const MESSAGE LB_GETSEL              = LISTBOX_MESSAGE(0x0187, 'LB_GETSEL');
const MESSAGE LB_GETCURSEL           = LISTBOX_MESSAGE(0x0188, 'LB_GETCURSEL');
const MESSAGE LB_GETTEXT             = LISTBOX_MESSAGE(0x0189, 'LB_GETTEXT');
const MESSAGE LB_GETTEXTLEN          = LISTBOX_MESSAGE(0x018A, 'LB_GETTEXTLEN');
const MESSAGE LB_GETCOUNT            = LISTBOX_MESSAGE(0x018B, 'LB_GETCOUNT');

const MESSAGE LB_GETSELCOUNT         = LISTBOX_MESSAGE(0x0190, 'LB_GETSELCOUNT');

const MESSAGE LB_GETITEMDATA         = LISTBOX_MESSAGE(0x0199, 'LB_GETITEMDATA');
const MESSAGE LB_SETITEMDATA         = LISTBOX_MESSAGE(0x019A, 'LB_SETITEMDATA');

const MESSAGE LB_SETCARETINDEX       = LISTBOX_MESSAGE(0x019E, 'LB_SETCARETINDEX');
const MESSAGE LB_GETCARETINDEX       = LISTBOX_MESSAGE(0x019F, 'LB_GETCARETINDEX');

const MESSAGE LB_FINDSTRINGEXACT     = LISTBOX_MESSAGE(0x01A2, 'LB_FINDSTRINGEXACT');

const MESSAGE LB_LASTMESSAGE         = LISTBOX_MESSAGE(0x01A9, 'LB_LASTMESSAGE');


