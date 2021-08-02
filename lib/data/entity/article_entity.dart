import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class ArticleEntity with JsonConvert<ArticleEntity> {
  String id; //id
  String bossId; //bossId
  String title; //标题
  String descContent = ""; //摘要
  bool isCollect; //是否收藏
  bool isPoint; //是否点赞
  int point; //点赞数
  int collect; //收藏数
  int releaseTime; //创建时间
  List<String> files = []; //图片列表
  BossInfoEntity bossVO;

  @override
  String toString() {
    return 'ArticleEntity{id: $id, bossId: $bossId, title: $title, descContent: $descContent, isCollect: $isCollect, isPoint: $isPoint, point: $point, collect: $collect, releaseTime: $releaseTime, files: $files, bossVO: $bossVO}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
