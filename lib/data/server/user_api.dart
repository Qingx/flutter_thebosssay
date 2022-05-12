import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/user_config.dart';
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

  ///微信登录
  Observable<TokenEntity> obtainJverifyLogin(String token) {
    var data = {
      "token": token,
      "deviceId": UserConfig.getIns().tempId,
    };
    return autoToken(() =>
        post<TokenEntity>("/api/account/sign-token", requestBody: data)
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
  Observable<TokenEntity> obtainBindPhone(
      String phone, String code, String rnd) {
    var data = {
      "call": phone,
      "code": code,
      "rnd": rnd,
    };
    return autoToken(() =>
        post<TokenEntity>("/api/account/check-bound", requestBody: data)
            .rebase());
  }

  ///刷新用户信息
  Observable<TokenEntity> obtainRefresh() {
    return autoToken(() => get<TokenEntity>("/api/account/refresh").rebase());
  }

  ///刷新用户信息 token过期
  Observable<TokenEntity> obtainRefreshUser() {
    return autoToken(() => get<TokenEntity>(
            "/api/account/tokenRefresh/${Global.user.user.value.id}")
        .rebase());
  }

  ///检查服务
  Observable<bool> obtainCheckServer() {
    return get<bool>("/api/user/check-server").success();
  }

  ///检查上架状态
  Observable<bool> obtainCheckShangjia() {
    return autoToken(() => get<bool>("/api/status/get").rebase());
  }

  ///检查app版本
  Observable<dynamic> obtainCheckUpdate() {
    return autoToken(() =>
        get<dynamic>("/api/version/check/iOS/${Global.versionName}").rebase());
  }
}
