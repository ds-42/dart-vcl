part of vcl;

extension VclIntExtension on int
{
  bool and(int mask) => (this & mask) != 0;
  bool or(int mask)  => (this | mask) != 0;

  bool beetwen(int start, int end) => this>=start && this<=end;

  String get twoDigits
  {
    if(this <  0) return '-${ (-this).twoDigits }';
    if(this < 10) return '0${ this }';
    return '${ this }';
  }

  String get threeDigits
  {
    if(this <   0) return '-${ (-this).threeDigits }';
    if(this <  10) return '00${ this }';
    if(this < 100) return '0${ this }';
    return '${ this }';
  }

  String get fourDigits
  {
    if(this <    0) return '-${ (-this).fourDigits }';
    if(this <   10) return '000${ this }';
    if(this <  100) return '00${ this }';
    if(this < 1000) return '0${ this }';
    return '${ this }';
  }

  String asHex([int size=0])
  {
    String res = this.toRadixString(16);
    while(res.length < size)
      res = '0$res';
    return res;
  }

}

extension VclStringExtension on String
{
  String insert(int pos, String str)
  {
    if(str.isEmpty)
      return this;
    return substring(0, pos) + str + substring(pos);
  }

  String remove(int pos, int count)
  {
    var p1 = pos;
    var p2 = pos+count;
    if(p2<p1)
    {
      p2 = pos;
      p1 = pos+count;
    }
    if(p1<0)
      p1=0;
    if(p2>length)
      p2=length;
    if(p1==0)
      return substring(p2);
    return substring(0, p1)+substring(p2);
  }
}

extension VclListExtension<T> on List
{
  void move(int curIndex, int newIndex)
  {
    if(curIndex == newIndex)
      return;

    var item = this[curIndex];
    removeAt(curIndex);
    insert(newIndex, item);
  }

  void resize(int newSize, T val)
  {
    while(length<newSize)
      add(val);
    if(length>newSize)
      removeRange(newSize, length);
  }
}

extension VclSetExtension<T> on Set<T>
{
  Set<T> _cast(dynamic source)
  {
    if(source is T)
      return { source };
    if(source is Set<T>)
      return source;
    if(source is List<T>)
      return Set<T>.from(source);
    if(source is List && source.isEmpty)
      return <T>{ };
    if(source is Set && source.isEmpty)
      return <T>{ };
    throw TypeError();
  }

  T operator [](int ndx) => elementAt(ndx);

  Set<T> operator << (T value) // Add element
  {
    add(value);
    return this;
  }

  Set<T> operator >> (T value) // Remove element
  {
    remove(value);
    return this;
  }

  Set<T> operator + (dynamic rhs) // Union
  {
    var res = Set<T>.from( this );
    res.addAll( _cast(rhs) );
    return res;
  }

  Set<T> operator - (dynamic rhs) // Difference
  {
    var res = Set<T>.from( this );
    res.removeAll( _cast(rhs) );
    return res;
  }

  Set<T> operator * (dynamic rhs) // Intersection
  {
    var res = Set<T>();

    for(T elem in _cast(rhs))
      if(contains(elem))
        res.add(elem);

    return res;
  }

  void assign(dynamic rhs)
  {
    clear();
    addAll(_cast(rhs));
  }

  bool changeState(T elem, bool state)
  {
    if(state)
    {
      if(contains(elem))
        return false;
      add(elem);
    }
    else
    {
      if(contains(elem)==false)
        return false;
      remove(elem);
    }
    return true;
  }

  bool isEqual(dynamic other)
  {
    var tmp = Set<T>.from( this );
    for(var item in _cast(other))
      if(tmp.remove(item) == false)
        return false;
    return tmp.isEmpty;
  }

}
