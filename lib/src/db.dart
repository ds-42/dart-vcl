part of vcl;

typedef void TDataChangeEvent(TObject Sender, TField? Field);
typedef void TDataOperation();

enum TFieldAttribute { HiddenCol, Readonly, Required, Link, UnNamed, Fixed }

typedef TFieldAttributes = Set<TFieldAttribute>;


// Misc DataSet types

enum TFieldType { Unknown, Dynamic, String, Integer, 
  Boolean, Float, Date, Time, DateTime,
AutoInc, ADT, Array, DataSet, }

String DataTypeToString(TFieldType type)
{
  switch(type)
  {

    case TFieldType.AutoInc: return 'AutoInc';
    case TFieldType.Boolean: return 'Boolean';

    case TFieldType.Date: return 'Date';
    case TFieldType.DateTime: return 'DateTime';
    case TFieldType.Dynamic: return 'Dynamic';
    case TFieldType.Float: return 'Float';
    case TFieldType.Integer: return 'Integer';
    case TFieldType.String: return 'String';
    case TFieldType.Time: return 'Time';
    default: return 'Unknown';
  }
}


enum TDataSetState { Inactive, Browse, Edit, Insert, SetKey,
    BlockRead,
    Opening }

enum TDataEvent { FieldChange, RecordChange, DataSetChange, DataSetScroll, LayoutChange,
  UpdateRecord, UpdateState, CheckBrowseMode, PropertyChange, FieldListChange,
  FocusControl, ParentScroll, ConnectChange,
  DataSetReady } // new


// Exception classes

class EDatabaseError extends TException
{
  EDatabaseError(String msg) : super(msg);

  EDatabaseError.CreateResFmt(String msg, var args) : super.CreateFmt(msg, args);
}


enum TFieldKind { Data, Calculated, Lookup, InternalCalc, Aggregate }


enum TBookmarkFlag { Current, BOF, EOF, Inserted }


enum TGetMode { Current, Next, Prior }

enum TGetResult { OK, BOF, EOF, Error }


enum TDataAction { Fail, Abort, Retry }



enum TLocateOption { CaseInsensitive, PartialKey }

typedef TLocateOptions = Set<TLocateOption>;


typedef TDataSetNotifyEvent(TDataSet DataSet);
typedef TDataSetErrorEvent(TDataSet DataSet, EDatabaseError E, TDataAction Action);



bool StateInEditModes(TDataSetState State)
{ 
  return
    State==TDataSetState.Edit ||
    State==TDataSetState.Insert ||
    State==TDataSetState.SetKey;
}



  void DatabaseError(String Message, [TComponent? Component])
  {
    if((Component!=null) && (Component.Name.isNotEmpty))
      throw EDatabaseError(SysUtils.Format('%s: %s', [Component.Name, Message]));
    else
      throw EDatabaseError(Message);
  }

  void DatabaseErrorFmt(String Message, var Args, [TComponent? Component])
  {
    DatabaseError(SysUtils.Format(Message, Args), Component);
  }



class TNamedItem extends TCollectionItem
{
  String _name = '';
  String
    get Name => _name;
    set Name(String Value) => SetDisplayName(Value);

  String GetDisplayName()
  {
    return _name;
  }

  void SetDisplayName(String Value)
  {
    if((Value != '') && (Value != _name) &&
        (Collection is TDefCollection) &&
        ((Collection as TDefCollection).IndexOf(Value) >= 0))
      DatabaseErrorFmt(DBConsts.SDuplicateName, [Value, Collection!.ClassName()]);
    _name = Value;
    super.SetDisplayName(Value);
  }
}

typedef void TDefUpdateMethod();

abstract class TDefCollection extends TOwnedCollection
{
  late final TDataSet DataSet;

  int _internalUpdateCount = 0;

  TUnsafeNotifyEvent? _onUpdate;
  TUnsafeNotifyEvent?
    get OnUpdate => _onUpdate;
    set OnUpdate(TUnsafeNotifyEvent? Value) => _onUpdate = Value;

  bool _updated = false;
  bool
    get Updated => _updated;
    set Updated(bool Value) => _updated = Value;

  TDefCollection(TPersistent? AOwner, TObjectCreator AClass) : super(AOwner, AClass)
  {
    _onUpdate = DoUpdate;
  }



  void Update(TCollectionItem? AItem)
  {
    if(!DataSet.ComponentState.contains(ComponentStates.Loading))
      OnUpdate!(AItem);
  }

  void DoUpdate(dynamic Sender)
  {
    if(_internalUpdateCount == 0)
    {
      Updated = false;
      DataSet.DefChanged(this);
    }
  }


  void UpdateDefs(TDefUpdateMethod AMethod)
  {
    if(Updated)
      return;

    _internalUpdateCount++;
    BeginUpdate();
    try
    {
      AMethod();
    }
    finally
    {
      EndUpdate();
      _internalUpdateCount--;
    }
    Updated = true; // Defs are now a mirror of data source
  }

  int IndexOf(String AName)
  {
    for(int i = 0; i < Count; i++)
      if(((_items[i]) as TNamedItem).Name == AName)
        return i;
    return -1;
  }

  TNamedItem? Find(String AName)
  {
    int i = IndexOf(AName);
    if(i < 0)
      return null;
    return _items[i] as TNamedItem;
  }



}

class TFieldDef extends TNamedItem
{
  TFieldDefs? _childDefs;

  int _precision = 0;
  int
    get Precision => _precision;
    set Precision(int Value)
    {
      _precision = Value;
      Changed(false);
    }

  int _fieldNo = 0;
  int
    get FieldNo
    {
      if(_fieldNo > 0)
        return _fieldNo;
      return Index + 1;
    }
    set FieldNo(int Value) => _fieldNo = Value;

  int _size = 0;
  int
    get Size
    {
      if(HasChildDefs() && (_size == 0))
        return _childDefs!.Count;
      else
        return _size;
    }
    set Size(int Value)
    {
      if(HasChildDefs() && (DataType != TFieldType.Array))
        return;
      _size = Value;
      Changed(false);
      
    }



  TFieldType _dataType = TFieldType.Unknown;
  TFieldType
    get DataType => _dataType;
    set DataType(TFieldType Value)
    {
  

      _dataType = Value;
      _precision = 0;
      switch(_dataType)
      {
        case TFieldType.String:
          _size = 20;
          break;

        default:
          _size = 0;
          break;
      }
      Changed(false);
    }

  TFieldAttributes _attributes = TFieldAttributes();
  TFieldAttributes
    get Attributes => _attributes;
    set Attributes(TFieldAttributes Value)
    {
      _attributes = Value;

      Changed(false);
    }

  bool
    get Required => Attributes.contains(TFieldAttribute.Required);
    set Required(bool Value)
    {
      if(Value)
        Attributes << TFieldAttribute.Required;
      else
        Attributes >> TFieldAttribute.Required;
    }



  bool HasChildDefs()
  {
    return (_childDefs != null) && (_childDefs!.Count > 0);
  }




  TField CreateFieldComponent(TDataSet Owner, [ TObjectField? ParentField, String FieldName = '' ])
  {

    TField Result =  Owner.CreateTypeField(DataType);
    try
    {
      Result.Size = Size;
      if(FieldName != '')
        Result.FieldName = FieldName;
      else
        Result.FieldName = Name;
      Result.Required = Attributes.contains(TFieldAttribute.Required);
      Result.ReadOnly = Attributes.contains(TFieldAttribute.Readonly);

      if(ParentField == null)
        Result.DataSet = (Collection as TFieldDefs).DataSet;

    }
    catch(E)
    {
      Result.Destroy();
      throw E;
    }
    return Result;
  }

  TField CreateField(TDataSet Owner, [ TObjectField? ParentField, String FieldName='', bool CreateChildren = true ])
  {
    TField Result = CreateFieldComponent(Owner, ParentField, FieldName);

    return Result;
  }
}

class TFieldDefs extends TDefCollection
{
  late final TFieldDef? _parentDef;


  late final TItems<TFieldDef> _fields;
  TItems<TFieldDef> get Items => _fields;

  TFieldDefs(TPersistent AOwner) : super(AOwner, (Sender) => TFieldDef())
  {
    _fields = TItems<TFieldDef>.from(super.Items);

    if(AOwner is TFieldDef)
    {
      _parentDef = AOwner;
      DataSet = (_parentDef!.Collection as TFieldDefs).DataSet;
    }
    else
    {
      _parentDef = null;
      DataSet = AOwner as TDataSet;
    }

  }



  TFieldDef AddFieldDef()
  {
    return super.Add() as TFieldDef;
  }

  void AddEx(String FieldName, TFieldType DataType, [ int Size=0, bool Required=false ])
  {
    if(FieldName == "")
      DatabaseError(DBConsts.SFieldNameMissing, DataSet);
    BeginUpdate();
    try
    {
      TFieldDef FieldDef = AddFieldDef();
      try
      {
        // FieldNo is defaulted
        FieldDef.Name = FieldName;
        FieldDef.DataType = DataType;
        FieldDef.Size = Size;
        // Precision is defaulted
        FieldDef.Required = Required;
      }
      catch(E)
      {
        FieldDef.Destroy();
        throw E;
      }
    }
    finally
    {
      EndUpdate();
    }
  }

  TFieldDef Find(String Name)
  {
    var Result = super.Find(Name) as TFieldDef?;
    if(Result == null)
      DatabaseErrorFmt(DBConsts.SFieldNotFound, [ Name ], DataSet);
    return Result!;
  }



  void InternalUpdate() 
  {
    DataSet.FieldDefList.Updated = false;
    UpdateDefs(DataSet.InitFieldDefs);
  }


}


abstract class TFlatList extends TStringList
{
  final TDataSet DataSet;

  bool _locked = true;
  bool
    get Locked => _locked;
    set Locked(bool Value) => _locked = Value;

