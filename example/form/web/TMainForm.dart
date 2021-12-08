part of demo;

class TMainForm extends TForm
{
  TMainForm() : super(Application)
  {
    Position = TPosition.ScreenCenter;

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
      CreateMenuItem(item, 'About');

    var pages = TPageControl(this)
      ..Align = TAlign.Client
      ..Parent = this;

    BuildPanelsPage(pages);
    var pageCtrls = BuildControlsPage(pages);
    BuildDialogsPage(pages);
    BuildDataSetPage(pages);

    pages.ActivePageIndex = 0;

    var status = TStatusBar(this);
    status.Parent = this;
    status.Panels.Add();
    status.Panels.Items[0]
      ..Width = 120
      ..Text = 'page count: ${ pages.PageCount }';

    status.SimpleText = '© dart-vcl [${vcl_lib_version}], ${vcl_lib_date.year}';

    Application.OnMessage = (msg, handled)
    {
      if(msg.message==WM_LBUTTONDOWN)
      {
        var ctrl = Windows.SendMessage(msg.hwnd, CM_GETINSTANCE);
        if(ctrl is TWinControl)
          (pageCtrls as TTabControls).SelectControl(ctrl);
      }
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