part of vcl;



enum TFlexAlignContent { FlexStart, Center, FlexEnd, SpaceBetween, SpaceAround, SpaceEvenly, Stretch }
enum TFlexAlignItem { FlexStart, Center, FlexEnd, Stretch }
enum TFlexDirection { Row, Column, /* RowReverse, ColumnReverse*/ }
enum TFlexJustify { Left, Center, Right, Stretch }
enum TFlexJustifyContent { FlexStart, Center, FlexEnd, SpaceBetween, SpaceAround, SpaceEvenly }

abstract class TFlexParams
{
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

  TMetric? _minHeight;
  TMetric?
    get MinHeight => _minHeight;
    set MinHeight(TMetric? Value)
    {
      if(_minHeight == Value)
        return;
      _minHeight = Value;
      Invalidate();
    }

  TMetric? _maxHeight;
  TMetric?
    get MaxHeight => _maxHeight;
    set MaxHeight(TMetric? Value)
    {
      if(_maxHeight == Value)
        return;
      _maxHeight = Value;
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

  TFlexAlignItem? _align;
  TFlexAlignItem?
    get Align => _align;
    set Align(TFlexAlignItem? Value)
    {
      if(_align == Value)
        return;
      _align = Value;
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

  void Invalidate();
}

class TFlexControlParams extends TFlexParams
{
  final TControl Control;

  TFlexControlParams(this.Control);

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
    if(Control.Parent is TFlexBox)
      (Control.Parent as TFlexBox).FlexControls();
  }

}

class TFlexParamItems extends TFlexParams
{
  final TFlexBox FlexBox;

  TFlexParamItems(this.FlexBox)
  {
    _grow = 0;
    _marginBottom = 5;
    _marginLeft = 5;
    _marginTop = 5;
    _marginRight = 5;
  }

  void Invalidate() => FlexBox.FlexControls();
}

class TCalcFlexParams
{
  final TFlexBox FlexBox;
  final TFlexControlParams Params;

  late final int marginLeft;
  late final int marginTop;
  late final int marginRight;
  late final int marginBottom;

  late final int ControlHeight;
  late final int ControlWidth;
  late final TMetric? MinWidth;
  late final TMetric? MaxWidth;
  late final TMetric? MinHeight;
  late final TMetric? MaxHeight;
  late final TMetric? ParamsWidth;

  late final double Grow;

