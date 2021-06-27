import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/util/base_sp.dart';

/// 用户数据相关缓存
class UserConfig extends BaseConfig {
  static UserConfig _mIns;

  UserConfig._() : super("user_config");

  factory UserConfig.getIns() {
    return _mIns ??= UserConfig._();
  }

  /// 设置用户信息
  set user(UserEntity entity) =>
      spInstance.putObject(UserKeys.K_USER_DATA, entity);

  /// 获取用户信息
  UserEntity get user => spInstance.getObject<UserEntity>(UserKeys.K_USER_DATA);

  /// 获取登录状态
  bool get loginStatus => (user ?? UserEntity()).isNotEmpty();

  /// 设置文件签名
  set sign(String sign) => spInstance.putString(UserKeys.K_HTTP_SIGN, sign);

  /// 获取文件签名
  String get sign => spInstance.getString(UserKeys.K_HTTP_SIGN);

  /// 设置用户token
  set token(String token) => spInstance.putString(UserKeys.K_HTTP_TOKEN, token);

  /// 获取用户token
  String get token => spInstance.getString(UserKeys.K_HTTP_TOKEN);

  /// 设置是否为第一次使用APP
  set firstUseApp(String used) => spInstance.putString(UserKeys.K_FIRST_USE, used);

  /// 检查是否为第一次使用APP
  String get firstUserApp =>
      spInstance.getString(UserKeys.K_FIRST_USE, defaultVal: "empty");
}

class UserKeys {
  static const K_USER_DATA = "K_USER_DATA";
  static const K_HTTP_SIGN = "K_HTTP_SIGN";
  static const K_HTTP_TOKEN = "K_HTTP_TOKEN";
  static const K_FIRST_USE = "K_FIRST_USE";
}

class BaseConfig {
  BaseSP spInstance;

  BaseConfig(String name) {
    spInstance = BaseSP(name);
  }

  void doAfterCreated(doNext(BaseSP sp)) {
    spInstance.event((_) => doNext(spInstance));
  }

  void clear() => spInstance.clear();
}
