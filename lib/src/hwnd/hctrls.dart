part of vcl;

class HComponent extends HWND
{
  HComponent(Element elem) : super._(elem);
}

class HControl extends HComponent
{

  HControl(Element elem) : super(elem);

  void setBounds(int left, int top, [int? width, int? height])
  {
    style.position='absolute';
    style.left='${left}px';
    style.top='${top}px';
    if(width != null)
      style.width='${width}px';
    if(height != null)
      style.height='${height}px';


  }

  RECT getBounds()
  {
    return handle.invisibilityProc(() =>
      handle.borderRect);
//    return handle.borderRect;
  }

  void invalidate()
  {
    Windows.InvalidateRect(this, null, true);
  }

  bool _enabled = true;
  bool get Enabled => _enabled;
  void set Enabled(bool Value)
  {
    if(_enabled==Value)
      return;
    _enabled=Value;
    EnableChanged();
  }

  void EnableChanged()
  {
  }
}

class HCustomControl extends HControl
{
  HCustomControl() : super(DivElement())
  {
    style
      ..position='absolute';
  }

  HCustomControl.elem(Element _elem) : super(_elem);

}

class HGraphicControl extends HControl
{
  HGraphicControl() : super( CanvasElement() )
  {
    style
      ..position='absolute';
  }

  void dispatch(Element elem, TMessage Message)
  {
    switch(Message.Msg)
    {
      case WM_PAINT:
        paint();
        break;

      default:
        super.dispatch(elem, Message);
        break;
    }
  }

  CanvasRenderingContext2D get canvas =>
      (handle as CanvasElement).context2D;

  void setBounds(int left, int top, [int? width, int? height])
  {
    if(width != null)
      (handle as CanvasElement).width=width;
    if(height != null)
      (handle as CanvasElement).height=height;
    super.setBounds(left, top, width, height);
  }

  void paint()
  {

  }

}

class HPopupControl extends HCustomControl
{
  HPopupControl.elem(Element _elem) : super.elem(_elem)
  {
  }

}

