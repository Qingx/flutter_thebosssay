import 'dart:convert';

import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BaseSP {
  String name;

  static SharedPreferences mSP;
  static Map<String, BaseSP> mCache = {};

  static init() {
    SharedPreferences.getInstance().then((value) => mSP = value);
  }

  BaseSP._create(this.name);

  factory BaseSP(String name) => mCache[name] ??= BaseSP._create(name);

  String _internalKey(String key) {
    return "##${name}_$key";
  }

  bool _isInternalName(String internalKey) {
    return internalKey.startsWith("##$name");
  }

  void putInt(String key, int value) {
    event((sp) => sp.setInt(_internalKey(key), value));
  }

  void putBool(String key, bool value) {
    event((sp) => sp.setBool(_internalKey(key), value));
  }

  void putString(String key, String value) {
    event((sp) => sp.setString(_internalKey(key), value));
  }

  void putDouble(String key, double value) {
    event((sp) => sp.setDouble(_internalKey(key), value));
  }

  void putStringList(String key, List<String> value) {
    event((sp) => sp.setStringList(_internalKey(key), value));
  }

  /// 添加object缓存
  void putObject<T>(String key, T value) {
    if (value != null) {
      final valueStr = json.encode(value);
      putString(key, valueStr);
    } else {
      putString(key, "");
    }
  }

  /// 清空当前实例对应的缓存
  void clear() {
    event((sp) {
      final keys = sp.getKeys();

      keys.forEach((element) {
        if (_isInternalName(element)) {
          sp.remove(element);
        }
      });
    });
  }

  @deprecated
  int getInt(String key, {int defaultVal}) =>
      mSP?.getInt(_internalKey(key)) ?? defaultVal;

  @deprecated
  bool getBool(String key, {bool defaultVal = false}) =>
      mSP?.getBool(_internalKey(key)) ?? defaultVal;

  @deprecated
  String getString(String key, {String defaultVal}) =>
      mSP?.getString(_internalKey(key)) ?? defaultVal;

  @deprecated
  double getDouble(String key, {double defaultVal}) =>
      mSP?.getDouble(_internalKey(key)) ?? defaultVal;

  @deprecated
  List<String> getStringList(String key, {List<String> defaultVal}) =>
      mSP?.getStringList(_internalKey(key)) ?? defaultVal;

  /// 获取指定类型的object
  @deprecated
  T getObject<T>(String key, {T defaultVal}) {
    String valueStr = getString(key);
    if (!valueStr.isNullOrEmpty() && valueStr != "null") {
      return JsonConvert.fromJsonAsT<T>(json.decode(valueStr));
    }
    return defaultVal;
  }

  /// 获取sp
  void event(void doEvent(SharedPreferences sp)) {
    final sp = mSP;

    if (sp != null) {
      doEvent(sp);
    } else {
      SharedPreferences.getInstance().then((value) {
        mSP = value;
        doEvent(value);
      });
    }
  }
}
