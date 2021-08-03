import 'dart:convert' as convert;

import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BossInfoEntity with JsonConvert<BossInfoEntity> {
  String id;
  String name; //boss名
  String head = ""; //boss头像
  String role; //boss角色, 职务
  String info; //boss描述
  bool top = false; //是否置顶
  bool isCollect = false; //是否追踪
  bool deleted = false; //是否被删除
  bool guide = false; //是否被推荐
  int readCount = 0; //阅读数
  int collect = 0; //收藏数
  int updateCount = 0; //更新数量
  int totalCount = 0; //发布文章总数
  int updateTime; //上次更新时间
  List<String> labels = []; //标签

  @override
  String toString() {
    return 'BossInfoEntity{id: $id, name: $name, head: $head, role: $role, info: $info, top: $top, isCollect: $isCollect, deleted: $deleted, guide: $guide, readCount: $readCount, collect: $collect, updateCount: $updateCount, totalCount: $totalCount, updateTime: $updateTime, labels: $labels}';
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
