part of vcl;

class TMetaClass
{
  static final _classes = Map<Type, TClass>();
  final Function Create;
  final Type _type;
  final String? _name;

  const TMetaClass._(this._type, this.Create, this._name);

  bool operator == (Object other) => other is TMetaClass && _type == other._type;

  String toString() => _name ?? _type.toString();


  String ClassName() => _name ?? '';


}

class TClass extends TMetaClass
{
  const TClass._(Type type, Function create, [String? name]) : super._(type, create, name);

  factory TClass(Type type, Function? create, [String? name])
  {
    if(name==null)
      name = '$type';
    TClass? _class = TMetaClass._classes[type];
    if(_class!=null)
    {
      if(create!=null)
      { 
        TMetaClass._classes.remove(_class);
        _class = TClass._(type, create, name);
        TMetaClass._classes[type]= _class;
      }
      return _class;
    }

    _class = TClass._(type, create!, name);
    TMetaClass._classes[type]= _class;
    return _class;
  }
}
