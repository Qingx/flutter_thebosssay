// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:rxdart/rxdart.dart';

void main() {
  var tt = Observable.defer((){
    print('test xxx');
    return Observable.just(1);
  });

  tt.listen((event) {
    print('test 1 => $event');
  });
  tt.listen((event) {
    print('test 2 => $event');
  });
}
