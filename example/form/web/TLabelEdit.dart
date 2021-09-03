part of demo;

class HLabelEdit extends HLabel
{
  final TWinControl Owner;

  HLabelEdit(this.Owner) : super()
  {
    handle.style
      ..left = '0px'
      ..top = '-${ SysMetric.ICaptionCy }px'
      ..width='${Owner.Width}px';
    if(Owner.HandleAllocated())
      handle.parentWindow = Owner.Handle;
  }
}


class TLabelEdit extends TCustomEdit
{
  TLabelEdit(TComponent AOwner) : super(AOwner);

  HLabelEdit? _caption;

  LabelElement get CaptionHandle
  {
    if(_caption==null)
      _caption = HLabelEdit(this);
    return _caption!.handle as LabelElement;
  }

  String get Caption => _caption == null? '' : _caption!.handle.text!;

  void set Caption(String Value)
  {
    bool inv=_caption==null;
    CaptionHandle.text = Value;
    if(inv)
      Flex.MarginTop = _caption == null? null : SysMetric.ICaptionCy + 5;
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    var edit = HEdit();

    if(ReadOnly)
      edit.input.readOnly=true;

    if(PasswordChar != '')
      edit.input.type='password';

    if(this.Text.isEmpty == false)
    {
      edit.input
        ..value = this.Text
        ..select();
    }

    edit.setColor(Color);

    WindowHandle = edit;
  }

  void CreateWnd()
  {
    super.CreateWnd();
    if(_caption != null)
      Handle.handle.append(_caption!.handle);
  }

  void Resize()
  {
    super.Resize();
    if(_caption != null)
      CaptionHandle.style.width='${Width}px';
  }

}