part of vcl;


class TCMGetFlexParams extends TCustomMessage
{
  TFlexParams get Params => WParam as TFlexParams;

  TCMGetFlexParams(TMessage message) : super(message);
}

enum TFlexAlignItems { FlexStart, FlexEnd, Center, Stretch }
enum TFlexJustify { Left, Center, Right, Stretch }
enum TFlexJustifyContent { Center, FlexStart, FlexEnd, SpaceBetween, SpaceAround, SpaceEvenly }
enum TFlexDirection { Row, Column, /* RowReverse, ColumnReverse*/ }

class TFlexParams
{
  final TControl Control;

  TFlexParams(this.Control);

  int? _marginLeft;
  int?
    get MarginLeft => _marginLeft;
    set MarginLeft(int? Value)
    {
      if(_marginLeft==Value)
        return;
      _marginLeft=Value;
      Invalidate();
    }

  int? _marginTop;
  int?
    get MarginTop => _marginTop;
    set MarginTop(int? Value)
    {
      if(_marginTop==Value)
        return;
      _marginTop=Value;
      Invalidate();
    }

  int? _marginRight;
  int?
    get MarginRight => _marginRight;
    set MarginRight(int? Value)
    {
      if(_marginRight==Value)
        return;
      _marginRight=Value;
      Invalidate();
    }

  int? _marginBottom;
  int?
    get MarginBottom => _marginBottom;
    set MarginBottom(int? Value)
    {
      if(_marginBottom==Value)
        return;
      _marginBottom=Value;
      Invalidate();
    }

  void SetMargin(int? left, int? top, int? right, int? bottom)
  {
    MarginLeft = left;
    MarginTop = top;
    MarginRight = right;
    MarginBottom = bottom;
  }

  TMetric? _minWidth;
  TMetric?
    get MinWidth => _minWidth;
    set MinWidth(TMetric? Value)
    {
      if(_minWidth == Value)
        return;
      _minWidth = Value;
      Invalidate();
    }

  TMetric? _maxWidth;
  TMetric?
    get MaxWidth => _maxWidth;
    set MaxWidth(TMetric? Value)
    {
      if(_maxWidth == Value)
        return;
      _maxWidth = Value;
      Invalidate();
    }

  TMetric? _width;
  TMetric?
    get Width => _width;
    set Width(TMetric? Value)
    {
      if(_width == Value)
        return;
      _width = Value;
      Invalidate();
    }

  TMetric? _height;
  TMetric?
    get Height => _height;
    set Height(TMetric? Value)
    {
      if(_height == Value)
        return;
      _height = Value;
      Invalidate();
    }



  double _grow = -1;
  double
    get Grow => _grow;
    set Grow(double value)
    {
      if(_grow == value)
        return;
      _grow = value;
      Invalidate();
    }

  TFlexJustify? _justify = TFlexJustify.Stretch;
  TFlexJustify?
    get Justify => _justify;
    set Justify(TFlexJustify? Value)
    {
      if(_justify == Value)
        return;
      _justify = Value;
      Invalidate();
    }

  bool _breakBefore = false; // start with new line
  bool
    get BreakBefore => _breakBefore;
    set BreakBefore(bool value)
    {
      if(_breakBefore==value)
        return;
      _breakBefore=value;
      Invalidate();
    }

  void Invalidate()
  {
    /// To do: add update
  }


}

class TCalcFlexParams
{
  final TFlexBox    FlexBox;
  final TFlexParams Params;

  late final int marginLeft;
  late final int marginTop;
  late final int marginRight;
  late final int marginBottom;

  late final int ControlHeight;
  late final int ControlWidth;
  late final TMetric? ParamsWidth;

  late final double Grow;

//  late final TFlexAlig

  TCalcFlexParams(this.FlexBox, this.Params)
  {
    Grow = Params.Grow<0? FlexBox.Grow : Params.Grow;

    if(FlexBox.FlexDirection == TFlexDirection.Row)
    {
      marginLeft    = Params.MarginLeft ?? FlexBox.MarginLeft;
      marginTop     = Params.MarginTop ?? FlexBox.MarginTop;
      marginRight   = Params.MarginRight ?? FlexBox.MarginRight;
      marginBottom  = Params.MarginBottom ?? FlexBox.MarginBottom;

      ControlHeight = Control.Height;
      ControlWidth  = Control.Width;
      ParamsWidth   = Params.Width;
    }
    else
    {
      marginLeft    = Params.MarginTop ?? FlexBox.MarginTop;
      marginTop     = Params.MarginLeft ?? FlexBox.MarginLeft;
      marginRight   = Params.MarginBottom ?? FlexBox.MarginBottom;
      marginBottom  = Params.MarginRight ?? FlexBox.MarginRight;

      ParamsWidth   = Params.Height;
      ControlHeight = Control.Width;
      ControlWidth  = Control.Height;
    }
  }

  TControl get Control => Params.Control;

  // calculated params
  int x = 0;
  int y = 0;
  int? width;
  int? height;

