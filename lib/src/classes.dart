part of vcl;

typedef void TEvent(dynamic Sender);
typedef Future<bool> TLogicEvent(dynamic Sender);
typedef void TWndMethod(TMessage Message);

typedef void TNotifyEvent(TObject Sender);
typedef void TUnsafeNotifyEvent(TObject? Sender);
typedef void TKeyEvent(TObject Sender, TKeyCode Key, TShiftState Shift);
typedef void TKeyPressEvent(TObject Sender, TKeyCode Key);
typedef void TMouseEvent(TObject Sender, TMouseButton Button, TShiftState Shift, int X, int Y);
typedef void TMouseMoveEvent(TObject Sender, TShiftState Shift, int X, int Y);

typedef TObject TObjectCreator(TObject? Owner);
typedef void TCanResizeEvent(TObject Sender, Integer NewWidth, Integer NewNeight, TPointer<bool> Accept);

// Text alignment types
enum TAlignment { LeftJustify, RightJustify, Center }

// Types used by standard events
enum ShiftStates { Shift, Alt, Ctrl, Left, Right, Middle, Double }

typedef TShiftState = Set<ShiftStates>;



class TShortCut extends TEnum
{
  const TShortCut(String AName) :super(AName);

  static const None  = TShortCut('None');   
  static const Shift = TShortCut('Shift');  
  static const Ctrl  = TShortCut('scCtrl'); 
  static const Alt   = TShortCut('scAlt');  
}

class EListError extends TException
{
  EListError(String msg) : super(msg);

  EListError.CreateFmt(String msg, List args) : super.CreateFmt(msg, args);

  EListError.CreateResFmt(dynamic ident, var args) : super.CreateResFmt(ident, args);
}

class EBitsError extends TException
{
  EBitsError.CreateRes(dynamic Ident) : super.CreateRes(Ident);
}


class EStringListError extends TException
{
  EStringListError.CreateFmt(String msg, List args) : super.CreateFmt(msg, args);
}


class EOutOfResources extends EOutOfMemory
{
  EOutOfResources(String msg) : super(msg);
}

class EInvalidOperation extends TException
{
  EInvalidOperation(String msg) : super(msg);

  EInvalidOperation.CreateRes(dynamic ident) : super.CreateRes(ident);

  EInvalidOperation.CreateFmt(String msg, var args) : super.CreateFmt(msg, args);

}


enum  TCollectionNotification { Added, Extracting, Deleting }


enum TOperation { Insert, Remove }
enum ComponentStates { Loading, Reading, /*Writing,*/ Destroying, Designing, /*Ancestor,*/
                       Updating, /*Fixups,*/ FreeNotification, Inline/*, DesignInstance*/ }

typedef TComponentState = Set<ComponentStates>;


enum ComponentStyles { Inheritable/*, CheckPropAvail, SubComponent, Transient*/ }

typedef TComponentStyle = Set<ComponentStyles>;



enum TListNotification  {Added, Extracted, Deleted}

class TList<T> extends TObject
{
  final _list = <T>[];

  int get Count => _list.length; // write SetCount;
  late final TItems<T> Items;

  T operator [](int Index)
  {
    if(Index < 0 || Index >= Count)
      Error(RTLConsts.SListIndexError, Index);
    return _list[Index];
  }

  TList() : super()
  {
    Items = TItems<T>(
      (int ndx)
      {
        if(ndx < 0 || ndx >= Count)
          Error(RTLConsts.SListIndexError, ndx);
        return _list[ndx];
      },
      () => _list.iterator,
      (int ndx, T Item)
      {
        if((ndx < 0) || (ndx >= Count))
          Error(RTLConsts.SListIndexError, ndx);
        if(Item != _list[ndx])
        {
          T Temp = _list[ndx];
          _list[ndx] = Item;
          if(Temp != null)
            Notify(Temp, TListNotification.Deleted);
          if(Item != null)
            Notify(Item, TListNotification.Added);
        }
      });
  }

  void Destroy()
  {
    _list.clear();
    super.Destroy();
  }

  int Add(T Item)
  {
    int Result = Count;
    _list.add(Item);
    if(Item != null)
      Notify(Item, TListNotification.Added);
    return Result;
  }

  void Clear()
  {
    _list.clear();
  }

