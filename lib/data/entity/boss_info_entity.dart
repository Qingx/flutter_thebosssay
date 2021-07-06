import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BossInfoEntity with JsonConvert<BossInfoEntity> {
  int collect; //收藏数
  int createTime; //创建时间
  int date; //生日
  String head; //boss头像
  String id;
  String info; //boss描述
  bool isCollect; //是否收藏
  bool isPoint; //是否点赞
  String name; //boss名
  int point; //点赞数
  String role; //boss角色, 职务
  int updateCount; //更新数量

  @override
  String toString() {
    return 'BossInfoEntity{collect: $collect, createTime: $createTime, date: $date, head: $head, id: $id, info: $info, isCollect: $isCollect, isPoint: $isPoint, name: $name, point: $point, role: $role, updateCount: $updateCount}';
  }
}
