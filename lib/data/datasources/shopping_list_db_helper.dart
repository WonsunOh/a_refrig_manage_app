// lib/data/shopping_list_db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/shopping_item_model.dart';

class ShoppingListDBHelper {
  ShoppingListDBHelper._privateConstructor();
  static final ShoppingListDBHelper instance = ShoppingListDBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shopping_list_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isChecked INTEGER NOT NULL
      )
      ''');
  }

  Future<void> insertItem(ShoppingItem item) async {
    final db = await database;
    await db.insert('shopping_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ShoppingItem>> getItems() async {
    final db = await database;
    final maps = await db.query('shopping_items', orderBy: 'id DESC');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) => ShoppingItem.fromMap(maps[i]));
  }

  Future<void> updateItem(ShoppingItem item) async {
    final db = await database;
    await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // 체크된 모든 아이템 삭제
  Future<void> deleteCheckedItems() async {
    final db = await database;
    await db.delete(
      'shopping_items',
      where: 'isChecked = ?',
      whereArgs: [1],
    );
  }
}