import 'package:event_bus/event_bus.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class Global {
  static UserController user = UserController();
  static EventBus eventBus = EventBus();
  static JPush jPush=JPush();
}
