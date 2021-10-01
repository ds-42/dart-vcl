# dart-vcl

Dart implementation of vcl interface C++Builder, Delphi for web application

## ChangeLog

[ChangeLog.md](CHANGELOG.md)

## About
If you now the programming languages of C++ Builder or Delphi, 
with the help of this library you can start creating web applications 
in the Dart with the familiar interface and Borland components. 

The library is based on the original sources of Borland components. 
This will allow you to use properties such as Align, Anchors, Object-events 
when designing dialog forms. 

HTML elements are used as an alternative to HWND - descriptors (Handle). 
As in windows, communication between windows is carried out using messages.

To create forms, the components TEdit, TComboBox, TPanel, TPageControl, TEdit, 
TCheckBox and others are implemented. 
Implemented components TDataSource, TDataSet, TDataLink, TDBGrid for working with databases 

Added flex component for flexible adjustment of the position of controls in dialog forms

**Warning.** The library was tested only in the browser Google Chrome

### Example

```dart
import 'package:vcl/vcl.dart';

void main() async 
{
  var form = TForm(Application);
  form.Position = TPosition.ScreenCenter;
  await form.ShowModal();
}
```
### Demo

Press [link](http://dart-vcl.delasoft.org/) for demo application or download last version [files](https://github.com/ds-42/dart-vcl/tree/main/demo) and open *index.html* in Google Chrome browser

[Source files](https://github.com/ds-42/dart-vcl/tree/main/example/form) of demo project 

### For example, my projects

- [Editor](http://editor.delasoft.org/)
- [Seniority calculator](http://cexp.delasoft.org/)
