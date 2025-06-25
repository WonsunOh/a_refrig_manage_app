import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/refrig_goods_model.dart';
import '../presentation/viewmodels/long_term_storage_viewmodel.dart';
import 'goods_providers.dart'; // goodsRepositoryProvider를 재사용

final longTermStorageViewModelProvider = StateNotifierProvider<
    LongTermStorageViewModel, AsyncValue<List<Product>>>((ref) {
  // 기존에 만들어 둔 goodsRepositoryProvider를 재사용합니다.
  return LongTermStorageViewModel(ref.watch(goodsRepositoryProvider));
});