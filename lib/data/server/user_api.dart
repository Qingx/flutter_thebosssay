import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/favorite_entity.dart';
import 'package:flutter_boss_says/data/entity/token_entity.dart';
import 'package:rxdart/rxdart.dart';

class UserApi extends BaseApi {
  UserApi._();

  static UserApi _mIns;

  factory UserApi.ins() => _mIns ??= UserApi._();

  /// 游客登录
  Observable<TokenEntity> obtainTempLogin(String tempId) {
    var data = {"deviceId": tempId};
    return post<TokenEntity>("/api/account/sign-device", requestBody: data)
        .rebase();
  }

  ///发送验证码
  Observable<bool> obtainSendCode(String phone) {
    var data = {"call": phone};
    return post<bool>("/api/account/send-code", requestBody: data).success();
  }

  ///验证码登录
  Observable<TokenEntity> obtainSignPhone(String phone, String code) {
    var data = {
      "call": phone,
      "code": code,
      "deviceId": DataConfig.getIns().tempId
    };
    return post<TokenEntity>("/api/account/sign-code", requestBody: data)
        .rebase();
  }

  ///修改用户信息
  Observable<bool> obtainUpdateUser({String nickName, String phone}) {
    var data = {"nickName": nickName, "phone": phone};
    return post<bool>("/api/account/update-user", requestBody: data).success();
  }

  ///刷新用户信息
  Observable<TokenEntity> obtainRefreshUser() {
    return get<TokenEntity>("/api/account/refresh").rebase();
  }

  ///获取用户收藏夹列表
  Observable<List<FavoriteEntity>> obtainFavoriteList() {
    return get<List<FavoriteEntity>>("/api/collect/list").rebase();
  }

  ///创建收藏夹
  Observable<FavoriteEntity> obtainCreateFavorite(String name) {
    var data = {"name": name};
    return post<FavoriteEntity>("/api/collect/commit", requestBody: data)
        .rebase();
  }

  ///删除收藏夹
  Observable<bool> obtainRemoveFavorite(String id) {
    var data = {"id": id};
    return post<FavoriteEntity>("/api/collect/delete", requestBody: data)
        .success();
  }
}
