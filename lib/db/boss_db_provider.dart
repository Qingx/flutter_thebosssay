import 'dart:convert' as convert;

import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/db/base_db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BossDbProvider extends BaseDbProvider {
  final String mTableName = "BossList";

  final String id = "";
  final String name = ""; //boss名
  final String head = ""; //boss头像
  final String role = ""; //boss角色, 职务
  final String info = ""; //boss描述
  final int date = 0; //生日
  final int isCollect = 0; //是否追踪 0：false 1：true
  final int isPoint = 0; //是否点赞 0：false 1：true
  final int deleted = 0; //是否被删除 0：false 1：true
  final int point = 0; //点赞数
  final int collect = 0; //收藏数
  final int updateCount = 0; //更新数量
  final int totalCount = 0; //发布文章总数
  final int readCount = 0; //阅读数
  final int updateTime = 0; //上次更新时间
  final int createTime = 0; //创建时间

  static BossDbProvider _mIns;

  BossDbProvider._();

  factory BossDbProvider.getIns() {
    return _mIns ??= BossDbProvider._();
  }

  @override
  tableName() {
    return mTableName;
  }

  @override
  createTableString() {
    return '''
        create table $mTableName (
        $id text primary key,$name text,
        $head text,$role text,
        $info text,$date integer，
        $isCollect integer,$isPoint integer,
        $deleted integer,$point integer,
        $collect integer,$updateCount integer,
        $totalCount integer,$readCount integer,
        $updateTime integer,$createTime integer,)
      ''';
  }

  ///查询数据库 by bossId
  Future _getBossProviderById(Database db, String bossId) async {
    List<Map<String, dynamic>> maps =
        await db.rawQuery("select * from $name where $id = $bossId");
    return maps;
  }

  ///插入到数据库
  Future<void> insert(BossInfoEntity entity) async {
    Database db = await getDataBase();
    var bossProvider = await _getBossProviderById(db, entity.id);
    if (bossProvider != null) {
      ///删除数据
      await db.delete(name, where: "$id = ?", whereArgs: [entity.id]);
    }
    await db.insert(mTableName, entity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  ///插入到数据库
  Future<void> insertList(String bossJson) async {
    Database db = await getDataBase();

    List<dynamic> list = convert.json.decode(bossJson);

    if (!list.isNullOrEmpty()) {
      list.forEach((element) async {
        element["isCollect"] = element["isCollect"] ? 1 : 0;
        element["isPoint"] = element["isPoint"] ? 1 : 0;

        await db.insert(mTableName, element,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
  }

  ///更新到数据库
  Future<void> update(BossInfoEntity entity) async {
    final db = await getDataBase();
    await db.update(
      'dogs',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  ///获取单个对象 by bossId
  Future<BossInfoEntity> getBossById(String bossId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await _getBossProviderById(db, bossId);
    if (!maps.isNullOrEmpty()) {
      return _bossInfoEntityFromJson(BossInfoEntity(), maps[0]);
    }
    return null;
  }

  ///获取列表对象 by bossId
  Future<List<BossInfoEntity>> getBossListById(String bossId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await _getBossProviderById(db, bossId);
    if (!maps.isNullOrEmpty()) {
      return List.generate(maps.length,
          (index) => _bossInfoEntityFromJson(BossInfoEntity(), maps[index]));
    }
    return null;
  }

  ///获取已经追踪的boss列表
  Future<List<BossInfoEntity>> getCollectBossList() async {
    Database db = await getDataBase();

    List<Map<String, dynamic>> maps =
        await db.rawQuery("select * from $name where $isCollect = 0");

    if (!maps.isNullOrEmpty()) {
      return List.generate(maps.length,
          (index) => _bossInfoEntityFromJson(BossInfoEntity(), maps[index]));
    }
    return null;
  }

  ///json->bean
  _bossInfoEntityFromJson(BossInfoEntity data, Map<String, dynamic> json) {
    if (json['id'] != null) {
      data.id = json['id'].toString();
    }
    if (json['name'] != null) {
      data.name = json['name'].toString();
    }
    if (json['head'] != null) {
      data.head = json['head'].toString();
    }
    if (json['role'] != null) {
      data.role = json['role'].toString();
    }
    if (json['info'] != null) {
      data.info = json['info'].toString();
    }
    if (json['date'] != null) {
      data.date = json['date'] is String
          ? int.tryParse(json['date'])
          : json['date'].toInt();
    }
    if (json['isCollect'] != null) {
      data.isCollect = json['isCollect'] == 1;
    }
    if (json['isPoint'] != null) {
      data.isPoint = json['isPoint'] == 1;
    }
    if (json['point'] != null) {
      data.point = json['point'] is String
          ? int.tryParse(json['point'])
          : json['point'].toInt();
    }
    if (json['collect'] != null) {
      data.collect = json['collect'] is String
          ? int.tryParse(json['collect'])
          : json['collect'].toInt();
    }
    if (json['updateCount'] != null) {
      data.updateCount = json['updateCount'] is String
          ? int.tryParse(json['updateCount'])
          : json['updateCount'].toInt();
    }
    if (json['totalCount'] != null) {
      data.totalCount = json['totalCount'] is String
          ? int.tryParse(json['totalCount'])
          : json['totalCount'].toInt();
    }
    if (json['readCount'] != null) {
      data.readCount = json['readCount'] is String
          ? int.tryParse(json['readCount'])
          : json['readCount'].toInt();
    }
    if (json['updateTime'] != null) {
      data.updateTime = json['updateTime'] is String
          ? int.tryParse(json['updateTime'])
          : json['updateTime'].toInt();
    }
    if (json['createTime'] != null) {
      data.createTime = json['createTime'] is String
          ? int.tryParse(json['createTime'])
          : json['createTime'].toInt();
    }
    return data;
  }
}
