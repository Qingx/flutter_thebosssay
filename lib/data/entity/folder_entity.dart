import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class FolderEntity with JsonConvert<FolderEntity> {
  String id;
  String name;
  String cover = "";
  int articleCount = 0;
  int bossCount = 0;
  int createTime;

  @override
  String toString() {
    return 'FolderEntity{id: $id, name: $name, cover: $cover, articleCount: $articleCount, bossCount: $bossCount, createTime: $createTime}';
  }
}