  void Delete(int Index)
  {
    if((Index < 0) || (Index >= Count))
      Error(RTLConsts.SListIndexError, Index);
    T Temp = Items[Index];
    _list.removeAt(Index);
    if(Temp != null)
      Notify(Temp, TListNotification.Deleted);
  }

  void Error(String Msg, int Data)
  {
    throw EListError.CreateFmt(Msg, [ Data ]);
  }


  T Get(int Index)
  {
    if((Index < 0) || (Index >= _list.length))
      Error(RTLConsts.SListIndexError, Index);
    return _list[Index];
  }



  int IndexOf(T Item)
  {
    return _list.indexOf(Item);
  }



  void Insert(int Index, T Item)
  {
    if((Index < 0) || (Index > Count))
      Error(RTLConsts.SListIndexError, Index);

    _list.insert(Index, Item);
    if(Item != null)
      Notify(Item, TListNotification.Added);
  }


  T get Last
  {
    return Get(_list.length - 1);
  }

  void Move(int CurIndex, int NewIndex)
  {
    if(CurIndex == NewIndex)
      return;
    if((NewIndex < 0) || (NewIndex >= Count))
      Error(RTLConsts.SListIndexError, NewIndex);
    dynamic Item = _list[CurIndex];
    Delete(CurIndex);
    Insert(NewIndex, Item);
  }



  int Remove(T Item)
  {
    int Result = IndexOf(Item);
    if(Result >= 0)
      Delete(Result);
    return Result;
  }

  T RemoveLast() // new
  {
    T Result = _list.removeLast();
    if(Result != null)
      Notify(Result, TListNotification.Deleted);
    return Result;
  }



  void Notify(T Ptr, TListNotification Action)
  {

  }


}



class TBits extends TObject
{
  final _bits = <int?>[];
  late final TItems<bool> Bits;

  int _size = 0;

  TBits() : super()
  {
    Bits = TItems<bool>(_getBit, () => throw UnimplementedError(), _setBit);
  }

  void Destroy()
  {
    super.Destroy();
  }

  bool operator [](int Index) => _getBit(Index);

  int get Size => _size;
  void set Size(int Value)
  {
    if(Value<0) Error();
    if(_size==Value)
      return;
    _size = Value;

    int ndx = (Value-1) ~/ BitsPerInt;
    _bits.length = ndx + 1;
  }

  static const BitsPerInt = 32;

  bool _getBit(int Index)
  {
    if(Index<0 || Index>=_size)
      Error();

    int pos = Index % BitsPerInt;
    int ndx = Index ~/ BitsPerInt;

    if(ndx>=_size)
      return false;

    int rec = _bits[ndx] ?? 0;

    return rec & 1<<pos != 0;
  }

  void _setBit(int Index, bool Value)
  {
    if(Index<0)
      Error();

    int pos = Index % BitsPerInt;
    int ndx = Index ~/ BitsPerInt;

    if(Index>=_size)
    {
      _size = Index + 1;

      _bits.length = ndx + 1;
    }

    int? rec = _bits[ndx];
    if(rec==null)
      rec=0;
    if(Value)
      _bits[ndx] = rec | (1<<pos);
    else
      _bits[ndx] = rec & ~(1<<pos);
  }

  String toString()
  {
    if(_size == 0)
      return '[empty]';

    String toBin(int? val, int size)
    {
      String str = '';
      if(val==null)
        val = 0;

      for(int i=0, s=1; i<=size; s<<=1)
      {
        str+=val&s==0? '0' : '1';
        if(++i%8 == 0)
          str+=' ';
      }
      return str;
    }

    String Result = '';
    int pos = (_size-1) % BitsPerInt;
    int ndx = (_size-1) ~/ BitsPerInt;

    for(int i=0; i<ndx; i++)
      Result+=toBin(_bits[i], BitsPerInt-1);

    return Result + toBin(_bits[ndx], pos);
  }

  String toHexString()
  {
    if(_size == 0)
      return '[empty]';

    String toHex(int? val)
    {
      String str = '';
      if(val==null)
        val = 0;

      for(int i=0; i<8; i++, val = val >> 4)
      {
        str+=(val! & 0xf).toRadixString(16);
        if(i==3)
          str+=' ';
      }
      return str;
    }

    String Result = '';
    int pos = (_size-1) % BitsPerInt;
    int ndx = (_size-1) ~/ BitsPerInt;

    for(int i=0; i<ndx; i++)
      Result+=toHex(_bits[i])+' ';

    return Result+toHex(_bits[ndx]);
  }

