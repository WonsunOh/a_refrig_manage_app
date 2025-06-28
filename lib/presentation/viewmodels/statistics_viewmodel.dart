// lib/viewmodel/statistics_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/goods_repository.dart'; // 중앙 프로바이더 파일 import


enum StatisticsPeriod { monthly, quarterly, yearly }
// 1. 통계 데이터 전체를 담을 모델 클래스
class StatisticsState {
  final AsyncValue<Map<String, int>> monthlyConsumption;
  final AsyncValue<List<Map<String, dynamic>>> topPurchasedItems;
  final AsyncValue<Map<String, int>> consumptionHabits;

  // ✅ [추가] 현재 선택된 기간을 저장하기 위한 상태
  final StatisticsPeriod period;

  StatisticsState({
    this.monthlyConsumption = const AsyncValue.loading(),
    this.topPurchasedItems = const AsyncValue.loading(),
    this.consumptionHabits = const AsyncValue.loading(),

    this.period = StatisticsPeriod.monthly,
  });

  StatisticsState copyWith({
    AsyncValue<Map<String, int>>? monthlyConsumption,
    AsyncValue<List<Map<String, dynamic>>>? topPurchasedItems,
    AsyncValue<Map<String, int>>? consumptionHabits,

    StatisticsPeriod? period,
  }) {
    return StatisticsState(
      monthlyConsumption: monthlyConsumption ?? this.monthlyConsumption,
      topPurchasedItems: topPurchasedItems ?? this.topPurchasedItems,
      consumptionHabits: consumptionHabits ?? this.consumptionHabits,

      period: period ?? this.period,
    );
  }
}


// 2. ViewModel (StateNotifier)
class StatisticsViewModel extends StateNotifier<StatisticsState> {
  final GoodsRepository _goodsRepository;

  StatisticsViewModel(this._goodsRepository) : super(StatisticsState()) {
    fetchAllStats(state.period);
  }

   // ✅ 기간 변경을 위한 public 메소드
  Future<void> setPeriod(StatisticsPeriod period) async {
    // 이 메소드가 UI의 버튼과 연결됩니다.
    fetchAllStats(period);
  }

  Future<void> fetchAllStats(StatisticsPeriod period) async {
    // 1. 로딩 상태와 현재 선택된 기간으로 state 업데이트
    state = StatisticsState(period: period);

    try {
      // Repository의 메소드를 각각 호출합니다.
      final monthlyData = await _goodsRepository.getMonthlyConsumptionStats(period: period);
      final topItemsData = await _goodsRepository.getTopPurchasedItems(period: period);
      final habitsData = await _goodsRepository.getConsumptionHabitStats(period: period);

      // 최종 상태 업데이트
      state = state.copyWith(
        monthlyConsumption: AsyncValue.data(monthlyData),
        topPurchasedItems: AsyncValue.data(topItemsData),
        consumptionHabits: AsyncValue.data(habitsData),
      );
    } catch (e, stack) {
      // 에러 처리
      state = StatisticsState(
        period: period,
        monthlyConsumption: AsyncValue.error(e, stack),
        topPurchasedItems: AsyncValue.error(e, stack),
        consumptionHabits: AsyncValue.error(e, stack),
      );
    }
  }
}

// 3. Provider 정의
// 이 Provider는 lib/providers.dart 파일로 옮겨서 중앙 관리하는 것을 추천합니다.