  bool _updated = false;
  bool
    get Updated => GetUpdated();
    set Updated(bool Value) => _updated=Value;

  void UpdateList();

  TFlatList(this.DataSet) : super()
  {
    OnChanging = this._listChanging;
  }


  TObject? FindItem(String Name, bool MustExist)
  {
    if(!Updated)
      Update();
    int i = IndexOf(Name);
    if(i > -1)
      return GetObject(i);
    else
    {
      if(MustExist)
        DatabaseErrorFmt(DBConsts.SFieldNotFound, [ Name ], DataSet);
      return null;
    }
  }

  int GetCount()
  {
    if(!Updated)
      Update();
    return super.GetCount();
  }

  bool GetUpdated()
  {
    return _updated;
  }

  void _listChanging(TObject Sender)
  {
    if(Locked)
      DatabaseError(RTLConsts.SReadOnlyProperty, DataSet);
  }

  void Update()
  {
    if(Updated)
      return;
    Locked = false;
    BeginUpdate();
    try
    {
      Clear();
      UpdateList();
      _updated = true;
    }
    finally
    {
      EndUpdate();
      Locked = true;
    }
  }
}

class TFieldDefList extends TFlatList
{
  late final TItems<TFieldDef> FieldDefs;

  TFieldDefList(TDataSet ADataSet) : super(ADataSet)
  {
    FieldDefs = TItems<TFieldDef>(
      (ndx)
      {
        if(!Updated)
          Update();
        return GetObject(ndx);
      },
      () => throw UnimplementedError() );
  }

  TFieldDef? Find(String Name)
  {
    return FindItem(Name, false) as TFieldDef;
  }

  TFieldDef? FieldByName(String Name)
  {
    return FindItem(Name, true) as TFieldDef;
  }

  void UpdateList()
  {

    void AddFieldDefs(String ParentName, TFieldDefs FieldDefs)
    {
      
      for(int i = 0;  i<FieldDefs.Count; i++)
      {
        TFieldDef FieldDef = FieldDefs.Items[i];
        String FieldName = ParentName+FieldDef.Name;
        AddObject(FieldName, FieldDef);

      }
    }

    if(DataSet.Active)
      DataSet.FieldDefs.InternalUpdate();
    AddFieldDefs("", DataSet.FieldDefs);
  }

  bool GetUpdated()
  {
    return _updated && DataSet.FieldDefs.Updated;
  }
}

class TFieldList extends TFlatList
{

  late final TItems<TField> Fields;

  TFieldList(TDataSet ADataSet) : super(ADataSet)
  {
    Fields = TItems<TField>(
      (ndx)
      {
        if(!Updated)
          Update();
        return Objects[ndx];
      },
      () => throw UnimplementedError() );
  }



  void UpdateList()
  {
    void AddFields(TFields AFields)
    { // Using Fields.FList.Count here to exclude sparse fields
      for(var item in AFields._list)
      {
        AddObject(item.FullName, item);
        
      }
    }

    AddFields(DataSet.Fields);
  }


}

class TFields extends TObject
{

  final TDataSet DataSet;

  final _list = <TField>[];
  late final TItems<TField> Fields;


  TFields(this.DataSet) : super()
  {
    Fields = TItems<TField>(
      (int ndx) => _list[ndx],
      () => _list.iterator );
    
  }


  void Changed()
  {
    if(!DataSet.ComponentState.contains(ComponentStates.Destroying))
      DataSet.DataEvent(TDataEvent.FieldListChange, null);
    
  }

  void CheckFieldKind(TFieldKind FieldKind, TField Field)
  {

  }

  void Add(TField Field)
  {
    CheckFieldKind(Field.FieldKind, Field);
    _list.add(Field);
    Field._fields = this;

    Changed();
  }

  TField? AddEx(String name, TFieldType type, [ int size = 0 ])
  {
    if(DataSet.Active)
      return null;

    TField Result = DataSet.CreateTypeField(type);
    if(size > 0)
      Result.Size = size;

    Result.FieldName = name;
    Add(Result);
    return Result;
  }

  void Remove(TField Field)
  {
    _list.remove(Field);
    Field._fields = null;
    Changed();
  }

  void Clear()
  {
    while(_list.isNotEmpty)
    {
      TField f = _list.removeLast();
      f._dataSet = null;
      f.Destroy();
    }
    Changed();
  }


  int get Count
  {

    return _list.length;
  }

  int IndexOf(TField Field)
  {
    return _list.indexOf(Field);
  }

  void CheckFieldName(String FieldName)
  {
    if(FieldName.isEmpty)
        DatabaseError(DBConsts.SFieldNameMissing, DataSet);
    if(FindField(FieldName) != null)
      DatabaseErrorFmt(DBConsts.SDuplicateFieldName, [FieldName], DataSet);
  }


  TField? FindField(String FieldName)
  {
    for(var item in _list)
    {
      if(item.FieldName == FieldName)
        return item;
    }
    return null;
  }

  TField? FieldByName(String FieldName)
  {
    TField? Result = FindField(FieldName);
    if(Result == null)
      DatabaseErrorFmt(DBConsts.SFieldNotFound, [FieldName], DataSet);
    return Result;
  }



  void SetFieldIndex(TField Field, int Value)
  {
    int CurIndex = _list.indexOf(Field);
    if(CurIndex >= 0)
    {
      int Count = _list.length;
      if(Value < 0) Value = 0;
      if(Value >= Count) Value = Count - 1;
      if(Value != CurIndex)
      {
        _list.removeAt(CurIndex);
        _list.insert(Value, Field);
        Field.PropertyChanged(true);
        Changed();
      }
    }
  }

}


class TField extends TComponent
{

  String _fieldName = '';
  TFields? _fields;
  TFieldType _dataType = TFieldType.Unknown;
  bool _readOnly = false;

  TFieldKind _fieldKind = TFieldKind.Data;
  TFieldKind
    get FieldKind => _fieldKind;
    set FieldKind(TFieldKind Value) => SetFieldKind(Value);

  TAlignment _alignment = TAlignment.LeftJustify;
  bool _visible = true;
  bool _required = false;

  int _size = 0;

  int _fieldNo = -1;


  String _displayLabel="";
  String
    get DisplayLabel => DisplayName;
    set DisplayLabel(String Value)
    {
      if(Value == _fieldName)
        Value = "";
      if(_displayLabel == Value)
        return;
      _displayLabel = Value;
      PropertyChanged(true);
    }

  String get DisplayName  =>
    _displayLabel.isEmpty? _fieldName : _displayLabel;


  String _keyFields = '';
  String get KeyFields => _keyFields; 

   TField? _parentField; 
   TField? get ParentField => _parentField;



  bool
    get AsBoolean => GetAsBoolean();
    set AsBoolean(bool Value) => SetAsBoolean(Value);

  TDateTime
    get AsDateTime => GetAsDateTime();
    set AsDateTime(TDateTime Value) => SetAsDateTime(Value);

  double
    get AsFloat => GetAsFloat();
    set AsFloat(double Value) => SetAsFloat(Value);

  int
    get AsInteger => GetAsInteger();
    set AsInteger(int Value) => SetAsInteger(Value);

  dynamic
    get AsNative => GetAsNative();
    set AsNative(dynamic Value) => SetAsNative(Value);

  String
    get AsString => GetAsString();
    set AsString(String Value) => SetAsString(Value);


  dynamic
    get AsVariant => GetAsVariant();
    set AsVariant(dynamic Value) => SetAsVariant(Value);


  TDataSet? _dataSet;
  TDataSet?
    get DataSet => _dataSet;
    set DataSet(TDataSet? Value) => SetDataSet(Value);


  TFieldType
    get DataType => _dataType;
    set DataType(TFieldType Value) => _dataType = Value;

  String get DisplayText
  {
    
    return GetText(true);
  }


  int get FieldNo => GetFieldNo();

  String get FullName
  {
    if((_parentField == null) || (DataSet == null))
      return FieldName;
    else
      return DataSet!.GetFieldFullName(this);
  }


  int
    get Size => GetSize();
    set Size(int Value) => SetSize(Value);

  String get Text // GetEditText
  {

    return GetText(false);
  }
  void set Text(String Value) // SetEditText
  {

      SetText(Value);
  }
    
  String get FieldName => _fieldName;

  bool
    get ReadOnly => _readOnly;
    set ReadOnly(bool Value)
    {
      if(_readOnly == Value)
        return;
      _readOnly = Value;
      PropertyChanged(true);
    }

  bool
    get Required => _required;
    set Required(bool Value) => _required = Value;

  bool
    get Visible => _visible;
    set Visible(bool Value)
    {
      if(_visible == Value)
        return;
      _visible = Value;
      PropertyChanged(true);
    }


  TField(TComponent AOwner) : super(AOwner)
  {

  }

  void Destroy()
  {
    if(_dataSet!=null)
    {
      DataSet!.Close();
      if(_fields != null)
        _fields!.Remove(this);
    }

    super.Destroy();
  }

  EDatabaseError AccessError(String TypeName)
  {
    
    return EDatabaseError.CreateResFmt(DBConsts.SFieldAccessError,
      [DisplayName, TypeName]);
  }



  void AssignValue(dynamic Value)
  {

  }

  void Bind(bool Binding)
  {

  }


  void CheckInactive()
  {
    _dataSet?.CheckInactive();
  }

  void Clear()
  {
    SetData(null);
  }



  void FocusControl()
  {
    if((_dataSet != null) && _dataSet!.Active)
      _dataSet!.DataEvent(TDataEvent.FocusControl, this);
  }

  void FreeBuffers()
  {

  }



  bool GetAsBoolean()
  {
    throw AccessError('Boolean'); // Do not localize
  }

  TDateTime GetAsDateTime()
  {
    throw AccessError('DateTime'); // Do not localize
  }

