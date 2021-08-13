import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/util/base_tool.dart';

import 'data_config.dart';

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
  bool get loginStatus => (user ?? UserEntity()).type == "1";

  /// 设置文件签名
  set sign(String sign) => spInstance.putString(UserKeys.K_HTTP_SIGN, sign);

  /// 获取文件签名
  String get sign => spInstance.getString(UserKeys.K_HTTP_SIGN);

  /// 设置用户token
  set token(String token) => spInstance.putString(UserKeys.K_HTTP_TOKEN, token);

  /// 获取用户token
  String get token =>
      spInstance.getString(UserKeys.K_HTTP_TOKEN, defaultVal: "empty_token");

  set setTempId(String tempId) =>
      spInstance.putString(UserKeys.K_TEMP_ID, tempId);

  /// 获取tempId
  String get tempId => spInstance.getString(UserKeys.K_TEMP_ID,
      defaultVal: BaseTool.createTempId());

  ///上次阅读文章时间
  set setLastReadTime(int time) =>
      spInstance.putInt(UserKeys.k_LAST_READ, time);

  ///上次阅读文章时间
  int get lastReadTime => spInstance.getInt(UserKeys.k_LAST_READ,
      defaultVal: DateTime.now().millisecondsSinceEpoch);
}

class UserKeys {
  static const K_USER_DATA = "K_USER_DATA";
  static const K_HTTP_SIGN = "K_HTTP_SIGN";
  static const K_HTTP_TOKEN = "K_HTTP_TOKEN";
  static const K_TEMP_ID = "K_YK_ID";
  static const k_LAST_READ = "k_LAST_READ";
}
