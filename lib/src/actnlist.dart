part of vcl;

typedef void TActionEvent(TBasicAction Action, TPointer<bool> Handled);
enum TActionListState { Normal, Suspended, SuspendedEnabled }




class TContainedAction extends TBasicAction
{


 TContainedAction(TComponent AOwner) : super(AOwner);

  Destroy()
  {
    if(ActionList != null)
      ActionList!.RemoveAction(this);
    super.Destroy();
  }


  TCustomActionList? _actionList;
  TCustomActionList?
   get ActionList => _actionList;
   set ActionList(TCustomActionList? AActionList)
   {
     if(ActionList == AActionList)
       return;
     if(ActionList != null)
       ActionList!.RemoveAction(this);
     if(AActionList != null)
       AActionList.AddAction(this);
   }
  

  
  bool Execute()
  {
    return (ActionList != null) && ActionList!.ExecuteAction(this) ||
      Application.ExecuteAction(this) || super.Execute();/* ||
      (SendAppMessage(CM_ACTIONEXECUTE, 0, Longint(Self)) = 1)*/
  }
  
  bool Update()
  {
    return (ActionList != null) && ActionList!.UpdateAction(this) ||
      Application.UpdateAction(this) || super.Update(); 
  }
}

class TCustomActionList extends TComponent
{


  final _actions = <TContainedAction>[];

  late final TItems<TContainedAction> Actions;
//  property Actions[Index: Integer]: TContainedAction read GetAction write SetAction; default;

  TCustomActionList(TComponent AOwner) : super(AOwner)
  {
   TStrings s;
    Actions = TItems<TContainedAction>(
       (int ndx) => _actions[ndx],
       () => _actions,
       (int ndx, TContainedAction val) => _actions[ndx].Assign(val) );


  }



  void AddAction(TContainedAction Action)
  {
    _actions.add(Action);
    Action._actionList = this;
    Action.FreeNotification(this);
  }

  void RemoveAction(TContainedAction Action)
  {
    if(_actions.remove(Action))
      Action._actionList = null;
  }



  TActionEvent? _onExecute;
  TActionEvent?
    get OnExecute => _onExecute;
    set OnExecute(TActionEvent? Value) => _onExecute = Value;

  bool ExecuteAction(TBasicAction Action)
  {
    var Result = TPointer(false);
    if(OnExecute != null)
      OnExecute!(Action, Result);
    return Result.Value;
  }

  TActionEvent? _onUpdate;
  TActionEvent?
    get OnUpdate => _onUpdate;
    set OnUpdate(TActionEvent? Value) => _onUpdate = Value;

  bool UpdateAction(TBasicAction Action)
  {
    var Result = TPointer(false);
    if(OnUpdate != null)
      OnUpdate!(Action, Result);
    return Result.Value;
  }

  TActionListState _state = TActionListState.Normal;
  TActionListState
    get State => _state;
    set State(TActionListState Value)
    {
      if(_state == Value)
        return;
      _state = Value;
      if(State == TActionListState.Suspended)
        return;
      for(var Action in _actions)
      {
        switch(Value)
        {
          case TActionListState.Normal:
            if(Action is TCustomAction)
              if(State == TActionListState.SuspendedEnabled)
                Action.Enabled = Action.SavedEnabledState;
            Action.Update();
            break;

          case TActionListState.SuspendedEnabled:
            if(Action is TCustomAction)
              if(Value == TActionListState.SuspendedEnabled)
              {
                Action.SavedEnabledState = Action.Enabled;
                Action.Enabled = true;
              }
            break;

          default:
            break;
        }
      }
    }
}

class TActionLink extends TBasicActionLink
{


  TActionLink(TObject AClient) : super(AClient);

 

 void SetAutoCheck(bool Value) // virtual
 {
 }

 void SetCaption(String Value) // virtual
 {
 }

  void SetChecked(bool Value) // virtual
  {
  }

  void SetEnabled(bool Value) // virtual
  {
  }

  void SetGroupIndex(int Value) // virtual
  {
  }

 

 void SetHint(String Value) // virtual
 {
 }

 


 void SetShortCut(TShortCut Value) // virtual
 {
 }

 void SetVisible(bool Value) // virtual
 {
 }

}

typedef void THintEvent(TPointer<String> HintStr, TPointer<bool> CanShow);

class TCustomAction extends TContainedAction
{


