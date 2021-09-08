import 'package:event_bus/event_bus.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/user_controller.dart';

class Global {
  static String versionName = "1.0.15";
  static String build = "+1";
  static UserController user = UserController()..user;
  static HintController hint = HintController();
  static EventBus eventBus = EventBus();
  static String shareUrl = "http://index.tianjiemedia.com/";
}
