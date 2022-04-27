part of demo;

TTabSheet BuildRichEditPage(TPageControl pages)
{
  return TTabRichEdit(pages)
    ..Caption = 'richedit'
    ..PageControl = pages;
}

class TTabRichEdit extends TTabSheet
{
  late final TRichEditTools tools;
  late final TRichEdit richEdit;

  TTabRichEdit(TPageControl pages) : super(pages)
  {
    tools = TRichEditTools(pages)
      ..Align = TAlign.Top
      ..Parent = this;

    richEdit = TRichEdit(this)
      ..Align = TAlign.Client
      ..Parent = this;

    tools.RichEdit = richEdit;
  }
}
