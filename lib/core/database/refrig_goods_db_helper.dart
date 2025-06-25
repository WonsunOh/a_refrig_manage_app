import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/refrig_goods_model.dart'; // Product 모델 경로 확인 필요

class RefrigGoodsDBHelper {
  static final RefrigGoodsDBHelper _instance = RefrigGoodsDBHelper._();
  static Database? _database;

  RefrigGoodsDBHelper._();

  factory RefrigGoodsDBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'RefrigGoods.db');
    // [핵심 수정]
    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: (db, version) {},
    );
  }

  // [핵심 수정] DB가 열릴 때마다 테이블 존재를 확인하고 생성합니다.
  Future<void> _onConfigure(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS RefrigGoods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        refrigName TEXT,
        storageName TEXT,
        foodName TEXT,
        category TEXT,
        iconAdress TEXT,
        inputDate TEXT,
        useDate TEXT,
        amount TEXT,
        useAmount TEXT,
        unit TEXT,
        memo TEXT,
        containerName TEXT
      )
    ''');
  }

  // Product의 toMap()과 fromMap()이 DB와 상호작용
  Future<int> insertGoods(Product product) async {
    final db = await database;
    return await db.insert('RefrigGoods', product.toMap());
  }
  
  // refrigName을 기준으로 상품 목록을 가져옵니다.
  Future<List<Product>> getGoods(String refrigName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('RefrigGoods',
        where: 'refrigName = ?', whereArgs: [refrigName]);

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> updateGoods(Product product) async {
    final db = await database;
    return await db.update('RefrigGoods', product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteGoods(int id) async {
    final db = await database;
    return await db
        .delete('RefrigGoods', where: 'id = ?', whereArgs: [id]);
  }

// [핵심] 모든 음식 목록을 가져오는 메소드
  Future<List<Product>> getAllGoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('RefrigGoods');

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
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