  bool _savedEnabledState = false;
  bool
    get SavedEnabledState => _savedEnabledState;
    set SavedEnabledState(bool Value) => _savedEnabledState=Value;

  TCustomAction(TComponent AOwner) : super(AOwner)
  {

  }

  bool _disableIfNoHandler = false;
  bool
    get DisableIfNoHandler =>_disableIfNoHandler;
    set DisableIfNoHandler(bool value) => _disableIfNoHandler = value;



  void AssignTo(TPersistent Dest)
  {
    if(Dest is TCustomAction)
    {
      Dest
        ..Caption = Caption
        ..Checked = Checked
        ..Enabled = Enabled
        // ..HelpContext = HelpContext
        ..Hint = Hint
        // ..ImageIndex = ImageIndex
        ..ShortCut = ShortCut
        ..Visible = Visible
        ..OnExecute = OnExecute
        ..OnUpdate = OnUpdate
        ..OnChange = OnChange;
     }
     else
       super.AssignTo(Dest);
  }

  bool _autoCheck = false;
  bool
    get AutoCheck => _autoCheck;
    set AutoCheck(bool Value)
    {
      if(_autoCheck == Value)
        return;

      for(var item in _clients)
        if(item is TActionLink)
          item.SetAutoCheck(Value);

      _autoCheck = Value;
      Change();
    }

  String _caption = '';
  String
    get Caption => _caption;
    set Caption(String Value)
    {
      if(_caption == Value)
        return;
      for(var link in _clients)
        if(link is TActionLink)
          link.SetCaption(Value);
      _caption = Value;
      Change();
    }

  bool _checking = false;
  bool _checked = false;
  bool
    get Checked => _checked;
    set Checked(bool Value)
    {
      if(_checking)
       return;
      _checking = true;
      try
      {
        if(_checked != Value)
        {
          for(var item in _clients)
          {
            if(item is TActionLink)
              item.SetChecked(Value);
          }
          _checked = Value;
          if((_groupIndex > 0) && _checked)
          {
            for(var item in ActionList!.Actions)
            {
              if((item != this) && (item is TCustomAction) &&
                 (item._groupIndex == _groupIndex))
                item.Checked = false;
            }
          }
          Change();
        }
      }
      finally
      {
        _checking = false;
      }
    }

  bool _enabled = true;
  bool
    get Enabled => _enabled;
    set Enabled(bool Value)
    {
      if(Enabled == Value)
        return;

      if(ActionList != null)
        if(ActionList!.State == TActionListState.Suspended)
        {
          _enabled = Value;
          return;
        }
        else
          if(ActionList!.State == TActionListState.SuspendedEnabled)
            Value = true;
      for(var link in _clients)
      {
        if(link is TActionLink)
          link.SetEnabled(Value);
      }
      _enabled = Value;
      Change();
    }

  int _groupIndex = 0;
  int get GroupIndex => _groupIndex;
  set GroupIndex(int Value)
  {
    if(_groupIndex == Value)
      return;
    _groupIndex = Value;
    for(var item in _clients)
    {
      if(item is TActionLink)
       item.SetGroupIndex(Value);
    }
    Change();
  }



  String _hint = '';
  String
    get Hint => _hint;
    set Hint(String Value)
    {
      if(Value == Hint)
        return;
      for(var link in _clients)
      {
        if(link is TActionLink)
          link.SetHint(Value);
      }
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

  bool _visible = true;
  bool
    get Visible => _visible;
    void set Visible(bool Value)
    {
      if(_visible == Value)
        return;
      for(var link in _clients)
      {
        if(link is TActionLink)
          link.SetVisible(Value);
      }
      _visible = Value;
      Change();
    }



  THintEvent? _onHint;
  THintEvent?
    get OnHint => _onHint;
    set OnHint(THintEvent? Value) => _onHint = Value;

  bool DoHint(TPointer<String> HintStr)
  {
    var Result = TPointer(false);
    if(OnHint != null)
      OnHint!(HintStr, Result);
    return Result.Value;
  }

  bool Execute()
  {
    if((ActionList != null) && (ActionList!.State != TActionListState.Normal))
      return false;
    Update();
    if(Enabled && _autoCheck)
      Checked = !Checked;
    return Enabled && super.Execute();
  }


}


class TAction extends TCustomAction
{
  TAction(TComponent AOwner) : super(AOwner)
  {
    DisableIfNoHandler = true;
  }
}

