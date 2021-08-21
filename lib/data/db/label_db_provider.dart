import 'package:flutter_boss_says/data/db/base_db_provider.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'dart:convert' as convert;

class LabelDbProvider extends BaseDbProvider {
  final String name = 'Label';

  final String columnId = "id";
  final String columnName = "name";

  LabelDbProvider._();

  static LabelDbProvider _mIns;

  factory LabelDbProvider.ins() => _mIns ??= LabelDbProvider._();

  @override
  String tableName() {
    return name;
  }

  @override
  String createTableString() {
    return '''
    create table $name (
    $columnId text primary key,
    $columnName text
    )
    ''';
  }

  ///插入到数据库
  Future<int> _insert(BossLabelEntity model) async {
    Database db = await getDataBase();
    return await db.insert(
      name,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<dynamic>> _batchInsert(List<BossLabelEntity> list) async {
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
  Observable<List<dynamic>> insertList(List<BossLabelEntity> list) {
    return Observable.fromFuture(_batchInsert(list));
  }

  Future<List<BossLabelEntity>> _queryAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    List<BossLabelEntity> list = [];

    if (!maps.isNullOrEmpty()) {
      list = maps.map((e) => BossLabelEntity.toBean(e)).toList();
    }
    return list;
  }

  ///获取全部
  Observable<List<BossLabelEntity>> getAll() {
    return Observable.fromFuture(_queryAll());
  }
}
