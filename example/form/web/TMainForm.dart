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

    BuildPanelsPage(pages);
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