  void Error()
  {
    throw EBitsError.CreateRes(RTLConsts.SBitsIndexError);
  }

  int OpenBit()
  {
    if(_size==0)
      return 0;

    int firstOpen(int val, int size)
    {
      for(int i=0; i<=size; i++)
        if(val & 1<<i == 0)
          return i;
      return size + 1;
    }

    int pos = (_size-1) % BitsPerInt;
    int ndx = (_size-1) ~/ BitsPerInt;
    for(int i=0; i<ndx; i++)
    {
      int? val = _bits[i];
      if(val==null)
        return i*BitsPerInt;
      if(val!=0xffffffff)
        return i*BitsPerInt+firstOpen(val, BitsPerInt-1);
    }
    if(_bits[ndx]==null)
      return ndx*BitsPerInt;

    return ndx*BitsPerInt+firstOpen(_bits[ndx]!, pos);
  }

}

abstract class TPersistent extends TObject
{


  void Assign(TPersistent Source)
  {
    Source.AssignTo(this);
  }

  void _assignError(TPersistent? Source)
  {
    String SourceName = Source == null? 'null' : Source.ClassName();
    throw EConvertError.CreateResFmt(RTLConsts.SAssignError, [SourceName, ClassName() ]);
  }

  void AssignTo(TPersistent Dest)
  {
    Dest._assignError(this);
  }



  TPersistent? GetOwner()
  {
    return null;
  }
}


class TInterfacedPersistent extends TPersistent //, IInterface)
{

}



class TCollectionItem extends TPersistent
{
  TCollection? _collection;
  int _ID = -1;

  TCollection? get Collection => _collection;
  void set Collection(TCollection? Value) => SetCollection(Value);

  void SetCollection(TCollection? Value)
  {
    if(_collection == Value)
      return;

    if(_collection != null)
      _collection!.RemoveItem(this);
    if(Value != null)
      Value.InsertItem(this);
  }

  int get ID => _ID;

  String get DispalyName => GetDisplayName();
  void set DisplayName(String Value) => SetDisplayName(Value);

  TCollectionItem();

  void Destroy()
  {
    SetCollection(null);
    super.Destroy();
  }

  void Changed(bool AllItems)
  {
    if((Collection != null) && (Collection!._updateCount == 0))
      Collection!.Update(AllItems? null : this);
  }

  int get Index
  {
    if(_collection == null)
      return -1;
    return _collection!._items.indexOf(this);
  }

  void set Index(int Value) => SetIndex(Value);

  void SetIndex(int Value)
  {
    int CurIndex = Index;
    if(CurIndex >= 0 && CurIndex != Value)
    {
      _collection!._items.remove(this);
      _collection!._items.insert(Value, this);
      Changed(true);
    }
  }

  String GetDisplayName()
  {
    return ClassName();
  }



  TPersistent? GetOwner()
  {
    return _collection;
  }


  void SetDisplayName(String Value)
  {
    Changed(false);
  }
}

abstract class TCollection extends TPersistent
{

  final _items = <TCollectionItem>[];
  int get Count => _items.length;

  int _updateCount = 0;
  int get UpdateCount => _updateCount;

  int _nextID = 0;
  int get NextID => _nextID;

  late final TItems<TCollectionItem> Items;

  final TObjectCreator _creator;

  TCollection(this._creator)
  {
    Items = TItems<TCollectionItem>(
      (ndx) => _items[ndx],
      () => _items.iterator,
      (ndx, value) => _items[ndx].Assign(value) );
    
  }


  TCollectionItem Add()
  {
    var Result = _creator(null);
    if(Result is TCollectionItem)
    {
      Result.Collection = this;
      Added(Result);
      return Result;
    }
    throw UnsupportedError('Invalid class type');
  }


  void BeginUpdate()
  {
    _updateCount++;
  }

  void Changed()
  {
    if(_updateCount == 0)
      Update(null);
  }

  void Clear()
  {
    if(_items.length > 0)
    {
      BeginUpdate();
      try
      {
        while(_items.length > 0)
          _items.removeLast(); 
      }
      finally
      {
        EndUpdate();
      }
    }
  }

  void EndUpdate()
  {
    _updateCount--;
    Changed();
  }



  TCollectionItem Insert(int Index)
  {
    TCollectionItem Result = Add();
    Result.Index = Index;
    return Result;
  }

