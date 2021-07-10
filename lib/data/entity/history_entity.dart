import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class HistoryEntity with JsonConvert<HistoryEntity> {
  String articleId;
  String articleTitle;
  String bossHead;
  String bossName;
  String id;
  int updateTime;
}
