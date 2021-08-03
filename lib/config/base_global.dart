import 'package:event_bus/event_bus.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class Global {
  static String versionCode = "1.0.7";
  static String build = "+2";
  static UserController user = UserController();
  static HintController hint = HintController();
  static EventBus eventBus = EventBus();
  static JPush jPush = JPush();
  static String shareUrl = "http://index.tianjiemedia.com/";
}
