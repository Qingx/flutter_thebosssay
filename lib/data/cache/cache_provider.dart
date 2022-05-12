import 'package:flutter_boss_says/config/page_data.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';

class CacheProvider {
  static CacheProvider _mIns;

  CacheProvider._();

  factory CacheProvider.getIns() {
    return _mIns ??= CacheProvider._();
  }

  List<BossLabelEntity> _mLabel = [];
  List<BossSimpleEntity> _mBoss = [];
  Page<ArticleSimpleEntity> _mArticle = Page(
      size: 10,
      pages: 0,
      total: 0,
      current: 0,
      searchCount: false,
      records: []);

  void insertLabelList(List<BossLabelEntity> list) {
    list = [BaseEmpty.emptyLabel, ...list];
    _mLabel = list;
  }

  List<BossLabelEntity> getAllLabel() {
    return _mLabel ??= [];
  }

  void clearLabel() {
    _mLabel = _mLabel ??= [];
    _mLabel.clear();
  }

  void insertBossList(List<BossSimpleEntity> list) {
    _mBoss = list;
  }

  List<BossSimpleEntity> getAllBoss() {
    if (_mBoss == null) {
      _mBoss = [];
    } else {
      _mBoss.sort((a, b) => (b.getSort()).compareTo(a.getSort()));
    }
    return _mBoss;
  }

  List<BossSimpleEntity> getBossByLabel(String label) {
    var list = getAllBoss();

    if (!list.isNullOrEmpty() && label != "-1") {
      list = list.where((element) => element.labels.contains(label)).toList();
    }
    return list;
  }

  List<BossSimpleEntity> getBossWithLastByLabel(String label) {
    var list = getBossByLabel(label);

    if (!list.isNullOrEmpty()) {
      list = list
          .where((element) =>
              BaseTool.isLatest(element.updateTime) &&
              BaseTool.showRedDots(element.id, element.updateTime))
          .toList();
    }

    return list;
  }

  void updateBoss(BossSimpleEntity entity) {
    if (!_mBoss.isNullOrEmpty()) {
      var index = _mBoss.indexWhere((element) => element.id == entity.id);
      if (index != -1) {
        _mBoss[index] = entity;
      }
    }
  }

  void insertBoss(BossSimpleEntity entity) {
    _mBoss = _mBoss ??= [];
    _mBoss.add(entity);
  }

  void insertBatchBoss(List<BossSimpleEntity> list) {
    _mBoss = _mBoss ??= [];
    _mBoss.addAll(list);
  }

  void deleteBoss(String id) {
    _mBoss = _mBoss ??= [];
    var index = _mBoss.indexWhere((element) => element.id == id);

    if (index != -1) {
      _mBoss.removeAt(index);
    }
  }

  void clearBoss() {
    _mBoss = _mBoss ??= [];
    _mBoss.clear();
  }

  void insertArticle(Page<ArticleSimpleEntity> page) {
    _mArticle = page;
  }

  Page<ArticleSimpleEntity> getAllArticle() {
    return _mArticle ??= Page(
        size: 10,
        pages: 0,
        total: 0,
        current: 0,
        searchCount: false,
        records: []);
  }

  void clearArticle() {
    _mArticle = Page(
        size: 10,
        pages: 0,
        total: 0,
        current: 0,
        searchCount: false,
        records: []);
  }

  void clearAll() {
    clearLabel();
    clearBoss();
    clearArticle();
  }
}