  void InsertItem(TCollectionItem Item)
  {

    _items.add(Item);
    Item._collection = this;
    Item._ID = _nextID;
    _nextID++;
    SetItemName(Item);
    Notify(Item, TCollectionNotification.Added);
    Changed();
    
  }

  void RemoveItem(TCollectionItem Item)
  {
    Notify(Item, TCollectionNotification.Extracting);
    if(Item == _items.last)
      _items.removeLast();
    else
      _items.remove(Item);
    Item._collection = null;
    
    Changed();
  }

  void SetItemName(TCollectionItem Item)
  {

  }

  void Update(TCollectionItem? Item)
  {

  }

  void Delete(int Index)
  {
    Notify(_items[Index], TCollectionNotification.Deleting);
    
    _items[Index].Collection = null;
  }



  void Added(TCollectionItem Item)
  {

  }

  void Deleting(TCollectionItem Item)
  {

  }

  void Notify(TCollectionItem Item, TCollectionNotification Action)
  {
    if(Action == TCollectionNotification.Added)
      Added(Item);
    else
    if(Action == TCollectionNotification.Deleting)
      Deleting(Item);
  }
}

// Collection class that maintains an "Owner" in order to obtain property
// path information at design-time
abstract class TOwnedCollection extends TCollection
{
  TPersistent? _owner;

  TOwnedCollection(this._owner, TObjectCreator proc) : super(proc)
  {

  }

  TPersistent? GetOwner()
  {
    return _owner;
  }
}



abstract class TStrings extends TPersistent
{

  int _updateCount = 0;
  int get UpdateCount => _updateCount;
    
  String Get(int Index);

  int GetCount();

  void Clear();
  void Delete(int Index);

  void Insert(int Index, String S); // virtual; abstract;

  int get Count => GetCount();
    

  late final TItems<dynamic> Objects;
  Iterator<dynamic> get iObjects => throw UnimplementedError();



  late final TItems<String> Strings;
  Iterator<String> get iStrings => throw UnimplementedError();

  String get Text => GetTextStr();
  set Text(String Value) => SetTextStr(Value);


  TStrings() : super()
  {
    Objects = TItems<dynamic>(GetObject, ()=>iObjects, PutObject);
    Strings = TItems<String>(Get, ()=>iStrings, Put);
  }

  void Destroy()
  {

    super.Destroy();
  }

  int Add(String S)
  {
    int Result = GetCount();
    Insert(Result, S);
    return Result;
  }

  int AddObject(String S, dynamic AObject)
  {
    int Result = Add(S);
    PutObject(Result, AObject);
    return Result;
  }

  void Append(String S)
  {
    Add(S);
  }

  void AddStrings(TStrings Strings)
  {
    BeginUpdate();
    try
    {
      for(int i=0; i<Strings.Count; i++)
        AddObject(Strings.Strings[i], Strings.Objects[i]);
    }
    finally
    {
      EndUpdate();
    }
  }

  void Assign(TPersistent Source)
  {
    if(Source is TStrings)
    {
      BeginUpdate();
      try
      {
        Clear();

        AddStrings(Source);
      }
      finally
      {
        EndUpdate();
      }
      return;
    }
    super.Assign(Source);
  }

  void AssignList(List list) // new
  {
    BeginUpdate();
    try
    {
      Clear();
      for(String str in list)
        Add(str);
    }
    finally
    {
      EndUpdate();
    }
  }

  void AssignMap(Map map) // new
  {
    BeginUpdate();
    try
    {
      Clear();
      map.forEach( (key, val) =>
          AddObject(val, key) );
    }
    finally
    {
      EndUpdate();
    }
  }

  void BeginUpdate()
  {
    if(_updateCount == 0)
      SetUpdateState(true);
    _updateCount++;
  }



  void EndUpdate()
  {
    _updateCount--;
    if(_updateCount == 0)
      SetUpdateState(false);
  }




  void Error(String Msg, int Data)
  {
    throw EStringListError.CreateFmt(Msg, [Data]);
  }



  dynamic GetObject(int Index)
  {
    return null;
  }



  String GetTextStr()
  {
    var Result = <int>[];
    int Count = GetCount();
    for(int i = 0; i<Count; i++)
    {
      Result.addAll(Get(i).codeUnits);
      Result.addAll(TObject.sLineBreak.codeUnits);
      String S = Get(i);
      int L = S.length;
    }
    return String.fromCharCodes(Result);
  }


