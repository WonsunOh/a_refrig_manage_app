import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goods_repository.dart';
import '../../data/models/product_model.dart';

class LongTermStorageViewModel
    extends StateNotifier<AsyncValue<List<Product>>> {
  final GoodsRepository _repository;
  // // 오래된 음식 기준으로 사용할 일수 (예: 180일)
  // final int _thresholdDays = 180;

  LongTermStorageViewModel(this._repository)
      : super(const AsyncValue.loading()) {
    fetchLongTermStorageFoods();
  }

  Future<void> fetchLongTermStorageFoods() async {
    state = const AsyncValue.loading();
    try {
      // 1. 모든 음식을 가져옵니다.
      final allGoods = await _repository.getAllGoods();
      // ✅ [수정] isLongTermStorage가 true인 음식만 필터링합니다.
      final longTermFoods = allGoods.where((product) => product.isLongTermStorage).toList();
      state = AsyncValue.data(longTermFoods);

      // // 2. 구매한 지 오래된 음식만 필터링합니다.
      // final now = DateTime.now();
      // final longTermFoods = allGoods.where((product) {
      //   if (product.inputDate == null) return false;

      //   // 오늘 날짜와 구매일의 차이를 계산합니다.
      //   final difference = now.difference(product.inputDate!).inDays;

      //   // 구매한 지 _thresholdDays(180일)가 넘었는지 확인
      //   return difference > _thresholdDays;
      // }).toList();

      // // 3. 필터링된 목록을 상태로 설정합니다.
      // state = AsyncValue.data(longTermFoods);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}