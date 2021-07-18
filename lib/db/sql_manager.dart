import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlManager {
  static const _VERSION = 1;
  static const _NAME = "tbs.db";
  static Database _database;

  static init() async {
    var databasePath = await getDatabasesPath();

    String path = join(databasePath, _NAME);

    _database = await openDatabase(path,
        version: _VERSION, onCreate: (Database db, int version) async {});
  }

  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  static isTableExits(String tableName) async {
    await getCurrentDatabase();

    var res = await _database.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.length > 0;
  }

  static close() {
    _database?.close();
    _database = null;
  }
}