  int IndexOf(String S)
  {
    for(int i = 0 ; i < Count; i++)
      if(Get(i)==S)
        return i;
    return -1;
  }



  int IndexOfObject(dynamic AObject)
  {
    for(int i=Count-1; i>=0; i--)
      if(GetObject(i) == AObject)
        return i;
    return -1;
  }

  void InsertObject(int Index, String S, dynamic AObject)
  {
    Insert(Index, S);
    PutObject(Index, AObject);
  }



  void Move(int CurIndex, int NewIndex)
  {
    if(CurIndex == NewIndex)
      return;
    BeginUpdate();
    try
    {
      String TempString = Get(CurIndex);
      dynamic TempObject = GetObject(CurIndex);
      Delete(CurIndex);
      InsertObject(NewIndex, TempString, TempObject);
    }
    finally
    {
      EndUpdate();
    }
  }

  void Put(int Index, String S)
  {
    dynamic TempObject = GetObject(Index);
    Delete(Index);
    InsertObject(Index, S, TempObject);
  }

  void PutObject(int Index, dynamic AObject)
  {

  }



  void SetTextStr(String Value)
  {
    BeginUpdate();
    try
    {
      Clear();
      var items = Value.split(RegExp(r'\r\n|\r|\n'));
      for(var item in items)
        Add(item);

    }
    finally
    {
      EndUpdate();
    }
  }

  void SetUpdateState(bool Updating)
  {

  }


}

class TStringItem
{
  String  FString;
  dynamic FObject;
  TStringItem(this.FString, this.FObject);
}

class _stringsIterator extends Iterator<String>
{
  int   ndx = -1;
  final list;
  _stringsIterator(this.list);

  @override
  String get current => list[ndx].FString;

  @override
  bool moveNext() => ++ndx<list.length;
}

class _objectsIterator extends Iterator<dynamic>
{
  int   ndx = -1;
  final list;

  _objectsIterator(this.list);

  @override
  dynamic get current => list[ndx].FObject;

  @override
  bool moveNext() => ++ndx<list.length;
}


class TStringList extends TStrings
{

  final _list = <TStringItem>[];

  bool _sorted = false;
  bool get Sorted => _sorted;
  void set Sorted(bool Value) {
    if(_sorted == Value)
      return;
    if(Value)
      Sort();
    _sorted = Value;
  }


  TNotifyEvent? _onChange;
  TNotifyEvent? get OnChange => _onChange;
  void set OnChange(TNotifyEvent? Value) => _onChange=Value;

  TNotifyEvent? _onChanging;
  TNotifyEvent? get OnChanging => _onChanging;
  void set OnChanging(TNotifyEvent? Value) => _onChanging=Value;

  

  TStringList() : super()
  {
  }



  String toString()
  {
    String Result='';
    String sp ='';
    _list.forEach((item){
      Result="$Result$sp${(item as TStringItem).FString}";
      sp=', ';
    });
    return '[$Result]';
  }


  int Add(String S)
  {
    return AddObject(S, null);
  }

  int AddObject(String S, dynamic AObject)
  {
    int Result = -1;
    if(!Sorted)
      Result = _list.length;
    else
      throw UnsupportedError('need write code');

    InsertItem(Result, S, AObject);
    return Result;
  }

  void Changed()
  {
    if((_updateCount == 0) && (_onChange != null))
      _onChange!(this);
  }

  void Changing()
  {
    if((_updateCount == 0) && (_onChanging != null))
      _onChanging!(this);
  }

  void Clear()
  {
    if(_list.length > 0)
    {
      Changing();
      _list.clear();

      Changed();
    }
  }

  void Delete(int Index)
  {
    if((Index < 0) || (Index >= Count))
      this.Error(RTLConsts.SListIndexError, Index);
    Changing();
    _list.removeAt(Index);
    
    Changed();
  }



  String Get(int Index)
  {
    if((Index < 0) || (Index >= _list.length))
      this.Error(RTLConsts.SListIndexError, Index);
    return _list[Index].FString;
  }

  Iterator<String> get iStrings => _stringsIterator(_list);



  int GetCount()
  {
    return _list.length;
  }

  dynamic GetObject(int Index)
  {
    if((Index < 0) || (Index >= _list.length))
      this.Error(RTLConsts.SListIndexError, Index);
    return _list[Index].FObject;
  }