  double GetAsFloat()
  {
    throw AccessError('Float'); // Do not localize
  }

  int GetAsInteger()
  {
    throw AccessError('Integer'); // Do not localize
  }

  dynamic GetAsNative()
  {
    return null;
  }

  void SetAsNative(dynamic Value)
  {
    if(Value is bool)
      SetAsBoolean(Value);
    else
    if(Value is String)
      SetAsString(Value);
    else
    if(Value is int)
      SetAsInteger(Value);
    else
    if(Value is TDateTime)
      SetAsDateTime(Value);
    else
      throw AccessError('Native'); // Do not localize
  }


  String GetAsString()
  {
    return DisplayText; // new

  }

  dynamic GetAsVariant()
  {
    return GetData();
    
  }



  String GetClassDesc()
  {

    return "";
  }

  dynamic GetData()
  {
    return DataSet?.GetFieldData(this);
  }

  
  int GetFieldNo()
  {

    return _fieldNo;
  }



  bool get IsNull => GetIsNull();
  bool GetIsNull() => GetData() == null;



  void PropertyChanged(bool LayoutAffected)
  {
    if((_dataSet != null) && _dataSet!.Active)
      _dataSet!.DataEvent(LayoutAffected? TDataEvent.LayoutChange : TDataEvent.DataSetChange, null);
  }


  void SetAsBoolean(bool Value)
  {
    throw AccessError('Boolean'); // Do not localize
  }

  void SetAsDateTime(TDateTime Value)
  {
    throw AccessError('DateTime'); // Do not localize
  }

  void SetAsFloat(double Value)
  {
    throw AccessError('Float'); // Do not localize
  }

  void SetAsInteger(int Value)
  {
    throw AccessError('Integer'); // Do not localize
  }

  void SetAsString(String Value)
  {
    throw AccessError('String'); // Do not localize
  }

  void SetAsVariant(dynamic Value)
  {
    if(Value == null)
      Clear();
    else
    {
      try
      {
        SetVarValue(Value);
      }
      catch(E)
      {

      }
      
    }
  }



  TAlignment
    get Alignment => _alignment;
    set Alignment(TAlignment Value)
    {
      if(_alignment == Value)
        return;
      _alignment = Value;
      PropertyChanged(false);
    }

  void SetData(dynamic Value)
  {
    DataSet!.SetFieldData(this, Value);
  }



  void SetDataSet(TDataSet? ADataSet)
  {
    if(ADataSet != _dataSet)
    {
      // Make sure new and old datasets are closed and fieldname is not a dup.
      if(_dataSet != null)
        _dataSet!.CheckInactive();

      if(ADataSet != null)
      {
        ADataSet.CheckInactive();

      }
      // If ParentField is set and part of a different dataset then clear it
      if((_parentField != null) && (_parentField!.DataSet != ADataSet))
      {
        _parentField!._fields!.Remove(this);
        _parentField = null;
      }
      else
      if(_dataSet != null)
      {
        if(FieldKind == TFieldKind.Aggregate)
          _dataSet!.AggFields.Remove(this);
        else
          _dataSet!.Fields.Remove(this);
      }
      // Add to the new dataset's field list, unless parentfield is still set
      if((ADataSet != null) && (_parentField == null))
      {
        if(FieldKind == TFieldKind.Aggregate)
          ADataSet.AggFields.Add(this);
        else
          ADataSet.Fields.Add(this);
      }
      _dataSet = ADataSet;
    }
  }



  void SetFieldKind(TFieldKind Value)
  {
    if(_fieldKind == Value)
      return;

    _fields?.CheckFieldKind(Value, this);
    if((DataSet != null))
    {

    }
    else
    {
      CheckInactive();
      _fieldKind = Value;
    }
  }

  void set FieldName(String Value)
  {
    CheckInactive;
    if((_dataSet != null) && (_fieldName != Value))
      _fields!.CheckFieldName(Value);
    _fieldName = Value;
    
    if(_dataSet != null)
      _dataSet!.Fields.Changed();
  }

  void SetFieldType(TFieldType Value)
  {

  }

  int get Index
  {
    if(_parentField != null)
      return _parentField!._fields!.IndexOf(this);

    if(_dataSet == null)
      return -1;

    return DataSet!.Fields.IndexOf(this);
  }

  set Index(int Value)
  {
    if(_fields != null)
      _fields!.SetFieldIndex(this, Value);
  }



  void CheckTypeSize(int Value)
  {
    
  }

  void SetSize(int Value)
  {
    CheckInactive;
    CheckTypeSize(Value);
    _size = Value;
  }

  int GetSize()
  {
    return _size;
  }

  String GetText(bool DisplayText)
  {

    return GetAsString();
  }

  void SetText(String Value)
  {
    SetAsString(Value);
  }

  void SetVarValue(dynamic Value)
  {
    if(Value is bool)
      SetAsBoolean(Value);
    else
    if(Value is int)
      SetAsInteger(Value);
    else
    if(Value is String)
      SetAsString(Value);
    else
    if(Value is TDateTime)
      SetAsDateTime(Value);
    else
      throw AccessError('Variant'); // Do not localize
  }


}

class TStringField extends TField
{

  String get Value => GetAsString();
  void set AsString(String Value) => SetAsString(Value);

  TStringField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.String;
    if(Size == 0)
      Size = 20; // Don't reset descendent settings
    
  }

  dynamic GetAsNative() => GetAsString();



  String GetAsString()
  {
    return GetValue();
  }

  dynamic GetAsVariant()
  {
    return GetValue();
  }


  String GetValue()
  
  {
    return GetData() ?? '';

  }


  void SetAsString(String Value)
  {
    SetData(Value);
    
  }

}


class TDynamicField extends TField
{


  TDynamicField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.Dynamic;
  }

  dynamic GetAsNative() => GetData();

}

class TNumericField extends TField
{

  TNumericField(TComponent AOwner) : super(AOwner)
  {
    Alignment = TAlignment.RightJustify;
  }



}

class TIntegerField extends TNumericField
{

  int
    get Value => GetAsInteger();
    set Value(int v) => SetAsInteger(v);

  TIntegerField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.Integer;

  }


  dynamic GetAsNative() => GetAsInteger();

  bool GetAsBoolean() =>
    GetAsInteger() != 0;

  int GetAsInteger()
  {
    return GetData() ?? 0;

  }

  String GetAsString()
  {

    return '${GetData() ?? ''}';

  }

  dynamic GetAsVariant()
  {
    return GetData();
    
  }

  void SetAdBoolean(bool Value) =>
    SetAsInteger(Value? 1 : 0);

  void SetAsInteger(int Value)
  {

    SetData(Value);
  }

  void SetAsString(String Value)
  {

  }


}


class TAutoIncField extends TIntegerField
{
  TAutoIncField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.AutoInc;
  }

}

class TFloatField extends TNumericField
{

  double
    get Value => GetAsFloat();
    set Value(double v) => SetAsFloat(v);

  TFloatField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.Float;
    
  }

  dynamic GetAsNative() => GetAsFloat();

  double GetAsFloat()
  {
    return GetData() ?? 0;

  }

  int GetAsInteger()
  {
    return GetAsFloat().toInt();
  }

  String GetAsString()
  {
    return '${ GetData() ?? '' }' ;
  }

  String GetAsExponential([int? fractionDigits])
  {
    var res = GetData() as double?;
    if(res == null)
      return '';
    if(res == 0)
      return '0';
    return res.toStringAsExponential(fractionDigits);

  }

  dynamic GetAsVariant()
  {
    return GetData();
    
  }



  void SetAsFloat(double Value)
  {

    SetData(Value);
  }

  void SetAsInteger(int Value)
  {
    SetAsFloat(Value.toDouble());
  }


}


class TBooleanField extends TField
{


  TBooleanField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.Boolean;

  }

  bool get Value => GetAsBoolean();
  void set Value(bool Value) => SetAsBoolean(Value);

  bool GetAsBoolean()
  {
    return GetData() ?? false;
  }

  String GetAsString()
  {
    dynamic res = GetData();
    if(res == null)
      return '';
    return res? 'true' : 'false';

  }


  void SetAsBoolean(bool Value)
  {

    SetData(Value);
  }


  dynamic GetAsNative() => GetAsBoolean();
}

class TDateTimeField extends TField
{
  String _displayFormat = "";
  String get DisplayFormat => _displayFormat; 

  TDateTimeField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.DateTime;
    Alignment = TAlignment.Center; // new
  }

  TDateTime
    get Value => GetAsDateTime();
    set Value(TDateTime Value) => SetAsDateTime(Value);



  TDateTime GetAsDateTime()
  {
    return GetData() ?? TDateTime();
  }



  String GetText(bool DisplayText)
  {
    TDateTime D = GetAsDateTime();
    if(D.Val == 0)
      return "";

    if(DisplayText)
      return SysUtils.DateTimeToString(_displayFormat, D);
    switch(DataType)
    {
      case TFieldType.Date:
        return SysUtils.DateTimeToString(SysUtils.ShortDateFormat, D);
      case TFieldType.Time:
        return SysUtils.DateTimeToString(SysUtils.LongTimeFormat, D);
      default:
        return SysUtils.DateTimeToString("", D);
    }
  }



  void SetAsDateTime(TDateTime Value)
  {
    SetData(Value);
  }


  dynamic GetAsNative() => GetAsDateTime();

}



class TDateField extends TDateTimeField
{
  TDateField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.Date;
  }


}


class TObjectField extends TField
{


  TObjectField(TComponent AOwner) : super(AOwner)
  {
    

  }


}


class TDataSetField extends TObjectField
{

  TDataSet? _nestedDataSet;

  TDataSetField(TComponent AOwner) : super(AOwner)
  {
    _dataType = TFieldType.DataSet;
  }

  void Destroy()
  {
    AssignNestedDataSet(null);

    super.Destroy();
  }



