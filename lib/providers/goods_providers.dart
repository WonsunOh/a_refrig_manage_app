import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/goods_repository.dart';
import '../models/refrig_goods_model.dart';
import '../presentation/viewmodels/goods_viewmodel.dart';

// 1. GoodsRepository Provider
final goodsRepositoryProvider = Provider<GoodsRepository>((ref) {
  return GoodsRepository();
});

// [수정] StateNotifierProvider가 다루는 상태의 타입을
// ViewModel의 상태 타입과 동일하게 맞춰줍니다.
final goodsViewModelProvider = StateNotifierProvider.family<
    GoodsViewModel, AsyncValue<Map<String, Map<String, List<Product>>>>, String>((ref, refrigName) {
  return GoodsViewModel(ref.watch(goodsRepositoryProvider), refrigName);
});