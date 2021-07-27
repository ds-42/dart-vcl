part of vcl;

class LPPTR
{
  final List<int> data;
  int ptr;

  LPPTR.def(this.data, this.ptr);

  factory LPPTR( [dynamic _data, int _ptr = 0] )
  {
    if(_data == null)
      return LPPTR.def(<int>[], _ptr);
    if(_data is List<int>)
      return LPPTR.def(_data, _ptr);
    if(_data is String)
      return LPPTR.def(_data.codeUnits, _ptr);
    if(_data is LPPTR)
      return LPPTR.def(_data.data, _data.ptr+_ptr);
    if(_data is int)
      return LPPTR.def([_data], _ptr);

    throw UnsupportedError('LPPTR::Invalid data type');
  }

  void init()
  {
    data.clear();
    ptr = 0;
  }

  void initData(LPPTR src, int len)
  {
    data.clear();
    var end = src.ptr+len;
    for(var i=src.ptr; i<end; i++)
      data.add(src.data[i]);
    ptr = 0;
  }

  int operator [](int ndx)
  {
    ndx+=ptr;
    if(ndx<0 || ndx>=data.length)
      return -1;
    return data[ndx];
  }

  void clear() => init();

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;

  void first() => ptr = 0;
  void last() => ptr = data.length;
  void prior( [int step=1] ) => ptr-=step;
  bool next( [int step=1] )
  {
    ptr+=step;
    return !eof;
  }


  bool get bof => ptr<0;
  bool get eof => ptr>=data.length;

  int get length => data.length;

  int
    get code
    {
      if(ptr<0 || ptr>=data.length)
        return -1;
      return data[ptr];
    }

    set code(int val)
    {
      if(ptr<0)
        data.insert(0, val);
      if(ptr>=data.length)
      {
        data.add(val);
        ptr++;
      }
      else
        data[ptr] = val;
    }
}

int _datacmp(List<int> s1, int p1, List<int> s2, int p2, [int? len] )
{
  int e1 = s1.length;
  int e2 = s2.length;

  if(len==null)
  {
    while(p1<e1 && p2<e2)
    {
      int d = s1[p1]-s2[p2];
      if(d!=0)
        return d;
      p1++;
      p2++;
    }
  }
  else
  {
    while(len!>0 && p1<e1 && p2<e2)
    {
      int d = s1[p1]-s2[p2];
      if(d!=0)
        return d;
      p1++;
      p2++;
      len--;
    }
  }

  if(len!=null && len==0)
    return 0;

  if(p1>=e1)
    return p2>=e2? 0 : -s2[p2];
  return s1[p1];
}

int datacmp(List<int> s1, List<int> s2, [int? len] ) =>
  _datacmp(s1, 0, s2, 0, len);

int memcmp(dynamic _s1, dynamic _s2, [int? len] )
{
  var s1 = LPPTR(_s1);
  var s2 = LPPTR(_s2);
  return _datacmp(s1.data, s1.ptr, s2.data, s2.ptr, len);
}
