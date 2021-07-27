part of vcl;

enum TFlexAlign { Top, Center, Bottom}

class TCMGetFlexParams extends TCustomMessage {

  TFlexParams get Params => WParam as TFlexParams;

  TCMGetFlexParams(TMessage message) : super(message);
}

extension FlexControlExtension on TControl
{
  TFlexParams get Flex
  {
    if(Parent != null && Parent is TFlexBand)
      return (Parent as TFlexBand)._getFlexParams(this);

    throw UnsupportedError('Parent is not Flex band');
  }

  void FlexInvalidate()
  {
    if(Parent != null && Parent is TFlexBand)
      (Parent as TFlexBand).InvalidateFlexControl(this);
  }
}

class TFlexParams
{
  final TFlexBand Band;
  final TControl  Control;
  void _testChanged()
  {
    if(Band._alignLevel==0)
      throw UnsupportedError('Band is not align mode. For using custom params use block DisableAlign() { ... } EnableAlign()');
  }

  TFlexParams(this.Band, this.Control);

  TFlexAlign? Align;
  bool       AutoSize = true;
  bool?      NewLine; // признак нахождения объекта первым в строке
  TRect      Bounds = TRect();
  TRect      Margin = TRect();
  int?       MinWidth;
  int?       MaxWidth;

  int? _width;
  int? get Width => _width;
  void set Width(int? Value)
  {
    _testChanged();
    _width = Value;
  }
}

class TFlexBand extends TWinControl
{
  int _indent = 10;
  int get Indent => _indent;
  void set Indent(int Value)
  {
    if(Value != _indent)
    {
      _indent = Value;
      // ...
    }
  }

  int _interval = 10;
  int get Interval => _interval;
  void set Interval(int Value)
  {
    if(Value != _interval)
    {
      _interval = Value;
      // ...
    }
  }

  var _flexList = <TFlexParams>[];
  TFlexParams _getFlexParams(TControl AControl)
  {
    for(TFlexParams p in _flexList) {
      if(p.Control == AControl)
        return p;
    }
    TFlexParams params = TFlexParams(this, AControl);
    params.Margin = TRect();
    params.Align = TFlexAlign.Bottom;
    AControl.Perform(CM_GETFLEXPARAMS, params);
    _flexList.add(params);
    return params;
  }

  void InvalidateFlexControl(TControl AControl)
  {
    for(TFlexParams p in _flexList)
      if(p.Control == AControl)
      {
        int? width = p.Width;
        AControl.Perform(CM_GETFLEXPARAMS, p);
        if(width!=null)
          p.Width = width;
      }
  }

  bool _flexOff = false;
  bool
    get FlexOff => _flexOff;
    set FlexOff(bool State)
    {
      if(FlexOff==State)
        return;
      _flexOff=State;
      if(FlexOff==false && _alignLevel==1)
        FlexControls();
    }

  int _marginBottom = 5;
  int _marginLeft = 5;
  int _marginTop = 5;
  int _marginRight = 5;

  int get MarginBottom => _marginBottom;
  int get MarginLeft => _marginLeft;
  int get MarginTop => _marginTop;
  int get MarginRight => _marginRight;

  void set MarginBottom(int Value) => SetMargin(MarginLeft, MarginTop, MarginRight, Value);
  void set MarginLeft(int Value) => SetMargin(Value, MarginTop, MarginRight, MarginBottom);
  void set MarginTop(int Value) => SetMargin(MarginLeft, Value, MarginRight, MarginBottom);
  void set MarginRight(int Value) => SetMargin(MarginLeft, MarginTop, Value, MarginBottom);

  void SetMargin(int ALeft, int ATop, int ARight, int ABottom)
  {
    if(((ALeft != _marginLeft) || (ATop != _marginTop) ||
       (ARight != _marginRight) || (ABottom != _marginBottom)))
    {

      _marginLeft = ALeft;
      _marginTop = ATop;
      _marginRight = ARight;
      _marginBottom = ABottom;

    }
  }

  bool CanFocus() => false;

