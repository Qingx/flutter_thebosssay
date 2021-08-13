import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/page_data.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/entity/favorite_entity.dart';
import 'package:flutter_boss_says/data/entity/history_entity.dart';
import 'package:flutter_boss_says/data/entity/operation_entity.dart';
import 'package:flutter_boss_says/data/entity/token_entity.dart';
import 'package:rxdart/rxdart.dart';

class UserApi extends BaseApi {
  UserApi._();

  static UserApi _mIns;

  factory UserApi.ins() => _mIns ??= UserApi._();

  /// 游客登录
  Observable<TokenEntity> obtainTempLogin(String tempId) {
    var data = {"deviceId": tempId};
    return autoToken(() =>
        post<TokenEntity>("/api/account/sign-device", requestBody: data)
            .rebase());
  }

  ///发送验证码 type==>验证码类型: 0.登录; 1.确认当前手机号; 2.修改手机号; 3.绑定手机号
  Observable<String> obtainSendCode(String phone, int type) {
    var data = {"call": phone, "type": type};
    return autoToken(() =>
        post<String>("/api/account/send-code", requestBody: data).rebase());
  }

  ///验证码登录
  Observable<TokenEntity> obtainSignPhone(
      String phone, String code, String rnd) {
    var data = {
      "call": phone,
      "code": code,
      "deviceId": UserConfig.getIns().tempId,
      "rnd": rnd,
    };
    return autoToken(() =>
        post<TokenEntity>("/api/account/sign-code", requestBody: data)
            .rebase());
  }

  ///微信登录
  Observable<TokenEntity> obtainWechatLogin(String code) {
    var data = {
      "code": code,
      "deviceId": UserConfig.getIns().tempId,
    };
    return autoToken(() =>
        post<TokenEntity>("/api/account/wechat/sign", requestBody: data)
            .rebase());
  }

  ///微信绑定
  Observable<TokenEntity> obtainWechatBind(String code) {
    var data = {
      "code": code,
    };
    return autoToken(() =>
        post<TokenEntity>("/api/account/wechat/bound", requestBody: data)
            .rebase());
  }

  ///修改用户信息
  Observable<bool> obtainChangeName(String nickName) {
    var data = {"nickName": nickName};
    return autoToken(() =>
        post<bool>("/api/account/update-user", requestBody: data).success());
  }

  ///验证当前手机号
  Observable<bool> obtainConfirmPhone(String phone, String code, String rnd) {
    var data = {
      "call": phone,
      "code": code,
      "rnd": rnd,
    };
    return autoToken(() =>
        post<bool>("/api/account/check-current", requestBody: data).success());
  }

  ///修改手机号
  Observable<bool> obtainChangePhone(String phone, String code, String rnd) {
    var data = {
      "call": phone,
      "code": code,
      "rnd": rnd,
    };
    return autoToken(() =>
        post<bool>("/api/account/check-change", requestBody: data).success());
  }

  ///绑定手机号
  Observable<bool> obtainBindPhone(String phone, String code, String rnd) {
    var data = {
      "call": phone,
      "code": code,
      "rnd": rnd,
    };
    return autoToken(() =>
        post<bool>("/api/account/check-bound", requestBody: data).success());
  }

  ///刷新用户信息
  Observable<TokenEntity> obtainRefreshUser() {
    return autoToken(() => get<TokenEntity>(
            "/api/account/tokenRefresh/${Global.user.user.value.id}")
        .rebase());
  }

  ///获取用户收藏夹列表
  Observable<List<FavoriteEntity>> obtainFavoriteList() {
    return autoToken(
        () => get<List<FavoriteEntity>>("/api/collect/list").rebase());
  }

  ///创建收藏夹
  Observable<FavoriteEntity> obtainCreateFavorite(String name) {
    var data = {"name": name};
    return autoToken(() =>
        post<FavoriteEntity>("/api/collect/commit", requestBody: data)
            .rebase());
  }

  ///删除收藏夹
  Observable<bool> obtainRemoveFavorite(String id) {
    var data = {"id": id};
    return autoToken(() =>
        post<FavoriteEntity>("/api/collect/delete", requestBody: data)
            .success());
  }

  ///收藏文章
  Observable<bool> obtainFavoriteArticle(String articleId, String folderId) {
    var data = {
      "groupId": folderId,
      "sourceId": articleId,
      "target": true,
      "type": 1
    };
    return autoToken(() =>
        post<FavoriteEntity>("/api/article/options", requestBody: data)
            .success());
  }

  ///取消收藏文章
  Observable<bool> obtainCancelFavoriteArticle(String articleId) {
    var data = {"sourceId": articleId, "target": false, "type": 1};
    return autoToken(() =>
        post<FavoriteEntity>("/api/article/options", requestBody: data)
            .success());
  }

  ///获取历史记录 today true
  Observable<Page<HistoryEntity>> obtainHistory(
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

  ///检查服务
  Observable<bool> obtainCheckServer() {
    return get<bool>("/api/user/check-server").success();
  }

  ///检查上架状态
  Observable<bool> obtainCheckShangjia() {
    return autoToken(() => get<bool>("/api/status/get").rebase());
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

  ///检查app版本
  Observable<dynamic> obtainCheckUpdate() {
    return autoToken(() =>
        get<dynamic>("/api/version/check/iOS/${Global.versionName}").rebase());
  }
}
