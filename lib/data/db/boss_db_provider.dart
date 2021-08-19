import 'package:flutter_boss_says/data/db/base_db_provider.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:sqflite/sqflite.dart';

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
    $columnUpdateTime text,
    $columnLabels text,
    $columnPhotoUrl text,
    )
    ''';
  }

  ///插入到数据库
  Future insert(BossSimpleEntity model) async {
    Database db = await getDataBase();

    await db.insert(
      name,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///获取全部
  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps = await db.query(name);
    // List<BossSimpleEntity> list = [];
    //
    // list = maps.map((e) => BossSimpleEntity.toBean(e)).toList();

    return maps;
  }
}
