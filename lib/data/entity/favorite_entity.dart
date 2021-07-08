import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class FavoriteEntity with JsonConvert<FavoriteEntity> {
  int count; //资源数量
  int createTime; //创建时间
  String id;
  List<ArticleEntity> list = [];
  String name; //收藏夹名字
  String userId; //用户id
}
