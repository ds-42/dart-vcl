part of vcl;

class HStatusBar extends HControl
{
  static final STATUSBAR = CLASS_ID('STATUSBAR');
  CLASS_ID get classID => STATUSBAR;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.flex }'
      '${ rule.borderBox }');
  }

  HStatusBar() : super( DivElement() );

}

class HStatusPanel extends HControl
{
  static final STATUSPANEL = CLASS_ID('STATUSPANEL');
  CLASS_ID get classID => STATUSPANEL;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.borderBox }'
      '${ rule.no_select }'
      'border: 1px inset;'
      'margin-top: 1px;'
      'margin-right: 3px;'
      'padding: 1px 2px;'
      'overflow: hidden');
  }

  HStatusPanel() : super( DivElement() );

}