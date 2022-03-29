part of vcl;

// extension oh html elements

extension HtmlElementExtension on Element
{
  static RECT make_rect(Rectangle rect)
  {
    return RECT(rect.left.truncate(), rect.top.truncate(),
                rect.right.truncate(), rect.bottom.truncate());
  }

  void setParent(Element? elem)
  {
    if(elem == null)
      remove();
    else
      elem.append(this);
  }

  set parentWindow(HWND? hwnd) => setParent(hwnd == null? null : hwnd.handle);

  HWND?
    get owner => HWND._subElements[this];
    set owner(HWND? hwnd)
    {
      if(hwnd == null)
        HWND._subElements.remove(this);
      else
        HWND._subElements[this] = hwnd;
    }

  bool
    get enabled => style.pointerEvents!='none';
    set enabled(bool state) => style.pointerEvents = state? '' : 'none';

  
  bool
    get visible => style.visibility!='hidden' && style.display!='none';
    set visible(bool value) => style.display = value? null : 'none';

  set left(int? l) => style.left=l==null? null : '${l}px';
  set top(int? t) => style.top=t==null? null : '${t}px';
  set height(int? h) => style.height=h==null? null : '${h}px';
  set width(int? w) => style.width=w==null? null : '${w}px';

  bool moveTo(int? l, int? t)
  {
    bool upd = false;

    String? left = l==null? null : '${l}px';
    if(style.left != left)
    {
      style.left = left;
      upd = true;
    }

    String? top = t==null? null : '${t}px';
    if(style.top != top)
    {
      style.top = top;
      upd = true;
    }

    return upd;
  }

  bool setSize(int? w, int? h)
  {
    bool upd = false;

    String? width = w==null? null : '${w}px';
    if(style.width != width)
    {
      style.width = width;
      upd = true;
    }

    String? height = h==null? null : '${h}px';
    if(style.height != height)
    {
      style.height = height;
      upd = true;
    }

    return upd;
  }

  void updateBounds(int? left, int? top, int? width, int? height, [int? right, int? bottom])
  {
    style.left   = left   == null? null : '${left}px';
    style.top    = top    == null? null : '${top}px';
    style.right  = right  == null? null : '${right}px';
    style.bottom = bottom == null? null : '${bottom}px';
    style.width  = width  == null? null : '${width}px';
    style.height = height == null? null : '${height}px';
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
    rect.assign(offsetRect);
    return true;
  }

  SIZE get borderSize
  {
    var b = borderEdge;
    var m = marginEdge;
    return SIZE((b.left - m.left).truncate(), (b.top - m.top).truncate());
  }

  RECT get offsetRect => make_rect(offset);

  RECT get borderRect => make_rect(borderEdge);

  int get borderHeight => borderRect.height;
  int get borderWidth  => borderRect.width;

  RECT get contentRect => make_rect(contentEdge);

  int get contentHeight => contentRect.height;
  int get contentWidth  => contentRect.width;

  RECT get marginRect => make_rect(marginEdge);

  RECT get paddingRect => make_rect(paddingEdge);

  dynamic invisibilityProc(Function proc)
  {
    dynamic processing(Element elem)
    {
      if(offsetParent == null)
      {
        if(elem.parent == null)
          return;

        bool mem = elem.style.undefVisibility();
        dynamic res = processing(elem.parent!);
        elem.style.defVisibility(mem);
        return res;
      }
      return proc();
    }

    return processing(this);

  }
}

extension CssStyleDeclarationExtension on CssStyleDeclaration
{
  bool get isDisplay => display != 'none';

  /*  If some element node in the node tree has the display = 'none' property,
   *  we cannot get the element's metric. defVisibility/undefVisibility temporarily changes
   *  the visibility property of an element
   */
  bool undefVisibility()
  {
    bool res = isDisplay;
    visibility = 'hidden';
    if(!res)
      display = null;
    return res;
  }

  void defVisibility(bool state)
  {
    if(state==false)
      display = 'none';
    visibility = null;
  }

}