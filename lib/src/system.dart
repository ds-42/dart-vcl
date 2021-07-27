part of vcl;


class TNullObject extends TObject
{

}

abstract class TObject
{
  static TObject NULL = TNullObject();


  static const String sLineBreak = '\r\n'; 



  TClass? _classType;
  TClass ClassType()
  {
    if(_classType==null)
      _classType = TClass(runtimeType, null); // конструктор остается пустым
    return _classType!;
  }

  String ClassName() => runtimeType.toString();



  void Destroy() // destructor
  {
  }

  void Free()
  {
    Destroy();
  }


  void DefaultHandler(TMessage Message)
  {

  }



  void Dispatch(TMessage Message)
  {
  
    DefaultHandler(Message);
  }


}
