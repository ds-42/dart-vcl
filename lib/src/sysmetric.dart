part of vcl;

class _sys_metric
{
  int  BorderCx = 0;
  int  BorderCy = 0;
  int  CellCy = 0;
  int  CaptionCy = 0;
  int  DropBtnCx = 0;
  int  DropItemCy = 0;
  int  VScrollCx = 0;
  int  HScrollCy = 0;
  int  InputCx = 0;
  int  InputCy = 0;
  int  ICaptionCy = 0;
  int  IBorderCx = 0;
  int  IBorderCy = 0;
  int  MenuCy = 0;
  int  MinimizedCx = 160;
  int  MinimizedCy = 28;
  int  ShortDateCx = 0;
  bool SmartMode = false;

  void init()
  {
    var grid = HGrid();

    var e1 = DivElement();

    e1.style ..left='0' ..top='0' ..width='100px' ..height='100px';
    e1.className = HGrid.GRID.name;

    var table = TableElement();
    table.style ..width='200px' ..height='200px';

    table.createTHead();

    var th =  table.tHead!.addRow();
    
    var cell = th.addCell() ;

    var p = Element.p() ..className='cell_p' ..text =  '..';
    cell.append(p);

    e1.append(table);
    document.body!.append(e1);

    RECT r1, r2;

    
    CellCy = th.clientHeight;
    if(CellCy>100)
      CellCy = 24; 


    
    int h1=e1.clientHeight;
    int w1=e1.clientWidth;

    e1.style.overflow='scroll';
    VScrollCx = w1-e1.clientWidth;
    HScrollCy = h1-e1.clientHeight;
    SmartMode = VScrollCx<=1 && HScrollCy<=1;
    DropBtnCx = SmartMode? 20 : SysMetric.VScrollCx;

    e1.remove();

    
    var form = HForm();
    form.caption.text='123456у';
    HMENU menu = Windows.CreateMenu();
    form.Menu = menu;
    menu.append('?');
    document.body!.append(form.handle);


    r1=form.handle.borderRect;
    r2=form.title.borderRect;
    CaptionCy = r2.height;
    form.title.style.height='${CaptionCy}px';

    r2=menu.handle.borderRect;
    MenuCy = r2.height;
    menu.handle.style.height='${MenuCy}px';

    BorderCx = 2;
    BorderCy = 2;


    
    HEdit edit = HEdit();
    form.client.append(edit.handle);
    edit.handle.style.height = '${edit.handle.borderEdge.height}px';

    r1 = edit.handle.borderRect;
    r2 = edit.input.contentRect;

    InputCx = 120; 
    InputCy = r1.height;
    IBorderCx = r2.left-r1.left-1; 
    IBorderCy = r2.top-r1.top-1;   

    var lbl = LabelElement();
    lbl.text = '00.00.0000';
    lbl.parentWindow = edit;
    r1 = lbl.borderRect;
    ICaptionCy = r1.height+2;
    ShortDateCx = r1.width;
    

    edit.release();

    var list = HPopupList();
    var item = list.addItem('item');
    form.client.append(list.handle);
    DropItemCy = item.borderRect.height;

    list.release();

    form.release();

      
  }

}

abstract class SysMetric
{
  static _sys_metric? _metric;

  static _sys_metric get Metric
  {
    if(_metric == null)
    {
      _metric = _sys_metric();
      _metric!.init();
    }
    return _metric!;
  }

  static int  get BorderCx     => Metric.BorderCx;
  static int  get BorderCy     => Metric.BorderCy;
  static int  get CaptionCy    => Metric.CaptionCy;
  static int  get CellCy       => Metric.CellCy;
  static int  get DropBtnCx    => Metric.DropBtnCx;
  static int  get DropItemCy   => Metric.DropItemCy;
  static int  get HScrollCy    => Metric.HScrollCy;
  static int  get IBorderCx    => Metric.IBorderCx;
  static int  get IBorderCy    => Metric.IBorderCy;
  static int  get ICaptionCy   => Metric.ICaptionCy;
  static int  get InputCy      => Metric.InputCy;
  static int  get InputCx      => Metric.InputCx;
  static int  get MenuCy       => Metric.MenuCy;
  static int  get MinimizedCx  => Metric.MinimizedCx;
  static int  get MinimizedCy  => Metric.MinimizedCy;
  static int  get ShortDateCx  => Metric.ShortDateCx;
  static bool get SmartMode    => Metric.SmartMode;
  static int  get VScrollCx    => Metric.VScrollCx;

  static int  get PixelRatio   => window.devicePixelRatio.truncate();
  static int  get ScreenHeight => window.screen!.height ?? 0;
  static int  get ScreenWidth  => window.screen!.width  ?? 0;

}

int GetSystemMetrics(int nIndex)
{
  switch(nIndex)
  {
    case Windows.SM_CXVSCROLL:    return SysMetric.VScrollCx;
    case Windows.SM_CYHSCROLL:    return SysMetric.HScrollCy;
    case Windows.SM_CYCAPTION:    return SysMetric.CaptionCy;
    case Windows.SM_CXBORDER:     return SysMetric.BorderCx;
    case Windows.SM_CYBORDER:     return SysMetric.BorderCy;
    case Windows.SM_CYMENU:       return SysMetric.MenuCy;
    case Windows.SM_CXMINIMIZED:  return 160;
    case Windows.SM_CYMINIMIZED:  return 28;
    case Windows.SM_CXMINTRACK:   return 136;
    case Windows.SM_CYMINTRACK:   return 39;
    case Windows.SM_CXMAXTRACK:   return Screen.Width;
    case Windows.SM_CYMAXTRACK:   return Screen.Height;
  }
  return 0;
}