import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/config/page_data.dart';

import 'package:flutter_boss_says/data/model/article_simple_entity.dart';

class BaseEmpty {
  static UserEntity emptyUser = UserEntity()
    ..avatar = ""
    ..deviceId = ""
    ..id = ""
    ..nickName = ""
    ..phone = ""
    ..collectNum = -1
    ..readNum = -1
    ..traceNum = -1
    ..type = "0"
    ..wxHead = ""
    ..wxName = ""
    ..tags = [];

  static BossLabelEntity emptyLabel = BossLabelEntity()
    ..id = "-1"
    ..name = "全部";

  static Page<ArticleSimpleEntity> emptyArticle = Page<ArticleSimpleEntity>(
      size: 10,
      pages: 0,
      total: 0,
      current: 0,
      searchCount: false,
      records: []);
}
