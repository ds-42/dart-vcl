part of vcl;

Future<int> MessageBox(dynamic data, String caption, int mode) async
{

  TButton CreateButton(TWinControl prnt, TModalResult mr)
  {
    return TButton(prnt)
      ..ModalResult = mr
      ..Caption = ModalResults.ResultToStr(mr, Locale.active)
      ..Parent = prnt
      ..Handle.style.height = null
      ..Handle.style.width = null;
  }

  String text = data.toString();

  TForm dlg = TForm(Screen.FocusedForm==null? Application : Screen.FocusedForm);
  dlg.Caption = caption;
  dlg.Position = Screen.FocusedForm==null? TPosition.ScreenCenter : TPosition.OwnerFormCenter;
  dlg.BorderStyle = TFormBorderStyle.Dialog;
  dlg.ClientWidth = 300;

  dlg.OnShow = (Sender)
  {
    dlg.WindowHandle!.handle.invisibilityProc(()
    {
      DivElement pText = DivElement();
      pText.style.whiteSpace = 'pre-line';
      if(text.isNotEmpty && text[0]==' ')
        pText.text = text.trim();
      else
        pText.innerHtml = text;
      pText.setParent(dlg.Handle.clientHandle);

      var r = pText.borderRect;
      int height = r.height;
      if(height>60)
      {
        dlg.ClientWidth = 400;
        r = pText.borderRect;
        height = r.height;
      }

      int dy = 0;
      if(height<60)
      {
        dy = (60-height)>>1;
        height = 60;
      }

      pText.style.textAlign='center';
      pText.style.paddingTop='${dy}px';
      pText.style.paddingLeft='5px';
      pText.style.paddingRight='5px';

      var btns = <TButton?>[null, null, null];

      switch(mode & 0x0F)
      {
        case Windows.MB_OK:
          btns[0] = CreateButton(dlg, TModalResult.Ok);
          break;
        case Windows.MB_OKCANCEL:
          btns[0] = CreateButton(dlg, TModalResult.Ok);
          btns[1] = CreateButton(dlg, TModalResult.Cancel);
          break;
        case Windows.MB_YESNO:
          btns[0] = CreateButton(dlg, TModalResult.Yes);
          btns[1] = CreateButton(dlg, TModalResult.No);
          break;
        case Windows.MB_YESNOCANCEL:
          btns[0] = CreateButton(dlg, TModalResult.Yes);
          btns[1] = CreateButton(dlg, TModalResult.No);
          btns[2] = CreateButton(dlg, TModalResult.Cancel);
          break;
        case Windows.MB_ABORTRETRYIGNORE:
          btns[0] = CreateButton(dlg, TModalResult.Abort);
          btns[1] = CreateButton(dlg, TModalResult.Retry);
          btns[2] = CreateButton(dlg, TModalResult.Ignore);
          break;
      }

      var bwidth = 80;
      var bheight = 0;
      var bcount = 0;
      for(TButton? btn in btns)
      {
        if(btn != null)
        {
          var r = btn.Handle.handle.borderRect;
          if(r.width > bwidth)
            bwidth = r.width;
          if(r.height > bheight)
            bheight = r.height;
          bcount++;
        }
      }

      int x = (dlg.ClientWidth - bwidth*bcount - 10*(bcount-1)) ~/ 2;
      for(TButton? btn in btns)
      {
        if(btn != null)
        {
          btn.SetBounds(x, height + 5, bwidth, bheight);
          x+=btn.Width + 10;
        }
      }

      dlg.ClientHeight = height + bheight + 10;
    });
  };

  TModalResult Result = await dlg.ShowModal();
  dlg.Free();

  switch(Result)
  {
    case TModalResult.Abort:  return Windows.ID_ABORT;
    case TModalResult.Cancel: return Windows.ID_CANCEL;
    case TModalResult.Ignore: return Windows.ID_IGNORE;
    case TModalResult.Ok:     return Windows.ID_OK;
    case TModalResult.No:     return Windows.ID_NO;
    case TModalResult.Retry:  return Windows.ID_RETRY;
    case TModalResult.Yes:    return Windows.ID_YES;
    default:                  return Windows.ID_CLOSE;
  }
}

Future<void> ShowMessage(dynamic data) async
{
  await MessageBox(data, Application.Title, Windows.MB_OK);
}

Future<void> ShowWarningMessage(dynamic data) async
{
  await MessageBox(data, '${ SysLocale.Warning }', Windows.MB_OK);
}

Future<void> ShowErrorMessage(dynamic data) async
{
  await MessageBox(data, '${ SysLocale.Error }', Windows.MB_OK);
}

Future<int> ShowQuestionMessage(dynamic data, [int mode = Windows.MB_YESNO]) async
{
  return await MessageBox(data, '', mode);
}

Future<String> InputBox(String ACaption, String APrompt, String ADefault) async
{
  var form = TForm(Screen.FocusedForm==null? Application : Screen.FocusedForm);
  form.BorderStyle = TBorderStyle.Dialog;
  form.Position = TPosition.OwnerFormCenter;
  form.Caption = ACaption;
  form.Width = 300;

  int top = 10;
  int width = form.ClientWidth-10;
  var label = TLabel(form)
    ..SetBounds(5, top, width, null)
    ..Caption = APrompt
    ..Parent = form;

  top+=label.Height+2;

  var edit = TEdit(form);
  edit
    ..SetBounds(5, top, width, null)
    ..Text = ADefault
    ..Parent = form;

  top+=edit.Height + 20;

  int btnLeft = (width-160)~/2;
  var btnOk = TButton(form)
    ..Caption = ModalResults.ResultToStr(TModalResult.Ok, Locale.active)
    ..SetBounds(btnLeft, top, 80, null)
    ..ModalResult = TModalResult.Ok
    ..Parent = form;

  TButton(form)
    ..Caption = ModalResults.ResultToStr(TModalResult.Cancel, Locale.active)
    ..SetBounds(btnLeft+90, top, 80, null)
    ..ModalResult = TModalResult.Cancel
    ..Parent = form;

  top+=btnOk.Height + 10;

  form.ClientHeight = top;

  if(await form.ShowModal() == TModalResult.Ok)
    ADefault = edit.Text;
  return ADefault;
}