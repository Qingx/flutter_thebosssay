import 'package:flutter_boss_says/data/entity/daily_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class HisFavEntity with JsonConvert<HisFavEntity> {
  String id;
  String articleId = "";
  String content = ""; //title
  String bossHead = "";
  String bossName = "";
  int createTime;
  String articleType; //1:言论 2:咨询
  String type; //1:文章 2:每日一言
  bool hidden = false; //boss是否隐藏
  String bossRole; //boss描述
  bool isCollect = false; //是否收藏
  bool isPoint = false; //是否点赞
  String cover = "";

  DailyEntity toDaily() {
    return DailyEntity()
      ..id = articleId
      ..bossHead = bossHead
      ..bossName = bossName
      ..bossRole = bossRole
      ..content = content
      ..createTime = createTime
      ..isCollect = isCollect
      ..isPoint = isPoint;
  }

  @override
  String toString() {
    return 'HisFavEntity{id: $id, articleId: $articleId, content: $content, bossHead: $bossHead, bossName: $bossName, createTime: $createTime, articleType: $articleType, type: $type, hidden: $hidden, bossRole: $bossRole, isCollect: $isCollect, isPoint: $isPoint, cover: $cover}';
  }
}
