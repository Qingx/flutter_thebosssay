import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/db/base_db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BossDbProvider extends BaseDbProvider {
  ///表名
  final String name = "BossInfo";

  final String columnId = "id";
  final String columnName = "name"; //boss名
  final String columnHead = "head"; //boss头像
  final String columnRole = "role"; //boss角色, 职务
  final String columnInfo = "info"; //boss描述
  final String columnIsCollect = "isCollect"; //是否追踪 0：false 1：true
  final String columnDeleted = "deleted"; //是否被删除 0：false 1：true
  final String columnGuide = "guide"; //是否被推荐 0：false 1：true
  final String columnCollect = "collect"; //收藏数
  final String columnUpdateCount = "updateCount"; //更新数量
  final String columnTotalCount = "totalCount"; //发布文章总数
  final String columnReadCount = "readCount"; //阅读数
  final String columnUpdateTime = "updateTime"; //上次更新时间
  final String columnLabels = "labels"; //标签

  static BossDbProvider _mIns;

  BossDbProvider._();

  factory BossDbProvider.getIns() {
    return _mIns ??= BossDbProvider._();
  }

  @override
  tableName() {
    return name;
  }

  @override
  createTableString() {
    return '''
        create table $name (
        $columnId text primary key,$columnName text,
        $columnHead text,$columnRole text,
        $columnIsCollect integer
        $columnDeleted integer,$columnGuide integer,
        $columnCollect integer,
        $columnUpdateCount integer,$columnTotalCount integer,
        $columnReadCount integer,$columnUpdateTime integer,
        $columnLabels text)
      ''';
  }

  ///查询列表对象byBossId
  Future _getBossProvider(Database db, String bossId) async {
    List<Map<String, dynamic>> maps =
        await db.query(name, where: "$columnId = ?", whereArgs: [bossId]);
    if (!maps.isNullOrEmpty()) {
      return maps;
    }
    return null;
  }

  ///插入单个对象byBean
  Future insertByBean(BossInfoEntity entity) async {
    Database db = await getDataBase();
    var bossProvider = await _getBossProvider(db, entity.id);
    if (bossProvider != null) {
      ///删除数据
      await db.delete(name, where: "$columnId = ?", whereArgs: [entity.id]);
    }
    return await db.insert(name, entity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  ///更新单个对象byBean
  Future<void> updateByBean(BossInfoEntity entity) async {
    final db = await getDataBase();
    await db.update(
      name,
      entity.toMap(),
      where: '$columnId = ?',
      whereArgs: [entity.id],
    );
  }

  ///获取单个对象byBossId
  Future<BossInfoEntity> getBossById(String bossId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await _getBossProvider(db, bossId);
    if (!maps.isNullOrEmpty()) {
      return BossInfoEntity().toBean(maps[0]);
    }
    return null;
  }

  ///插入对象列表byBean
  Future<void> insertListByBean(List<BossInfoEntity> list) async {
    Database db = await getDataBase();

    List.generate(list.length, (index) async {
      var bossProvider = await _getBossProvider(db, list[index].id);
      if (bossProvider != null) {
        ///删除数据
        await db
            .delete(name, where: "$columnId = ?", whereArgs: [list[index].id]);
      }
      return await db.insert(name, list[index].toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  ///更新对象列表byBean
  Future<void> updateListByBean(List<BossInfoEntity> list) async {
    final db = await getDataBase();
    List.generate(list.length, (index) async {
      await db.update(
        name,
        list[index].toMap(),
        where: '$columnId = ?',
        whereArgs: [list[index].id],
      );
    });
  }

  ///查询全部列表对象
  Future<List<Map<String, dynamic>>> getAllBossMap() async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps = await db.query(name);
    return maps;
  }

  ///查询全部列表对象
  Future<List<BossInfoEntity>> getAllBoss() async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps = await db.query(name);
    if (!maps.isNullOrEmpty()) {
      return maps.map((e) => BossInfoEntity().toBean(e)).toList();
    }
    return null;
  }

  ///查询列表对象byBossIdList
  Future<List<BossInfoEntity>> getBossListById(List<String> ids) async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps =
        await db.query(name, where: "$columnId = ?", whereArgs: ids);
    if (!maps.isNullOrEmpty()) {
      return maps.map((e) => BossInfoEntity().toBean(e)).toList();
    }
    return null;
  }

  ///查询全部列表对象byLabel
  Future<List<BossInfoEntity>> getAllBossByLabel(String label) async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps = await db.query(name);
    if (!maps.isNullOrEmpty()) {
      return maps
          .map((e) => BossInfoEntity().toBean(e))
          .toList()
          .where((element) => element.labels.contains(label))
          .toList();
    }
    return null;
  }

  ///查询追踪的boss列表
  Future<List<BossInfoEntity>> getCollectBoss() async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps =
        await db.query(name, where: "$columnIsCollect = ?", whereArgs: [1]);
    if (!maps.isNullOrEmpty()) {
      return maps.map((e) => BossInfoEntity().toBean(e)).toList();
    }
    return null;
  }

  ///查询追踪的boss列表byLabel
  Future<List<BossInfoEntity>> getCollectBossByLabel(String label) async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps =
        await db.query(name, where: "$columnIsCollect = ?", whereArgs: [1]);
    if (!maps.isNullOrEmpty()) {
      return maps
          .map((e) => BossInfoEntity().toBean(e))
          .toList()
          .where((element) => element.labels.contains(label))
          .toList();
    }
    return null;
  }

  ///查询追踪的boss列表byLabel
  Future<List<BossInfoEntity>> getRecommendBoss() async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps =
        await db.query(name, where: "$columnGuide = ?", whereArgs: [1]);
    if (!maps.isNullOrEmpty()) {
      return maps.map((e) => BossInfoEntity().toBean(e)).toList();
    }
    return null;
  }
}
