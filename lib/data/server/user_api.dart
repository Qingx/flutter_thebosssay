import 'package:flutter_boss_says/config/base_api.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:rxdart/rxdart.dart';

class UserApi extends BaseApi {
  UserApi._();

  static UserApi _mIns;

  factory UserApi.ins() => _mIns ??= UserApi._();

  /// 发送短信验证码
  Observable<bool> obtainSendMsg(String phone) {
    return get("/apk-user/sms/send/$phone").success();
  }

  /// 短信登录
  Observable<UserEntity> obtainLoginTel(String phone, String code) {
    var data = {'phone': phone, 'code': code};
    return post<UserEntity>("/apk/account/sign-in-phone", requestBody: data)
        .rebase();
  }

  /// 游客登录
  Observable<String> obtainTempLogin(String tempId) {
    var data = {"deviceId": tempId};
    return post<String>("/api/account/sign-device", requestBody: data).rebase();
  }
}
