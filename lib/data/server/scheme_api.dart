import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

class SchemeApi {
  SchemeApi._();

  static SchemeApi _mIns;

  factory SchemeApi.ins() => _mIns ??= SchemeApi._();

  void test() {
    getInitialLink().then((value) {
      print('getInitialLink=>$value');
    });
  }

}
