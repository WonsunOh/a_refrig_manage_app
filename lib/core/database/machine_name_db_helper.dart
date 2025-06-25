import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/machine_name_model.dart';

class MachineNameDBHelper {
  static final MachineNameDBHelper _instance = MachineNameDBHelper._();
  static Database? _database;

  MachineNameDBHelper._();

  factory MachineNameDBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'MachineName.db');
    // [핵심 수정] onCreate가 아닌 onConfigure 파라미터에 _onConfigure 함수를 전달합니다.
    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: (db, version) {
        // onConfigure에서 IF NOT EXISTS로 테이블을 생성하므로,
        // onCreate에서는 아무것도 할 필요가 없습니다.
        // 하지만 version을 지정하면 onCreate 콜백 자체가 필요하므로 비워둡니다.
      },
    );
  }

  // [핵심 수정] DB가 열릴 때마다 테이블 존재를 확인하고 생성합니다.
  Future<void> _onConfigure(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS machine_table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        machineName TEXT,
        refrigIcon TEXT,
        machineType TEXT
      )
    ''');
  }

  // insert
  Future<int> insertMachine(MachineName machineName) async {
    final db = await database;
    return await db.insert('machine_table', machineName.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // list
  Future<List<MachineName>> getMachineName() async {
    final db = await database;
    final List<Map> maps = await db.query('machine_table');

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      return MachineName.fromMap(maps[i]);
    });
  }

  // update
  Future<int> updateMachine(MachineName machineName) async {
    final db = await database;
    return await db.update('machine_table', machineName.toMap(),
        where: 'id = ?', whereArgs: [machineName.id]);
  }

  // delete
  Future<int> deleteMachine(int id) async {
    final db = await database;
    return await db
        .delete('machine_table', where: 'id = ?', whereArgs: [id]);
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
