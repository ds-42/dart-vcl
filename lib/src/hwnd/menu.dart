part of vcl;

class HMENU extends HComponent
{
  static final _MENU = CLASS_ID('HMENU');
  CLASS_ID get classID => _MENU;

  static final MAINMENU  = CLASS_ID('MAINMENU');
  static final MENUITEM  = CLASS_ID('MENUITEM');
  static final POPUPMENU = CLASS_ID('POPUPMENU');
  static final SEPARATE  = CLASS_ID('SEPARATE');
  static final SUBMENU   = CLASS_ID('SUBMENU');

  void defineClassRule(TWndStyle rule)
  {
    // MAINMENU
    rule.addRule('.${ MAINMENU }',
      'padding: 1px;'
      'background: rgba(255,255,255,.2);'

    );

    // POPUPMENU
    rule.addRule('.${ POPUPMENU }',
      'box-shadow: 2px 2px 5px rgba(0,0,0,.25);'
      'tab-index: -1;'
      'position: absolute;'
      'z-index: 2000;');

    // MENUITEM:
    rule.addRule('.${ MENUITEM }',
      '${ rule.no_select }'
      'border: 1px solid transparent;'
      'white-space: nowrap;'
      'padding: 2px 5px 2px 5px;'
      'position: relative;'
      'display: inline-block;');
    rule.addRule('.${ MENUITEM } .content',
      'display: flex;'
      'justify-content: space-between');
    rule.addRule('.${ MENUITEM } .hotkey',
        'padding-left: 10px;');
    rule.addRule('.${ MENUITEM }:hover',
      'border: 1px solid #70a0e0;'
      'background-color: #b9c8e3;');
    rule.addRule('.${ MENUITEM }.disabled',
      'pointer-events: none;'
      'text-shadow: 0.5px 0.5px white;'
      'color: gray;'
      'opacity: 0.8;');

    // SUBMENU
    rule.addRule('.${ SUBMENU }',
      'left: -1px;'
      'Top: 110%;'
      'list-style: none;'
      'display: block;'
      'visibility: hidden;'
      'padding: 2px;'
      'position: absolute;'
      'border: 1px solid #b0b0b0;'
      'background: #cccccc;'
      'box-shadow: 2px 2px 5px rgba(0,0,0,.25);'
      'z-index: 5;');
    rule.addRule(".${ SUBMENU } .${ SUBMENU }",
      'left: 100%;'
      'top: -1px;');
    rule.addRule('.${ SUBMENU } .${ MENUITEM }',
      'display: block;'
      'padding-left: 20px;');

    // SEPARATE
    rule.addRule('.${ SEPARATE }',
      'margin: 4px 0 4px 20px;'
      'border-top: 1px solid #a0a0a0;'
      'border-bottom: 1px solid #f0f0f0;');
  }

  String get type => handle.className;

  HMENU(CLASS_ID type) : super( DivElement() )
  {
    handle.className = type.name;

  }

  void release()
  {

    handle.remove();
  }





  DivElement? append(String text, { HMENU? submenu, int value=0, bool enabled=true } )
  {
    DivElement getMain(DivElement item)
    {
      Element tmp = item;

      while(tmp.parent!=null)
      {
        String name = tmp.parent!.className;

        if(name==MAINMENU.name || name == MENUITEM.name || name == SUBMENU.name)
          item = tmp.parent as DivElement;
        tmp = tmp.parent!;
      }
      return item;
    }

    if(text == '-')
    {
      DivElement s = DivElement();
      s.className = SEPARATE.name;
      handle.append(s);
      return null;
    }

    var item = DivElement();
    item.className = MENUITEM.name;

    var content = SpanElement();
    content.className = 'content';
    item.append(content);

    var tdata = text.split('\t');
    content.text = tdata[0];
    if(tdata.length>1)
    {
      var hotkey = SpanElement();
      hotkey.className='hotkey';
      hotkey.text=tdata[1];
      content.append(hotkey);
    }

    if(value != 0)
      item.setAttribute('id', '$value');

    if(enabled == false)
      item.classes.add('disabled');

    item.onClick.listen((event)
    {
      if(event.path.contains(item))
      {
        var main = getMain(item);
        if(type == MAINMENU.name)
        {
          String? fold = main.getAttribute('fold');
          if(fold==null)
            main.setAttribute('fold', '');
          else
            main.removeAttribute('fold');


          if(submenu!=null)
            submenu.handle.style.visibility = fold==null? 'visible' : 'hidden';

        }
        else
        {
          handle.style.visibility = 'hidden';

        }

        if(OnClick != null)
        {
          String? id = item.getAttribute('id');
          if(id != null)
            OnClick!(int.parse(id));
        }

      }
    });

    if(submenu != null)
    {
      submenu.handle.className = SUBMENU.name;
      item.append(submenu.handle);
      item.onMouseOver.listen((event)
      {
        var main = getMain(item);
        String? fold = main.getAttribute('fold');
        if(fold!=null)
          submenu.handle.style.visibility = 'visible';
      });
      item.onMouseOut.listen((event)
      {
        submenu.handle.style.visibility = 'hidden';
      });
    }

    handle.append(item);


    return item;
  }

  TEvent? OnClick;
}

