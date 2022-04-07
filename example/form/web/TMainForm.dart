part of demo;

class TMainForm extends TForm
{
  TMainForm() : super(Application)
  {
    Position = TPosition.ScreenCenter;

    Constraints
        ..MinWidth = 300
        ..MinHeight = 200;

    TMenuItem item;
    Menu = TMainMenu(this);
    item = CreateMenuItem(Menu!, 'File');
      CreateMenuItem(item, 'Open\tCtrl+O');
      CreateMenuItem(item, 'Save\tCtrl+S');
      CreateMenuItem(item, 'Save as ...');
      CreateMenuItem(item, '-');
      CreateMenuItem(item, 'Exit\tAlt+X');

    item = CreateMenuItem(Menu!, 'Edit');
      CreateMenuItem(item, 'Cut\tCtrl+X');
      CreateMenuItem(item, 'Copy\tCtrl+C');
      CreateMenuItem(item, 'Paste\tCtrl+V');
      CreateMenuItem(item, '-');
      CreateMenuItem(item, 'Delete').Enabled = false;
      CreateMenuItem(item, '-');
      item = CreateMenuItem(item, 'Zoom');
        CreateMenuItem(item, '10 %');
        CreateMenuItem(item, '50 %');
        CreateMenuItem(item, '100 %');
        CreateMenuItem(item, '-');
        CreateMenuItem(item, 'Fit to page');

    item = CreateMenuItem(Menu!, '?');
      CreateMenuItem(item, 'About')
        ..OnClick = (Sender) async { await TAboutForm(this).ShowModal(); };

    var pages = TPageControl(this)
      ..Align = TAlign.Client
      ..Parent = this;

    BuildPanelsPage(pages);
    BuildControlsPage(pages);
    BuildFlexControlsPage(pages);
    BuildDialogsPage(pages);
    BuildDataSetPage(pages);


    var status = TStatusBar(this);
    status.Height = 22;
    status.Parent = this;
    status.Panels.Add();
    status.Panels.Add();
    status.Panels.Items[0].Width = 100;
    status.Panels.Items[1].Width = 200;

    status.SimpleText = '© dart-vcl [${vcl_lib_version}], ${vcl_lib_date.year}';

    TTabSet(status)
      ..Width = status.Panels.Items[1].Width
      ..MoveTo(105, 1)
      ..SoftTop = true
      ..Tabs.Add('tab-1')
      ..Tabs.Add('tab-2')
      ..Tabs.Add('tab-3')
      ..Parent = status
      ..OnChange = (Sender, int tab)
      {
        Caption = 'MainForm [select tab: ${tab+1}]';
        return true;
      };

    void UpdateStatusText()
    {
      status.Panels.Items[0].Text = 'page: ${pages.ActivePageIndex + 1} / ${pages.PageCount}';
    }

    pages.OnChange = (Sender) => UpdateStatusText();

    UpdateStatusText();
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