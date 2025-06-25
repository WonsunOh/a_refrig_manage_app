import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/goods_repository.dart';
import '../../core/repositories/machine_repository.dart';
import '../../models/dashboard_state_model.dart';
import '../../models/machine_name_model.dart';
import '../../models/refrig_goods_model.dart';

class DashboardViewModel extends StateNotifier<AsyncValue<DashboardState>> {
  final GoodsRepository _goodsRepository;
  final MachineRepository _machineRepository; // MachineRepository 추가

  // [수정] 생성자에서 MachineRepository를 받도록 변경
  DashboardViewModel(this._goodsRepository, this._machineRepository) : super(const AsyncValue.loading()) {
    fetchDashboardData();
  }
  Future<void> fetchDashboardData() async {
    state = const AsyncValue.loading();
    try {
      // 1. 모든 음식과 모든 공간(machine) 정보를 병렬로 가져옵니다.
      final allGoodsFuture = _goodsRepository.getAllGoods();
      final allMachinesFuture = _machineRepository.getMachineNames();

      final results = await Future.wait([allGoodsFuture, allMachinesFuture]);
      
      final allGoods = results[0] as List<Product>;
      final allMachines = results[1] as List<MachineName>;

      // 2. 공간 이름과 타입을 매핑하는 Map을 만듭니다.
      final machineTypeMap = <String, String?>{};
      for (var machine in allMachines) {
        machineTypeMap[machine.machineName!] = machine.machineType;
      }
      
      // 3. 기존의 소비기한 필터링 로직은 그대로 수행합니다.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final List<Product> expiringTodayList = [];
      final List<Product> expiringSoonList = [];

      for (var product in allGoods) {
        if (product.useDate != null) {
          final useDate = DateTime(product.useDate!.year, product.useDate!.month, product.useDate!.day);
          final difference = useDate.difference(today).inDays;

          if (difference == 0) {
            expiringTodayList.add(product);
          } else if (difference > 0 && difference <= 3) {
            expiringSoonList.add(product);
          }
        }
      }
      
      // 4. 최종적으로 모든 정보를 담은 DashboardState를 상태로 설정합니다.
      state = AsyncValue.data(DashboardState(
        expiringToday: expiringTodayList,
        expiringSoon: expiringSoonList,
        machineTypeMap: machineTypeMap, // 타입 맵 정보 포함
      ));

    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}