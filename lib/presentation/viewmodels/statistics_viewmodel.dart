// lib/viewmodel/statistics_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_refrig_manage_app/providers.dart';

import '../../data/repositories/goods_repository.dart'; // 중앙 프로바이더 파일 import

// 1. 통계 데이터 전체를 담을 모델 클래스
class StatisticsState {
  final AsyncValue<Map<String, int>> monthlyConsumption;
  final AsyncValue<List<Map<String, dynamic>>> topPurchasedItems;
  final AsyncValue<Map<String, int>> consumptionHabits;

  StatisticsState({
    this.monthlyConsumption = const AsyncValue.loading(),
    this.topPurchasedItems = const AsyncValue.loading(),
    this.consumptionHabits = const AsyncValue.loading(),
  });

  StatisticsState copyWith({
    AsyncValue<Map<String, int>>? monthlyConsumption,
    AsyncValue<List<Map<String, dynamic>>>? topPurchasedItems,
    AsyncValue<Map<String, int>>? consumptionHabits,
  }) {
    return StatisticsState(
      monthlyConsumption: monthlyConsumption ?? this.monthlyConsumption,
      topPurchasedItems: topPurchasedItems ?? this.topPurchasedItems,
      consumptionHabits: consumptionHabits ?? this.consumptionHabits,
    );
  }
}


// 2. ViewModel (StateNotifier)
class StatisticsViewModel extends StateNotifier<StatisticsState> {
  final GoodsRepository _goodsRepository;

  StatisticsViewModel(this._goodsRepository) : super(StatisticsState()) {
    fetchAllStats();
  }

  Future<void> fetchAllStats() async {
    // 초기 로딩 상태 설정
    state = StatisticsState();
    
    // 각 통계 데이터를 비동기적으로 불러와 상태를 업데이트합니다.
    try {
      final monthlyData = await _goodsRepository.getMonthlyConsumptionStats();
      state = state.copyWith(monthlyConsumption: AsyncValue.data(monthlyData));
      
      final topItemsData = await _goodsRepository.getTopPurchasedItems();
      state = state.copyWith(topPurchasedItems: AsyncValue.data(topItemsData));
      
      final habitsData = await _goodsRepository.getConsumptionHabitStats();
      state = state.copyWith(consumptionHabits: AsyncValue.data(habitsData));

    } catch (e, stack) {
      // 에러 발생 시 상태 업데이트
      state = StatisticsState(
        monthlyConsumption: AsyncValue.error(e, stack),
        topPurchasedItems: AsyncValue.error(e, stack),
        consumptionHabits: AsyncValue.error(e, stack),
      );
    }
  }
}

// 3. Provider 정의
// 이 Provider는 lib/providers.dart 파일로 옮겨서 중앙 관리하는 것을 추천합니다.
