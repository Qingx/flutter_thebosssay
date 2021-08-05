import 'package:event_bus/event_bus.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/user_controller.dart';

class Global {
  static String versionCode = "1.0.7";
  static String build = "+3";
  static UserController user = UserController();
  static HintController hint = HintController();
  static EventBus eventBus = EventBus();
  static String shareUrl = "http://index.tianjiemedia.com/";
}
