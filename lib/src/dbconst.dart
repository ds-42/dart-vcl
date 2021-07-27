part of vcl;

abstract class DBConsts
{

  static const SFieldNameMissing = 'Field name missing';
  static const SDuplicateFieldName = 'Duplicate field name \'%s\'';
  static const SFieldNotFound = 'Field \'%s\' not found';
  static const SFieldAccessError = 'Cannot access field \'%s\' as type %s';

  static const SFieldRequired = 'Field \'%s\' must have a value';
  
  static const SDuplicateName = 'Duplicate name \'%s\' in %s';
  static const SCircularDataLink = 'Circular datalinks are not allowed';

  static const SDataSourceChange = 'DataSource cannot be changed';

  static const SDataSetOpen = 'Cannot perform this operation on an open dataset';
  static const SNotEditing = 'Dataset not in edit or insert mode';
  static const SDataSetClosed = 'Cannot perform this operation on a closed dataset';
  static const SDataSetEmpty = 'Cannot perform this operation on an empty dataset';
  static const SDataSetReadOnly = 'Cannot modify a read-only dataset';
  static const SNestedDataSetClass = 'Nested dataset must inherit from %s';

  static const SDataSetUnidirectional = 'Operation not allowed on a unidirectional dataset';
  
  static const SRecordNotFound = 'Record not found';


  static const SDeleteRecordQuestion = 'Delete record?';

}