  void AssignNestedDataSet(TDataSet? Value)
  {
    if(_nestedDataSet!=null)
    {
      _nestedDataSet!.Close();
      _nestedDataSet!._dataSetField = null;

    }
    if(Value!=null)
    {

      _fields = Value.Fields;
    }

    _nestedDataSet = Value;
  }


}

class TDataLink extends TPersistent
{
  TDataSource? _dataSource;
  TDataSource?
    get DataSource => _dataSource;
    set DataSource(TDataSource? ADataSource)
    {
      if(_dataSource == ADataSource)
        return;
      if(_dataSourceFixed)
        DatabaseError(DBConsts.SDataSourceChange, _dataSource);
      if(_dataSource != null)
        _dataSource!.RemoveDataLink(this);
      if(ADataSource != null)
        ADataSource.AddDataLink(this);
    }

  TDataLink? _next;

  int _bufferCount = 1;
  int
    get BufferCount => GetBufferCount(); 
    set BufferCount(int Value) => SetBufferCount(Value);

  int GetBufferCount() => _bufferCount;

  void SetBufferCount(int Value)
  {
    if(_bufferCount == Value)
      return;
    _bufferCount = Value;
    if(Active)
    {
      UpdateRange();
      DataSet!.UpdateBufferCount();
      UpdateRange();
    }
  }

  int _firstRecord = 0;

  bool _readOnly = false;
  bool
    get ReadOnly => _readOnly;
    set ReadOnly(bool Value)
    {
      if(_readOnly == Value)
        return;
      _readOnly = Value;
      UpdateState();
    }

  bool _active = false;
  bool
    get Active => _active;
    set Active(bool Value)
    {
      if(_active == Value)
        return;
      _active = Value;
      if(Value)
        UpdateRange();
      else
        _firstRecord = 0;
      ActiveChanged();
    }

  bool _visualControl = false;
  bool
    get VisualControl => _visualControl;
    set VisualControl(bool Value) => _visualControl = Value;

  bool _editing = false;
  bool
    get Editing => _editing;
    set Editing(bool Value)
    {
      if(_editing == Value)
        return;
      _editing = Value;
      EditingChanged();
    }

  bool _updating =false;

  bool _dataSourceFixed=false;
  bool
    get DataSourceFixed => _dataSourceFixed;
    set DataSourceFixed(bool Value) => _dataSourceFixed=Value;

  TDataSet? get DataSet
  {
    return DataSource?.DataSet;
  }

  TDataLink() : super()
  {
  }

  void Destroy()
  {
    _active = false;
    _editing = false;
    _dataSourceFixed = false;
    DataSource = null;
    super.Destroy();
  }

  void UpdateRange()
  {
    int Min = DataSet!._activeRecord - _bufferCount + 1;
    if(Min < 0)
      Min = 0;
    int Max = DataSet!._recordCount - _bufferCount;
    if(Max < 0)
      Max = 0;
    if(Max > DataSet!._activeRecord)
      Max = DataSet!._activeRecord;
    if(_firstRecord < Min)
      _firstRecord = Min;
    if(_firstRecord > Max)
      _firstRecord = Max;
    if((_firstRecord != 0) && (DataSet!._activeRecord - _firstRecord < _bufferCount - 1))
      _firstRecord--;
  }

  void UpdateState()
  {
    Active = (DataSource != null) && (DataSource!.State != TDataSetState.Inactive);
    Editing = (DataSource != null) && (StateInEditModes(DataSource!.State) && !_readOnly);
  }

  void UpdateRecord()
  {
    _updating = true;
    try
    {
      UpdateData();
    }
    finally
    {
      _updating = false;
    }
  }

  bool Edit()
  {
    if(!_readOnly && (DataSource != null))
      DataSource!.Edit();
    return _editing;
  }

  int
    get ActiveRecord => GetActiveRecord();
    set ActiveRecord(int Value) => SetActiveRecord(Value);

  int GetActiveRecord()
  {
    if(DataSource!.State == TDataSetState.SetKey)
      return 0;
    return DataSource!.DataSet!._activeRecord - _firstRecord;
  }

  void SetActiveRecord(int Value)
  {
    if(DataSource!.State != TDataSetState.SetKey)
      DataSource!.DataSet!._activeRecord = Value + _firstRecord;
  }

  int get RecordCount => GetRecordCount();

  int GetRecordCount()
  {
    if(DataSource!.State == TDataSetState.SetKey)
      return 1;
    int Result = DataSource!.DataSet!._recordCount;
    if(Result > _bufferCount)
      return _bufferCount;
    return Result;
  }

  void DataEvent(TDataEvent Event, dynamic Info)
  { 
    if(Event == TDataEvent.UpdateState)
    {
      UpdateState();
      return;
    }
    if(_active == false)
      return;

    switch(Event)
    {
      case TDataEvent.FieldChange:
      case TDataEvent.RecordChange:
        if(!_updating)
          RecordChanged(Info as TField?);
        break;

      case TDataEvent.DataSetChange:
      case TDataEvent.DataSetScroll:
      case TDataEvent.LayoutChange:
        int Count = 0;
        if(DataSet!.State != TDataSetState.SetKey)
        {
          int Active = DataSource!.DataSet!._activeRecord;
          int First = _firstRecord + Info as int;
          int Last = First + _bufferCount - 1;
          if(Active > Last)
            Count = Active - Last;
          else
          if(Active < First)
            Count = Active - First;
          _firstRecord = First + Count;
        }
        if(Event == TDataEvent.DataSetChange)
          DataSetChanged();
        else
        if(Event == TDataEvent.DataSetScroll)
          DataSetScrolled(Count);
        else
        if(Event == TDataEvent.LayoutChange)
          LayoutChanged();
        break;

      case TDataEvent.UpdateRecord:
        UpdateRecord();
        break;

      case TDataEvent.CheckBrowseMode:
        CheckBrowseMode();
        break;

      case TDataEvent.FocusControl:
        FocusControl(Info as TField);
        break;

      default:
        break;
    }
  }

  void ActiveChanged()
  {

  }

  void CheckBrowseMode()
  {

  }

  void DataSetChanged()
  {
    RecordChanged(null);
  }

  void DataSetScrolled(int Distance)
  {
    DataSetChanged();
  }

  void EditingChanged()
  {

  }



  void FocusControl(TField Field)
  {

  }

  void LayoutChanged()
  {
    DataSetChanged();
  }

  void RecordChanged(TField? Field)
  {

  }



  void UpdateData()
  {

  }

  bool get Bof => GetBof();
  bool GetBof() => DataSet!.Bof;

  bool get Eof => GetEof();
  bool GetEof() => DataSet!.Eof;

  int MoveBy(int Distance) =>
    DataSet!.MoveBy(Distance);
}


class TDataSource extends TComponent
{
  TDataSet? _dataSet;
  TDataSet?
    get DataSet => _dataSet;
    set DataSet(TDataSet? ADataSet)
    {
      if(IsLinkedTo(ADataSet))
        DatabaseError(DBConsts.SCircularDataLink, this);
      if(_dataSet != null)
        _dataSet!.RemoveDataSource(this);
      if(ADataSet != null)
        ADataSet.AddDataSource(this);
    }

  final DataLinks = TList();

  bool _enabled = true;
  bool
    get Enabled => _enabled;
    set Enabled(bool Value)
    {
      _enabled = true;
      UpdateState();
    }

  bool _autoEdit = true;
  bool
    get AutoEdit => _autoEdit;
    set AutoEdit(bool Value) => _autoEdit=Value;

  TDataSetState _state = TDataSetState.Inactive;
  TDataSetState
    get State => _state;
    set State(TDataSetState Value)
    {
      if(_state == Value)
        return;
      TDataSetState PriorState = _state;
      _state = Value;
      NotifyDataLinks(TDataEvent.UpdateState, 0);
      if(!ComponentState.contains(ComponentStates.Destroying))
      {
        if(_onStateChange != null)
          _onStateChange!(this);
        if(PriorState == TDataSetState.Inactive)
          if(_onDataChange!=null)
            _onDataChange!(this, null);
      }
    }

  TNotifyEvent? _onStateChange;
  TNotifyEvent?
    get OnStateChange => _onStateChange;
    set OnStateChange(TNotifyEvent? Value) => _onStateChange=Value;

  TDataChangeEvent? _onDataChange;
  TDataChangeEvent?
    get OnDataChange => _onDataChange;
    set OnDataChange(TDataChangeEvent? Value) => _onDataChange=Value;

  TNotifyEvent? _onUpdateData;
  TNotifyEvent?
    get OnUpdateData => _onUpdateData;
    set OnUpdateData(TNotifyEvent? Value) => _onUpdateData=Value;

  TDataSource(TComponent AOwner) : super(AOwner)
  {

  }

  void Destroy()
  {
    _onStateChange = null;
    DataSet = null;
    while(DataLinks.Count > 0)
      RemoveDataLink(DataLinks.Last);
    DataLinks.Destroy();
    super.Destroy();
  }

  void Edit()
  {
    if(AutoEdit && (State == TDataSetState.Browse))
      DataSet!.Edit();
  }

  void UpdateState()
  {
    if(Enabled && (DataSet != null))
      State = DataSet!.State;
    else
      State = TDataSetState.Inactive;
  }

  bool IsLinkedTo(TDataSet? DataSet)
  {
    while(DataSet != null)
    {
      if((DataSet.DataSetField != null) &&
         (DataSet.DataSetField!.DataSet!.GetDataSource() == this))
        return true;
      TDataSource? DataSource = DataSet.GetDataSource();
      if(DataSource == null)
        break;
      if(DataSource == this)
        return true;
      DataSet = DataSource.DataSet;
    }
    return false;
  }

  void AddDataLink(TDataLink DataLink)
  {
    DataLinks.Add(DataLink);
    DataLink._dataSource = this;
    if(DataSet != null)
      DataSet!.UpdateBufferCount();
    DataLink.UpdateState();
  }

