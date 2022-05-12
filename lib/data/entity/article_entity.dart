import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'package:flutter_boss_says/util/base_tool.dart';

class ArticleEntity with JsonConvert<ArticleEntity> {
  String id; //id
  String bossId; //bossId
  String title; //标题
  String descContent = ""; //摘要
  bool isCollect; //是否收藏
  bool isRead = false; //是否已读
  bool isPoint = false; //是否点赞
  int readCount = 0; //阅读数
  int collect = 0; //收藏数
  int point = 0; //点赞数
  int releaseTime; //发布时间
  int articleTime; //文章时间
  List<String> files = []; //图片列表
  BossInfoEntity bossVO;
  bool hidden = false;
  String filterType;

  int getShowTime() {
    return releaseTime ?? articleTime;
  }

  bool isLatest() {
    return BaseTool.inThreeDays(getShowTime()) && !isRead;
  }

  bool inThreeDays() {
    return BaseTool.inThreeDays(getShowTime());
  }

  @override
  String toString() {
    return 'ArticleEntity{id: $id, bossId: $bossId, title: $title, descContent: $descContent, isCollect: $isCollect, isRead: $isRead, isPoint: $isPoint, readCount: $readCount, collect: $collect, point: $point, releaseTime: $releaseTime, articleTime: $articleTime, files: $files, bossVO: $bossVO, hidden: $hidden, filterType: $filterType}';
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
