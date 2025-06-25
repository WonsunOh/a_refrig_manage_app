
import '../../models/refrig_goods_model.dart';
import '../database/refrig_goods_db_helper.dart';

/// Goods 데이터 소스를 관리하는 저장소 클래스
class GoodsRepository {
  final RefrigGoodsDBHelper _dbHelper;

  GoodsRepository({RefrigGoodsDBHelper? dbHelper})
      : _dbHelper = dbHelper ?? RefrigGoodsDBHelper();

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

  // [신규] 특정 냉장고의 전체 품목 수를 가져오는 메소드
  Future<int> getGoodsCount(String refrigName) async {
    final goods = await _dbHelper.getGoods(refrigName);
    return goods.length;
  }

  // [신규] 특정 냉장고의 소비기한 임박 품목 수를 가져오는 메소드
  Future<int> getExpiringSoonCount(String refrigName, {int thresholdDays = 3}) async {
    final goods = await _dbHelper.getGoods(refrigName);
    final now = DateTime.now();
    int count = 0;

    for (var product in goods) {
      if (product.useDate != null) {
        final today = DateTime(now.year, now.month, now.day);
        final useDate = DateTime(product.useDate!.year, product.useDate!.month, product.useDate!.day);
        final difference = useDate.difference(today).inDays;
        if (difference >= 0 && difference <= thresholdDays) {
          count++;
        }
      }
    }
    return count;
  }
  
}