part of vcl;


class TContainedAction extends TBasicAction
{


 TContainedAction(TComponent AOwner) : super(AOwner);


}
 

class TActionLink extends TBasicActionLink
{


  TActionLink(TObject AClient) : super(AClient);

 


 void SetShortCut(TShortCut Value)
 {

 }



}



class TCustomAction extends TContainedAction
{



  TCustomAction(TComponent AOwner) : super(AOwner)
  {

  }

  bool _disableIfNoHandler = false;
  bool
    get DisableIfNoHandler =>_disableIfNoHandler;
    set DisableIfNoHandler(bool value) => _disableIfNoHandler = value;



  bool _enabled = true;
  bool
    get Enabled => _enabled;
    set Enabled(bool Value)

    {
      if(Enabled == Value)
        return;

      _enabled = Value;
      Change();
    }



  String _hint = '';
  String
    get Hint => _hint;
    set Hint(String Value)

    {
      if(Value == Hint)
        return;

      _hint = Value;
      Change();
    }



  TShortCut _shortCut = TShortCut.None;
  TShortCut
    get ShortCut => _shortCut;
     set ShortCut(TShortCut Value)
    {
      if(_shortCut == Value)
        return;
      for(var item in _clients)
      {
        if(item is TActionLink)
          item.SetShortCut(Value);
      }
      _shortCut = Value;
      Change();
    }



  bool DoHint(TPointer<String> HintStr)
  {
    bool Result = true;

    return Result;
  }

  bool Execute()
  {

    return Enabled && super.Execute();
  }


}
