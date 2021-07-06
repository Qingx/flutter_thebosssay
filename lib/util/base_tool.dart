import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class BaseTool {
  static bool eq(double num1, double num2) {
    return (num1 - num2).abs() <= 0.000005;
  }

  static void toast({String msg}) {
    Fluttertoast.showToast(msg: msg);
  }

  static final _uuid = Uuid();

  static String createTempId() {
    String uuid = _uuid.v4().replaceAll(RegExp(r'-'), "");
    return "temp$uuid";
  }
}
