part of vcl;

class TLabelGroup extends TLabel
{
  TLabelGroup(TComponent AOwner) : super(AOwner)
  {
    AutoSize = false;
  }

  void CreateWindowHandle(TCreateParams Params)
  {
    WindowHandle = HLabelGroup()
      ..caption.text = Params.Caption
      ..textAlign = Alignment;
  }

}