  Iterator<dynamic> get iObjects => _objectsIterator(_list);



  void Insert(int Index, String S)
  {
    InsertObject(Index, S, null);
  }

  void InsertObject(int Index, String S, dynamic AObject)
  {
    if(Sorted)
      this.Error(RTLConsts.SSortedListError, 0);
    if((Index < 0) || (Index > Count))
      this.Error(RTLConsts.SListIndexError, Index);
    InsertItem(Index, S, AObject);
  }

  void InsertItem(int Index, String S, dynamic AObject)
  {
    Changing();
    _list.insert(Index, TStringItem(S, AObject));
    Changed();
  }


  void Put(int Index, String S)
  {
    if(Sorted)
      this.Error(RTLConsts.SSortedListError, 0);
    if((Index < 0) || (Index >= _list.length))
      this.Error(RTLConsts.SListIndexError, Index);
    Changing();
    _list[Index].FString = S;
    Changed();
  }

  void PutObject(int Index, dynamic AObject)
  {
    if((Index < 0) || (Index >= Count))
      this.Error(RTLConsts.SListIndexError, Index);
    Changing();
    _list[Index].FObject = AObject;
    Changed();
  }



  void Sort()
  {

  }


}


abstract class TStream extends TObject
{


}


abstract class TCustomMemoryStream extends TStream
{
  
}

class TMemoryStream extends TCustomMemoryStream
{

}


class TComponent extends TPersistent
{ 
  TComponent? _owner;
  TComponent? get Owner => _owner;

  dynamic _tag;
  dynamic get Tag => _tag;
  void set Tag(dynamic Value) => _tag = Value;

  final _components = <TComponent>[];
  int get ComponentCount => _components.length;

  late final TItems<TComponent> Components;

  final _freeNotifies = <TComponent>[];

  final _componentState = TComponentState();
  TComponentState get ComponentState => _componentState;

    
  TComponentStyle _componentStyle = TComponentStyle();
  TComponentStyle get ComponentStyle => _componentStyle;

  TComponent(this._owner) : super()
  {
    Components = TItems<TComponent>(
      (int ndx) => _components[ndx],
      ()        => _components.iterator );

    ComponentStyle.assign( [ComponentStyles.Inheritable] );

    Owner?.InsertComponent(this);
  }

  void Destroy()
  {
    Destroying();
    while(_freeNotifies.isNotEmpty)
      _freeNotifies.last.Notification(this, TOperation.Remove);
    DestroyComponents();
    if(Owner != null)
      Owner!.RemoveComponent(this);
    super.Destroy();
  }

  void BeforeDestruction()
  {
    if(!ComponentState.contains(ComponentStates.Destroying))
      Destroying();
  }

  void FreeNotification(TComponent AComponent)
  {
    if((Owner == null) || (AComponent.Owner != Owner))
    {
      // Never acquire a reference to a component that is being deleted.
      assert(!(ComponentState.contains(ComponentStates.Destroying) ||
               AComponent.ComponentState.contains(ComponentStates.Destroying)));
      if(!_freeNotifies.contains(AComponent))
      {
        _freeNotifies.add(AComponent);
        AComponent.FreeNotification(this);
      }
    }
    _componentState << ComponentStates.FreeNotification;
  }




  void _insert(TComponent AComponent)
  {
    _components.add(AComponent);
    AComponent._owner = this;
  }

  void InsertComponent(TComponent AComponent)
  {
    AComponent.ValidateContainer(this);

    _insert(AComponent);

  }

  void _remove(TComponent AComponent)
  {
    AComponent._owner = null;
    _components.remove(AComponent);
  }

  void RemoveComponent(TComponent AComponent)
  {
    
    _remove(AComponent);
  }

  void DestroyComponents()
  {
    while(_components.isNotEmpty)
    {
      var obj = _components.last;
      if((obj._componentState.contains(ComponentStates.FreeNotification))
        || (_componentState.contains(ComponentStates.Designing) && _componentState.contains(ComponentStates.Inline)))
        RemoveComponent(obj);
      else
        _remove(obj);
      obj.Destroy();
    }
  }

  void Destroying()
  {
    if(!_componentState.contains(ComponentStates.Destroying))
    {
      _componentState << ComponentStates.Destroying;
      for(var item in _components)
        item.Destroying();
    }
  }