  void RemoveDataLink(TDataLink DataLink)
  {
    DataLink._dataSource = null;
    DataLinks.Remove(DataLink);
    DataLink.UpdateState();
    if(DataSet != null)
      DataSet!.UpdateBufferCount();
  }

  void NotifyLinkTypes(TDataEvent Event, dynamic Info, bool LinkType)
  {
    for(int i = DataLinks.Count - 1; i>=0; i--)
    {
      TDataLink DataLink = DataLinks.Items[i];
      if(LinkType == DataLink.VisualControl)
        DataLink.DataEvent(Event, Info);
    }
  }

  void NotifyDataLinks(TDataEvent Event, dynamic Info)
  {
    // Notify non-visual links (i.e. details), before visual controls
    NotifyLinkTypes(Event, Info, false);
    NotifyLinkTypes(Event, Info, true);
  }

  void DataEvent(TDataEvent Event, dynamic Info)
  {
    if(Event == TDataEvent.UpdateState)
      UpdateState();
    else
    if(_state != TDataSetState.Inactive)
    {
      NotifyDataLinks(Event, Info);
      switch(Event)
      {
        case TDataEvent.FieldChange:
          if(_onDataChange!=null)
            _onDataChange!(this, Info);
          break;
        case TDataEvent.RecordChange:
        case TDataEvent.DataSetChange:
        case TDataEvent.DataSetScroll:
        case TDataEvent.LayoutChange:
          if(_onDataChange != null)
            _onDataChange!(this, null);
        break;
        case TDataEvent.UpdateRecord:
          if(_onUpdateData != null)
            _onUpdateData!(this);
          break;
        default:
          break;
      }
    }
  }
}



abstract class TRecordBuf
{

}

abstract class TDataSet extends TComponent 
{

  late final TFields Fields;
  int get FieldCount => Fields.Count;

  late final TFields AggFields;

  late final TFieldDefs _fieldDefs;
  TFieldDefs
    get FieldDefs => _fieldDefs;
    set FieldDefs(TFieldDefs Value) => FieldDefs.Assign(Value);

  late final TFieldDefList FieldDefList;

  late final TFieldList FieldList;

  final _dataSources = <TDataSource>[];

  TDataLink? _firstDataLink;

  int _bufferCount = 0;
  int _recordCount = 0;

  int _activeRecord = 0;
  int
    get ActiveRecord => _activeRecord;
    set ActiveRecord(int value) => _activeRecord = value; // new

  int _currentRecord = 0;
  int get CurrentRecord => _currentRecord;

  final _buffers = <TRecordBuf>[];

  int _calcFieldsSize = 0;
  int get CalcFieldsSize => _calcFieldsSize;


  int _disableCount = 0;

  int _blobFieldCount = 0;
  int get BlobFieldCount => _blobFieldCount;

  int _blockReadSize = 0;
  int get BlockReadSize => _blockReadSize;


  TDataSetField? _dataSetField;
  TDataSetField?
    get DataSetField => _dataSetField;
    set DataSetField(TDataSetField? Value) => SetDataSetField(Value);

  bool _isUniDirectional = false;
  bool get IsUniDirectional => _isUniDirectional;


  int _fieldNoOfs = 1;
  int get FieldNoOfs => _fieldNoOfs;




  TDataSetState _state = TDataSetState.Inactive;
  TDataSetState get State => _state;

  TDataEvent _enableEvent = TDataEvent.LayoutChange; // ???
  TDataSetState _disableState = TDataSetState.Inactive;

  bool _bof = true;
  bool get Bof => _bof;

  bool _eof = true;
  bool get Eof => _eof;

  bool _modified = false;
  bool get Modified => _modified;


  bool _internalCalcFields = false;
  bool get InternalCalcFields => _internalCalcFields;


  bool _defaultFields = false;
  bool get DefaultFields => _defaultFields;


  bool _internalOpenComplete = false;
  // Events 
  TDataSetNotifyEvent? _beforeOpen;
  TDataSetNotifyEvent? _afterOpen;
  TDataSetNotifyEvent? _beforeClose;
  TDataSetNotifyEvent? _afterClose;
  TDataSetNotifyEvent? _beforeInsert;
  TDataSetNotifyEvent? _afterInsert;
  TDataSetNotifyEvent? _beforeEdit;
  TDataSetNotifyEvent? _afterEdit;
  TDataSetNotifyEvent? _beforePost;
  TDataSetNotifyEvent? _afterPost;
  TDataSetNotifyEvent? _beforeCancel;
  TDataSetNotifyEvent? _afterCancel;
  TDataSetNotifyEvent? _beforeDelete;
  TDataSetNotifyEvent? _afterDelete;
  TDataSetNotifyEvent? _beforeRefresh;
  TDataSetNotifyEvent? _afterRefresh;

  TDataSetNotifyEvent? _afterScroll;
  TDataSetNotifyEvent?
    get AfterScroll => _afterScroll;
    set AfterScroll(TDataSetNotifyEvent? Value) => _afterScroll= Value;

  TDataSetNotifyEvent? _beforeScroll;
  TDataSetNotifyEvent?
    get BeforeScroll => _beforeScroll;
    set BeforeScroll(TDataSetNotifyEvent? Value) => _beforeScroll= Value;

  TDataSetNotifyEvent? _onNewRecord;
  TDataSetNotifyEvent? _onCalcFields;
  TDataSetErrorEvent? _onEditError;
  TDataSetErrorEvent? _onPostError;
  TDataSetErrorEvent? _onDeleteError;


  // abstract methods required for all datasets
  TGetResult GetRecord(TRecordBuf? Buffer, TGetMode GetMode, bool DoCheck);
  void InternalClose();
//    procedure InternalHandleException; virtual; abstract;
  void InternalInitFieldDefs();
  void InternalOpen();
  bool IsCursorOpen();


  bool get CanModify => GetCanModify();

  TDataSet(TComponent? AOwner) : super(AOwner)
  {
    _fieldDefs = TFieldDefs(this);
    FieldDefList = TFieldDefList(this);
    Fields = TFields(this);
    FieldList = TFieldList(this);

    AggFields = TFields(this);

    ClearBuffers();
  
  }

  void Destroy()
  {
    Destroying();
    Close();
    SetDataSetField(null);

    super.Destroy();
  }

  void SetState(TDataSetState Value)
  {
    if(_state == Value)
      return;
    _state = Value;
    _modified = false;
    DataEvent(TDataEvent.UpdateState, 0);
  }

  void SetModified(bool Value)
  {
    _modified = Value;
  }


  void SetDataSetField(TDataSetField? Value)
  {
    if(_dataSetField == Value)
      return;

    if((Value != null) && ((Value.DataSet == this) ||
       ((Value.DataSet!.GetDataSource() != null) &&
        (Value.DataSet!.GetDataSource()!.DataSet == this))))
      DatabaseError(DBConsts.SCircularDataLink, this);

    if(Active) Close();
    _dataSetField?.AssignNestedDataSet(null);
    _dataSetField = Value;
    if(Value != null)
    {
      Value.AssignNestedDataSet(this);
      if(Value.DataSet!.Active)
        Open();
    }
  }



  void SetUniDirectional(bool Value)
  {
    _isUniDirectional = Value;
  }


  void Open()
  {
    Active = true;
  }

  void Close()
  {
    Active = false;

  }

  void CheckBiDirectional()
  {
    if(IsUniDirectional)
      DatabaseError(DBConsts.SDataSetUnidirectional, this);
  }

  void CheckInactive()
  {
    if(Active == false)
      return;

    if(ComponentState.contains(ComponentStates.Updating) && ComponentState.contains(ComponentStates.Designing))
      Close();
    else
      DatabaseError(DBConsts.SDataSetOpen, this);

  }

  void CheckActive()
  {
    if(State == TDataSetState.Inactive)
      DatabaseError(DBConsts.SDataSetClosed, this);
  }

  bool get Active => _state != TDataSetState.Inactive && _state != TDataSetState.Opening;
  void set Active(bool Value) => SetActive(Value);

  void SetActive(bool Value)
  {
    if(ComponentState.contains(ComponentStates.Reading))
    {

    }
    else
    if(Active != Value)
    {
      if(Value)
      {
        DoBeforeOpen();
        try
        {
          OpenCursor();
        }
        finally
        {
          if(State != TDataSetState.Opening)
            OpenCursorComplete();
        }
      }
      else
      {
        if(!(ComponentState.contains(ComponentStates.Destroying)))
          DoBeforeClose();

        SetState(TDataSetState.Inactive);
        CloseCursor();
        if(!(ComponentState.contains(ComponentStates.Destroying)))
          DoAfterClose();
      }
    }
  }

  void DoInternalOpen()
  {
    _defaultFields = FieldCount == 0;
    InternalOpen();
    _internalOpenComplete = true;
    UpdateBufferCount();
    _bof = true;
  }

  void OpenCursorComplete()
  {
    try
    {
      if(State == TDataSetState.Opening)
        DoInternalOpen();
    }
    finally
    {
      if(_internalOpenComplete)
      {
        SetState(TDataSetState.Browse);
        DoAfterOpen();
      }
      else
      {
        SetState(TDataSetState.Inactive);
        CloseCursor();
      }
    }
  }

  void OpenCursor([bool InfoQuery = false])
  {
    if(InfoQuery)
      InternalInitFieldDefs();
    else
    if(State != TDataSetState.Opening)
      DoInternalOpen();
  }

  void CloseCursor()
  {
    _blockReadSize = 0;
    _internalOpenComplete = false;
    FreeFieldBuffers();
    ClearBuffers();
    SetBufListSize(0);
    InternalClose();
    _bufferCount = 0;
    _defaultFields = false;
  }


  // Field Management

  void DefChanged(TObject Sender)
  {

  }

