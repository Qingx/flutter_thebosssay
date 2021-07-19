import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/db/base_db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class ArticleDbProvider extends BaseDbProvider {
  ///表名
  final String name = "ArticleInfo";

  final String columnId = "id";
  final String columnBossId = "bossId"; //boss名
  final String columnTitle = "title"; //boss头像
  final String columnContent = "content"; //boss角色, 职务
  final String columnDescContent = "descContent"; //boss描述
  final String columnIsCollect = "isCollect"; //是否追踪 0：false 1：true
  final String columnIsPoint = "isPoint"; //是否点赞 0：false 1：true
  final String columnPoint = "point"; //点赞数
  final String columnCollect = "collect"; //收藏数
  final String columnCreateTime = "createTime"; //创建时间
  final String columnStatus = "status"; //创建时间
  final String columnFiles = "files"; //标签

  static ArticleDbProvider _mIns;

  ArticleDbProvider._();

  factory ArticleDbProvider.getIns() {
    return _mIns ??= ArticleDbProvider._();
  }

  @override
  createTableString() {
    return '''
        create table $name (
        $columnId text primary key,$columnBossId text,
        $columnTitle text,$columnContent text,
        $columnDescContent text,$columnIsCollect integer,
        $columnIsPoint integer,$columnPoint integer,
        $columnCollect integer,$columnCreateTime integer,
        $columnStatus integer,$columnFiles text)
      ''';
  }

  @override
  tableName() {
    return name;
  }

  ///查询列表对象byId
  Future _getArticleProvider(Database db, String bossId) async {
    List<Map<String, dynamic>> maps =
        await db.query(name, where: "$columnId = ?", whereArgs: [bossId]);
    if (!maps.isNullOrEmpty()) {
      return maps;
    }
    return null;
  }

  ///插入单个对象byBean
  Future insertByBean(ArticleEntity entity) async {
    Database db = await getDataBase();
    var bossProvider = await _getArticleProvider(db, entity.id);
    if (bossProvider != null) {
      ///删除数据
      await db.delete(name, where: "$columnId = ?", whereArgs: [entity.id]);
    }
    return await db.insert(name, entity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  ///更新单个对象byBean
  Future<void> updateByBean(ArticleEntity entity) async {
    final db = await getDataBase();
    await db.update(
      name,
      entity.toMap(),
      where: '$columnId = ?',
      whereArgs: [entity.id],
    );
  }

  ///获取单个对象byBossId
  Future<ArticleEntity> getArticleById(String bossId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await _getArticleProvider(db, bossId);
    if (!maps.isNullOrEmpty()) {
      return ArticleEntity().toBean(maps[0]);
    }
    return null;
  }

  ///插入对象列表byBean
  void insertListByBean(List<ArticleEntity> list) async {
    List.generate(list.length, (index) => insertByBean(list[index]));
  }
}
