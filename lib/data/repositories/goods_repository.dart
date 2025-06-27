import 'package:sqflite/sqflite.dart';

import '../models/product_model.dart';
import '../datasources/refrig_goods_db_helper.dart';

/// Goods 데이터 소스를 관리하는 저장소 클래스
class GoodsRepository {
  // [수정] 생성자를 간결하고 명확하게 변경합니다.
  final RefrigGoodsDBHelper _dbHelper;
  GoodsRepository(this._dbHelper);

  /// 특정 냉장고(refrigName)의 모든 음식 목록 가져오기
  /// 파라미터를 String refrigName으로 수정
  Future<List<Product>> getGoods(String refrigName) =>
      _dbHelper.getGoods(refrigName);

  /// 모든 음식 목록 가져오기
  Future<List<Product>> getAllGoods() => _dbHelper.getAllGoods();

  /// 음식 추가
  Future<int> addGood(Product product) => _dbHelper.insertGoods(product);

  /// 음식 수정
  Future<int> updateGood(Product product) => _dbHelper.updateGoods(product);

  /// 음식 삭제
  Future<int> deleteGood(int id) => _dbHelper.deleteGoods(id);

  // [추가!] 특정 공간에 속한 모든 음식 데이터를 삭제하는 메소드
  Future<int> deleteGoodsByRefrigName(String refrigName) async {
    return await _dbHelper.deleteGoodsByRefrigName(refrigName);
  }


  // [신규] 특정 냉장고의 전체 품목 수를 가져오는 메소드
  Future<int> getGoodsCount(String refrigName) async {
    final goods = await _dbHelper.getGoods(refrigName);
    return goods.length;
  }

  // [신규] 특정 냉장고의 소비기한 임박 품목 수를 가져오는 메소드
  Future<int> getExpiringSoonCount(
    String refrigName, {
    int thresholdDays = 3,
  }) async {
    final goods = await _dbHelper.getGoods(refrigName);
    final now = DateTime.now();
    int count = 0;

    for (var product in goods) {
      if (product.useDate != null) {
        final today = DateTime(now.year, now.month, now.day);
        final useDate = DateTime(
          product.useDate!.year,
          product.useDate!.month,
          product.useDate!.day,
        );
        final difference = useDate.difference(today).inDays;
        if (difference >= 0 && difference <= thresholdDays) {
          count++;
        }
      }
    }
    return count;
  }

  // [추가 및 수정 완료] 중복 없는 모든 음식 이름 목록 가져오기
  Future<List<String>> getUniqueFoodNames() async {
    final db = await _dbHelper.database;
    // 'tableName' getter 대신 실제 테이블 이름 'RefrigGoods'를 사용합니다.
    final List<Map<String, dynamic>> maps = await db.query(
      'RefrigGoods',
      distinct: true,
      columns: ['foodName'],
      orderBy: 'foodName ASC',
    );

    return List.generate(maps.length, (i) {
      return maps[i]['foodName'] as String;
    });
  }

  // [추가] 월별 소비량 통계
  // 월별로 'useAmount'가 1 이상인 (소비된) 상품의 수를 계산합니다.
  Future<Map<String, int>> getMonthlyConsumptionStats() async {
    final db = await _dbHelper.database;
    // 'inputDate'를 'YYYY-MM' 형식으로 자르고, 이 형식으로 그룹화하여 각 그룹의 개수를 셉니다.
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT
      strftime('%Y-%m', inputDate) as month,
      COUNT(*) as count
    FROM RefrigGoods
    WHERE useAmount IS NOT NULL AND CAST(useAmount AS INTEGER) > 0
    GROUP BY month
    ORDER BY month DESC
  ''');

    return {for (var map in maps) map['month'] as String: map['count'] as int};
  }

  // [추가] 가장 많이 구매한 상품 TOP 5
  // 'foodName'으로 그룹화하여 가장 많이 등장하는 상품 5개를 가져옵니다.
  Future<List<Map<String, dynamic>>> getTopPurchasedItems({
    int limit = 5,
  }) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT
      foodName,
      COUNT(*) as count
    FROM RefrigGoods
    GROUP BY foodName
    ORDER BY count DESC
    LIMIT ?
  ''',
      [limit],
    );

    return maps;
  }

  // [추가] 소비 습관 통계 (소비기한 내/만료)
  // 소비기한(useDate)과 현재 날짜를 비교하여 소비/만료된 상품 수를 계산합니다.
  Future<Map<String, int>> getConsumptionHabitStats() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // 소비기한 내에 소비한 상품 수
    final consumedOnTimeResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count
    FROM RefrigGoods
    WHERE useAmount IS NOT NULL AND CAST(useAmount AS INTEGER) > 0
    AND useDate >= ?
  ''',
      [today],
    );
    final int consumedOnTime = Sqflite.firstIntValue(consumedOnTimeResult) ?? 0;

    // 소비기한이 지나 만료된 (소비되지 않은) 상품 수
    final expiredResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count
    FROM RefrigGoods
    WHERE (useAmount IS NULL OR CAST(useAmount AS INTEGER) = 0)
    AND useDate < ?
  ''',
      [today],
    );
    final int expired = Sqflite.firstIntValue(expiredResult) ?? 0;

    return {'consumedOnTime': consumedOnTime, 'expired': expired};
  }


}