  void InitFieldDefs()
  {
    if(IsCursorOpen())
      InternalInitFieldDefs();
    else
      try
      {
        OpenCursor(true);
      }
      finally
      {
        CloseCursor();
      }
  }





  String GetFieldFullName(TField Field)
  {
    String Result = Field.FieldName;
    
    return Result;
  }


  TField CreateTypeField(TFieldType Type)
  {
    switch(Type)
    {
      case TFieldType.AutoInc:
        return TAutoIncField(this);

      case TFieldType.Boolean:
        return TBooleanField(this);

      case TFieldType.Dynamic:
        return TDynamicField(this);

      case TFieldType.Date:
        return TDateField(this);

      case TFieldType.DateTime:
        return TDateTimeField(this);

      case TFieldType.Float:
        return TFloatField(this);

      case TFieldType.Integer:
        return TIntegerField(this);

      case TFieldType.String:
        return TStringField(this);

      default:
        return TField(this);
    }
  }

  void CreateFields()
  {
    
    for(int i = 0; i<FieldDefList.Count; i++)
    {
      TFieldDef fld = FieldDefList.FieldDefs[i];

      if((fld.DataType != TFieldType.Unknown) )
        fld.CreateField(this, null, FieldDefList.Strings[i]);
    }
    
  }

  void DestroyFields()
  {
    Fields.Clear();

  }

  void CheckFieldCompatibility(TField Field, TFieldDef FieldDef)
  {

  }


  void BindFields(bool Binding)
  {
  
    void DoBindFields(TFields Fields)
    {
      for(int i = 0; i<Fields.Count; i++)
      { 
        TField WithField = Fields.Fields[i];
        if(Binding)
        {

          {
            TFieldDef? FieldDef;
            int FieldIndex = FieldDefList.IndexOf(WithField.FullName);
            if(FieldIndex != -1)
              FieldDef = FieldDefList.FieldDefs[FieldIndex];
            else
              DatabaseErrorFmt(DBConsts.SFieldNotFound, [WithField.DisplayName], this);

            if(WithField.FieldKind == TFieldKind.InternalCalc)
              WithField._fieldNo = FieldDef!.FieldNo;
            else
              WithField._fieldNo = FieldIndex + _fieldNoOfs;
            CheckFieldCompatibility(Fields.Fields[i], FieldDef!);
            
          }
          WithField.Bind(true);
        }
        else
        {
          WithField.Bind(false);
          WithField._fieldNo = 0;
        }

      }
    }

    _calcFieldsSize = 0;
    _blobFieldCount = 0;
    _internalCalcFields = false;
    DoBindFields(Fields);
  }

  void FreeFieldBuffers()
  {
    for(int i = 0; i <Fields.Count; i++)
      Fields.Fields[i].FreeBuffers();
  }


  dynamic ConvertToFieldFormat(TField fld, dynamic Value)
  {
    switch(fld.DataType)
    {
      case TFieldType.Dynamic:
        return Value;

      case TFieldType.Boolean:
        if(Value is bool)
          return Value;
        if(Value is int)
          return Value!=0;
        break;

      case TFieldType.AutoInc:
      case TFieldType.Integer:
        if(Value is int)
          return Value;
        if(Value is double)
          return Value.truncate();
        break;

      case TFieldType.Date:
      case TFieldType.DateTime:
      case TFieldType.Time:
        if(Value is TDateTimeBase)
          return TDateTime(Value);
        if(Value is String)
          return TDateTime.parse(Value);

        break;

      case TFieldType.Float:
        if(Value is double)
          return Value;
        if(Value is int)
          return Value.toDouble();
        break;

      case TFieldType.String:
        if(Value is String)
          return Value;
        break;

      default:
        break;
    }
    return null;
  }

  
  dynamic GetFieldData(TField fld)
  {
    dynamic Value = GetFieldValue(fld);
    if(Value == null)
      return null;
    return ConvertToFieldFormat(fld, Value);
  }

  
  dynamic GetFieldValue(TField fld)
  {
    return null;
  }



  void SetFieldData(TField Field, dynamic Value)
  {

  }



  TField? FieldByName(String FieldName)
  {
    TField? Result = FindField(FieldName);
    if(Result == null)
      DatabaseErrorFmt(DBConsts.SFieldNotFound, [FieldName], this);
    return Result;
  }


  TField? FindField(String name)
  {
    TField? Result = Fields.FindField(name);

    
    return Result;
  }


// Datasource/Datalink Interaction

  TDataSource? get DataSource => GetDataSource();
  TDataSource? GetDataSource()
  {
    return null;
  }



  void AddDataSource(TDataSource DataSource)
  {
    _dataSources.add(DataSource);
    DataSource._dataSet = this;
    UpdateBufferCount();
    DataSource.UpdateState();
  }

  void RemoveDataSource(TDataSource DataSource)
  {
    DataSource._dataSet = null;
    _dataSources.remove(DataSource);
    DataSource.UpdateState();
    UpdateBufferCount();
  }

  void DataEvent(TDataEvent Event, dynamic Info)
  {


  void NotifyDetails()
  {

    if(State == TDataSetState.BlockRead)
      for(var item in _dataSources)
        item.NotifyLinkTypes(Event, Info, false);
  }

  void CheckNestedBrowseMode()
  {

  }


  switch(Event)
  {
    case TDataEvent.FieldChange:

      break;

    case TDataEvent.FieldListChange:
    case TDataEvent.LayoutChange:
      FieldList.Updated = false;
      break;

    case TDataEvent.PropertyChange:
      FieldDefs.Updated = false;
      break;

    case TDataEvent.CheckBrowseMode:
      CheckNestedBrowseMode();
      break;

    case TDataEvent.DataSetChange:
    case TDataEvent.DataSetScroll:
      NotifyDetails();
      break;

    default:
      break;
  }


    if((_disableCount == 0) && (State !=  TDataSetState.BlockRead))
    {
      for(var item in _dataSources)
        item.DataEvent(Event, Info);

    }
    else
    if((Event == TDataEvent.UpdateState) && (State == TDataSetState.Inactive) ||
       (Event == TDataEvent.LayoutChange))
      _enableEvent = TDataEvent.LayoutChange;
  }

  bool ControlsDisabled()
  {
    return _disableCount != 0;
  }

  void DisableControls()
  {
    if(_disableCount == 0)
    {
      _disableState = _state;
      _enableEvent = TDataEvent.DataSetChange;
    }
    _disableCount++;
  }

  void EnableControls()
  {
    if(_disableCount != 0)
    {
      _disableCount--;
      if(_disableCount == 0)
      {
        if(_disableState != _state)
          DataEvent(TDataEvent.UpdateState, 0);
        if((_disableState != TDataSetState.Inactive) && (_state != TDataSetState.Inactive))
          DataEvent(_enableEvent, 0);
      }
    }
  }

  void UpdateRecord()
  {
    if(!StateInEditModes(State))
      DatabaseError(DBConsts.SNotEditing, this);
    DataEvent(TDataEvent.UpdateRecord, 0);
  }

  // Buffer Management

  TRecordBuf AllocRecordBuffer();


  void FreeRecordBuffer(TRecordBuf? Buffer)
  {

  }

  void SetBufListSize(int Value)
  {
    if(_buffers.length == Value)
      return;

    while(_buffers.length < Value)
      _buffers.add(AllocRecordBuffer());

    while(_buffers.length > Value)
      FreeRecordBuffer(_buffers.removeLast());
  }

  void SetBufferCount(int Value)
  {
    void AdjustFirstRecord(int Delta)
    {
      if(Delta != 0)
      {
        TDataLink? DataLink = _firstDataLink;
        while(DataLink != null)
        {
          if(DataLink.Active)
            DataLink._firstRecord+=Delta;
          DataLink = DataLink._next;
        }
      }
    }

    if(_bufferCount != Value)
    {
      if((_bufferCount > Value) && (_recordCount > 0))
      {
        int Delta = _activeRecord;
        TDataLink? DataLink = _firstDataLink;
        while(DataLink != null)
        {
          if(DataLink.Active && (DataLink._firstRecord < Delta))
            Delta = DataLink._firstRecord;
          DataLink = DataLink._next;
        }
        for(int i = 0; i<Value; i++)
          MoveBuffer(i + Delta, i);
        _activeRecord-=Delta;
        if(_currentRecord != -1)
          _currentRecord-=Delta;
        if(_recordCount > Value)
          _recordCount = Value;
        AdjustFirstRecord(-Delta);
      }
      SetBufListSize(Value + 1);
      _bufferCount = Value;
      if(!ComponentState.contains(ComponentStates.Destroying))
      {
        GetNextRecords();
        AdjustFirstRecord(GetPriorRecords());
      }
    }
  }

  void UpdateBufferCount()
  {
    if(IsCursorOpen())
    {
      int MaxBufferCount = 1;
      _firstDataLink = null;
      for(int i = _dataSources.length - 1; i>=0; i--)
      {
        TList WithDataLink = _dataSources[i].DataLinks;
        for(int j = WithDataLink.Count - 1; j>=0; j--)
        {
          TDataLink DataLink = WithDataLink.Items[j];
          DataLink._next = _firstDataLink;
          _firstDataLink = DataLink;
          if(DataLink._bufferCount > MaxBufferCount)
            MaxBufferCount = DataLink._bufferCount;
        }
      }
      SetBufferCount(MaxBufferCount);
    }
  }

  void SetCurrentRecord(int Index)
  {

    if((_currentRecord != Index) || (_dataSetField != null))
    {
      if((DataSetField != null) && (DataSetField!.DataSet!.State != TDataSetState.Insert))
        DataSetField!.DataSet!.UpdateCursorPos();
      if(!IsUniDirectional)
      {
        TRecordBuf Buffer = _buffers[Index];
        switch(GetBookmarkFlag(Buffer))
        {
          case TBookmarkFlag.Current:
          case TBookmarkFlag.Inserted:
            InternalSetToRecord(Buffer);
            break;

          case TBookmarkFlag.BOF:
            InternalFirst();
            break;

          case TBookmarkFlag.EOF:
            InternalLast();
        }
      }
      _currentRecord = Index;
    }
  }

