import 'dart:convert';

import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/util/base_sp.dart';

/// 应用数据相关缓存
class DataConfig extends BaseConfig {
  static DataConfig _mIns;

  DataConfig._() : super("data_config");

  factory DataConfig.getIns() {
    return _mIns ??= DataConfig._();
  }

  ///设置Boss更新时间
  void setBossTime(String id, int time) {
    Map<String, dynamic> map = Map();

    String jsonStr =
        spInstance.getString(DataKeys.K_BOSS_TIME, defaultVal: "empty");

    if (jsonStr != "empty") {
      map = json.decode(jsonStr);
    }

    if (map.containsKey(id)) {
      map.update(id, (value) => time);
    } else {
      map[id] = time;
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
  set isShangjia(bool result) =>
      spInstance.putBool(DataKeys.K_IS_SHANGJIA, result);

  /// 检查是否为上架
  bool get isShangjia =>
      spInstance.getBool(DataKeys.K_IS_SHANGJIA, defaultVal: false);

  set setBossLabels(List<BossLabelEntity> list) =>
      spInstance.putObject<List<BossLabelEntity>>(DataKeys.K_BOSS_LABELS, list);

  List<BossLabelEntity> get bossLabels => spInstance
      .getObject<List<BossLabelEntity>>(DataKeys.K_BOSS_LABELS, defaultVal: []);

  ///上次拉取boss缓存时间
  set setUpdateTime(int time) =>
      spInstance.putInt(DataKeys.K_UPDATE_TIME, time);

  ///上次拉取boss缓存时间
  int get updateTime =>
      spInstance.getInt(DataKeys.K_UPDATE_TIME, defaultVal: 1);
}

class DataKeys {
  static const K_FIRST_USE = "K_FIRST_USE";
  static const K_BOSS_LABELS = "K_BOSS_LABELS";
  static const K_UPDATE_TIME = "K_UPDATE_TIME";
  static const K_IS_SHANGJIA = "K_IS_SHANGJIA";
  static const K_BOSS_TIME = "K_BOSS_TIME";
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
