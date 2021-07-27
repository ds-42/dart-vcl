part of vcl;

class HGroupBox extends HControl
{
  static final GROUPBOX = CLASS_ID('GROUPBOX');
  CLASS_ID get classID => GROUPBOX;

  void defineClassRule(TWndStyle rule)
  {
    rule.add('',
      'position: absolute;'
      'box-sizing: border-box;'
      'border: 2px groove;'
      'overflow:hidden;'
      'margin:0;'
      'padding:5px;');
    rule.add('legend',
      'user-select:none;'
      'padding:0px 3px;');
  }


  final legend = LegendElement();
  final client = DivElement();

  Element getClientHandle() => client;

  HGroupBox() : super( FieldSetElement() )
  {
    handle.append(legend);
    handle.append(client);

    client.style
      ..position='absolute'
      ..left = '0'
      ..top = '5px'
      ..right = '0'
      ..bottom = '0';


  }
}
