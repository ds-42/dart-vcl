part of vcl;

class HInput extends HControl 
{
  static final INPUT = CLASS_ID('INPUT');
  CLASS_ID get classID => INPUT;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      '${ rule.softBorder }');
  }

  HInput() : super( InputElement() );
}

class HTextArea extends HControl 
{
  static final TEXTAREA = CLASS_ID('TEXTAREA');
  CLASS_ID get classID => TEXTAREA;

  void defineClassRule(TWndStyle rule)
  {
    rule.addFocusStyle();
    rule.add('',
      '${ rule.block }'
      '${ rule.borderBox }'
      '${ rule.softBorder }'
      'resize: none;');
  }

  HTextArea() : super( TextAreaElement() );

  bool
    get wrap => (handle as TextAreaElement).wrap != 'off';
    set wrap(bool state) {
      (handle as TextAreaElement).wrap = state? 'soft' : 'off';
    }

}

class HSelect extends HControl 
{
  static final SELECT = CLASS_ID('SELECT');
  CLASS_ID get classID => SELECT;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      '${ rule.block }');
    rule.add('option',
      'user-select: none;');

  }

  HSelect() : super( SelectElement() );
}

class HDateTimePick extends HControl 
{
  static final DATETIMEPICK = CLASS_ID('DATETIMEPICK');
  CLASS_ID get classID => DATETIMEPICK;

  HDateTimePick() : super( InputElement() )
  {
    (handle as InputElement).type = 'datetime-local';
  }
}

