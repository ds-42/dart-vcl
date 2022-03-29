part of vcl;

class HLabelGroup extends HControl
{
  static final LABELGROUP = CLASS_ID('LABELGROUP');
  CLASS_ID get classID => LABELGROUP;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.flex }'
      '${ rule.inline }'
      '${ rule.no_select }');
  }


  final leftHr = HRElement();
  final caption = LabelElement();
  final rightHr = HRElement();

  HLabelGroup() : super( DivElement() )
  {
    handle.className = classID.name;

    handle.append(caption);
    handle.append(rightHr);

    style.display = 'flex';

    leftHr.style
      ..width = '100%'
      ..height = '0'
      ..marginRight = '5px';

    rightHr.style
      ..width = '100%'
      ..height = '0'
      ..marginLeft = '5px';

    WNDPROC? defproc;
    defproc = Windows.ChangeWindowProc(this, (elem, message)
    { // mainproc
      switch (message.Msg)
      {
        case WM_SHOWWINDOW:
          style.display = message.WParam ? 'flex' : 'none';
          break;

        default:
          defproc!(elem, message);
          break;
      }
    });
  }

  TAlignment _textAlign = TAlignment.LeftJustify;

  TAlignment
  get textAlign => _textAlign;
  set textAlign(TAlignment value)
  {
    if(_textAlign == value)
      return;
    _textAlign = value;
    bool lhr = false;
    bool rhr = false;
    switch(value)
    {
      case TAlignment.LeftJustify:
        lhr = false;
        rhr = true;
        break;

      case TAlignment.RightJustify:
        lhr = true;
        rhr = false;
        break;

      case TAlignment.Center:
        lhr = true;
        rhr = true;
        break;
    }

    if(lhr==false)
      leftHr.remove();
    else
    if(leftHr.parent == null)
      handle.insertBefore(leftHr, caption);

    if(rhr==false)
      rightHr.remove();
    else
    if(rightHr.parent == null)
      handle.append(rightHr);
  }
}
