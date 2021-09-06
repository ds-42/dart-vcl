part of demo;

class TRecordBuffer extends TRecordBuf
{
  dynamic       Record;
  int           Index = 0;
  TBookmarkFlag Flag = TBookmarkFlag.Current;
}

abstract class TCustomDataSet extends TDataSet
{
  int  FCursor = 0;
  bool FIsOpen = false;

  TCustomDataSet(TComponent? Aowner) : super(Aowner)
  {

  }

  TFieldDef DefineField(String FieldName, TFieldType FieldType)
  {
    TFieldDef fd = FieldDefs.AddFieldDef();
    fd.DataType=FieldType;
    fd.FieldNo=fd.ID;
    fd.Name=FieldName;
    return fd;
  }

  TFieldDef DefineFieldEx(String FieldName, TFieldType FieldType, int Size)
  {
    TFieldDef fd = DefineField(FieldName, FieldType);
    fd.Size=Size;
    return fd;
  }

  bool GetCanModify()
  {
    return false;
  }

  TRecordBuf AllocRecordBuffer()
  {
    return TRecordBuffer();
  }

  void FreeRecordBuffer(TRecordBuf? buf)
  {
    (buf as TRecordBuffer).Record = null;
  }

  TBookmarkFlag GetBookmarkFlag(TRecordBuf buf)
  {
    return (buf as TRecordBuffer).Flag;
  }

  void SetBookmarkFlag(TRecordBuf buf, TBookmarkFlag Value)
  {
    (buf as TRecordBuffer).Flag = Value;
  }

  void InternalSetToRecord(TRecordBuf buf)
  {
    FCursor = (buf as TRecordBuffer).Index+1;
  }

  int GetRecNo()
  {
    if(FIsOpen)
    {
      TRecordBuf buf = ActiveBuffer();
      if(!IsEmpty())
        return (buf as TRecordBuffer).Index+1;
    }
    return super.GetRecNo();
  }

  void SetRecNo(int Value)
  {
    CheckBrowseMode();
    if(Value < 1 || Value > RecordCount)
      return;

    FCursor=Value;
    Resync(rmCenter: true);
  }

  TGetResult GetRecord(TRecordBuf? Buffer, TGetMode GetMode, bool DoCheck)
  {
    TRecordBuffer buf = Buffer as TRecordBuffer;
    switch(GetMode)
    {
      case TGetMode.Prior:
        if(FCursor <= 1)
          return TGetResult.BOF;
        else
          FCursor--;
        break;

      case TGetMode.Next:
        if(FCursor >= RecordCount)
          return TGetResult.EOF;
        else
          FCursor++;
        break;

      case TGetMode.Current:
        if(FCursor<1 || FCursor > RecordCount)
          return TGetResult.Error;
        break;
    }

    buf.Flag = TBookmarkFlag.Current;
    buf.Index = FCursor-1;
    InternalDefineRecord(buf);
    //CopyRecord(buf.Record, Source[FCursor-1]);
    return TGetResult.OK;
  }

  void InternalDefineRecord(TRecordBuffer buf)
  {
  }

  bool IsCursorOpen()
  {
    return FIsOpen;
  }

  void InternalClose()
  {
    FIsOpen = false;
    Fields.Clear();
  }

  void InternalOpen()
  {
    FIsOpen = true;
    FCursor = 0;

    InitFieldDefs();
    CreateFields();
    BindFields(true);
  }

  void InternalFirst()
  {
    FCursor = 0;
  }

  void InternalLast()
  {
    FCursor = RecordCount + 1;
  }

  void InternalInitFieldDefs()
  {

  }

  TDataSetNotifyEvent? _afterModify;
  TDataSetNotifyEvent?
  get AfterModify => _afterModify;
  set AfterModify(TDataSetNotifyEvent? event) => _afterModify = event;

  void DoAfterDelete()
  {
    super.DoAfterDelete();
    DoAfterModify();
  }

  void DoAfterPost()
  {
    super.DoAfterPost();
    DoAfterModify();
  }

  void DoAfterModify()
  {
    if(AfterModify!=null)
      AfterModify!(this);
  }

}


class TDataMap extends TCustomDataSet
{
  final Records = [];

  int GetRecordCount() => Records.length;

  TDataMap(TComponent AOwner) : super(AOwner)
  {

  }

  void Import(List recs)
  {
    Records.clear();
    recs.forEach((item){
      if(item is Map)
        Records.add(Map.from(item));
    });
    Resync();
  }

  bool GetCanModify()
  {
    return true;
  }

  Map CreateRecord()
  {
    return Map();
  }

  Map? GetRecordData()
  {
    TRecordBuffer buf = ActiveBuffer() as TRecordBuffer;
    if(buf.Index<Records.length)
      return Map.from(Records[buf.Index]);
    return null;
  }

  void AppendRecordMap(Map data)
  {
    Records.add(Map.from(data));
    DoAfterModify();
  }

  void InternalInitRecord(TRecordBuf Buffer)
  {
    (Buffer as TRecordBuffer).Record = CreateRecord();
    super.InternalInitRecord(Buffer);
  }

  bool _rawMode=false;
  TRecordBuffer? _floatingRecord;

  dynamic GetFieldValue(TField fld)
  {
    if(_rawMode)
    {
      if(ActiveRecord == -1)
        return _floatingRecord!.Record[fld.FieldName];
      return Records[ActiveRecord][fld.FieldName];
    }

    var buf = ActiveBuffer() as TRecordBuffer;
    if(buf.Record == null)
    {
      int ndx = buf.Index;
      if(ndx>=Records.length)
        return null;
      return Records[ndx][fld.FieldName];
    }
    return buf.Record[fld.FieldName];
  }

  void SetFieldData(TField fld, dynamic Value)
  {
    TRecordBuffer buf = ActiveBuffer() as TRecordBuffer;
    if(buf.Record != null)
      buf.Record[fld.FieldName] = Value;
    else
      Records[buf.Index][fld.FieldName] = Value;
  }

  void InternalClose()
  {
    Records.clear();
    super.InternalClose();
  }

  void InternalEdit()
  {
    super.InternalEdit();
    TRecordBuffer buf = (ActiveBuffer() as TRecordBuffer);
    buf.Record = Map.from(Records[buf.Index]);
  }

  void InternalPost()
  {
    super.InternalPost();
    _floatingRecord = ActiveBuffer() as TRecordBuffer;
    if(State == TDataSetState.Edit)
      Records.removeAt(_floatingRecord!.Index);

    if(State == TDataSetState.Edit || State == TDataSetState.Insert)
    {
      int pos = State==TDataSetState.Insert? Records.length : _floatingRecord!.Index;
      if(pos<0 || pos>=Records.length)
      {
        pos = Records.length;
        Records.add(_floatingRecord!.Record);
      }
      else
        Records.insert(pos, _floatingRecord!.Record);
      _floatingRecord!.Record=null;
      FCursor=pos+1;
    }
    _floatingRecord = null;
  }

  void InternalCancel()
  {
    super.InternalCancel();
    TRecordBuffer buf = (ActiveBuffer() as TRecordBuffer);
    buf.Record = null;
  }

  void InternalDelete()
  {
    TRecordBuffer buf = (ActiveBuffer() as TRecordBuffer);
    Records.removeAt(buf.Index);

  }

  void Clear()
  {
    if(Records.length == 0)
      return;
    Records.clear();
    Resync();
  }
}
