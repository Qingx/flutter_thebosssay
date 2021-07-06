import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/config/page_data.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:rxdart/rxdart.dart';

class BossApi extends BaseApi {
  BossApi._();

  static BossApi _mIns;

  factory BossApi.ins() => _mIns ??= BossApi._();

  ///引导页boss列表
  Observable<BossEntity> obtainGuideBoss() {
    var data = {"page": 1, "pageSize": 12};
    return post<BossEntity>("/api/boss/recommend", requestBody: data).rebase();
  }

  ///收藏单个boss
  Observable<bool> obtainFollowBoss(String id) {
    var data = {"sourceId": id, "type": 1, "target": true};
    return post<bool>("/api/boss/options", requestBody: data).success();
  }

  ///引导页收藏多个boss
  Observable<bool> obtainGuideFollowList(List<String> ids) {
    var data = {"sourceIds": ids, "type": 1, "target": true, "forced": true};
    return post<bool>("/api/boss/options", requestBody: data).success();
  }

  ///取消收藏boss
  Observable<bool> obtainNoFollowBoss(String id) {
    var data = {"sourceId": id, "type": 1, "target": false};
    return post<bool>("/api/boss/options", requestBody: data).success();
  }

  ///已关注的最近更新的boss列表
  Observable<List<BossInfoEntity>> obtainLatestBoss() {
    return get<List<BossInfoEntity>>("/api/boss/nearby-update").rebase();
  }

  ///获取追踪 最近更新文章
  Observable<Page<ArticleEntity>> obtainFollowArticle(PageParam pageParam) {
    final param = pageParam.toParam();
    return postPage<ArticleEntity>("/api/article/recommend", requestBody: param)
        .rebase(pageParam: pageParam);
  }
}
