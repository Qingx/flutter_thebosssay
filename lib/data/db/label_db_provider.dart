import 'package:flutter_boss_says/data/db/base_db_provider.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class LabelDbProvider extends BaseDbProvider {
  final String name = 'Label';

  final String columnId = "id";
  final String columnName = "name";

  LabelDbProvider._();

  static LabelDbProvider _mIns;

  factory LabelDbProvider.ins() => _mIns ??= LabelDbProvider._();

  @override
  tableName() {
    return name;
  }

  @override
  createTableString() {
    return '''
    create table $name (
    $columnId text primary key,
    $columnName text
    )
    ''';
  }

  ///插入到数据库
  Future insert(BossLabelEntity model) async {
    Database db = await getDataBase();
    return await db.insert(
      name,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///获取全部
  Future<List<BossLabelEntity>> getAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    List<BossLabelEntity> list = [];

    if (!maps.isNullOrEmpty()) {
      list = maps.map((e) => BossLabelEntity.toBean(e)).toList();
    }
    return list;
  }
}
