import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'dart:convert' as convert;

class ArticleEntity with JsonConvert<ArticleEntity> {
  String id; //id
  String bossId; //bossId
  String title; //标题
  String content; //内容
  String descContent; //摘要
  bool isCollect; //是否收藏
  bool isPoint; //是否点赞
  int point; //点赞数
  int collect; //收藏数
  int createTime; //创建时间
  int status; //审核状态
  List<String> files = []; //图片列表
  BossInfoEntity bossVO;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bossId': bossId,
      'title': title,
      'content': content,
      'descContent': descContent,
      'isCollect': isCollect ? 1 : 0,
      'isPoint': isPoint ? 1 : 0,
      'point': point,
      'collect': collect,
      'createTime': createTime,
      'status': status,
      'files': convert.json.encode(files)
    };
  }

  ArticleEntity toBean(Map<String, dynamic> json) {
    return ArticleEntity()
      ..id = json["id"]
      ..bossId = json["bossId"]
      ..title = json["title"]
      ..content = json["content"]
      ..descContent = json["descContent"]
      ..isCollect = json["isCollect"] == 1
      ..isPoint = json["isPoint"] == 1
      ..point = json["point"]
      ..collect = json["collect"]
      ..createTime = json["createTime"]
      ..status = json["status"]
      ..files = (convert.json.decode(json["files"] ?? []) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
  }

  @override
  String toString() {
    return 'ArticleEntity{id: $id, bossId: $bossId, title: $title, content: $content, descContent: $descContent, files: $files, isCollect: $isCollect, isPoint: $isPoint, point: $point, collect: $collect, createTime: $createTime, status: $status, bossVO: $bossVO}';
  }
}
