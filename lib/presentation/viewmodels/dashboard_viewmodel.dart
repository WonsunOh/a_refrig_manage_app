// lib/presentation/viewmodels/dashboard_viewmodel.dart (최종 수정안)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_state_model.dart';
import '../../data/repositories/goods_repository.dart';

class DashboardViewModel extends StateNotifier<AsyncValue<DashboardState>> {
  final GoodsRepository _goodsRepository;

  DashboardViewModel(this._goodsRepository) : super(const AsyncLoading()) {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    state = const AsyncValue.loading();
    try {
      final allGoods = await _goodsRepository.getAllGoods();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 소비기한이 3일 이내로 남은 상품들을 필터링합니다.
      final imminentExpiryList = allGoods.where((p) {
        if (p.useDate == null) return false;
        final difference = p.useDate!.difference(today).inDays;
        return difference >= 0 && difference <= 3;
      }).toList();

      // 구매한 지 30일이 넘은 상품들을 필터링합니다.
      final longTermStorageList = allGoods.where((p) {
        // p.inputDate가 null이면 이 상품은 계산에서 제외합니다.
        if (p.inputDate == null) return false; 
        
        // inputDate가 null이 아님이 보장되므로, ! 연산자를 안전하게 사용할 수 있습니다.
        final difference = today.difference(p.inputDate!).inDays;
        return difference > 30;
      }).toList();

      state = AsyncValue.data(
        DashboardState(
          imminentExpiry: imminentExpiryList,
          longTermStorage: longTermStorageList,
        ),
      );
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}