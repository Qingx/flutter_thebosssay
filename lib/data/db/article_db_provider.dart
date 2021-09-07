import 'package:flutter_boss_says/data/db/base_db_provider.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class ArticleDbProvider extends BaseDbProvider {
  final String name = 'TackArticle';

  final String columnId = "id";
  final String columnTitle = "title";
  final String columnDescContent = "descContent";
  final String columnIsCollect = "isCollect";
  final String columnIsRead = "isRead";
  final String columnIsPoint = "isPoint";
  final String columnReadCount = "readCount";
  final String columnCollect = "collect";
  final String columnPoint = "point";
  final String columnReleaseTime = "releaseTime";
  final String columnArticleTime = "articleTime";
  final String columnFiles = "files";
  final String columnBossId = "bossId";
  final String columnBossName = "bossName";
  final String columnBossHead = "bossHead";
  final String columnBossRole = "bossRole";
  final String columnRecommendType = "recommendType";

  ArticleDbProvider._();

  static ArticleDbProvider _mIns;

  factory ArticleDbProvider.ins() => _mIns ??= ArticleDbProvider._();

  @override
  String tableName() {
    return name;
  }

  @override
  String createTableString() {
    return '''
    create table $name (
    $columnId text primary key,
    $columnTitle text,
    $columnDescContent text,
    $columnIsCollect text,
    $columnIsRead text,
    $columnIsPoint text,
    $columnReadCount integer,
    $columnCollect integer,
    $columnPoint integer,
    $columnReleaseTime integer,
    $columnArticleTime integer,
    $columnBossId text,
    $columnBossName text,
    $columnBossHead text,
    $columnBossRole text,
    $columnFiles text,
    $columnRecommendType text
    )
    ''';
  }

  ///查询数据库
  Future _getArticleProvider(Database db, String id) async {
    List<Map<String, dynamic>> maps =
        await db.rawQuery("select * from $name where $columnId = $id");
    return maps;
  }

  ///插入到数据库
  Future<int> _insert(ArticleSimpleEntity model) async {
    Database db = await getDataBase();

    var article = await _getArticleProvider(db, model.id);
    if (article != null) {
      ///删除数据
      await db.delete(name, where: "$columnId = ?", whereArgs: [model.id]);
    }
    return await db.insert(
      name,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<dynamic>> _batchInsert(List<ArticleSimpleEntity> list) async {
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
  Observable<List<dynamic>> insertList(List<ArticleSimpleEntity> list) {
    return Observable.fromFuture(_batchInsert(list));
  }

  ///获取全部
  Future<List<ArticleSimpleEntity>> _queryAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    List<ArticleSimpleEntity> list = [];

    if (!maps.isNullOrEmpty()) {
      list = maps.map((e) => ArticleSimpleEntity.toBean(e)).toList();
    }
    return list;
  }

  Future<int> _deleteAll() async {
    Database db = await getDataBase();
    return db.delete(name);
  }

  ///获取全部
  Observable<List<ArticleSimpleEntity>> getAll() {
    return Observable.fromFuture(_queryAll());
  }

  ///删除全部
  Observable<int> deleteAll() {
    return Observable.fromFuture(_deleteAll());
  }
}
