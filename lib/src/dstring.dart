part of vcl;

class AnsiString
{

    static final spf = PrintFormat();
    
    AnsiString sprintf(String format, var args)
    {
      _data = spf(format, args);
      return this;
    }

    String toString() => _data;

    // Constructors
    AnsiString( [dynamic val] )
    {
      if(val == null)
        _data = '';
      else
      if(val is String)
        _data = val;
      else
      if(val is AnsiString)
        _data = val._data;
      else
        _data = '$val';
    }

    AnsiString.str(this._data);



    // Comparisons
    bool operator ==(Object rhs)
    {
      if(rhs is String)
        return _data == rhs;
      if(rhs is AnsiString)
        return _data == rhs._data;
      return false;
    }


    bool operator <  (Object rhs) => AnsiCompare(rhs)<0;
    bool operator >  (Object rhs) => AnsiCompare(rhs)>0;
    bool operator <= (Object rhs) => AnsiCompare(rhs)<=0;
    bool operator >= (Object rhs) => AnsiCompare(rhs)>=0;

    int AnsiCompare(Object rhs)
    {
      if(rhs is String)
        return datacmp(_data.codeUnits, rhs.codeUnits);
      if(rhs is AnsiString)
        return datacmp(_data.codeUnits, rhs._data.codeUnits);
      return -1;
    }

    int AnsiCompareIC(Object rhs) //ignorecase
    {
      if(rhs is String)
        return datacmp(_data.toLowerCase().codeUnits, rhs.toLowerCase().codeUnits);
      if(rhs is AnsiString)
        return datacmp(_data.toLowerCase().codeUnits, rhs._data.toLowerCase().codeUnits);
      return -1;
    }

    // Accessing character at specified index

    int operator [](int idx)
    {
      // ThrowIfOutOfRange(idx);   // Should Range-checking be optional to avoid overhead ??
      return _data.codeUnitAt(idx-1);
    }

    void operator []=(int idx, int code)
    {
      idx--;
      String tmp = '';
      if(idx>0)
        tmp = _data.substring(0, idx);
      _data = '$tmp${String.fromCharCode(code)}${_data.substring(idx+1) }';
    }

    // Concatenation
    AnsiString operator + (dynamic rhs) =>
      AnsiString.str('$_data$rhs');

    // C string operator
    String c_str() => _data;

    

    // Query attributes of string
    int Length() => _data.length;
    bool IsEmpty() => _data.isEmpty;



    // Modify string
    AnsiString Insert(dynamic _str, int index)
    {
      var str = AnsiString(_str);
      _data = _data.insert(index-1, str._data);
      return this;
    }

    AnsiString Delete(int index, int count)
    {
      index--;
      String tmp = '';
      if(index>0)
        tmp = _data.substring(0, index);
      _data = '$tmp${_data.substring(index+count) }';
      return this;
    }

    AnsiString SetLength(int newLength)
    {
      if(newLength<_data.length)
        _data = _data.substring(0, newLength);
      else
        _data = '$_data${' '*(newLength-_data.length)}';
      return this;
    }

    int Pos(dynamic _subStr)
    {
      var subStr = AnsiString(_subStr);
      return _data.indexOf(subStr._data) + 1;
    }

    AnsiString LowerCase() =>
        AnsiString.str(_data.toLowerCase());

    AnsiString UpperCase() =>
      AnsiString.str(_data.toUpperCase());

    AnsiString Trim() =>
      AnsiString.str(_data.trim());

    AnsiString TrimLeft() =>
      AnsiString.str(_data.trimLeft());

    AnsiString TrimRight() =>
      AnsiString.str(_data.trimRight());

    AnsiString SubString(int index, int count) =>
      AnsiString.str(_data.substring(index-1, index+count-1));

    int ToInt() =>
      int.parse(_data);

    int ToIntDef(int defaultValue) =>
      int.tryParse(_data) ?? defaultValue;

    double ToDouble() =>
      double.parse(_data);


  String _data = '';
}