  void RemoveNotification(TComponent AComponent)
  {
    _freeNotifies.remove(AComponent);
  }

  void RemoveFreeNotification(TComponent AComponent)
  {
    RemoveNotification(AComponent);
    AComponent.RemoveNotification(this);
  }

  void Notification(TComponent AComponent, TOperation Operation)
  {
    if(Operation == TOperation.Remove)
      RemoveFreeNotification(AComponent);

    int i = ComponentCount - 1;
    while(i>= 0)
    {
      Components[i].Notification(AComponent, Operation);
      i--;
      if(i >= ComponentCount) {
        i = ComponentCount - 1;
      }
    }
  }



  void ValidateContainer(TComponent AComponent)
  {
    AComponent.ValidateInsert(this);
  }

  void ValidateInsert(TComponent AComponent)
  {

  }

  TComponent? FindComponent(String AName)
  {
    if(AName.isNotEmpty)
    {
      for(var item in _components)
        if(SysUtils.SameText(item.Name, AName))
          return item;
    }
    return null;
  }

  String _name = '';
  String
    get Name => _name;
    set Name(String value) => SetName(value);

  void SetName(String NewName)
  {
    if(_name == NewName)
      return;

    ChangeName(NewName);

  }

  void ChangeName(String NewName)
  {
    _name = NewName;
  }


}

class TBasicActionLink extends TObject {
  

  TBasicActionLink(TObject AClient) : super()
  {
    AssignClient(AClient);
  }

  TNotifyEvent? _onChange;

  TNotifyEvent?
  get OnChange => _onChange;

  set OnChange(TNotifyEvent? Value) => _onChange = Value;

  void AssignClient(TObject AClient) {

  }

  

  bool Execute(TComponent? AComponent)
  {
    if(_action!.ActionComponent != AComponent)
    {
      if(_action!.ActionComponent!=null)
        _action!.ActionComponent!.RemoveFreeNotification(_action!);
      if(AComponent != null)
        AComponent.FreeNotification(_action!);
      _action!.ActionComponent = AComponent;
    }
    return _action!.Execute();
  }

  TBasicAction? _action;
  TBasicAction?
    get Action => _action;
    set Action(TBasicAction? Value)
    {
      if(Value == _action)
        return;
      if(_action != null)
        _action!.UnRegisterChanges(this);
      _action = Value;
      if(Value != null)
        Value.RegisterChanges(this);
    }



  bool Update()
  {
    return _action!.Update();
  }
}

class TBasicAction extends TComponent
{

  TComponent? _actionComponent;
  TComponent?
    get ActionComponent => _actionComponent;
    set ActionComponent(TComponent? Value) => _actionComponent = Value;

  final _clients = <TBasicActionLink>[];

  TBasicAction(TComponent AOwner) : super(AOwner)
  {

  }

  void Destroy() // destructor
  {
    super.Destroy();
    if(ActionComponent != null)
      ActionComponent!.RemoveFreeNotification(this);
    while(_clients.isNotEmpty)
      UnRegisterChanges(_clients.last);
    // FreeAndNil(FClients);
  }



  TNotifyEvent? _onExecute;
  TNotifyEvent?
    get OnExecute => _onExecute;
    set OnExecute(TNotifyEvent? event) => SetOnExecute(event);

  bool Execute()
  {
    if(OnExecute==null)
      return false;
    OnExecute!(this);
    return true;
  }

  TNotifyEvent? _onUpdate;
  TNotifyEvent?
    get OnUpdate => _onUpdate;
    set OnUpdate(TNotifyEvent? value) => _onUpdate = value;

  bool Update()
  {
    if(_onUpdate==null)
      return false;
    OnUpdate!(this);
    return true;
  }

  void SetOnExecute(TNotifyEvent? Value)

  {

      _onExecute = Value;
      Change();

  }

  TNotifyEvent? _onChange;
  TNotifyEvent?
    get OnChange => _onChange;
    set OnChange(TNotifyEvent? event) => _onChange = event;

  void Change()
  {
    if(OnChange != null)
      OnChange!(this);
  }

  void RegisterChanges(TBasicActionLink Value)
  {
    Value._action = this;
    _clients.add(Value);
  }

  void UnRegisterChanges(TBasicActionLink Value)
  {
    if(_clients.remove(Value))
      Value._action = null;

  }

}
