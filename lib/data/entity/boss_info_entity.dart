import 'dart:convert' as convert;

import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BossInfoEntity with JsonConvert<BossInfoEntity> {
  String id;
  String name; //boss名
  String head = ""; //boss头像
  String role; //boss角色, 职务
  String info; //boss描述
  bool isCollect = false; //是否追踪
  bool deleted = false; //是否被删除
  bool guide = false; //是否被推荐
  int readCount = 0; //阅读数
  int collect = 0; //收藏数
  int updateCount = 0; //更新数量
  int totalCount = 0; //发布文章总数
  int updateTime; //上次更新时间
  List<String> labels = []; //标签

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'head': head,
      'role': role,
      'info': info,
      'isCollect': isCollect ? 1 : 0,
      'deleted': deleted ? 1 : 0,
      'guide': guide ? 1 : 0,
      'readCount': readCount,
      'collect': collect,
      'updateCount': updateCount,
      'totalCount': totalCount,
      'updateTime': updateTime,
      'labels': convert.json.encode(labels)
    };
  }

  BossInfoEntity toBean(Map<String, dynamic> json) {
    return BossInfoEntity()
      ..id = json["id"]
      ..name = json["name"]
      ..head = json["head"]
      ..role = json["role"]
      ..info = json["info"]
      ..isCollect = json["isCollect"] == 1
      ..deleted = json["deleted"] == 1
      ..guide = json["guide"] == 1
      ..readCount = json["readCount"]
      ..collect = json["collect"]
      ..updateCount = json["updateCount"]
      ..totalCount = json["totalCount"]
      ..updateTime = json["updateTime"]
      ..labels = (convert.json.decode(json["labels"]) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
  }

  @override
  String toString() {
    return 'BossInfoEntity{id: $id, name: $name, head: $head, role: $role, info: $info, isCollect: $isCollect, deleted: $deleted, guide: $guide, readCount: $readCount, collect: $collect, updateCount: $updateCount, totalCount: $totalCount, updateTime: $updateTime, labels: $labels}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossInfoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
