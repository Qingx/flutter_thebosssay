import 'package:event_bus/event_bus.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class Global {
  static UserController user = UserController();
  static HintController hint = HintController();
  static EventBus eventBus = EventBus();
  static JPush jPush = JPush();
  static String hintText = "请输入内容";
  static String version = "1.0.2";
}
