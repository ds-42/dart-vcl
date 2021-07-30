part of demo;

class TMainForm extends TForm
{
  TMainForm() : super(Application)
  {
    Position = TPosition.ScreenCenter;

    TMenuItem item;
    Menu = TMainMenu(this);
    item = CreateMenuItem(Menu!, 'File');
      CreateMenuItem(item, 'Open');
      CreateMenuItem(item, 'Save');
      CreateMenuItem(item, 'Save as ...');
      CreateMenuItem(item, '-');
      CreateMenuItem(item, 'Exit');

    item = CreateMenuItem(Menu!, 'Edit');
      CreateMenuItem(item, 'Cut');
      CreateMenuItem(item, 'Copy');
      CreateMenuItem(item, 'Paste');
      CreateMenuItem(item, '-');
      CreateMenuItem(item, 'Delete').Enabled = false;

    item = CreateMenuItem(Menu!, '?');
      CreateMenuItem(item, 'About');

    var pages = TPageControl(this)
      ..Align = TAlign.Client
      ..Parent = this;

    BuildStandardPage(pages);
    BuildControlsPage(pages);
    BuildDialogsPage(pages);

    pages.ActivePageIndex = 0;

    var status = TStatusBar(this);
    status.Parent = this;
    status.Panels.Add();
    status.Panels.Items[0]
      ..Width = 120
      ..Text = 'page count: ${ pages.PageCount }';

    status.SimpleText = '© dart-vcl, 2021';

  }

  void BuildStandardPage(TPageControl pages)
  {
    var page = TTabSheet(pages)
      ..Caption = 'panels'
      ..PageControl = pages;

    TPanel(page)
      ..Caption = 'alTop'
      ..Align = TAlign.Top
      ..Parent = page;

    TPanel(page)
      ..Caption = 'alBottom'
      ..Align = TAlign.Bottom
      ..Parent = page;

    TPanel(page)
      ..Caption = 'alLeft'
      ..Align = TAlign.Left
      ..Parent = page;

    TPanel(page)
      ..Caption = 'alRight'
      ..Align = TAlign.Right
      ..Parent = page;

    var panel = TPanel(page)
      ..Caption = 'alClient'
      ..Align = TAlign.Client
      ..Parent = page;

    TPanel(panel)
      ..SetBounds(10, 10, panel.Width-20, 50)
      ..Caption = 'akRight + akLeft + akTop'
      ..Anchors = TAnchors()<<TAnchorKind.Right<<TAnchorKind.Left<<TAnchorKind.Top
      ..Parent = panel;

    TPanel(panel)
      ..SetBounds(10, panel.Height-60, panel.Width-20, 50)
      ..Caption = 'akRight + akLeft + akBottom'
      ..Anchors = TAnchors()<<TAnchorKind.Right<<TAnchorKind.Left<<TAnchorKind.Bottom
      ..Parent = panel;
  }

  void BuildControlsPage(TPageControl pages)
  {
    var page = TTabSheet(pages)
      ..Caption = 'controls'
      ..PageControl = pages;

    TEdit(page)
      ..SetBounds(10, 20, 120, null)
      ..Text = 'TEdit'
      ..Parent = page;

    var combo = TComboBox(page)
      ..SetBounds(10, 50, 120, null)
      ..Text = 'TComboBox'
      ..Parent = page;
    for(var i=0; i<10; i++)
      combo.Items.Add('Item $i');

    TCheckBox(page)
      ..SetBounds(210, 20, 120, null)
      ..Caption = 'TCheckBox'
      ..Checked = true
      ..Parent = page;

    TRadioButton(page)
      ..SetBounds(210, 40, 120, null)
      ..Caption = 'TRadioButton 1'
      ..Parent = page;

    TRadioButton(page)
      ..SetBounds(210, 60, 120, null)
      ..Caption = 'TRadioButton 2'
      ..Parent = page;
  }

  void BuildDialogsPage(TPageControl pages)
  {
    var page = TTabSheet(pages)
      ..Caption = 'dialogs'
      ..PageControl = pages;

    TButton(page)
      ..Caption = 'Simple form'
      ..SetBounds(10, 10, 150, null)
      ..Parent = page
      ..OnClick = (Sender) {
        TForm(this)
          ..Position = TPosition.ScreenCenter
          ..Show();
      };

    TButton(page)
      ..Caption = 'Modal form'
      ..SetBounds(10, 40, 150, null)
      ..Parent = page
      ..OnClick = (Sender) async {
        var form = TForm(this);
        form.Position = TPosition.ScreenCenter;
        form.OnClose = (Sender, Action) async
        {
/*          if(await ShowQuestionMessage('Close the form?') != Windows.ID_YES)
            Action.Value = TCloseAction.None;*/
        };
        await form.ShowModal();
        await ShowMessage('The modal form was closed');
      };

    TButton(page)
      ..Caption = 'Show message'
      ..SetBounds(10, 70, 150, null)
      ..Parent = page
      ..OnClick = (Sender) {
        ShowMessage('Simple message');
      };

    TButton(page)
      ..Caption = 'Input box'
      ..SetBounds(10, 100, 150, null)
      ..Parent = page
      ..OnClick = (Sender) async {
        var name = await InputBox('Input box', 'Enter your name', '');
        if(name.isNotEmpty)
          await ShowMessage('Hello, $name');
      };

    TButton(page)
      ..Caption = 'User dialog'
      ..SetBounds(10, 130, 150, null)
      ..Parent = page
      ..OnClick = (Sender) async {
        var dlg = TUserDialog(this);
        if(await dlg.ShowModal() == TModalResult.Ok)
          ShowMessage('Hello, ${ dlg.userName} ');
        else
          ShowMessage('See you later');
      };
  }

  static TMenuItem CreateMenuItem(TComponent Owner, String Caption, [int Index=-1/*, TNotifyEvent ev*/])
  {
    var item = TMenuItem(Owner);
    if(Owner is TMenuItem)
    {
      if(Index == -1)
        Owner.Add(item);
      else
        Owner.Insert(Index, item);
    }
    else
    if(Owner is TMenu)
    {
      if(Index==-1)
        Owner.Items.Add(item);
      else
        Owner.Items.Insert(Index, item);
    }
    item.Caption = Caption;
    return item;
  }


}