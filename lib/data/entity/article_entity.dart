import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class ArticleEntity with JsonConvert<ArticleEntity> {
  String bossId; //bossId
  BossInfoEntity bossVO;
  String content; //内容
  int createTime; //创建时间
  String descContent; //摘要
  List<String> files = []; //图片列表
  String id; //id
  bool isCollect; //是否收藏
  bool isPoint; //是否点赞
  int point; //点赞数
  int collect; //收藏数
  int status; //审核状态
  String title; //标题

}
