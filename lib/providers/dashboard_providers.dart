import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_state_model.dart';
import '../presentation/viewmodels/dashboard_viewmodel.dart';
import 'goods_providers.dart';
import 'machine_providers.dart';

final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardState>>((ref) {
  // 음식 데이터를 가져오기 위해 기존 GoodsRepository를 사용합니다.
  return DashboardViewModel(
    ref.watch(goodsRepositoryProvider),
    ref.watch(machineRepositoryProvider),
  );
});