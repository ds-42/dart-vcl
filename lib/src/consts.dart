part of vcl;


abstract class Consts
{

  static const SNoCanvasHandle = 'Canvas does not allow drawing';
  
  static const SCannotFocus = 'Cannot focus a disabled or invisible window';
  static const SParentRequired = 'Control \'%s\' has no parent window';

  static const SMDIChildNotVisible = 'Cannot hide an MDI Child Form';
  static const SVisibleChanged = 'Cannot change Visible in OnShow or OnHide';
  static const SCannotShowModal = 'Cannot make a visible window modal';
  static const SScrollBarRange = 'Scrollbar property out of range';
  
  static const SMenuIndexError = 'Menu index out of range';
  static const SMenuReinserted = 'Menu inserted twice';
  static const SMenuNotFound = 'Sub-menu is not in menu';
  
  static const SGroupIndexTooLow = 'GroupIndex cannot be less than a previous menu item\'s GroupIndex';
  
  static const SControlParentSetToSelf = 'A control cannot have itself as its parent';

  static const SGridTooLarge = 'Grid too large for operation';
  static const STooManyDeleted = 'Too many rows or columns deleted';
  static const SIndexOutOfRange = 'Grid index out of range';
  static const SFixedColTooBig = 'Fixed column count must be less than column count';
  static const SFixedRowTooBig = 'Fixed row count must be less than row count';


  static const SDateEncodeError = 'Invalid argument to date encode';

  static const SInsertLineError = 'Unable to insert a line';


  static const SDuplicateMenus = 'Menu \'%s\' is already being used by another form';


}