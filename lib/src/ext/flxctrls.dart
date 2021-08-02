part of vcl;

class TCMGetFlexParams extends TCustomMessage
{

  TFlexParams get Params => WParam as TFlexParams;

  TCMGetFlexParams(TMessage message) : super(message);
}

enum TFlexJustify { Left, Center, Right, Content }
enum TFlexJustifyContent { Center, FlexStart, FlexEnd, SpaceBetween, SpaceAround, SpaceEvenly }

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

  TFlexJustify? _justify;
  TFlexJustify?
    get Justify => _justify;
    set Justify(TFlexJustify? Value)
    {
      if(_justify == Value)
        return;
      _justify = Value;
      Invalidate();
    }

  void Invalidate()
  {
    /// To do: add update
  }

  // Old fields
  bool AutoSizeOld = true; /* not use */
  int? MinWidthOld;        /* not use */
  int? MaxWidthOld;        /* not use */


}

class TCalcFlexParams
{
  final TFlexBox    FlexBox;
  final TFlexParams Params;

  TCalcFlexParams(this.FlexBox, this.Params);

  TControl get Control => Params.Control;

  int x = 0;
  int y = 0;
  int? width;
  int? height;

  int size = 0; // size of cell
  int lSpace = 0; // space before cell
  int rSpace = 0; // space after cell

  int get marginLeft => Params.MarginLeft ?? FlexBox.MarginLeft;
  int get marginTop => Params.MarginTop ?? FlexBox.MarginTop;
  int get marginRight => Params.MarginRight ?? FlexBox.MarginRight;
  int get marginBottom => Params.MarginBottom ?? FlexBox.MarginBottom;

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
    WindowHandle = HFlexBand();
  }

  TFlexJustifyContent _justifyContent = TFlexJustifyContent.FlexStart;
  TFlexJustifyContent
    get JustifyContent => _justifyContent;
    set JustifyContent(TFlexJustifyContent Value)
    {
      _justifyContent = Value;
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

  bool CanFocus() => false;

  void Resize()
  {
    super.Resize();

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
      FlexControls(list);

    for(var flex in list)
      flex.Params.Control.SetBounds(flex.x, flex.y, flex.width, flex.height);
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

  void FlexControls(List<TCalcFlexParams> list)
  {
    int cWidth = ClientWidth;

    // calc cell size
    for(var flex in list)
    {
      if(flex.Params.Width!=null)
        flex.size = flex.Params.Width!.toPixel(cWidth);
      else
        flex.size = flex.marginLeft + flex.Control.Width + flex.marginRight;
    }

    int lineSize = 0;
    var line = <TCalcFlexParams>[]; // line of objects
    var lines = [];
    for(var flex in list)
    {
      if(line.isNotEmpty && (lineSize + flex.size > cWidth))
      {
        lines.add(line);
        line = <TCalcFlexParams>[];
      }
      line.add(flex);
      lineSize += flex.size;
    }
    if(line.isNotEmpty)
      lines.add(line);

    // out controls by line
    int px = 0;
    int py = 0;
    for(var line in lines)
    {
      int height = 0;
      for(var flex in list)
      {
        int h = flex.Control.Height + flex.marginTop + flex.marginBottom;
        if(h > height)
          height = h;
      }
      FlexLineControls(line, px, py, cWidth, height);
      py += height;
    }

    if(Height != py)
      SetBounds(Left, Top + Height - py, Width, py);
  }

  void FlexLineControls(List<TCalcFlexParams> list, int px, int py, int cWidth, int cHeight)
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

      flex.y = py + flex.marginTop;

      int tx = px + flex.lSpace ;
      int size = flex.size - flex.marginLeft - flex.marginRight;
      switch(just)
      {
        case TFlexJustify.Right:
          flex.x = tx + flex.size - flex.Control.Width - flex.marginRight;
          break;
        case TFlexJustify.Center:
          flex.x = ((tx + flex.marginLeft)*2 + size - flex.Control.Width)~/2;
          break;
        case TFlexJustify.Content:
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

