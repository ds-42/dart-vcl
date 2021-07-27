part of vcl;

class HGrid extends HScrollControl
{
  static final GRID = CLASS_ID('GRID');
  CLASS_ID get classID => GRID;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
        'border: 1px solid #808080;'
        'background: white;'
        'box-sizing: border-box;'
        'user-select: none;');
    rule.add('table',
        'border-collapse: collapse;'
        'outline: none;');
    rule.add('td, th',
        'background: white;'
        'margin: 0px;'
        'padding: 0px;'
        'border-right: 1px solid #c0c0c0;'
        'border-bottom: 1px solid #c0c0c0;'
        'box-sizing: border-box;');
    rule.addRule('.fixed_cell .cell_p',
        'text-overflow: ellipsis');
    rule.add('.fixed_cell',
        'background: #eee no-repeat;'
        'background-image: linear-gradient(#aaa, #ddd);'
        'background-position: 1px 1px;'
        'border-right: 1px solid #808080;'
        'border-bottom: 1px solid #808080;');
    rule.add('.cell',
        'background: white;');
    rule.add('.cell_p',
        'overflow: hidden;'
        'margin: 0px;'
        'padding: 2px;'
        'white-space: nowrap;'
        'box-sizing: border-box;');
  }

  final table = TableElement();
  final body = Element.tag('tbody') as TableSectionElement;

  Element getClientHandle() => table;

  HGrid() : super()
  {
    handle.style
      ..overflow='hidden'
      ..position='absolute'
      ..width='320px'
      ..height='120px';

    table.style.tableLayout = 'fixed';
    table.tabIndex=0;

    client.tabIndex=0;
    client.style.outline='none';

    HWND hTable = HWND(table);
    hTable.props << WindowProp.ChildOwner; // for get messages of table elements
    client.append(table);

    table.children.add(body);

    client.owner = this;
    table.owner = this;

  }
}
