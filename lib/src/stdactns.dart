part of vcl;


class THintAction extends TCustomAction
{
  THintAction(TComponent AOwner) : super(AOwner)
  {
    DisableIfNoHandler = false;
  }

}

