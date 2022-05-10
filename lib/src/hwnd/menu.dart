part of vcl;

class HMENU extends HComponent
{
  static final _MENU = CLASS_ID('HMENU');
  CLASS_ID get classID => _MENU;

  static final MAINMENU  = 'MAINMENU';
  static final MENUITEM  = 'MENUITEM';
  static final POPUPMENU = 'POPUPMENU';
  static const SEPARATE  = 'SEPARATE';

  static const CONTENT = 'mi-content';
  static const HOTKEY  = 'mi-hotkey';
  static const FOLD    = 'menu-fold';

  void defineClassRule(TWndStyle rule)
  {
    rule.addRule('.${ MAINMENU }',
      'padding: 1px;'
      'background: rgba(255,255,255,.2);'
    );

    rule.addRule('.$MAINMENU .$MENUITEM',
      'display: inline-block;'
      );

    rule.addRule('.$POPUPMENU .$MENUITEM',
      'display: block;'
      'padding-left: 20px;'
    );

    rule.addRule('.$POPUPMENU',
     '${ rule.font }'
      'left: -1px;'
      'Top: calc(100% + 1px);'
      'min-width: 120px;'
      'display: none;'
      'padding: 2px;'
      'position: absolute;'
      'border: 1px solid #b0b0b0;'
      'background: #cccccc;'
      'box-shadow: 2px 2px 5px rgba(0,0,0,.25);'
      'z-index: 5;');

    // MENUITEM:
    rule.addRule('.$MENUITEM',
      '${ rule.no_select }'
      'position: relative;'
      'border: 1px solid transparent;'
      'white-space: nowrap;'
      'padding: 2px 5px 2px 5px;');

    rule.addRule('.$MENUITEM .$HOTKEY',
      'padding-left: 15px;');

    rule.addRule('.$MENUITEM:hover',
      'border: 1px solid #70a0e0;'
      'background-color: #b9c8e3;');

    rule.addRule('.$MENUITEM.disabled',
      'pointer-events: none;'
      'text-shadow: 0.5px 0.5px white;'
      'color: gray;'
      'opacity: 0.8;');

    rule.addRule(".$POPUPMENU .$POPUPMENU",
      'left: calc(100% + 1px);'
      'top: -4px;');

    rule.addRule('.$CONTENT',
      'display: flex;'
      'align-items: center;'
      'justify-content: space-between;');

    rule.addRule('.$SEPARATE',
      'margin: 4px 0 4px 20px;'
      'border-top: 1px solid #a0a0a0;'
      'border-bottom: 1px solid #f0f0f0;');
  }

  HMENU._(String type) : super( DivElement() )
  {
    handle.className = type;
  }

  HMENU() : this._( MENUITEM );

  static HMENU? find(Element elem)
  {
    while(true)
    {
      var hwnd = HWND._elements[elem];
      if(hwnd is HMENU)
        return hwnd;

      if(elem.parent==null)
        return null;

      elem = elem.parent!;
    }
  }

  static HMENU? findRoot(Element elem)
  {
    var menu = find(elem);
    if(menu==null)
      return null;

    while(menu!.handle.parent != null)
    {
      var parent = find(menu.handle.parent!);
      if(parent==null)
        return menu;
      menu = parent;
    }
    return menu;
  }

  DivElement? append(String text, { HMENU? submenu, int value=0, bool enabled=true } )
  {
    if(text == '-')
    {
      var s = DivElement();
      s.className = SEPARATE;
      handle.append(s);
      return null;
    }

    var item = DivElement();
    item.className = MENUITEM;

    var content = DivElement();
    content.className = CONTENT;
    item.append(content);

    var tdata = text.split('\t');
    content.text = tdata[0];
    if(tdata.length>1/* && submenu==null*/)
    {
      var hotkey = SpanElement();
      hotkey.className = HOTKEY;
      hotkey.text = tdata[1];
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
        var root = findRoot(item);

        if(this is HMAINMENU)
        {
          var fold = handle.getAttribute(FOLD);
          if(fold==null)
            handle.setAttribute(FOLD, '');
          else
            handle.removeAttribute(FOLD);

          if(submenu!=null)
            submenu.handle.style.display = fold==null? 'block' : null;
        }
        else
        {
          event.stopPropagation();
          if(submenu==null)
          {
            Element elem = handle;
            while(true)
            {
              elem.style.display = null;
              if(elem==root || elem.parent==null)
                break;
              elem = elem.parent!;
            }
          }
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
      submenu.handle.className = POPUPMENU;
      item.append(submenu.handle);
      item.onMouseOver.listen((event)
      {
        var root = findRoot(item);
        if(root is HMAINMENU)
        {
          String? fold = root.handle.getAttribute(FOLD);
          if(fold==null)
            return;
        }

        submenu.handle.style.display = 'block';
      });
      item.onMouseOut.listen((event)
      {
        submenu.handle.style.display = null;
      });

    }

    handle.append(item);

    return item;
  }

  TEvent? OnClick;
}

class HMAINMENU extends HMENU
{
  HMAINMENU() : super._(HMENU.MAINMENU);
}

class HPOPUPMENU extends HMENU
{
  HPOPUPMENU() : super._(HMENU.POPUPMENU);
}