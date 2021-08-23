import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';

class BaseEmpty {
  static UserEntity emptyUser = UserEntity()
    ..avatar = ""
    ..deviceId = ""
    ..id = ""
    ..nickName = ""
    ..phone = ""
    ..collectNum = -1
    ..readNum = -1
    ..traceNum = -1
    ..type = "0"
    ..wxHead = ""
    ..wxName = ""
    ..tags = [];

  static BossLabelEntity emptyLabel = BossLabelEntity()
    ..id = "-1"
    ..name = "全部";
}
