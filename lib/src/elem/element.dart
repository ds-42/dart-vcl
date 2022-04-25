part of vcl;

class TElementStyle extends TNodeStyle
{
  TElementStyle(CLASS_ID cid) : super(cid);
}

abstract class HElement
{
  late final Element handle;

  CLASS_ID get tagId;

  HElement()
  {
    var cid = tagId;
    handle = Element.tag(cid.name);

    if(cid.name.isNotEmpty)
    {
      if(TNodeStyle._styles.add(cid.name))
      {
        var rule = TElementStyle(cid);
        defineRule(rule);
      }
    }
  }

  void defineRule(TElementStyle rule)
  {
    rule.classId.defineRule(rule);
  }

  CssStyleDeclaration get style => handle.style;

  Element?
    get parent => handle.parent;
    set parent(Element? value)
    {
      if(value == parent)
        return;
      if(value==null)
        handle.remove();
      else
        value.append(handle);
    }

  void assign(HElement elem)
  {

  }
}
