import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class GuidBossEntity with JsonConvert<GuidBossEntity>{
  String id;
  String name;
  String role;
  String head;

  @override
  String toString() {
    return 'GuidBossEntity{id: $id, name: $name, role: $role, head: $head}';
  }
}