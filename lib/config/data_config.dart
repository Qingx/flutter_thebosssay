import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/util/base_sp.dart';
import 'package:flutter_boss_says/util/base_tool.dart';

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
