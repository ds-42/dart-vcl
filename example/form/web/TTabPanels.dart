part of demo;

TTabSheet BuildPanelsPage(TPageControl pages)
{
  return TTabPanels(pages)
    ..Caption = 'panels'
    ..PageControl = pages;
}

class TTabPanels extends TTabSheet
{
  TTabPanels(TPageControl pages) : super(pages)
  {
    TPanel(this)
      ..Caption = 'alTop'
      ..Align = TAlign.Top
      ..Parent = this;

    TPanel(this)
      ..Caption = 'alBottom'
      ..Align = TAlign.Bottom
      ..Parent = this;

    TPanel(this)
      ..Caption = 'alLeft'
      ..Align = TAlign.Left
      ..Parent = this;

    TPanel(this)
      ..Caption = 'alRight'
      ..Align = TAlign.Right
      ..Parent = this;

    var panel = TPanel(this)
      ..Caption = 'alClient'
      ..Align = TAlign.Client
      ..Parent = this;

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
}