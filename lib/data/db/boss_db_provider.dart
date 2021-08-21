import 'package:flutter_boss_says/data/db/base_db_provider.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:rxdart/rxdart.dart';
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
  Future<int> _insert(BossSimpleEntity model) async {
    Database db = await getDataBase();
    return await db.insert(
      name,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _update(BossSimpleEntity model) async {
    Database db = await getDataBase();
    return await db.update(
      name,
      model.toMap(),
      where: '$columnId = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> _delete(String id) async {
    Database db = await getDataBase();
    return await db.delete(
      name,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  ///插入到数据库
  Observable<int> insert(BossSimpleEntity model) {
    return Observable.fromFuture(_insert(model));
  }

  ///更新到数据库
  Observable<int> update(BossSimpleEntity model) {
    return Observable.fromFuture(_update(model));
  }

  ///删除一条数据
  Observable<int> delete(String id) {
    return Observable.fromFuture(_delete(id));
  }

  Future<List<dynamic>> _batchInsert(List<BossSimpleEntity> list) async {
    Database db = await getDataBase();
    Batch batch = db.batch();

    list.forEach((element) {
      batch.insert(
        name,
        element.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    return await batch.commit(continueOnError: true);
  }

  ///批量插入
  Observable<List<dynamic>> insertList(List<BossSimpleEntity> list) {
    return Observable.fromFuture(_batchInsert(list));
  }

  Future<List<BossSimpleEntity>> _queryAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    List<BossSimpleEntity> list = [];

    if (!maps.isNullOrEmpty()) {
      list = maps.map((e) => BossSimpleEntity.toBean(e)).toList();
    }
    return list;
  }

  ///获取全部
  Observable<List<BossSimpleEntity>> getAll() {
    return Observable.fromFuture(_queryAll());
  }

  Future<List<BossSimpleEntity>> _getByLabel(String label) async {
    List<BossSimpleEntity> list = [];
    list = await _queryAll();

    if (!list.isNullOrEmpty() && label != "-1") {
      list = list.where((element) => element.labels.contains(label)).toList();
    }
    return list;
  }

  ///通过标签获取列表
  Observable<List<BossSimpleEntity>> getByLabel(String label) {
    return Observable.fromFuture(_getByLabel(label));
  }

  Future<List<BossSimpleEntity>> _getLastWithLabel(String label) async {
    List<BossSimpleEntity> list = [];
    list = await _getByLabel(label);

    if (!list.isNullOrEmpty()) {
      list = list
          .where((element) => BaseTool.isLatest(element.updateTime))
          .toList();
    }
    return list;
  }

  ///通过标签获取最近更新列表
  Observable<List<BossSimpleEntity>> getLastWithLabel(String label) {
    return Observable.fromFuture(_getLastWithLabel(label));
  }
}
