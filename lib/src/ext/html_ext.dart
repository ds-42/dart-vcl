part of vcl;

// extension oh html elements

extension HtmlElementExtension on Element
{
  void setParent(Element? elem)
  {
    if(elem == null)
      remove();
    else
      elem.append(this);
  }

  set parentWindow(HWND? hwnd) => setParent(hwnd==null? null : hwnd.handle);

  HWND?
    get owner => HWND._subElements[this];
    set owner(HWND? hwnd)
    {
      if(hwnd == null)
        HWND._subElements.remove(this);
      else
        HWND._subElements[this] = hwnd;
    }

  set left(int? l) => style.left=l==null? null : '${l}px';
  set top(int? t) => style.top=t==null? null : '${t}px';
  set height(int? h) => style.height=h==null? null : '${h}px';
  set width(int? w) => style.width=w==null? null : '${w}px';

  void moveTo(int? l, int? t)
  {
    style.left=l==null? null : '${l}px';
    style.top =t==null? null : '${t}px';
  }

  void setSize(int? w, int? h)
  {
    style.height=h==null? null : '${h}px';
    style.width =w==null? null : '${w}px';
  }

  void setMaxLength(int len)
  {
    if(len<=0)
    {
      removeAttribute('maxlength');
      return;
    }

    if(this is InputElement)
      (this as InputElement).maxLength = len;
    else
    if(this is TextAreaElement)
      (this as TextAreaElement).maxLength = len;
  }

  bool getOffsetRect(RECT rect)
  {
    if(offsetParent == null)
      return false;
    var rr = offset;
    rect
      ..left=rr.left.truncate()
      ..top=rr.top.truncate()
      ..right=rr.right.truncate()
      ..bottom=rr.bottom.truncate();
    return true;
  }

  RECT get offsetRect
  {
    var rect = offset;
    return RECT(rect.left.truncate(), rect.top.truncate(),
                rect.right.truncate(), rect.bottom.truncate());
  }

  TRect get borderRect
  {
    var rect = borderEdge;
    return TRect(rect.left.truncate(), rect.top.truncate(),
                 rect.right.truncate(), rect.bottom.truncate());
  }

  int get borderHeight => borderRect.height;
  int get borderWidht  => borderRect.width;

  TRect get contentRect
  {
    var rect = contentEdge;
    return TRect(rect.left.truncate(), rect.top.truncate(),
                 rect.right.truncate(), rect.bottom.truncate());
  }

  int get contentHeight => contentRect.height;
  int get contentWidth  => contentRect.width;
}
