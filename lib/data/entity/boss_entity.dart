import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BossEntity with JsonConvert<BossEntity> {
  int current;
  bool hitCount;
  int pages;
  List<BossInfoEntity> records = [];
  bool searchCount;
  int size;
  int total;
}
