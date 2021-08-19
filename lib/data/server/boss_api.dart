import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/config/page_data.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/banner_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/guide_boss_entity.dart';
import 'package:rxdart/rxdart.dart';

class BossApi extends BaseApi {
  BossApi._();

  static BossApi _mIns;

  factory BossApi.ins() => _mIns ??= BossApi._();

  ///引导页boss列表
  Observable<List<GuidBossEntity>> obtainGuideBoss() {
    return autoToken(
        () => get<List<GuidBossEntity>>("/api/boss/guide").rebase());
  }

  ///追踪单个boss
  Observable<bool> obtainFollowBoss(String id) {
    var data = {"sourceId": id, "type": 1, "target": true};
    return autoToken(
        () => post<bool>("/api/boss/options", requestBody: data).success());
  }

  ///取消追踪boss
  Observable<bool> obtainNoFollowBoss(String id) {
    var data = {"sourceId": id, "type": 1, "target": false};
    return autoToken(
        () => post<bool>("/api/boss/options", requestBody: data).success());
  }

  ///引导页追踪多个boss
  Observable<bool> obtainGuideFollowList(List<String> ids) {
    var data = {"sourceIds": ids, "type": 1, "target": true, "forced": true};
    return autoToken(
        () => post<bool>("/api/boss/options", requestBody: data).success());
  }

  ///已追踪的boss列表 已追踪且有更新的boss列表
  Observable<List<BossInfoEntity>> obtainFollowBossList(
      String label, bool mustUpdate) {
    var data = {
      "labels": label == "-1" ? null : [label],
      "mustUpdate": mustUpdate
    };
    return autoToken(() =>
        post<List<BossInfoEntity>>("/api/boss/collected", requestBody: data)
            .rebase());
  }

  ///获取追踪 最近更新文章
  Observable<Page<ArticleEntity>> obtainFollowArticle(
      PageParam pageParam, String label) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {
        "labels": label == "-1" ? null : [label]
      };
      map.addAll(data);
    });

    return autoToken(() =>
        postPage<ArticleEntity>("/api/article/recommend", requestBody: param)
            .rebase(pageParam: pageParam)
            .map((value) {
          return value;
        }));
  }

  ///获取boss标签列表
  Observable<List<BossLabelEntity>> obtainBossLabels() {
    return autoToken(
        () => get<List<BossLabelEntity>>("/api/boss/labels").rebase());
  }

  ///获取boss列表
  Observable<List<BossInfoEntity>> obtainAllBossList() {
    return autoToken(
        () => get<List<BossInfoEntity>>("/api/boss/noPageList/").rebase());
  }

  ///搜索boss列表
  Observable<List<BossInfoEntity>> obtainAllBossSearchList(String search) {
    return autoToken(() =>
        get<List<BossInfoEntity>>("/api/boss/noPageList/?name=$search")
            .rebase());
  }

  ///获取boss的文章列表
  Observable<Page<ArticleEntity>> obtainBossArticleList(
      PageParam pageParam, String bossId) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {"bossId": bossId};
      map.addAll(data);
    });
    return autoToken(() =>
        postPage<ArticleEntity>("/api/article/list", requestBody: param)
            .rebase(pageParam: pageParam));
  }

  ///获取所有文章列表
  Observable<Page<ArticleEntity>> obtainAllArticle(
      PageParam pageParam, String label) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {
        "labels": label == "-1" ? null : [label]
      };
      map.addAll(data);
    });
    return autoToken(() =>
        postPage<ArticleEntity>("/api/article/list", requestBody: param)
            .rebase(pageParam: pageParam));
  }

  ///搜索boss
  Observable<Page<BossInfoEntity>> obtainSearchBossList(
      PageParam pageParam, String search) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {"name": search};
      map.addAll(data);
    });
    return autoToken(() =>
        postPage<BossInfoEntity>("/api/boss/list", requestBody: param)
            .rebase(pageParam: pageParam));
  }

  ///搜索文章
  Observable<Page<ArticleEntity>> obtainSearchArticleList(
      PageParam pageParam, String search) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {"name": search};
      map.addAll(data);
    });
    return autoToken(() =>
        postPage<ArticleEntity>("/api/article/list", requestBody: param)
            .rebase(pageParam: pageParam));
  }

  ///获取文章详情
  Observable<ArticleEntity> obtainArticleDetail(String id) {
    return autoToken(
        () => get<ArticleEntity>("/api/article/details/$id").rebase());
  }

  ///获取Boss详情
  Observable<BossInfoEntity> obtainBossDetail(String id) {
    return autoToken(
        () => get<BossInfoEntity>("/api/boss/details/$id").rebase());
  }

  ///获取全部Boss详情
  Observable<List<BossInfoEntity>> obtainAllBoss(int time) {
    return autoToken(
        () => get<List<BossInfoEntity>>("/api/boss/all-list/$time").rebase());
  }

  ///banner
  Observable<List<BannerEntity>> obtainBanner() {
    return autoToken(() =>
        get<List<BannerEntity>>("/api/operationPicture/get/banner").rebase());
  }
}
