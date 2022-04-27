part of demo;

TTabSheet BuildDataSetPage(TPageControl pages)
{
  return TTabDataSet(pages)
    ..Caption = 'dataset'
    ..PageControl = pages;
}

const taAppend = TUserAction('Append');
const taChange = TUserAction('Change');
const taCopy   = TUserAction('Copy');
const taDelete = TUserAction('Delete');

class TTabDataSet extends TTabSheet
{
  late final TDataSet pers;

  TTabDataSet(TPageControl pages) : super(pages)
  {
    TSpeedButton CreateToolButton(TUserAction action, String hint)
    {
      TAsset tools = Assets['app/tools'];
      var btn = TSpeedButton(this)
//        ..Caption=caption
        ..Glyph.src = tools['$action'].data
        ..NumGlyphs = 0
        ..ShowHint = true
        ..SetSize(30, 30)
        ..Hint = hint

        ..OnClick = (Sender) => DoAction(action);
      return btn;
    }
    // tools
    TFlexBox(this)
      ..Align = TAlign.Top
      ..Parent = this
      ..FlexItems.SetMargin(1, 1, 1, 1)
      ..Add([
        CreateToolButton(taAppend, 'Append record'),
        CreateToolButton(taCopy,   'Copy record'),
        CreateToolButton(taChange, 'Change record'),
        CreateToolButton(taDelete, 'Delete record')
          ..Flex.MarginLeft = 10,
      ]);

    // define dataset
    pers = TDataMap(this)
      ..FieldDefs.AddEx('PersonalCode', TFieldType.AutoInc)
      ..FieldDefs.AddEx('Surname',      TFieldType.String)
      ..FieldDefs.AddEx('Name',         TFieldType.String)
      ..FieldDefs.AddEx('Patronymic',   TFieldType.String)
      ..Open();

    void AppendRecord(int PersonalCode, String Surname, String Name, String Patronymic)
    {
      pers.Append();
      pers.FieldByName('PersonalCode')!.AsInteger = PersonalCode;
      pers.FieldByName('Surname')!.AsString = Surname;
      pers.FieldByName('Name')!.AsString = Name;
      pers.FieldByName('Patronymic')!.AsString = Patronymic;
      pers.Post();
    }

    AppendRecord(1, 'Ivanov',  'Ivan', 'Ivanovich');
    AppendRecord(2, 'Petrov',  'Petr', 'Petrovich');
    AppendRecord(3, 'Sidorov', 'Sidr', 'Sidorov');

    pers.First();

    var ds = TDataSource(this);
    ds.DataSet = pers;

    TDBGrid(this)
      ..Align = TAlign.Client
      ..Columns.AddEx('Surname',    'Surname', 150)
      ..Columns.AddEx('Name',       'Name', 150)
      ..Columns.AddEx('Patronymic', 'Patronymic', 150)
      ..DataSource = ds
      ..DBOptions+= DBGridOptions.RowSelect
      ..Parent = this
      ..OnDblClick = (Sender) => DoAction(taChange);
  }

  void DoAction(TUserAction action) async
  {
    if(action==taDelete)
    {
      if(pers.IsEmpty())
        return;

      if(await ShowQuestionMessage('Delete active record?') == Windows.ID_YES)
        pers.Delete();
      return;
    }

    TLabelEdit Surname, Name, Patronymic;
    var dlg = TForm(this)
      ..ClientWidth = 400
      ..BorderStyle = TFormBorderStyle.Dialog
      ..Position = TPosition.OwnerFormCenter;

    TFlexBox(dlg)
      ..Align = TAlign.Top
      ..Width = dlg.ClientWidth // for auto size dialog
      ..FlexItems.Grow = 1
      ..Parent = dlg
      ..Add([
        Surname = TLabelEdit(this)
          ..Caption = 'Surname',

        Name = TLabelEdit(this)
          ..Caption = 'Name',

        Patronymic = TLabelEdit(this)
          ..Caption = 'Patronymic',

        TButton(this)
          ..Flex.BreakBefore = true
          ..Flex.Justify = TFlexJustify.Right
          ..ModalResult = TModalResult.Ok
          ..Caption = 'OK',
      ]);

    if(action==taChange && pers.IsEmpty())
      action==taAppend;

    if(action != taAppend)
    {
      Surname.Text = pers['Surname'];
      Name.Text = pers['Name'];
      Patronymic.Text = pers['Patronymic'];
    }

    dlg.Caption = action == taChange? 'Change record' : 'Append record';

    dlg.AutoSize = true;
    if(await dlg.ShowModal() == TModalResult.Ok)
    {
      action == taChange? pers.Edit() : pers.Append();
      pers['Surname'] = Surname.Text;
      pers['Name'] = Name.Text;
      pers['Patronymic'] = Patronymic.Text;
      pers.Post();
    }
  }
}