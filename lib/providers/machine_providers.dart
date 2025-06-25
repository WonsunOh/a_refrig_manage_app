
// 1. Repository Provider: MachineRepository의 인스턴스를 제공합니다.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/machine_repository.dart';
import '../models/machine_name_model.dart';
import '../presentation/viewmodels/machine_viewmodel.dart';
import 'goods_providers.dart';

final machineRepositoryProvider = Provider<MachineRepository>((ref) {
  return MachineRepository();
});

// 2. ViewModel Provider: MachineViewModel의 인스턴스를 생성하고 상태 변화를 감지할 수 있도록 StateNotifierProvider를 사용합니다.
//    ViewModel이 생성될 때 Repository를 주입(DI)해줍니다.
final machineViewModelProvider =
    StateNotifierProvider<MachineViewModel, AsyncValue<List<MachineName>>>((ref) {
  return MachineViewModel(
    ref.watch(machineRepositoryProvider),
    ref.watch(goodsRepositoryProvider), // GoodsRepository 주입
  );
});