  void EnableAlign()
  {
    if(_alignLevel == 1)
    { // update elements position before align finish
      bool san = ControlState.contains(ControlStates.AlignmentNeeded);
      FlexControls();
      ControlState.changeState(ControlStates.AlignmentNeeded, san);
    }
    super.EnableAlign();
  }

  void FlexControls()
  {
    if(FlexOff)
      return;

    var list = <TFlexParams>[];

    for(int i = 0; i<ControlCount; i++)
    {
      TControl ctrl = Controls[i];
      if(ctrl.Visible && ((ctrl.Align == TAlign.None) || ctrl.Anchors.isEqual([TAnchorKind.Left, TAnchorKind.Top])))
      {
        TFlexParams params = _getFlexParams(ctrl);

        list.add(params);

      }
    }

    int cWidth = ClientWidth - MarginRight;

    int px = MarginLeft;
    int py = MarginTop;
    int start = 0;
    int fCount = 0;
    int maxTop = 0;
    int maxBottom = 0;
    int maxHeight = 0;
    for(int i = 0; i<=list.length; i++)
    {
      int width = 0;
      int margin = 0;
      TFlexParams? p = i<list.length? list[i] : null;
      if(p != null)
      {
        TControl ctrl =p.Control;
        //width = ctrl.Width;
        width = 0;
        if(p.Width == null)
        {
          if(p.AutoSize == false)
            width = ctrl.Width;
        }
        else
          width = p.Width!;
        margin = p.Margin.left+p.Margin.right;
      }


      if((px+width+margin>cWidth || i==list.length || (p!=null && p.NewLine==true)) && (i-start>0))
      { // align elements in line
        int dx = 0;
        for(int j=start; j<i; j++)
        {
          TFlexParams p = list[j];
          int dy = 0;
          switch(p.Align)
          {
            case TFlexAlign.Top: // top align
              dy = 0;
              break;

            case TFlexAlign.Center: // center align
              dy = (maxHeight - p.Bounds.height) ~/ 2;
              if(dy<0)
                dy = 0;
              break;

            default: // bottom align
              dy = maxHeight - p.Bounds.height;
              break;
          }
          p.Bounds.offset(dx, maxTop + dy);

          if(p.AutoSize && p.Width == null)
          {
            int d = ((cWidth - px) / fCount).ceil();
            p.Bounds.right+=d;
            dx+=d;
            px+=d;

            int nWidth = p.Bounds.width;
            if(p.MinWidth != null && nWidth<p.MinWidth!)
              nWidth=p.MinWidth!;
            if(p.MaxWidth != null && nWidth>p.MaxWidth!)
              nWidth=p.MaxWidth!;

            d = nWidth - p.Bounds.width;
            if(d!=0)
            {
              p.Bounds.right+=d;
              dx+=d;
              px+=d;
            }

            fCount--;
          }
        }

        start = i;
        fCount = 0;
        px = MarginLeft;
        py+= maxHeight + Interval + maxBottom + maxTop;
        maxHeight=0;
        maxTop=0;
        maxBottom=0;
      }

      if (p != null)
      {
        if(p.Margin.top > maxTop)
          maxTop = p.Margin.top;
        if(p.Margin.bottom > maxBottom)
          maxBottom = p.Margin.bottom;
        if(p.Control.Height > maxHeight)
          maxHeight = p.Control.Height;
        if(p.AutoSize && p.Width == null)
          fCount++;
        if(i > start)
          px+= Indent;
        p.Bounds = TRect(px, py, px + width+p.Margin.left, py + p.Control.Height);
        px = p.Bounds.right+p.Margin.right;
      }
    }

    for(TFlexParams p in list)
      p.Control.SetBounds(p.Bounds.left, p.Bounds.top, p.Bounds.width, p.Bounds.height);

    _flexList = list;
    if(py>MarginTop)
      py-=Interval;
    Height = py+MarginBottom;
  }

  TFlexBand(TComponent AOwner) : super(AOwner)
  {
    Width = 100;
    Height = 36;
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HFlexBand();

  }
}

