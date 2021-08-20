import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'dart:convert' as convert;

class ArticleSimpleEntity with JsonConvert<ArticleSimpleEntity> {
  String id; //id
  String title; //标题
  String descContent = ""; //摘要
  bool isCollect = false; //是否收藏
  bool isRead = false; //是否已读
  int readCount = 0; //阅读数
  int collect = 0; //收藏数
  int releaseTime; //发布时间
  int articleTime; //文章时间
  List<String> files = []; //图片列表
  BossSimpleEntity bossVO;

  int getShowTime() {
    return articleTime ?? releaseTime;
  }

  @override
  String toString() {
    return 'ArticleSimpleEntity{id: $id, title: $title, descContent: $descContent, isCollect: $isCollect, isRead: $isRead, readCount: $readCount, collect: $collect, releaseTime: $releaseTime, articleTime: $articleTime, files: $files, bossVO: $bossVO}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'descContent': descContent,
      'isCollect': isCollect ? 1 : 0,
      'isRead': isRead ? 1 : 0,
      'readCount': readCount,
      'releaseTime': releaseTime,
      'articleTime': articleTime,
      'files': convert.json.encode(files),
      'bossVO': convert.json.encode(bossVO.toMap())
    };
  }

  static ArticleSimpleEntity toBean(Map<String, dynamic> json) {
    return ArticleSimpleEntity()
      ..id = json["id"]
      ..title = json["title"]
      ..descContent = json["descContent"]
      ..isCollect = json["isCollect"] == 1
      ..isRead = json["isRead"] == 1
      ..readCount = json["readCount"]
      ..releaseTime = json["releaseTime"]
      ..articleTime = json["articleTime"]
      ..files = (convert.json.decode(json["files"]) as List<dynamic>)
          .map((e) => e.toString())
          .toList()
      ..bossVO = BossSimpleEntity.toBean(
          convert.json.decode(json["bossVO"]) as Map<String, dynamic>);
  }
}
