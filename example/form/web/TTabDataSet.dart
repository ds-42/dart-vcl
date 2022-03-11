part of demo;

TTabSheet BuildDataSetPage(TPageControl pages)
{
  return TTabDataSet(pages)
    ..Caption = 'dataset'
    ..PageControl = pages;
}

enum TUserAction { Append, Change, Copy, Delete }

class TTabDataSet extends TTabSheet
{
  late final TDataSet pers;

  TTabDataSet(TPageControl pages) : super(pages)
  {
    TButton CreateToolButton(TUserAction action, String caption, String hint)
    {
      return TButton(this)
        ..Caption=caption
        ..ShowHint = true
        ..Hint = hint
        ..OnClick = (Sender) => DoAction(action);
    }
    // tools
    TFlexBox(this)
      ..Align = TAlign.Top
      ..Parent = this
      ..Add([
        CreateToolButton(TUserAction.Append, 'Append', 'Append record'),
        CreateToolButton(TUserAction.Change, 'Change', 'Change record'),
        CreateToolButton(TUserAction.Copy,   'Copy',   'Copy record'),
        CreateToolButton(TUserAction.Delete, 'Delete', 'Delete record'),
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
      ..OnDblClick = (Sender) => DoAction(TUserAction.Change);
  }

  void DoAction(TUserAction action) async
  {
    if(action==TUserAction.Delete)
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

    if(action==TUserAction.Change && pers.IsEmpty())
      action==TUserAction.Append;

    if(action != TUserAction.Append)
    {
      Surname.Text = pers['Surname'];
      Name.Text = pers['Name'];
      Patronymic.Text = pers['Patronymic'];
    }

    dlg.Caption = action == TUserAction.Change? 'Change record' : 'Append record';

    dlg.AutoSize = true;
    if(await dlg.ShowModal() == TModalResult.Ok)
    {
      action == TUserAction.Change? pers.Edit() : pers.Append();
      pers['Surname'] = Surname.Text;
      pers['Name'] = Name.Text;
      pers['Patronymic'] = Patronymic.Text;
      pers.Post();
    }
  }
}