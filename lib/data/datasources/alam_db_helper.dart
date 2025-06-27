// ### Alam 에 필요한 Databse 형식(SQLite)  ### //

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/alam_model.dart';

class AlamDBHelper {
  static final AlamDBHelper _instance = AlamDBHelper._();
  static Database? _database;

   static const String tableName = 'Alam';

   AlamDBHelper._();
  factory AlamDBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'Alam.db');
    // [핵심 수정]
    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: (db, version) {},
    );
  }

 Future<void> _onConfigure(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Alam(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alamDate TEXT,
        alamName TEXT,
        alamTime TEXT
      )
    ''');
  }

  

  // list
  Future<List<Alam>> getAlam() async {
    final db = await database;
    // [수정] 하드코딩된 이름 대신 tableName 변수 사용
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      return Alam.fromMap(maps[i]);
    });
  }

  Future<int> insertAlam(Alam alam) async {
    Database? db = await database;

    return await db.insert(
      tableName,
      alam.toMap(), //model 로 부터
      conflictAlgorithm: ConflictAlgorithm.ignore, //중복항목으로 인한 충돌 무시
    );
  }

  Future<int> updateAlam(Alam alam) async {
    Database? db = await database;
    return await db.update(tableName, alam.toMap(),
        where: 'id = ?', whereArgs: [alam.id]);
  }

  Future<int> deleteAlam(int id) async {
    Database? db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllAlams() async {
    Database? db = await AlamDBHelper().database;
    return await db.delete(tableName);
  }

  // [추가] DB 연결을 닫는 메소드
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null; // 인스턴스도 null로 만들어 다음에 새로 열도록 함
  }

  // [추가] 파일 생성을 보장하기 위한 더미 읽기 메소드
  Future<int> getCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM machine_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  
}