  int size   = 0; // size of cell
  int lSpace = 0; // space before cell
  int rSpace = 0; // space after cell

}


class TFlexBox extends TWinControl
{

  TFlexBox(TComponent AOwner) : super(AOwner)
  {
    Width = 185;
    Height = 40;
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HFlexBox();
  }

  TFlexDirection _flexDirection = TFlexDirection.Row;
  TFlexDirection
    get FlexDirection => _flexDirection;
    set FlexDirection(TFlexDirection value)
    {
      if(_flexDirection == value)
        return;
      _flexDirection = value;
      _flexProcessing();
    }

  TFlexJustifyContent _justifyContent = TFlexJustifyContent.FlexStart;
  TFlexJustifyContent
    get JustifyContent => _justifyContent;
    set JustifyContent(TFlexJustifyContent Value)
    {
      _justifyContent = Value;
      // to do: invalidate
    }

  TFlexAlignItems _alignItems = TFlexAlignItems.FlexStart;
  TFlexAlignItems
    get AlignItems => _alignItems;
    set AlignItems(TFlexAlignItems value)
    {
      if(_alignItems == value)
        return;
      _alignItems = value;
      // to do: invalidate
    }

  int _marginBottom = 5;
  int _marginLeft = 5;
  int _marginTop = 5;
  int _marginRight = 5;

  int get MarginBottom => _marginBottom;
  int get MarginLeft => _marginLeft;
  int get MarginTop => _marginTop;
  int get MarginRight => _marginRight;

  double _grow = 0;
  double
    get Grow => _grow;
    set Grow(double Value)
    {
      if(Value<0)
        Value = 0;
      if(_grow==Value)
        return;
      _grow=Value;
      // to do: invalidate
    }

  bool CanFocus() => false;

  void Resize()
  {
    super.Resize();
    _flexProcessing();
  }

  void _flexProcessing()
  {
    var list = <TCalcFlexParams>[];

    for(int i = 0; i<ControlCount; i++)
    {
      TControl ctrl = Controls[i];
      if(ctrl.Visible )
      {
        
        list.add(TCalcFlexParams(this, ctrl.Flex));
      }
    }

    if(list.isNotEmpty)
      _flexControls(list);

    for(var flex in list)
    {
      if(FlexDirection==TFlexDirection.Row)
        flex.Params.Control.SetBounds(flex.x, flex.y, flex.width, flex.height);
      else
        flex.Params.Control.SetBounds(flex.y, flex.x, flex.height, flex.width);
    }
  }

  void Add(List<TControl> ctrls)
  {
    DisableAlign();
    for(var ctrl in ctrls)
    {
      ctrl.Parent = this;
    }
    EnableAlign();
  }

  // update grow size in line
  List<TCalcFlexParams> _growControls(List<TCalcFlexParams> line, int cWidth)
  {
    int width = 0;
    double grow = 0;
    for(var flex in line)
    {
      if(flex.Grow>0)
        grow+=flex.Grow;
      else
        width+=flex.size;
    }

    if(grow>0)
    {
      int dGrow = cWidth - width;

      width = 0;
      for(int i=0; i<line.length; i++)
      {
        var flex = line[i];
        if(flex.Grow>0)
        {
          flex.size = dGrow * flex.Grow ~/ grow;

          if(flex.Params.MinWidth!=null)
          {
            int w = flex.Params.MinWidth!.toPixel(cWidth);
            if(flex.size<w)
              flex.size = w;
          }

          if(flex.Params.MaxWidth!=null)
          {
            int w = flex.Params.MaxWidth!.toPixel(cWidth);
            if(flex.size>w)
              flex.size = w;
          }

          dGrow-=flex.size;
          grow-=flex.Grow;
        }

        if((i>0) && (width + flex.size > cWidth))
        {
          var rest = <TCalcFlexParams>[];

          while(i<line.length)
          {
            rest.add(line[i]);
            line.removeAt(i);
          }

          _growControls(line, cWidth); 
          return rest;
        }

        width+=flex.size;
      }
    }

    return <TCalcFlexParams>[];
  }

