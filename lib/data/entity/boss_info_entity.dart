import 'dart:convert' as convert;

import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BossInfoEntity with JsonConvert<BossInfoEntity> {
  String id;
  String name; //boss名
  String head = ""; //boss头像
  String role; //boss角色, 职务
  String info; //boss描述
  int date; //生日
  bool isCollect = false; //是否追踪
  bool isPoint = false; //是否点赞
  bool deleted = false; //是否被删除
  bool guide = false; //是否被推荐
  int point; //点赞数
  int collect; //收藏数
  int updateCount; //更新数量
  int totalCount; //发布文章总数
  int readCount; //阅读数
  int updateTime; //上次更新时间
  int createTime; //创建时间
  List<String> labels = []; //标签

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'head': head,
      'role': role,
      'info': info,
      'date': date,
      'isCollect': isCollect ? 1 : 0,
      'isPoint': isPoint ? 1 : 0,
      'deleted': deleted ? 1 : 0,
      'guide': guide ? 1 : 0,
      'point': point,
      'collect': collect,
      'updateCount': updateCount,
      'totalCount': totalCount,
      'readCount': readCount,
      'updateTime': updateTime,
      'createTime': createTime,
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
      ..date = json["date"]
      ..isCollect = json["isCollect"] == 1
      ..isPoint = json["isPoint"] == 1
      ..deleted = json["deleted"] == 1
      ..guide = json["guide"] == 1
      ..point = json["point"]
      ..collect = json["collect"]
      ..updateCount = json["updateCount"]
      ..totalCount = json["totalCount"]
      ..readCount = json["readCount"]
      ..updateTime = json["updateTime"]
      ..createTime = json["createTime"]
      ..labels = (convert.json.decode(json["labels"]) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
  }

  @override
  String toString() {
    return 'BossInfoEntity{id: $id, name: $name, head: $head, role: $role, info: $info, date: $date, isCollect: $isCollect, isPoint: $isPoint, deleted: $deleted, point: $point, collect: $collect, updateCount: $updateCount, totalCount: $totalCount, readCount: $readCount, updateTime: $updateTime, createTime: $createTime}';
  }
}
