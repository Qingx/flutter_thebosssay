import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';

class BaseEmpty {
  static UserEntity emptyUser = UserEntity()..type = "0";
  static BossLabelEntity emptyLabel = BossLabelEntity()..id = "-1";
}
