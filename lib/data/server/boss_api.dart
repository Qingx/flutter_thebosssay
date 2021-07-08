import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/config/page_data.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
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

  ///追踪单个boss
  Observable<bool> obtainFollowBoss(String id) {
    var data = {"sourceId": id, "type": 1, "target": true};
    return post<bool>("/api/boss/options", requestBody: data).success();
  }

  ///取消追踪boss
  Observable<bool> obtainNoFollowBoss(String id) {
    var data = {"sourceId": id, "type": 1, "target": false};
    return post<bool>("/api/boss/options", requestBody: data).success();
  }

  ///引导页追踪多个boss
  Observable<bool> obtainGuideFollowList(List<String> ids) {
    var data = {"sourceIds": ids, "type": 1, "target": true, "forced": true};
    return post<bool>("/api/boss/options", requestBody: data).success();
  }

  ///已追踪的boss列表 已追踪且有更新的boss列表
  Observable<List<BossInfoEntity>> obtainFollowBossList(
      String label, bool mustUpdate) {
    var data = {
      "labels": label == "-1" ? null : [label],
      "mustUpdate": mustUpdate
    };
    return post<List<BossInfoEntity>>("/api/boss/collected", requestBody: data)
        .rebase();
  }

  ///获取追踪 最近更新文章
  Observable<Page<ArticleEntity>> obtainFollowArticle(PageParam pageParam) {
    final param = pageParam.toParam();
    return postPage<ArticleEntity>("/api/article/recommend", requestBody: param)
        .rebase(pageParam: pageParam);
  }

  ///获取boss标签列表
  Observable<List<BossLabelEntity>> obtainBossLabels() {
    return get<List<BossLabelEntity>>("/api/boss/labels").rebase();
  }

  ///获取boss列表
  Observable<Page<BossInfoEntity>> obtainAllBossList(
      PageParam pageParam, String label) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {
        "labels": label == "-1" ? null : [label]
      };
      map.addAll(data);
    });
    return postPage<BossInfoEntity>("/api/boss/list", requestBody: param)
        .rebase(pageParam: pageParam);
  }

  ///获取boss的文章列表
  Observable<Page<ArticleEntity>> obtainBossArticleList(
      PageParam pageParam, String bossId) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {"bossId": bossId};
      map.addAll(data);
    });
    return postPage<ArticleEntity>("/api/article/list", requestBody: param)
        .rebase(pageParam: pageParam);
  }
}
