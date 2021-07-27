part of vcl;

class HLabel extends HControl
{
  static final LABEL = CLASS_ID('LABEL');
  CLASS_ID get classID => LABEL;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
        '${ rule.block }'
        '${ rule.inline }'
        '${ rule.no_select }');
  }

  HLabel() : super( LabelElement() );
}

class HHint extends HComponent
{
  static final HINT = CLASS_ID('HINT');
  CLASS_ID get classID => HINT;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
        '${ rule.block }${ rule.font }'
        'padding: 2px; border: 1px outset;'
        'box-shadow: 1px 1px 3px rgba(0,0,0,.25);'
        'box-sizing: border-box;'
        'animation: showBlock 150ms linear;'
        'text-align: center;'
        'background-color: ${ clInfoBk.html };');
    rule.addRule('@keyframes showBlock',
        '0% { opacity: 0; } ');
  }

  HHint() : super( DivElement() );
}