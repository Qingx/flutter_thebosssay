import 'dart:convert' as convert;

import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class ArticleSimpleEntity with JsonConvert<ArticleSimpleEntity> {
  String id; //id
  String title; //标题
  String descContent = ""; //摘要
  bool isCollect; //是否收藏
  bool isRead = false; //是否已读
  int readCount = 0; //阅读数
  int collect = 0; //收藏数
  int releaseTime = 0; //发布时间
  int articleTime = 0; //文章时间
  List<String> files = []; //图片列表
  String bossId; //bossId
  String bossName; //boss名
  String bossHead = ""; //boss头像
  String bossRole; //boss角色, 职务

  int getShowTime() {
    return articleTime ?? releaseTime;
  }

  @override
  String toString() {
    return 'ArticleSimpleEntity{id: $id, title: $title, descContent: $descContent, isCollect: $isCollect, isRead: $isRead, readCount: $readCount, collect: $collect, releaseTime: $releaseTime, articleTime: $articleTime, files: $files, bossId: $bossId, bossName: $bossName, bossHead: $bossHead, bossRole: $bossRole}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? "",
      'title': title ?? "",
      'descContent': descContent ?? "",
      'isCollect': isCollect ? "1" : "0",
      'isRead': isRead ? "1" : "0",
      'readCount': readCount ?? 0,
      'collect': collect ?? 0,
      'releaseTime': releaseTime ?? 0,
      'articleTime': articleTime ?? 0,
      'bossId': bossId ?? "",
      'bossName': bossName ?? "",
      'bossHead': bossHead ?? "",
      'bossRole': bossRole ?? "",
      'files': files.isNullOrEmpty() ? "empty" : convert.json.encode(files)
    };
  }

  static ArticleSimpleEntity toBean(Map<String, dynamic> json) {
    return ArticleSimpleEntity()
      ..id = json["id"]
      ..title = json["title"]
      ..descContent = json["descContent"]
      ..isCollect = json["isCollect"] == "1"
      ..isRead = json["isRead"] == "1"
      ..readCount = json["readCount"]
      ..collect = json["collect"]
      ..releaseTime = json["releaseTime"]
      ..articleTime = json["articleTime"]
      ..bossId = json["bossId"]
      ..bossName = json["bossName"]
      ..bossHead = json["bossHead"]
      ..bossRole = json["bossRole"]
      ..files = json["files"] == "empty"
          ? []
          : (convert.json.decode(json["files"]) as List<dynamic>)
              .map((e) => e.toString())
              .toList();
  }
}
