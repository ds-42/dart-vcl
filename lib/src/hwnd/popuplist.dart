part of vcl;

class HPopupList extends HPopupControl
{
  static final POPUPLIST = CLASS_ID('POPUPLIST');
  CLASS_ID get classID => POPUPLIST;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.font }${ rule.no_select }'
      'margin: 0;'
      'padding: 0;'
      'width: 150px;'
      'height: 100px;'
      'overflow-y: auto;'
      'border: 1px solid gray;'
      'position: absolute;'
      'background: #fff;'
      'box-shadow: 2px 2px 5px rgba(0,0,0,.25);'
      'box-sizing: border-box;'
      'white-space: nowrap;');

    rule.add('li',
      'list-style: none;'
      'padding: 1px 3px;'
      'overflow:hidden;'
      'line-height:1;');
    rule.add('li.active',
      'background-color: #a0a0ff;'
      'color: white;');
    rule.add('li:hover',
      'background-color: #a0a0ff;'
      'color: white;');

    rule.addRule('.coloritem span',
      'border: 1px solid gray;'
      'display: inline-block;'
      'width: 11px;'
      'height: 11px;'
      'margin: 0px 3px 0px 0px;'
      'vertical-align: middle;');
  }

  HWND? control;

  HPopupList() : super.elem(UListElement())
  {
    WNDPROC? defproc;
    defproc = Windows.ChangeWindowProc(this, (elem, message)
    { // mainproc
      switch(message.Msg)
      {
        case WM_SHOWWINDOW:
          if(control!=null)
          {
            var rect = TRect();
            Windows.GetWindowRect(control!, rect);
            style
              ..left = '${rect.left}px'
              ..top = '${rect.bottom-1}px'
              ..width = '${rect.width}px'
              ..zIndex ='${HForm.zOrder+1}';
          }
          defproc!(elem, message);
          break;

        case WM_LBUTTONDOWN:
          POINT pt = message.LParam;
          var rect = handle.client;
          // test mouse in client rect
          if(pt.x<rect.left || pt.x>rect.right || pt.y<rect.top || pt.y>rect.bottom)
            break;

          // find element
          pt = Windows.GetCursorPos();
          Element? elem = document.elementFromPoint(pt.x, pt.y);
          while(elem!=null)
          {
            if(elem.parent == handle)
            {
              
              if(control!=null)
                Windows.SendMessage(control!, CB_SETCURSEL, handle.children.indexOf(elem));
              break;
            }
            elem = elem.parent;
          }
          Windows.ShowWindow(this, Windows.SW_HIDE);
          break;
      
        default:
          defproc!(elem, message);
          break;
      }
    });

  }

  LIElement addItem(String text)
  {
    var item = LIElement();
    item.text = text;
    handle.append(item);
    return item;
  }
}
