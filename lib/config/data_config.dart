import 'package:flutter_boss_says/util/base_sp.dart';

/// 应用数据相关缓存
class DataConfig extends BaseConfig {
  static DataConfig _mIns;

  DataConfig._() : super("data_config");

  factory DataConfig.getIns() {
    return _mIns ??= DataConfig._();
  }

  /// 设置是否为第一次使用APP
  set firstUseApp(String used) =>
      spInstance.putString(DataKeys.K_FIRST_USE, used);

  /// 检查是否为第一次使用APP
  String get firstUserApp =>
      spInstance.getString(DataKeys.K_FIRST_USE, defaultVal: "empty");

  set setTempId(String tempId) =>
      spInstance.putString(DataKeys.K_TEMP_ID, tempId);

  /// 获取tempId
  String get tempId =>
      spInstance.getString(DataKeys.K_TEMP_ID, defaultVal: "empty");
}

class DataKeys {
  static const K_FIRST_USE = "K_FIRST_USE";
  static const K_TEMP_ID = "K_YK_ID";
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
