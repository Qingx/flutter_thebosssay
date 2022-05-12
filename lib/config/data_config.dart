import 'dart:convert';

import 'package:flutter_boss_says/util/base_sp.dart';

/// 应用数据相关缓存
class DataConfig extends BaseConfig {
  static DataConfig _mIns;

  DataConfig._() : super("data_config");

  factory DataConfig.getIns() {
    return _mIns ??= DataConfig._();
  }

  ///设置Boss更新时间
  void setBossTime(
    String id,
  ) {
    int nowTime = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> map = Map();

    String jsonStr =
        spInstance.getString(DataKeys.K_BOSS_TIME, defaultVal: "empty");

    if (jsonStr != "empty") {
      map = json.decode(jsonStr);
    }

    if (map.containsKey(id)) {
      map.update(id, (value) => nowTime);
    } else {
      map[id] = nowTime;
    }

    spInstance.putString(DataKeys.K_BOSS_TIME, json.encode(map));
  }

  ///获取Boss更新时间
  int getBossTime(String id) {
    String jsonStr =
        spInstance.getString(DataKeys.K_BOSS_TIME, defaultVal: "empty");

    int time = -1;

    if (jsonStr != "empty") {
      Map<String, dynamic> map = json.decode(jsonStr);
      if (map.containsKey(id)) {
        time = map[id];
      }
    }

    return time;
  }

  ///获取全部Boss更新时间
  Map<String, dynamic> getAllBossTime() {
    Map<String, dynamic> map = Map();

    String jsonStr =
        spInstance.getString(DataKeys.K_BOSS_TIME, defaultVal: "empty");

    if (jsonStr != "empty") {
      map = json.decode(jsonStr);
    }

    return map;
  }

  /// 设置是否为第一次使用APP
  set firstUseApp(bool result) =>
      spInstance.putBool(DataKeys.K_FIRST_USE, result);

  /// 检查是否为第一次使用APP
  bool get firstUserApp =>
      spInstance.getBool(DataKeys.K_FIRST_USE, defaultVal: true);

  /// 设置是否为上架
  set isCheckFinish(bool result) =>
      spInstance.putBool(DataKeys.K_IS_SHANGJIA, result);

  /// 检查是否正在上架
  bool get isCheckFinish =>
      spInstance.getBool(DataKeys.K_IS_SHANGJIA, defaultVal: false);

  ///进入首页来源 splash/登录
  set fromSplash(bool fromSplash) =>
      spInstance.putBool(DataKeys.K_FROM_SPLASH, fromSplash);

  ///进入首页来源 splash/登录
  bool get fromSplash =>
      spInstance.getBool(DataKeys.K_FROM_SPLASH, defaultVal: true);

  set notifiTime(int time) =>
      spInstance.putInt(DataKeys.K_SHOW_NOTIFI_TIME, time);

  int get notifiTime =>
      spInstance.getInt(DataKeys.K_SHOW_NOTIFI_TIME, defaultVal: -1);

  set notID(String id) => spInstance.putString(DataKeys.K_LAST_NOID, id);

  String get notID =>
      spInstance.getString(DataKeys.K_LAST_NOID, defaultVal: "");
}

class DataKeys {
  static const K_FIRST_USE = "K_FIRST_USE";
  static const K_IS_SHANGJIA = "K_IS_SHANGJIA";
  static const K_BOSS_TIME = "K_BOSS_TIME";
  static const K_FROM_SPLASH = "K_FROM_SPLASH";
  static const K_SHOW_NOTIFI_TIME = "K_SHOW_NOTIFI_TIME";
  static const K_LAST_NOID = "K_LAST_NOID";
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