  void _flexControls(List<TCalcFlexParams> list)
  {
    int cWidth = FlexDirection==TFlexDirection.Row? ClientWidth : ClientHeight;

    // calc cell size
    for(var flex in list)
    {
      if(flex.ParamsWidth!=null)
        flex.size = flex.ParamsWidth!.toPixel(cWidth);
      else
      {
        if(flex.Grow>0)
          flex.size = 0;
        else
          flex.size = flex.marginLeft + flex.ControlWidth + flex.marginRight;
      }

      if(flex.Grow==0)
      {
        if(flex.Params.MinWidth!=null)
        {
          int w = flex.Params.MinWidth!.toPixel(cWidth);
          if(flex.size<w)
            flex.size=w;
        }

        if(flex.Params.MaxWidth!=null)
        {
          int w = flex.Params.MaxWidth!.toPixel(cWidth);
          if(flex.size>w)
            flex.size=w;
        }
      }
    }

    int lineWidth = 0;
    var lines = < List<TCalcFlexParams> >[];

    var line = <TCalcFlexParams>[]; // line of objects
    for(var flex in list)
    {
      if(line.isNotEmpty && ((lineWidth + flex.size > cWidth) || flex.Params.BreakBefore))
      {
        var rest = _growControls(line, cWidth);
        lines.add(line);
        line = rest;

        while(line.isNotEmpty && flex.Params.BreakBefore)
        {
          lines.add(line);
          line = _growControls(line, cWidth);
        }

        lineWidth = 0;
        for(var flex in line)
          if(flex.Grow==0)
            lineWidth+=flex.size;
      }
//      if(flex.Params.Basis!=null)

      line.add(flex);
      lineWidth += flex.size;
    }

    while(line.isNotEmpty)
    {
      var rest = _growControls(line, cWidth);
      lines.add(line);
      line = rest;
    }

    // out controls by line
    int px = 0;
    int py = 0;

    for(var line in lines)
    {
      int height = 0;
      for(var flex in line)
      {
        int h = flex.ControlHeight + flex.marginTop + flex.marginBottom;
        if(h > height)
          height = h;
      }

      _flexLineControls(line, px, py, cWidth, height);
      py += height;
    }

    if(FlexDirection==TFlexDirection.Row)
    {
      if(Height != py)
      {
        if(Align == TAlign.Bottom)
          SetBounds(Left, Top + Height - py, Width, py);
        else
          Height = py;
      }
    }
    else
    {
      if(Width != py)
      {
        if(Align == TAlign.Right)
          SetBounds(Left + Width - py, Top, py, Height);
        else
          Width = py;
      }
    }
  }

  void _flexLineControls(List<TCalcFlexParams> list, int px, int py, int cWidth, int cHeight)
  {
    // calc size of objects
    int objWidth = 0;
    for(var flex in list)
      objWidth+=flex.size;

    TFlexJustify defJust = TFlexJustify.Left;
    switch(JustifyContent)
    {
      case TFlexJustifyContent.FlexStart:
        defJust = TFlexJustify.Left;
        list.last.rSpace = cWidth - objWidth;
        break;

      case TFlexJustifyContent.FlexEnd:
        list.first.lSpace = cWidth - objWidth;
        defJust = TFlexJustify.Right;
        break;

      case TFlexJustifyContent.Center:
        list.first.lSpace = (cWidth - objWidth) ~/ 2;
        list.last.rSpace = list.first.lSpace ~/ 2;
        list.first.lSpace-= list.first.rSpace;
        defJust = TFlexJustify.Center;
        break;

      case TFlexJustifyContent.SpaceBetween:
        defJust = TFlexJustify.Center;
        int delta = cWidth - objWidth;
        int count = list.length - 1;

        for(var flex in list)
        {
          if(flex != list.first)
          {
            flex.lSpace = delta ~/ count;
            delta-=flex.lSpace;
            count--;
          }
        }
        break;

      case TFlexJustifyContent.SpaceAround:
        defJust = TFlexJustify.Center;
        int delta = cWidth - objWidth;
        int count = list.length;

        for(var flex in list)
        {
          flex.lSpace = delta ~/ count;
          flex.rSpace = flex.lSpace ~/ 2;
          flex.lSpace = flex.lSpace - flex.rSpace;
          delta-=flex.lSpace + flex.rSpace;
          count--;
        }
        break;

      case TFlexJustifyContent.SpaceEvenly:
        defJust = TFlexJustify.Center;
        int delta = cWidth - objWidth;
        int count = list.length + 1;

        for(var flex in list)
        {
          flex.lSpace = delta ~/ count;
          delta-=flex.lSpace;
          count--;
        }
        list.last.rSpace = delta;
        break;
    }

    for(var flex in list)
    {
      TFlexJustify just = flex.Params.Justify ?? defJust;

      switch(AlignItems)
      {
        case TFlexAlignItems.FlexEnd:
          flex.y = py + cHeight - flex.marginBottom - flex.ControlHeight;
          break;
        case TFlexAlignItems.Center:
          flex.y = py + (cHeight - flex.ControlHeight) ~/ 2;
          break;
        case TFlexAlignItems.Stretch:
          flex.y = py + flex.marginTop;
          flex.height = cHeight - flex.marginTop - flex.marginBottom;
          break;
        default: // TFlexAlignItems.FlexStart
          flex.y = py + flex.marginTop;
          break;
      }

      int tx = px + flex.lSpace ;
      int size = flex.size - flex.marginLeft - flex.marginRight;

      switch(just)
      {
        case TFlexJustify.Right:
          flex.x = tx + flex.size - flex.ControlWidth - flex.marginRight;
          break;
        case TFlexJustify.Center:
          flex.x = ((tx + flex.marginLeft)*2 + size - flex.ControlWidth)~/2;
          break;
        case TFlexJustify.Stretch:
          flex.x = tx + flex.marginLeft;
          flex.width = size;
          break;
        default: // TFlexJustify.Left
          flex.x = tx + flex.marginLeft;
          break;
      }

      px += flex.lSpace + flex.size + flex.rSpace;
    }

  }
}

