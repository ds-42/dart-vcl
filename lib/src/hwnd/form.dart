part of vcl;

class HForm extends HCustomControl
{
  static final FORM = CLASS_ID('FORM');
  CLASS_ID get classID => FORM;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.block }${ rule.font }'
      'border: 1px solid gray;'
      'box-shadow: 5px 5px 10px rgba(0,0,0,.25);'
      'background-color: ${ clBtnFace.html };'
//      'margin: 3px;'
      'box-sizing: border-box;');

    rule.add('.bounds',
      'position: absolute;'
      'left: -3px;'
      'top: -3px;'
      'right: -3px;'
      'bottom: -3px;'
    );

    rule.add('.client',
      'position: absolute;'
      'overflow: auto;');

    rule.add('.title',
      'background: radial-gradient(#6060ff, #a0a0ff);'
      'text-shadow: 1px  1px 0 #6060ff,'
                   '1px -1px 0 #6060ff,'
                  '-1px  1px 0 #6060ff,'
                  '-1px -1px 0 #6060ff;'
      'color: white;'
      'box-sizing: border-box;');

    rule.add('.inactive',
      'background: radial-gradient(#808080, #c0c0c0);'
      'text-shadow: 1px  1px 0 #808080,'
                   '1px -1px 0 #808080,'
                  '-1px  1px 0 #808080,'
                  '-1px -1px 0 #808080;');

    rule.add('.caption',
      '${ rule.inline }${ rule.no_select }'
      'padding: 4px 20px 4px 4px;'
      'font-family: Arial, sans-serif;'
      'font-size: 12pt;'
      'font-weight: bolder;'
      'line-height: 1;'
      'margin: 0;');

    rule.add('.btn-close',
      'font-size: 22px;'
      'position: absolute;'
      'right: 4px;'
      'top: -1px;'
      '-webkit-user-select: none;'
      '-moz-user-select: none;'
      '-ms-user-select: none;'
      'ser-select: none;');

    rule.add('.btn-close:hover',
      'text-shadow: 0px 0px 1px white;'
      'font-weight: bolder;'
      'color: red;');
  }

  static int _zOrder = 1000;
  static int get zOrder => _zOrder;

  final title = DivElement();
  final caption = HeadingElement.h2();
  final client = DivElement();
  final close = AnchorElement();
  final bounds = DivElement();

  CanvasElement? canvas;

  HWND? ownedWindow;

  Element getClientHandle() => client;

  void Close() => hide();



  HMENU? _menu;
  HMENU? get Menu => _menu;
  set Menu(HMENU? Value)
  {
    if(_menu == Value)
       return;

    if(_menu != null)
      _menu!.release();

    _menu = Value;

    if(_menu != null)
      handle.insertBefore(_menu!.handle, client);
  }

  HForm() : super()
  { 
    bounds.className  = 'bounds';
    caption.className= 'caption';
    client.className = 'client';
    title.className  = 'title';
    close.className  = 'btn-close';

    handle.append(bounds);

    handle.append(title);
    title.append(caption);
    title.append(close);
    handle.append(client);

    int cy = SysMetric.CaptionCy;
    if(cy > 0)
      title.style.height = '${cy}px';

    handle.style.width='320px';
    handle.style.height='240px';

    close.text = '×';
    close.onClick.listen((event) => Close() );

    client.style.zIndex = '0';



    bounds.owner = this;
    title.owner = this;
    caption.owner = this;
    close.owner = this;
    client.owner = this;
  }

  void release()
  { 
    super.release();
  }

  void insetRect(RECT rect)
  {
    _wnd.inset_rect.assign(rect);

    client.style
      ..left = '${rect.left}px'
      ..top = '${rect.top}px'
      ..right = '${rect.right}px'
      ..bottom = '${rect.bottom}px';

    if(canvas != null)
    {
      canvas!.style
        ..left = '${rect.left}px'
        ..top = '${rect.top}px';
//        ..right = '${rect.right}px'
//        ..bottom = '${rect.bottom}px';
//      canvas!.width = 300;
//      canvas!.height = 300;
    }
  }

  void _updateCanvasSize()
  {
    var rect = _wnd.client_rect;
    int w = rect.width - 2;
    int h = rect.height - 2;

    var cnv = canvas!;
    cnv.style.left = '${rect.left}px';
    cnv.style.top = '${rect.top}px';
    if(cnv.width!=w) cnv.width=w;
    if(cnv.height!=h) cnv.height=h;
  }

  void canvasNeeded()
  {
    if(canvas==null)
    {
      canvas = CanvasElement()
        ..style.position = 'absolute'
        ..style.zIndex = '-1';
      _updateCanvasSize();
      handle.insertBefore(canvas!, client);
    }
  }

  void set_window_rect(int left, int top, int width, int height)
  {
    if(canvas!=null)
      _updateCanvasSize();
    super.set_window_rect(left, top, width, height);
  }

  void dispatch(Element elem, TMessage message)
  {
    switch(message.Msg)
    {

      case WM_GETTEXT:
        message.Result = caption.text;
        break;

      case WM_SETTEXT:
        caption.text = message.LParam;
        break;

      case WM_NCHITTEST:
        POINT pos = message.LParam;
        var b = clientHandle.borderRect;
        message.Result = _wmHitTest(POINT(pos.x - b.left, pos.y-b.top));
        break;

      case WM_MOUSEMOVE:
//        print(_wmHitTest(message.LParam));
        String? type; // = 'default';
        switch(_wmHitTest(message.LParam))
        {
          case Windows.HTBOTTOMRIGHT: type = 'se'; break;
          case Windows.HTBOTTOM:      type = 's';  break;
          case Windows.HTBOTTOMLEFT:  type = 'sw'; break;
          case Windows.HTLEFT:        type = 'w';  break;
          case Windows.HTTOP:         type = 'n';  break;
          case Windows.HTTOPLEFT:     type = 'nw'; break;
          case Windows.HTTOPRIGHT:    type = 'ne'; break;
          case Windows.HTRIGHT:       type = 'e';  break;

          default:
            bounds.style.cursor=null;
            break;
        }
        if(type!=null)
          bounds.style.cursor='$type-resize';
        break;

      case WM_WINDOWPOSCHANGING:
        var pos = message.LParam as WINDOWPOS;
        if(!pos.flags.and(Windows.SWP_NOSIZE))
        {
          int cy = SysMetric.CaptionCy;
          if(pos.cx<100) pos.cx=100;
          if(pos.cy<cy)  pos.cy=cy;
        }
        super.dispatch(elem, message);
        break;



      default:
        super.dispatch(elem, message);
        break;
    }
  }

  void show()
  {

/*    handle.style.zIndex ='${ zOrder+1 }';*/


    super.show();
  }


  void hide()
  { 
    super.hide();

    if(handle.parent == null)
      return;
  //  zOrder--;
    handle.remove();
  }

  int _wmHitTest(POINT pos)
  {
    var m = bounds.borderRect;
    var c = clientHandle.borderRect;

    OffsetRect(m, -c.left, -c.top);
    if(PtInRect(m, pos) == false)
      return Windows.HTNOWHERE;

    var b = handle.borderRect;
    OffsetRect(b, -c.left, -c.top);

    if(!_wnd.dwStyle.and(Windows.WS_POPUP))
    {
      bool top = pos.y < b.top+2;
      bool left = pos.x < 0;
      bool right = pos.x > c.width;
      bool bottom = pos.y > c.height;

      if(top)
      {
        if(left)
          return Windows.HTTOPLEFT;
        if(right)
          return Windows.HTTOPRIGHT;
        return Windows.HTTOP;
      }

      if(bottom)
      {
        if(left)
          return Windows.HTBOTTOMLEFT;
        if(right)
          return Windows.HTBOTTOMRIGHT;
        return Windows.HTBOTTOM;
      }

      if(left)
        return Windows.HTLEFT;
      if(right)
        return Windows.HTRIGHT;
    }

    if(_wnd.dwStyle.and(Windows.WS_CAPTION))
    {
      if(Title && pos.y < b.top+SysMetric.CaptionCy)
        return Windows.HTCAPTION;
    }

    return Windows.HTCLIENT;
  }

  bool get Title => title.parent != null;
  void set Title(bool Value)
  {
    if(Title==Value)
      return;
    if(Value)
      handle.append(title);
    else
      title.remove();

  }

  void updateActive(bool state)
  {
    if(state)
      title.classes.remove('inactive');
    else
      title.classes.add('inactive');
  }
}
