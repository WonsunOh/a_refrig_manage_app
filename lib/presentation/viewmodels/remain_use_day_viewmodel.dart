import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goods_repository.dart';
import '../../data/models/product_model.dart';

class RemainUseDayViewModel extends StateNotifier<AsyncValue<List<Product>>> {
  final GoodsRepository _repository;
  // 사용예정일 임박 기준으로 사용할 일수 (예: 3일)
  final int _thresholdDays = 3;

  RemainUseDayViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchExpiringFoods();
  }

  Future<void> fetchExpiringFoods() async {
    state = const AsyncValue.loading();
    try {
      // 1. 모든 음식을 가져옵니다.
      final allGoods = await _repository.getAllGoods();

      // 2. 사용예정일이 임박한 음식만 필터링합니다.
      final now = DateTime.now();
      final expiringGoods = allGoods.where((product) {
        if (product.useDate == null) return false;

        // 오늘 날짜와 사용예정일의 차이를 계산합니다.
        // 날짜만 비교하기 위해 시/분/초는 0으로 초기화합니다.
        final today = DateTime(now.year, now.month, now.day);
        final useDate = DateTime(
          product.useDate!.year,
          product.useDate!.month,
          product.useDate!.day,
        );

        final difference = useDate.difference(today).inDays;

        // 사용예정일이 지났거나(_thresholdDays 이내) 오늘까지인 경우
        return difference >= 0 && difference <= _thresholdDays;
      }).toList();

      // [핵심 수정] 사용예정일(useDate)을 기준으로 리스트를 오름차순 정렬합니다.
      // 사용예정일이 가장 가까운 음식이 맨 위로 오게 됩니다.
      expiringGoods.sort((a, b) {
        if (a.useDate == null && b.useDate == null) return 0;
        if (a.useDate == null) return 1; // 날짜 없는 항목을 뒤로 보냄
        if (b.useDate == null) return -1; // 날짜 없는 항목을 뒤로 보냄
        return a.useDate!.compareTo(b.useDate!);
      });

      // 3. 필터링된 목록을 상태로 설정합니다.
      state = AsyncValue.data(expiringGoods);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
