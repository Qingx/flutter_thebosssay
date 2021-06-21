import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var user = UserEntity().obs;

  setUser(UserEntity entity) {
    user.firstRebuild = true;
    user.value = entity;

    update();
  }
}
