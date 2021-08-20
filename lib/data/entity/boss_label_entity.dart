import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BossLabelEntity with JsonConvert<BossLabelEntity> {
  String id;
  String name;

  @override
  String toString() {
    return 'BossLabelEntity{id: $id, name: $name}';
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  static BossLabelEntity toBean(Map<String, dynamic> json) {
    return BossLabelEntity()
      ..id = json["id"]
      ..name = json["name"];
  }
}
