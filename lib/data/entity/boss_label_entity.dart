import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BossLabelEntity with JsonConvert<BossLabelEntity> {
  int createTime; //创建时间
  String id;
  String keyValue; //自定义标记
  String name; //名称
  String parentId; //归属父id
  int sort; //排序标记
  int type;

  @override
  String toString() {
    return 'BossLabelEntity{createTime: $createTime, id: $id, keyValue: $keyValue, name: $name, parentId: $parentId, sort: $sort, type: $type}';
  } //字典类型
}
