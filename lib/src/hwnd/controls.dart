part of vcl;

class HFlexBox extends HControl
{
  static final FLEXBOX = CLASS_ID('FLEXBOX');
  CLASS_ID get classID => FLEXBOX;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      'background: #cccccc;'
      'whiteSpace: nowrap;'
      'overflow: hidden;'
      'userSelect: none;');
  }

  HFlexBox() : super( DivElement() );
}

class HPanel extends HControl
{
  static final PANEL = CLASS_ID('PANEL');
  CLASS_ID get classID => PANEL;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      'background: #cccccc;'
      'whiteSpace: nowrap;'
      'overflow: hidden;'
      'text-overflow: ellipsis;'
      'userSelect: none;');
//        style.textAlign = 'center';
    rule.addRule('.${ classID }.text',
      'text-align:center; padding: 0 5px;');
  }

  HPanel() : super( DivElement() );
}