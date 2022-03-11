part of vcl;

/*
 * Combo Box Notification Codes
 */

const int CBN_SELCHANGE =      1;

class HComboBox extends HCustomControl
{
  static final COMBOBOX = CLASS_ID('COMBOBOX');
  CLASS_ID get classID => COMBOBOX;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();

    rule.add('',
      'position: absolute;'
      'box-sizing: border-box;'
      'background: white;'
      'border: 1px solid #A0A0A0;');
    rule.add('select',
      'position: absolute;'
      'left: -1px;'
      'width: calc(100% + 2px); '
      'height: 100%;'
      'outline: none;'
      'border: none;'
      'background-color: inherit;');
    rule.add('input',
      'position: absolute;'
      'left: 2px;'
      'top: 0;'
      'bottom: 0;'
      'outline: none;'
      'border: none;'
      'width: calc(100% - 20px);'
      'background-color: inherit;');
  }

  final overlay = DivElement();
  final select = SelectElement();
  final input = InputElement();
  final objects = Map<OptionElement, dynamic>();

  int get selectedIndex => select.selectedIndex ?? 0;
  int get selectLength => select.length ?? 0;

  Element getClientHandle() => input;

  HComboBox() : super()
  {
    handle.append(overlay);
    overlay.append(select);
    overlay.append(input);

    overlay.style
      ..position = "absolute"
      ..background = "inherit"
      ..overflow = "hidden"
      ..width = "100%"
      ..height = "100%";

    OptionElement option = OptionElement(value: "null");
    option.hidden = true;
    option.disabled = true;
    option.selected = true;
    select.children.add(option);

    input.spellcheck = false;

    input.owner = this;
    select.owner = this;


//    select.onChange.listen((event) => Windows.SendMessage(this, CN_COMMAND, TCommand(selectedIndex - 1, CBN_SELCHANGE)) );
    select.onChange.listen((event) =>  ItemIndex = selectedIndex - 1); //Windows.SendMessage(this, CN_COMMAND, TCommand(selectedIndex - 1, CBN_SELCHANGE)) );

    WNDPROC? defproc;
    defproc = Windows.ChangeWindowProc(this, (elem, message)
    { // mainproc


      if(message.Msg is COMBOBOX_MESSAGE)
      {
        switch(message.Msg)
        {
          case CB_RESETCONTENT:
            objects.clear();
            defproc!(select, message);
            break;

          case CB_SETEDITSEL:
            input.setSelectionRange(0, message.LParam);
            break;

          case CB_SETCURSEL:

            ItemIndex = message.WParam;
            message.Result = ItemIndex;
            break;

          case CB_SETITEMDATA:
            OptionElement elem = select.options[message.WParam+1];
            objects[elem] = message.LParam;
            break;

          case CB_GETITEMDATA:
            int ndx = message.WParam;
            if(ndx < 0 || ndx >=selectLength)
            {
              message.Result = Windows.CB_ERR;
              return;
            }
            OptionElement elem = select.options[ndx+1];
            message.Result = objects[elem];
            break;

          case CB_FINDSTRINGEXACT:
            message.Result = -1;
            String str = (message.LParam as String).toLowerCase();
            for(var item in select.options)
              if(item.text!.toLowerCase() == str)
              {
                message.Result = item.index-1;
                break;
              }
            break;

          default:
            defproc!(select, message);
            break;
        }
        return;
      }

      switch(message.Msg)
      {
        case WM_GETTEXT:
          message.Result = input.value;
          break;

        case WM_SETTEXT:
          input.value = message.LParam;
          if(!Windows.IsFocused(this))
            input.setSelectionRange(0, SysUtils.MAXLONG);
          break;

        case WM_KEYDOWN:
          switch(message.WParam)
          {
            case KeyCode.UP:
              if(ItemIndex>0)
                ItemIndex--;
              message.Result = false;
              break;
            case KeyCode.DOWN:
              ItemIndex++;
              message.Result = false;
              break;
          }
          break;

        default:
          defproc!(elem, message);
          break;
      }
    });

  }

  void UpdateText()
  {

    input.value = select.options[selectedIndex].text;
    input.select();
  }

  int get ItemIndex
  {
    if(selectedIndex<0)
      return -1;
    OptionElement elem = select.options[selectedIndex];
    if(elem.hidden)
      return -1;
    return selectedIndex-1;
  }

  set ItemIndex(int Value)
  {
    int ndx = Value+1;
    if(ndx < 0)
      ndx = 0;
    if(ndx >= selectLength)
      ndx = selectLength;
    if(selectLength == ndx)
      return;
    select.selectedIndex=ndx;
    UpdateText();
    Windows.SendMessage(this, CN_COMMAND, TCommand(ndx - 1, CBN_SELCHANGE));
  }

  void EnableChanged()
  {
    super.EnableChanged();
    input.disabled = !Enabled;
    select.disabled = !Enabled;
  }

}
