part of vcl;

class HFlexBand extends HControl
{
  static final FLEXBAND = CLASS_ID('FLEXBAND');
  CLASS_ID get classID => FLEXBAND;

  HFlexBand() : super( DivElement() );
}

class HPanel extends HControl
{
  static final PANEL = CLASS_ID('PANEL');
  CLASS_ID get classID => PANEL;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.block }${ rule.borderBox }'
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