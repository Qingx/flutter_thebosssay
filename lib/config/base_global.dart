import 'package:event_bus/event_bus.dart';
import 'package:flutter_boss_says/config/user_controller.dart';

class Global {
  static UserController user = UserController();
  static EventBus eventBus = EventBus();
}
