import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class TestBossInfoEntity with JsonConvert<TestBossInfoEntity>{
  int size;
  int pages;
  int total;
  int current;
  bool searchCount = false;

  List<BossInfoEntity> records;
}