  TRecordBuf? GetBuffer(int Index)
  {
    if(Index < _buffers.length)
      return _buffers[Index];
    return null;
  }

  bool GetNextRecord()
  {
    TGetMode GetMode = TGetMode.Next;

    if(_recordCount > 0)
    {
      SetCurrentRecord(_recordCount - 1);
      if((State == TDataSetState.Insert) && (_currentRecord == _activeRecord) &&
          (GetBookmarkFlag(ActiveBuffer())) == TBookmarkFlag.Current)
        GetMode = TGetMode.Current;
    }
    else
    if((DataSetField != null) && (DataSetField!.DataSet!.State != TDataSetState.Insert))
      DataSetField!.DataSet!.UpdateCursorPos();
    bool Result = (GetRecord(GetBuffer(_recordCount), GetMode, true) == TGetResult.OK);
    if(Result)
    {
      if(_recordCount == 0)
        ActivateBuffers();
      else
      if(_recordCount < _bufferCount)
        _recordCount++;
      else
        MoveBuffer(0, _recordCount);
      _currentRecord = _recordCount - 1;
    }
    else
      CursorPosChanged();
    return Result;
  }

  bool GetPriorRecord()
  {
    CheckBiDirectional();
    if(_recordCount > 0)
      SetCurrentRecord(0);
    bool Result = GetRecord(GetBuffer(_recordCount), TGetMode.Prior, true) == TGetResult.OK;
    if(Result)
    {
      if(_recordCount == 0)
        ActivateBuffers();
      else
      {
        MoveBuffer(_recordCount, 0);
        if(_recordCount < _bufferCount)
        {
          _recordCount++;
          _activeRecord++;
        }
      }
      _currentRecord = 0;
    }
    else
      CursorPosChanged();
    return Result;
  }

  void Resync( { bool rmExact = false, bool rmCenter = false} )
  {
    if(!IsUniDirectional)
    {
      if(rmExact)
      {
        CursorPosChanged();
        if(GetRecord(_buffers[_recordCount], TGetMode.Current, true) != TGetResult.OK)
          DatabaseError(DBConsts.SRecordNotFound, this);
      }
      else
      if((GetRecord(_buffers[_recordCount], TGetMode.Current, false) != TGetResult.OK) &&
          (GetRecord(_buffers[_recordCount], TGetMode.Next, false) != TGetResult.OK) &&
          (GetRecord(_buffers[_recordCount], TGetMode.Prior, false) != TGetResult.OK))
      {
        ClearBuffers();
        DataEvent(TDataEvent.DataSetChange, 0);
        return;
      }
      int Count = rmCenter? ((_bufferCount - 1) / 2).truncate() : _activeRecord;

      MoveBuffer(_recordCount, 0);
      ActivateBuffers();
      try
      {
        while((Count > 0) && GetPriorRecord())
          Count--;
        GetNextRecords();
        GetPriorRecords();
      }
      finally
      {
        DataEvent(TDataEvent.DataSetChange, 0);
      }

    }
  }

  void MoveBuffer(int CurIndex, int NewIndex)
  {
    if(!IsUniDirectional && (CurIndex != NewIndex))
    {
      TRecordBuf Buffer = _buffers.removeAt(CurIndex);
      _buffers.insert(NewIndex, Buffer);

    }
  }

  TRecordBuf ActiveBuffer()
  {
    return _buffers[_activeRecord];
  }

  TRecordBuf TempBuffer()
  {
    return _buffers[_recordCount];
  }

  void ClearBuffers()
  {
    _recordCount = 0;
    _activeRecord = 0;
    _currentRecord = -1;
    _bof = true;
    _eof = true;
  }

  void ActivateBuffers()
  {
    _recordCount = 1;
    _activeRecord = 0;
    _currentRecord = 0;
    _bof = false;
    _eof = false;
  }

  void UpdateCursorPos()
  {
    if(_recordCount > 0)
      SetCurrentRecord(_activeRecord);
  }

  void CursorPosChanged()
  {
    _currentRecord = -1;
  }

  bool GetCurrentRecord(TRecordBuf Buffer)
  {
    return false;
  }

  int GetNextRecords()
  {
    int Result = 0;
    while((_recordCount < _bufferCount) && GetNextRecord())
      Result++;
    return Result;
  }

  int GetPriorRecords()
  {
    int Result = 0;
    if(!IsUniDirectional)
      while((_recordCount < _bufferCount) && GetPriorRecord())
        Result++;
    return Result;
  }

  void InitRecord(TRecordBuf Buffer)
  {
    InternalInitRecord(Buffer);
    ClearCalcFields(Buffer);
    SetBookmarkFlag(Buffer, TBookmarkFlag.Inserted);
  }

  bool IsEmpty()
  {
    return _activeRecord >= _recordCount;
  }


  void ClearCalcFields(TRecordBuf Buffer)
  {

  }


// Navigation
  void InternalFirst()
  {
  }

  void InternalLast()
  {
  }

  void First()
  {
    CheckBrowseMode();
    DoBeforeScroll();
    bool FReopened = false;
    if(IsUniDirectional)
    {
      if(!Bof)
      {  // Need to Close and Reopen dataset: (Midas)
        Active = false;
        Active = true;
      }
      FReopened = true;
    }
    else
      ClearBuffers();
    try
    {
      InternalFirst();
      if(!FReopened)
      {
        GetNextRecord();
        GetNextRecords();
      }
    }
    finally
    {
      _bof = true;
      DataEvent(TDataEvent.DataSetChange, 0);
      DoAfterScroll();
    }
  }

  void Last()
  {
    CheckBiDirectional();
    CheckBrowseMode();
    DoBeforeScroll();
    ClearBuffers();
    try
    {
      InternalLast();
      GetPriorRecord();
      GetPriorRecords();
    }
    finally
    {
      _eof = true;
      DataEvent(TDataEvent.DataSetChange, 0);
      DoAfterScroll();
    }
  }

  int MoveBy(int Distance)
  {

    CheckBrowseMode();
    int Result = 0;
    DoBeforeScroll();
    if(((Distance > 0) && !_eof) || ((Distance < 0) && !_bof))
    {
      _bof = false;
      _eof = false;
      int OldRecordCount = _recordCount;
      int ScrollCount = 0;
      try
      {
        while(Distance > 0)
        {
          if(_activeRecord < _recordCount - 1)
            _activeRecord++;
          else
          {
            int I = _recordCount < _bufferCount? 0 : 1;
            if(GetNextRecord())
            {
              ScrollCount-=I;
              if(_activeRecord < _recordCount - 1)
                _activeRecord++;
            }
            else
            {
              _eof = true;
              break;
            }
          }
          Distance--;
          Result++;
        }

        while(Distance < 0)
        {
          if(_activeRecord > 0)
            _activeRecord--;
          else
          {
            int I = _recordCount < _bufferCount? 0 : 1;
            if(GetPriorRecord())
            {
              ScrollCount+=I;
              if(_activeRecord > 0)
                _activeRecord--;
            }
            else
            {
              _bof = true;
              break;
            }
          }
          Distance++;
          Result--;
        }
      }
      finally
      {
        if(_recordCount != OldRecordCount)
          DataEvent(TDataEvent.DataSetChange, 0);
        else
          DataEvent(TDataEvent.DataSetScroll, ScrollCount);
        DoAfterScroll();
      }
    }
    return Result;
  }

  void Next()
  {
    if(BlockReadSize > 0)
      BlockReadNext();
    else
      MoveBy(1);
  }

  void BlockReadNext()
  {
    MoveBy(1);
  }

  void Prior()
  {
    MoveBy(-1);
  }

  void Refresh()
  {
    DoBeforeRefresh();
    CheckBrowseMode();
    UpdateCursorPos();
    try
    {
      InternalRefresh();
    }
    finally
    {
      Resync();
      DoAfterRefresh();
    }
  }

  void SetBlockReadSize(int Value)
  {
    if(Value > 0)
    {
      CheckActive();
      SetState(TDataSetState.BlockRead);
    }
    else
    if(State == TDataSetState.BlockRead)
      SetState(TDataSetState.Browse);
    _blockReadSize = Value;
  }

// Editing

  void CheckParentState()
  {
    if(DataSetField != null)
      DataSetField!.DataSet!.Edit();
  }

  void Edit()
  {
    if(State!=TDataSetState.Edit && State!=TDataSetState.Insert)
      if(_recordCount == 0)
        Insert();
      else
      {
        CheckBrowseMode();
        CheckCanModify();
        DoBeforeEdit();
        CheckParentState();
        CheckOperation(InternalEdit, _onEditError);
        //GetCalcFields(ActiveBuffer);
        SetState(TDataSetState.Edit);
        DataEvent(TDataEvent.RecordChange, null);
        DoAfterEdit();
      }
  }

  void Insert()
  {
    
    BeginInsertAppend();

    MoveBuffer(_recordCount, _activeRecord);
    TRecordBuf Buffer = ActiveBuffer();
    InitRecord(Buffer);
    if(_recordCount == 0)
      SetBookmarkFlag(Buffer, TBookmarkFlag.BOF);

    if(_recordCount < _bufferCount)
      _recordCount++;
    InternalInsert();
    EndInsertAppend();
  }

  void Append()
  {
    BeginInsertAppend();
    ClearBuffers();
    TRecordBuf Buffer = _buffers[0];
    InitRecord(Buffer);
    SetBookmarkFlag(Buffer, TBookmarkFlag.EOF);
    _recordCount = 1;
    _bof = false;
    GetPriorRecords();
    InternalInsert();
    EndInsertAppend();
  }