  TCalcFlexParams(this.FlexBox, this.Params)
  {
    var grow = Params.Grow<0? FlexBox.FlexItems.Grow : Params.Grow;
    Grow = grow<0? 0 : grow;

    if(FlexBox.FlexDirection == TFlexDirection.Row)
    {
      marginLeft    = Params.MarginLeft ?? (FlexBox.FlexItems.MarginLeft ?? 0);
      marginTop     = Params.MarginTop ?? (FlexBox.FlexItems.MarginTop ?? 0);
      marginRight   = Params.MarginRight ?? (FlexBox.FlexItems.MarginRight ?? 0);
      marginBottom  = Params.MarginBottom ?? (FlexBox.FlexItems.MarginBottom ?? 0);

      ControlHeight = Control.Height;
      ControlWidth  = Control.Width;
      MinWidth      = Control.Flex.MinWidth ?? FlexBox.FlexItems.MinWidth;
      MaxWidth      = Control.Flex.MaxWidth ?? FlexBox.FlexItems.MaxWidth;
      MinHeight     = Control.Flex.MinHeight ?? FlexBox.FlexItems.MinHeight;
      MaxHeight     = Control.Flex.MaxHeight ?? FlexBox.FlexItems.MaxHeight;
      ParamsWidth   = Params.Width;
    }
    else
    {
      marginLeft    = Params.MarginTop ?? (FlexBox.FlexItems.MarginTop ?? 0);
      marginTop     = Params.MarginLeft ?? (FlexBox.FlexItems.MarginLeft ?? 0);
      marginRight   = Params.MarginBottom ?? (FlexBox.FlexItems.MarginBottom ?? 0);
      marginBottom  = Params.MarginRight ?? (FlexBox.FlexItems.MarginRight ?? 0);

      ControlHeight = Control.Width;
      ControlWidth  = Control.Height;
      MinWidth      = Control.Flex.MinHeight ?? FlexBox.FlexItems.MinHeight;
      MaxWidth      = Control.Flex.MaxHeight ?? FlexBox.FlexItems.MaxHeight;
      MinHeight     = Control.Flex.MinWidth ?? FlexBox.FlexItems.MinWidth;
      MaxHeight     = Control.Flex.MaxWidth ?? FlexBox.FlexItems.MaxWidth;
      ParamsWidth   = Params.Height;
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
  late final TFlexParamItems FlexItems;

  TFlexBox(TComponent AOwner) : super(AOwner)
  {
    FlexItems = TFlexParamItems(this);
    Width = 185;
    Height = 40;
  }

  void UpdateShowing()
  {
    DisableAlign();
    super.UpdateShowing();
    EnableAlign();
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HFlexBox();
    WindowHandle!.setColor(Color);
  }

  void _cmShowingChanged(TMessage Message)
  {
    if(_showing)
      RequestAlign();
//      Realign();
    super._cmShowingChanged(Message);
  }

  TFlexDirection _flexDirection = TFlexDirection.Row;
  TFlexDirection
    get FlexDirection => _flexDirection;
    set FlexDirection(TFlexDirection value)
    {
      if(_flexDirection == value)
        return;
      _flexDirection = value;
      FlexControls();
    }

  TFlexJustifyContent _justifyContent = TFlexJustifyContent.FlexStart;
  TFlexJustifyContent
    get JustifyContent => _justifyContent;
    set JustifyContent(TFlexJustifyContent Value)
    {
      _justifyContent = Value;
      FlexControls();
    }

  TFlexAlignItem _alignItems = TFlexAlignItem.FlexStart;
  TFlexAlignItem
    get AlignItems => _alignItems;
    set AlignItems(TFlexAlignItem value)
    {
      if(_alignItems == value)
        return;
      _alignItems = value;
      FlexControls();
    }

  TFlexAlignContent _alignContent = TFlexAlignContent.FlexStart;
  TFlexAlignContent
    get AlignContent => _alignContent;
    set AlignContent(TFlexAlignContent value)
    {
      if(_alignContent == value)
        return;
      _alignContent = value;
      FlexControls();
    }

  bool CanFocus() => false;

  bool CanFlex() => true;

  void AlignControls(TControl? AControl, TRect Rect)
  {
//    super.AlignControls(AControl, Rect);
    _flexProcessing();
  }

  void FlexControls() => Realign();

  void _flexProcessing()
  {
    if(!CanFlex())
      return;

    var list = <TCalcFlexParams>[];

    for(int i = 0; i<ControlCount; i++)
    {
      TControl ctrl = Controls[i];
      if(ctrl.Visible && ((ctrl.Align == TAlign.None) || ctrl.Anchors.isEqual([TAnchorKind.Left, TAnchorKind.Top])))
        list.add(TCalcFlexParams(this, ctrl.Flex));
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

          if(flex.Params.Justify != TFlexJustify.Stretch)
          {
            int w;
            switch(flex.Params.Justify)
            {
              case TFlexJustify.Left:
                w = flex.ControlWidth + flex.marginRight;
                break;
              case TFlexJustify.Right:
                w = flex.ControlWidth + flex.marginLeft;
                break;
              case TFlexJustify.Center:
                w = flex.ControlWidth + flex.marginLeft + flex.marginRight;
                break;
              default:
                w = 0;
                break;
            }
            if(flex.size < w)
              flex.size = w;
          }

          if(flex.MinWidth!=null)
          {
            int w = flex.MinWidth!.toPixel(cWidth);
            if(flex.size<w)
              flex.size = w;
          }

          if(flex.MaxWidth!=null)
          {
            int w = flex.MaxWidth!.toPixel(cWidth);
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

          var items = _growControls(line, cWidth); 
          rest.insertAll(0, items);
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
        if(flex.MinWidth!=null)
        {
          int w = flex.MinWidth!.toPixel(cWidth);
          if(flex.size<w)
            flex.size=w;
        }

        if(flex.MaxWidth!=null)
        {
          int w = flex.MaxWidth!.toPixel(cWidth);
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

    int rest = Height-py;
    if(rest>0)
    {
      switch(AlignContent)
      {
        case TFlexAlignContent.FlexStart:
          break;

        case TFlexAlignContent.FlexEnd:
        case TFlexAlignContent.Center:
          if(AlignContent==TFlexAlignContent.Center)
            rest = rest ~/ 2;
          for(var line in lines)
            for(var flex in line)
              flex.y+=rest;
          break;

        case TFlexAlignContent.SpaceBetween:
          int cnt = lines.length - 1;
          int dy = 0;
          for(int i=1; i<lines.length; i++)
          {
            int rr = rest ~/ cnt;
            dy+=rr;
            var line = lines[i];
            for(var flex in line)
              flex.y+=dy;
            rest-=rr;
            cnt--;
          }
          break;

        case TFlexAlignContent.SpaceAround:
          int count = lines.length;
          int dy = 0;
          for(var line in lines)
          {
            int h = rest ~/ count;
            int h2 = h ~/ 2;
            dy+=h-h2;
            for(var flex in line)
              flex.y+=dy;
            dy+=h2;
            rest-=h;
            count--;
          }
          break;

        case TFlexAlignContent.SpaceEvenly:
          int count = lines.length + 1;
          int dy = 0;
          for(var line in lines)
          {
            int h = rest ~/ count;
            dy+=h;
            for(var flex in line)
              flex.y+=dy;
            rest-=h;
            count--;
          }
          break;

        case TFlexAlignContent.Stretch:
          break;
      }
    }


    if(FlexDirection==TFlexDirection.Row)
    {
      if(Height != py)
      {
        if(Align == TAlign.Bottom)
          SetBounds(Left, Top + Height - py, Width, py);
        else
        if(Align == TAlign.Top)
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
        if(Align == TAlign.Left)
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
      TFlexAlignItem align = flex.Params.Align ?? AlignItems;

      switch(align)
      {
        case TFlexAlignItem.FlexEnd:
          flex.y = py + cHeight - flex.marginBottom - flex.ControlHeight;
          break;

        case TFlexAlignItem.Center:
          flex.y = py + (cHeight - flex.ControlHeight) ~/ 2;
          break;

        case TFlexAlignItem.Stretch:
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

