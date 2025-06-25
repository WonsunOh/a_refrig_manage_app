import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/refrig_goods_model.dart';
import '../presentation/viewmodels/remain_use_day_viewmodel.dart';
import 'goods_providers.dart'; // goodsRepositoryProvider를 재사용하기 위해 import

final remainUseDayViewModelProvider = StateNotifierProvider<
    RemainUseDayViewModel, AsyncValue<List<Product>>>((ref) {
  // 이미 만들어둔 goodsRepositoryProvider를 재사용합니다.
  return RemainUseDayViewModel(ref.watch(goodsRepositoryProvider));
});