  void Post()
  {
    UpdateRecord();
    if(State==TDataSetState.Edit || State==TDataSetState.Insert)
    {
      DataEvent(TDataEvent.CheckBrowseMode, 0);
      DoBeforePost();
      CheckOperation(InternalPost, _onPostError);
      FreeFieldBuffers();
      SetState(TDataSetState.Browse);
      Resync();
      DoAfterPost();
    }
  }

  void Cancel()
  {
    void CancelNestedDataSets()
    {

    }

    if(State == TDataSetState.Edit || State == TDataSetState.Insert)
    {
      CancelNestedDataSets();
      DataEvent(TDataEvent.CheckBrowseMode, 0);
      DoBeforeCancel();
      bool DoScrollEvents = State == TDataSetState.Insert;
      if(DoScrollEvents)
        DoBeforeScroll();
      UpdateCursorPos();
      InternalCancel();
      FreeFieldBuffers();
      SetState(TDataSetState.Browse);
      Resync();
      DoAfterCancel();
      if(DoScrollEvents)
        DoAfterScroll();
    }
  }

  void Delete()
  {
    CheckActive();
    if(State==TDataSetState.Insert || State == TDataSetState.SetKey)
      Cancel();
    else
    {
      if(_recordCount == 0)
        DatabaseError(DBConsts.SDataSetEmpty, this);
      DataEvent(TDataEvent.CheckBrowseMode, 0);
      DoBeforeDelete();
      DoBeforeScroll();
      CheckOperation(InternalDelete, _onDeleteError);
      FreeFieldBuffers();
      SetState(TDataSetState.Browse);
      Resync();
      DoAfterDelete();
      DoAfterScroll();
    }
  }

  void BeginInsertAppend()
  {
    CheckBrowseMode();
    CheckCanModify();
    DoBeforeInsert();
    CheckParentState();
    DoBeforeScroll();
  }

  void EndInsertAppend()
  {
    SetState(TDataSetState.Insert);
    try
    {
      DoOnNewRecord();
    }
    catch(E)
    {
      UpdateCursorPos();
      FreeFieldBuffers();
      SetState(TDataSetState.Browse);
      Resync();
      throw E;
    }
    _modified = false;
    DataEvent(TDataEvent.DataSetChange, 0);
    DoAfterInsert();
    DoAfterScroll();
  }

  void AddRecord(List Values, bool Append)
  {

    BeginInsertAppend();
    if(!Append)
      UpdateCursorPos();
    DisableControls();
    try
    {
      MoveBuffer(_recordCount, _activeRecord);
      try
      {
        var Buffer = ActiveBuffer();
        InitRecord(Buffer);
        _state = TDataSetState.Insert;
        try
        {
          DoOnNewRecord();
          DoAfterInsert();
          SetFields(Values);
          DoBeforePost();
          InternalAddRecord(Buffer, Append);
        }
        finally
        {
          FreeFieldBuffers();
          _state = TDataSetState.Browse;
          _modified = false;
        }
      }
      catch(E)
      {
        MoveBuffer(_activeRecord, _recordCount);
        throw E;
      }
      Resync();
      DoAfterPost();
    }
    finally
    {
      EnableControls();
    }
  }

  void InsertRecord(List Values)
  {
    AddRecord(Values, false);
  }

  void AppendRecord(List Values)
  {
    AddRecord(Values, true);
  }

  void CheckOperation(TDataOperation Operation, TDataSetErrorEvent? ErrorEvent)
  {

    bool Done = false;
    do
    {
      try
      {
        UpdateCursorPos();
        Operation();
        Done = true;
      }
      catch(E)
      {
        print(E);

        break; // new
      }
    } while(!Done);
  }

  void SetFields(List Values)
  {
    int i = 0;
    for(var item in Values)
      Fields.Fields[i++].AssignValue(item);
  }



  void CheckRequiredFields()
  {
    for(int i = 0; i<Fields.Count; i++)
    {
      TField WithField = Fields.Fields[i];
      if(WithField.Required && !WithField.ReadOnly && (WithField.FieldKind == TFieldKind.Data) && WithField.IsNull)
      {
        WithField.FocusControl();
        DatabaseErrorFmt(DBConsts.SFieldRequired, [ WithField.DisplayName ]);
      }
    }
  }



// Editing Stubs

  void InternalInitRecord(TRecordBuf Buffer)
  {

  }

  void InternalAddRecord(TRecordBuf Buffer, bool Append)
  {

  }

  void InternalDelete()
  {

  }

  void InternalPost()
  {
    CheckRequiredFields();
  }

  void InternalCancel()
  {

  }

  void InternalEdit()
  {

  }

  void InternalInsert()
  {

  }

  void InternalRefresh()
  {

  }



  TBookmarkFlag GetBookmarkFlag(TRecordBuf Buffer)
  {
    return TBookmarkFlag.Current;
  }

  void SetBookmarkFlag(TRecordBuf Buffer, TBookmarkFlag Value)
  {

  }

  void InternalGotoBookmark(var Bookmark)
  {

  }

  void InternalSetToRecord(TRecordBuf Buffer)
  {

  }

  bool BookmarkValid(var Bookmark)
  {
    return false;
  }

  

  /// Filter / Locate / Find

  

  bool _filtered = false;
  bool
    get Filtered => _filtered;
    set Filtered(bool value) => SetFiltered(value);

  void SetFiltered(bool value)
  {
    if(value == true)
      CheckBiDirectional();
    _filtered = value;
  }



  String _filterText = '';
  String
    get Filter => _filterText;
    set Filter(String value) => SetFilterText(value);

  void SetFilterText(String value)
  {
    CheckBiDirectional();
    _filterText = value;
  }



  bool Locate(Map data, TLocateOptions Options)
  {
    CheckBiDirectional();
    return false;
  }



// Informational

  void CheckBrowseMode()
  {
    CheckActive();
    DataEvent(TDataEvent.CheckBrowseMode, 0);
    switch(State)
    {
      case TDataSetState.Edit:
      case TDataSetState.Insert:
        UpdateRecord();
        if(Modified)
          Post();
        else
          Cancel();
        break;

      case TDataSetState.SetKey:
        Post();
        break;

      default:
        break;
    }
  }

  bool GetCanModify()
  {
    return true;
  }

  void CheckCanModify()
  {
    if(!CanModify)
      DatabaseError(DBConsts.SDataSetReadOnly, this);
  }



  int get RecordCount => GetRecordCount();

  int GetRecordCount() => -1;

  int get RecNo => GetRecNo();
  int GetRecNo() => -1;

  void set RecNo(int Value) => SetRecNo(Value);
  void SetRecNo(int Value) {

  }



  bool IsSequenced()
  {
    return true;
  }



  // Event Handler Helpers

  void DoAfterCancel()
  {
    if(_afterCancel!= null) _afterCancel!(this);
  }

  void DoAfterClose()
  {
    if(_afterClose!=null) _afterClose!(this);
  }

  void DoAfterDelete()
  {
    if(_afterDelete!=null) _afterDelete!(this);
  }

  void DoAfterEdit()
  {
    if(_afterEdit!=null) _afterEdit!(this);
  }

  void DoAfterInsert()
  {
    if(_afterInsert!=null) _afterInsert!(this);
  }

  void DoAfterOpen()
  {
    if(_afterOpen!=null) _afterOpen!(this);
    if(!IsEmpty()) DoAfterScroll();
  }

  void DoAfterPost()
  {
    if(_afterPost!=null) _afterPost!(this);
  }


  void DoAfterRefresh()
  {
    if(_afterRefresh!=null) _afterRefresh!(this);
  }

  void DoAfterScroll()
  {
    if(_afterScroll!=null) _afterScroll!(this);
  }

  void DoBeforeCancel()
  {
    if(_beforeCancel!=null) _beforeCancel!(this);
  }

  void DoBeforeClose()
  {
    if(_beforeClose!=null) _beforeClose!(this);
  }


  void DoBeforeDelete()
  {
    if(_beforeDelete!=null) _beforeDelete!(this);
  }

  void DoBeforeEdit()
  {
    if(_beforeEdit!=null) _beforeEdit!(this);
  }

  void DoBeforeInsert()
  {
    if(_beforeInsert!=null) _beforeInsert!(this);
  }

  void DoBeforeOpen()
  {
    if(_beforeOpen!=null) _beforeOpen!(this);
  }

  void DoBeforePost()
  {
    if(_beforePost!=null) _beforePost!(this);
  }

  void DoBeforeRefresh()
  {
    if(_beforeRefresh!=null) _beforeRefresh!(this);
  }

  void DoBeforeScroll()
  {
    if(_beforeScroll!=null) _beforeScroll!(this);
  }

  void DoOnCalcFields()
  {
    if(_onCalcFields!=null) _onCalcFields!(this);
  }

  void DoOnNewRecord()
  {
    if(_onNewRecord!=null) _onNewRecord!(this);
  }




  dynamic operator [](String name)
  {
    TField? f = FindField(name);
    if(f == null)
      return null;
    return f.AsNative;
  }

  void operator []=(String name, dynamic value)
  {
    TField? f = FindField(name);
    if(f != null)
      f.AsNative = value;
  }

  double AsFloat(String name)
  {
    TField? fld = FindField(name);
    if(fld == null)
      return 0.0;
    return fld.AsFloat;
  }

  int AsInteger(String name)
  {
    TField? fld = FindField(name);
    if(fld == null)
      return 0;
    return fld.AsInteger;
  }

  String AsString(String name)
  {
    TField? fld = FindField(name);
    if(fld == null)
      return "";
    return fld.AsString;
  }

  TDateTime AsDateTime(String name)
  {
    TField? fld = FindField(name);
    if(fld == null)
      return TDateTime();
    return fld.AsDateTime;
  }

}
