import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'dart:convert' as convert;

class BossSimpleEntity with JsonConvert<BossSimpleEntity> {
  String id;
  String name; //boss名
  String head = ""; //boss头像
  String role; //boss角色, 职务
  bool top = false; //是否置顶
  int updateTime; //上次更新时间
  List<String> labels = []; //标签
  List<String> photoUrl = []; //标签图片

  BossSimpleEntity(
      {this.id,
      this.name,
      this.head,
      this.role,
      this.top,
      this.updateTime,
      this.labels,
      this.photoUrl});

  int getSort() {
    return updateTime + (top ? BaseTool.TwentyYears : 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'head': head,
      'role': role,
      'top': top ? 1 : 0,
      'updateTime': updateTime,
      'labels': convert.json.encode(labels),
      'photoUrl': convert.json.encode(photoUrl)
    };
  }

  static BossSimpleEntity toBean(Map<String, dynamic> json) {
    return BossSimpleEntity()
      ..id = json["id"]
      ..name = json["name"]
      ..head = json["head"]
      ..role = json["role"]
      ..top = json["top"] == 1
      ..updateTime = json["updateTime"]
      ..labels = (convert.json.decode(json["labels"]) as List<dynamic>)
          .map((e) => e.toString())
          .toList()
      ..photoUrl = (convert.json.decode(json["photoUrl"]) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
  }

  @override
  String toString() {
    return 'BossSimpleEntity{id: $id, name: $name, head: $head, role: $role, top: $top, updateTime: $updateTime, labels: $labels, photoUrl: $photoUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossSimpleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
