import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/config/page_data.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/banner_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/daily_entity.dart';
import 'package:flutter_boss_says/data/entity/favorite_entity.dart';
import 'package:flutter_boss_says/data/entity/folder_entity.dart';
import 'package:flutter_boss_says/data/entity/guide_boss_entity.dart';
import 'package:flutter_boss_says/data/entity/his_fav_entity.dart';
import 'package:flutter_boss_says/data/entity/history_entity.dart';
import 'package:flutter_boss_says/data/entity/operation_entity.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:rxdart/rxdart.dart';

class AppApi extends BaseApi {
  AppApi._();

  static AppApi _mIns;

  factory AppApi.ins() => _mIns ??= AppApi._();

  ///引导页boss列表
  Observable<List<GuidBossEntity>> obtainGetGuideBossList() {
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
  Observable<bool> obtainCancelFollowBoss(String id) {
    var data = {"sourceId": id, "type": 1, "target": false};
    return autoToken(
        () => post<bool>("/api/boss/options", requestBody: data).success());
  }

  ///引导页追踪多个boss
  Observable<bool> obtainFollowBossList(List<String> ids) {
    var data = {"sourceIds": ids, "type": 1, "target": true, "forced": true};
    return autoToken(
        () => post<bool>("/api/boss/options", requestBody: data).success());
  }

  ///已追踪的全部boss列表
  Observable<List<BossSimpleEntity>> obtainGetAllFollowBoss(String label) {
    var data = {
      "labels": label == "-1" ? null : [label],
      "mustUpdate": false
    };
    return autoToken(() =>
        post<List<BossSimpleEntity>>("/api/boss/collected", requestBody: data)
            .rebase());
  }

  ///获取追踪 最近更新文章
  Observable<Page<ArticleSimpleEntity>> obtainGetTackArticleList(
      PageParam pageParam, String label) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {
        "labels": label == "-1" ? null : [label]
      };
      map.addAll(data);
    });
    var path = "/api/article/recommendArticle";
    path = "/api/article/recommendArticle/random";

    return autoToken(() =>
        postPage<ArticleSimpleEntity>(path, requestBody: param)
            .rebase(pageParam: pageParam)
            .map((value) {
          return value;
        }));
  }

  ///获取boss标签列表
  Observable<List<BossLabelEntity>> obtainGetLabelList() {
    return autoToken(
        () => get<List<BossLabelEntity>>("/api/boss/labels").rebase());
  }

  ///获取boss列表
  Observable<List<BossInfoEntity>> obtainGetAllBossList() {
    return autoToken(
        () => get<List<BossInfoEntity>>("/api/boss/noPageList/").rebase());
  }

  ///搜索boss列表
  Observable<List<BossInfoEntity>> obtainGetBossSearchList(String search) {
    return autoToken(() =>
        get<List<BossInfoEntity>>("/api/boss/noPageList/?name=$search")
            .rebase());
  }

  ///获取所有文章列表
  Observable<Page<ArticleEntity>> obtainGetAllArticleList(
      PageParam pageParam, String label) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {
        "labels": label == "-1" ? null : [label]
      };
      map.addAll(data);
    });
    var path = "/api/article/list/square";
    return autoToken(() => postPage<ArticleEntity>(path, requestBody: param)
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
  Observable<ArticleEntity> obtainGetArticleDetail(String id) {
    return autoToken(
        () => get<ArticleEntity>("/api/article/details/$id").rebase());
  }

  ///获取Boss详情
  Observable<BossInfoEntity> obtainGetBossDetail(String id) {
    return autoToken(
        () => get<BossInfoEntity>("/api/boss/details/$id").rebase());
  }

  ///banner
  Observable<List<BannerEntity>> obtainGetBanner() {
    return autoToken(() =>
        get<List<BannerEntity>>("/api/operationPicture/get/banner").rebase());
  }

  ///Boss文章
  Observable<Page<ArticleSimpleEntity>> obtainGetBossArticleList(
      PageParam pageParam, String bossId, String type) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {"bossId": bossId, "filterType": type};
      map.addAll(data);
    });
    return autoToken(
      () => postPage<ArticleSimpleEntity>("/api/article/list/page",
              requestBody: param)
          .rebase(pageParam: pageParam),
    );
  }

  ///每日一言
  Observable<DailyEntity> obtainGetDaily() {
    return autoToken(() => get<DailyEntity>("/api/speech/get-speech").rebase());
  }

  ///点赞每日一言 target true->点赞 false->取消点赞
  Observable<bool> obtainPointDaily(String id, bool target) {
    var data = {"sourceId": id, "type": 0, "target": target};
    return autoToken(
        () => post<bool>("/api/speech/options", requestBody: data).success());
  }

  ///收藏每日一言
  Observable<bool> obtainCollectDaily(String id, String groupId) {
    var data = {"groupId": groupId, "sourceId": id, "type": 1, "target": true};
    return autoToken(
        () => post<bool>("/api/speech/options", requestBody: data).success());
  }

  ///取消收藏每日一言
  Observable<bool> obtainCancelCollectDaily(String id) {
    var data = {"sourceId": id, "type": 1, "target": false};
    return autoToken(
        () => post<bool>("/api/speech/options", requestBody: data).success());
  }

  ///点赞记录列表 code 1：文章 2：每日一言
  Observable<Page<HisFavEntity>> obtainPointList(
      PageParam pageParam, String code) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {"type": code};
      map.addAll(data);
    });
    return autoToken(
      () => postPage<HisFavEntity>("/api/speech/point-history",
              requestBody: param)
          .rebase(pageParam: pageParam),
    );
  }

  ///获取用户收藏夹列表
  Observable<List<FolderEntity>> obtainCollectFolder() {
    return autoToken(
        () => get<List<FolderEntity>>("/api/collect/get-collet").rebase());
  }

  ///获取收藏夹文章列表
  Observable<Page<HisFavEntity>> obtainFolderArticle(
      PageParam pageParam, String id, String articleId) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {
        "collectId": id,
        "articleId": articleId,
      };
      map.addAll(data);
    });
    return autoToken(() =>
        postPage<HisFavEntity>("/api/collect/list-collet", requestBody: param)
            .rebase(pageParam: pageParam));
  }

  ///创建收藏夹
  Observable<FavoriteEntity> obtainCreateFavorite(String name) {
    var data = {"name": name};
    return autoToken(() =>
        post<FavoriteEntity>("/api/collect/commit", requestBody: data)
            .rebase());
  }

  ///删除收藏夹
  Observable<bool> obtainRemoveFolder(String id) {
    var data = {"id": id};
    return autoToken(() =>
        post<FavoriteEntity>("/api/collect/delete", requestBody: data)
            .success());
  }

  ///收藏文章
  Observable<bool> obtainCollectArticle(String articleId, String folderId) {
    var data = {
      "groupId": folderId,
      "sourceId": articleId,
      "target": true,
      "type": 1
    };
    return autoToken(() =>
        post<dynamic>("/api/article/options", requestBody: data).success());
  }

  ///取消收藏文章
  Observable<bool> obtainCancelCollectArticle(String articleId) {
    var data = {"sourceId": articleId, "target": false, "type": 1};
    return autoToken(() =>
        post<FavoriteEntity>("/api/article/options", requestBody: data)
            .success());
  }

  ///获取历史记录 today true
  Observable<Page<HistoryEntity>> obtainHistoryList(
      PageParam pageParam, bool today) {
    final param = pageParam.toParam(doCreate: (map) {
      var data = {"today": today};
      map.addAll(data);
    });
    return autoToken(() =>
        postPage<HistoryEntity>("/api/article/read-history", requestBody: param)
            .rebase(pageParam: pageParam));
  }

  ///删除历史记录
  Observable<bool> obtainDeleteHistory(String id) {
    return autoToken(() => get<bool>("/api/article/del-read/$id").success());
  }

  ///阅读文章
  Observable<bool> obtainReadArticle(String id) {
    return autoToken(() => get<bool>("/api/article/read/$id").success());
  }

  ///获取运营图片
  Observable<OperationEntity> obtainOperationPhoto() {
    return autoToken(
        () => get<OperationEntity>("/api/operationPicture/get").rebase());
  }

  ///将boss置顶or取消置顶
  Observable<bool> obtainBossTopOrMove(String bossId, bool top) {
    var data = {
      "bossId": bossId,
      "top": top,
    };
    return autoToken(
        () => post<bool>("/api/boss/top-boss", requestBody: data).success());
  }

  ///获取收藏夹对象
  Observable<FolderEntity> obtainGetFolder(String id) {
    return autoToken(
        () => get<FolderEntity>("/api/collect/get-obj/$id").rebase());
  }

  ///点赞文章
  Observable<bool> obtainDoPoint(String articleId) {
    var data = {"sourceId": articleId, "target": true, "type": 0};
    return autoToken(() =>
        post<dynamic>("/api/article/options", requestBody: data).success());
  }

  ///取消点赞文章
  Observable<bool> obtainCancelPoint(String articleId) {
    var data = {"sourceId": articleId, "target": false, "type": 0};
    return autoToken(() =>
        post<dynamic>("/api/article/options", requestBody: data).success());
  }
}
