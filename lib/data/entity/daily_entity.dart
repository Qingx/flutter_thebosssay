import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class DailyEntity with JsonConvert<DailyEntity> {
  String id;
  String bossHead;
  String bossName;
  String bossRole;
  String content;
  int createTime;
  bool isCollect;
  bool isPoint;

  @override
  String toString() {
    return 'DailyEntity{id: $id, bossHead: $bossHead, bossName: $bossName, bossRole: $bossRole, content: $content, createTime: $createTime, isCollect: $isCollect, isPoint: $isPoint}';
  }
}
