import 'package:flutter_boss_says/data/db/base_db_provider.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class ArticleDbProvider extends BaseDbProvider {
  final String name = 'TackArticle';

  final String columnId = "id";
  final String columnTitle = "title";
  final String columnDescContent = "descContent";
  final String columnIsCollect = "isCollect";
  final String columnIsRead = "isRead";
  final String columnReadCount = "readCount";
  final String columnCollect = "collect";
  final String columnReleaseTime = "releaseTime";
  final String columnArticleTime = "articleTime";
  final String columnFiles = "files";
  final String columnBossVO = "bossVO";

  ArticleDbProvider._();

  static ArticleDbProvider _mIns;

  factory ArticleDbProvider.ins() => _mIns ??= ArticleDbProvider._();

  @override
  tableName() {
    return name;
  }

  @override
  createTableString() {
    return '''
    create table $name (
    $columnId text primary key,
    $columnDescContent text,
    $columnIsCollect text,
    $columnIsRead text,
    $columnReadCount integer,
    $columnCollect integer,
    $columnReleaseTime integer,
    $columnArticleTime integer,
    $columnFiles text,
    $columnBossVO text
    )
    ''';
  }

  ///插入到数据库
  Future insert(ArticleSimpleEntity model) async {
    Database db = await getDataBase();
    return await db.insert(
      name,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///获取全部
  Future<List<ArticleSimpleEntity>> getAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    List<ArticleSimpleEntity> list = [];

    if (!maps.isNullOrEmpty()) {
      list = maps.map((e) => ArticleSimpleEntity.toBean(e)).toList();
    }
    return list;
  }
}
