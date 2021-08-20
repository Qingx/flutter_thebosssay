import 'package:flutter_boss_says/data/db/base_db_provider.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BossDbProvider extends BaseDbProvider {
  final String name = 'TackBoss';

  final String columnId = "id";
  final String columnName = "name";
  final String columnHead = "head";
  final String columnRole = "role";
  final String columnTop = "top";
  final String columnUpdateTime = "updateTime";
  final String columnLabels = "labels";
  final String columnPhotoUrl = "photoUrl";

  BossDbProvider._();

  static BossDbProvider _mIns;

  factory BossDbProvider.ins() => _mIns ??= BossDbProvider._();

  @override
  tableName() {
    return name;
  }

  @override
  createTableString() {
    return '''
    create table $name (
    $columnId text primary key,
    $columnName text,
    $columnHead text,
    $columnRole text,
    $columnTop text,
    $columnUpdateTime integer,
    $columnLabels text,
    $columnPhotoUrl text
    )
    ''';
  }

  ///插入到数据库
  Future insert(BossSimpleEntity model) async {
    Database db = await getDataBase();
    return await db.insert(
      name,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///获取全部
  Future<List<BossSimpleEntity>> getAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    List<BossSimpleEntity> list = [];

    if (!maps.isNullOrEmpty()) {
      list = maps.map((e) => BossSimpleEntity.toBean(e)).toList();
    }
    return list;
  }

  ///通过标签获取列表
  Future<List<BossSimpleEntity>> getByLabel(String label) async {
    List<BossSimpleEntity> list = [];
    list = await getAll();

    if (!list.isNullOrEmpty()) {
      list = list.where((element) => element.labels.contains(label)).toList();
    }
    return list;
  }

  ///通过标签获取最近更新列表
  Future<List<BossSimpleEntity>> getByLabelWithLatest(String label) async {
    List<BossSimpleEntity> list = [];
    list = await getByLabel(label);

    if (!list.isNullOrEmpty()) {
      list = list
          .where((element) => BaseTool.isLatest(element.updateTime))
          .toList();
    }
    return list;
  }
}
