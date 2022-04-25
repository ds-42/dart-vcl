part of vcl;

typedef dynamic ENUMPROC(dynamic elem);

class _NodeInfo
{
  bool def = false;
  bool close = true;
}

class HRichEdit extends HControl
{
  static final RICHEDIT = CLASS_ID('RICHEDIT');
  CLASS_ID get classID => RICHEDIT;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      '${ rule.softBorder }'
      'background-color: white;'
    );

    rule.add('.client',
     'left: 1px;'
     'top: 1px;'
     'right: 1px;'
     'bottom: 1px;'
     'overflow: auto;'
     'outline: none;'
    );
  }

  final client = DivElement();

  Element getClientHandle() => client;

  HRichEdit() : super( DivElement() )
  {
    client
      ..className = 'client'
      ..contentEditable = 'true'
      ..spellcheck = false
      ..innerHtml = '<div><br></div>'
      ..owner = this;

    handle.append(client);
  }

  static const int NEED_LF      = 0x0001; // return end of line
  static const int NEED_EOT     = 0x0002; // return end of text

  static const int NEED_CHARS   = 0x0004; // return data as <int>[]
  static const int NEED_STRINGS = 0x0008; // return data as String
  static const int NEED_SIZE    = 0x000C; // return data as Length
  static const int NEED_NODE    = 0x0010; // return data as Node
  static const int NEED_TEXT    = 0x0020; // return data as Text

  static const int DATA_MASK    = 0x000C;

  bool _export(ENUMPROC proc, List<int> data, int keys)
  {
    if( keys & NEED_SIZE == NEED_SIZE )
    {
      if( proc(data.length) == false )
        return false;
    }
    else
    {
      if( keys.and(NEED_CHARS) && proc(data) == false )
        return false;

      if( keys.and(NEED_STRINGS) && proc(String.fromCharCodes(data)) == false )
        return false;
    }
    return true;
  }

  List<int> getChars(Text text)
  {
    var codes = List<int>.from(text.text!.codeUnits);
    // TODO: normal data
    return codes;
  }

  bool enumChars(ENUMPROC proc, [int keys = NEED_STRINGS | NEED_LF])
  {
    dynamic doEnum(Node node, _NodeInfo info)
    {
      for(var elem in node.nodes)
      {
        if(keys.and(NEED_NODE) && proc(elem) == false)
          return false;

        if(elem.nodeType == Node.TEXT_NODE)
        { // <TEXT>
          if(keys.and(NEED_TEXT) && proc(elem) == false)
            return false;

          if(keys.and(DATA_MASK) && elem.text != null)
          {
            var data = getChars(elem as Text);

            if(_export(proc, data, keys) == false)
              return false;
          }
          info.def = true;
        }
        else
        if(elem is BRElement)
        { // <BR>
          if(info.def == false)
            info.def = true;
          else
          {
            if(keys.and(NEED_LF) && proc(null) == false)
              return false;
            info.close = false;
          }
        }
        else
        if(elem is DivElement)
        { // <DIV>
          if(info.def && keys.and(NEED_LF) && proc(null) == false)
            return false;
          info.def = false;

          var inf = _NodeInfo();

          if(doEnum(elem, inf) == false)
            return false;

          // </DIV>
          if(inf.def && inf.close)
          {
            if(keys.and(NEED_LF) && proc(null) == false)
              return false;
//            info.is_def = false;
          }
        }
        else
        {
          var inf = _NodeInfo();
          inf.def = info.def;
          if( doEnum(elem, inf) == false )
            return false;
          info.def = inf.def;
        }
      }
    }

    if(doEnum(clientHandle, _NodeInfo()) == false)
      return false;

    if(keys.and(NEED_EOT) && proc(null) == false)
      return false;

    return true; /* eof */
  }

  bool enumLines(ENUMPROC proc, [int keys = NEED_STRINGS | NEED_LF])
  {
    bool lf = true;
    var line = <int>[];
    if(enumChars((chars)
    {
      if(chars == null)
      {
        lf = false;
        if(keys.and(DATA_MASK))
        {
          if(_export(proc, line, keys) == false)
            return false;
        }
        if(keys.and(NEED_LF) && proc(null) == false)
          return false;

        line.clear();
      }
      else
      {
        if(keys.and(DATA_MASK))
          line.addAll(chars);
        lf = true;
      }
    }, NEED_CHARS | NEED_LF) == false)
      return false;

    if(lf)
    {
      if(keys.and(DATA_MASK) && _export(proc, line, keys) == false)
        return false;
      if(keys.and(NEED_EOT) && proc(null) == false)
        return false;
    }

    return true;  /* eof */
  }

  void execCommand(String command, [String value = ''])
  {
    client.focus();
    document.execCommand(command, false, value); 
  }

  void dispatch(Element elem, TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_CLEAR:
        client.innerHtml = '<div><br></div>';
        break;

      case EM_EXGETSEL:       Message.Result = getSel(Message.LParam); break;
      case EM_EXLINEFROMCHAR: Message.Result = getLineFromChar(Message.LParam); break;
      case EM_EXSETSEL:       Message.Result = setSel(Message.LParam);  break;
      case EM_GETEVENTMASK:   Message.Result = 0; break; // dummy
      case EM_GETSEL:         Message.Result = getSelStart(Message.WParam); break;
      case EM_GETLINE:        Message.Result = getLine(Message.WParam, Message.LParam); break;
      case EM_GETLINECOUNT:   Message.Result = lineCount; break;
      case EM_LINEINDEX:      Message.Result = getLineIndex(Message.WParam); break;
      case EM_LINELENGTH:     Message.Result = getLineLength(Message.WParam); break;
      case EM_REPLACESEL:     Message.Result = replaceSel(Message.LParam); break;
      case EM_SETEVENTMASK:   Message.Result = 0; break; // dummy

      default:
        super.dispatch(elem, Message);
        break;
    }
  }

  int getLine(int ndx, TPointer<String> str)
  {
    if(ndx < 0) return 0;

    enumLines((line)
    {
      if(ndx-- <= 0)
      {
        str.Value = line;
        return false; // exit
      }
    }, NEED_STRINGS);

    return str.Value.length;
  }

  int get lineCount
  {
    int res = 0;
    enumLines((lf){ res++; }, NEED_LF|NEED_EOT);
    return res;
  }

  int getLineFromChar(int count)
  {
    int ndx = -1;
    enumLines((len)
    {
      ndx++;
      count -= (len as int ) + 2; // \r\n
      if(count < 0)
        return false; // exit
    }, NEED_SIZE);

    return ndx;
  }

  // Gets the character index of the first character of a specified line in
  // a multiline edit control. A character index is the zero-based index of
  // the character from the beginning of the edit control.
  int getLineIndex(int ndx)
  {
    int start = 0;
    if(ndx==-1)
      start = selStart;

    int res = 0;
    enumLines((_size)
    {
      int size = _size;
      if(ndx==-1)
      {
        if(start <= res+size)
          return false;
      }
      else
      if(ndx-- <= 0)
        return false; // exit

      res += size + 2; // \r\n

    }, NEED_SIZE);

    return res;
  }

  int getLineLength(int count)
  {
    int size = 0;
    bool eof = enumLines((len)
    {
      size += len as int;
      if(count <= size)
      {
        size = len;
        return false; // exit
      }
      size += 2; // \r\n

    }, NEED_SIZE);

    return eof? 0 : size;
  }

  int _get_pos(Node node, int offset)
  {
    if(node.lastChild != null)
    {
      node = node.lastChild!;
      offset = 0;
    }

    int pos = 0;
    dynamic res;
    enumChars((ptr)
    {
      if(ptr is int)
      {
        if(res == null)
          pos += ptr;
      }
      else
      if(ptr == null)
        pos+=2; // \r\n
      else
      if(node == ptr)
      {
        if(node is BRElement)
          return false;
        pos += offset;
        res = false; // node is found
        return;
      }
      return res;
    }, NEED_NODE | NEED_SIZE | NEED_LF);
    return pos;
  }

  int get selStart
  {
    var sel = window.getSelection()!;
    var rgn = sel.getRangeAt(0);
    return _get_pos(rgn.startContainer, rgn.startOffset);
  }

  int get selEnd
  {
    var sel = window.getSelection()!;
    var rgn = sel.getRangeAt(0);
    return _get_pos(rgn.endContainer, rgn.endOffset);
  }

  int getSelStart(Integer res)
  {
    res.Value = selStart;
    return 0;
  }

  int getSel(TCharRange range)
  {
    range.cpMin = selStart;
    range.cpMax = selEnd;
    return 0;
  }

  int setSel(TCharRange range)
  {
    int start = range.cpMin;
    int end = range.cpMax;
    var rgn = document.createRange();
    bool ps = false;
    bool pe = false;

    Text? last;
    enumChars((text)
    {
      if(ps && pe)
        return false; // exit

      if(text==null)
      { // \r\n
        start-=2;
        end-=2;
      }
      else
      {
        last = text;
        var str = (text as Text).text ?? '';
        int len = str.length;

        if(ps==false && start<=len)
        {
          if(start<=0)
            rgn.setStartBefore(text);
          else
            rgn.setStart(text, start);
          ps = true;
        }

        if(pe==false && end<=len)
        {
          if(end<=0)
            rgn.setEndBefore(text);
          else
            rgn.setEnd(text, end);
          pe = true;
        }

        start-=len;
        end-=len;
      }
    }, NEED_TEXT|NEED_LF);

    if(ps==false)
    {
      if(last==null)
        return -1;
      rgn.setStart(last!, last!.text!.length);
      ps = true;
    }

    if(ps)
    {
      if(pe==false)
      {
        if(last==null)
          return -1;
        rgn.setEnd(last!, last!.text!.length);

      }
      var sel = window.getSelection()!;
      sel.removeAllRanges();
      sel.addRange(rgn);
    }
    return 0;
  }

  int replaceSel(String text)
  {
    var sel = window.getSelection()!;
    var rgn = sel.getRangeAt(0);
    rgn.deleteContents();
    if(text.isNotEmpty)
    {
      text = text.replaceAll('\r\n', '<br>');
      rgn.insertNode(Element.html('<div>$text</div>'));
      sel.setPosition(rgn.endContainer, rgn.endOffset);
    }
    return 0;
  }

/* Event notification masks */

 static const int ENM_CHANGE				= 0x00000001;

}

const MESSAGE EM_EXGETSEL            = MESSAGE(1076, 'EM_EXGETSEL');

const MESSAGE EM_EXLINEFROMCHAR      = MESSAGE(1078, 'EM_EXLINEFROMCHAR');
const MESSAGE EM_EXSETSEL            = MESSAGE(1079, 'EM_EXSETSEL');

const MESSAGE EM_GETEVENTMASK        = MESSAGE(1083, 'EM_GETEVENTMASK');

const MESSAGE EM_SETEVENTMASK        = MESSAGE(1093, 'EM_SETEVENTMASK');
