import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
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

  ///获取boss最近更新文章时间
  static String getUpdateTime(int startTime) {
    int endTime = DateTime
        .now()
        .millisecondsSinceEpoch;

    if (endTime >= startTime) {
      int diff = endTime - startTime;

      int days = diff ~/ (1000 * 60 * 60 * 24);
      int hours = diff ~/ (1000 * 60 * 60);
      int minutes = diff ~/ (1000 * 60);
      int seconds = diff ~/ 1000;

      if (days > 0) {
        return "$days天前更新";
      } else if (hours > 0) {
        return "最近$hours小时更新";
      } else if (minutes > 0) {
        return "$minutes分钟前更新";
      } else {
        return "$seconds秒前更新";
      }
    } else {
      return "时间戳异常";
    }
  }

  Future<bool> isWeChatInstalled() {
    return fluwx.isWeChatInstalled;
  }
}
