import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/goods_repository.dart';
import '../../core/repositories/machine_repository.dart';
import '../../models/machine_name_model.dart';

/// MachineName 리스트의 상태를 관리하는 ViewModel
class MachineViewModel extends StateNotifier<AsyncValue<List<MachineName>>> {
  final MachineRepository _machineRepository;
  final GoodsRepository _goodsRepository; // GoodsRepository 추가

  // [수정] 생성자에서 GoodsRepository를 받도록 변경
  MachineViewModel(this._machineRepository, this._goodsRepository)
      : super(const AsyncValue.loading()) {
    fetchMachineNames();
  }

  // [수정] fetchMachineNames 메소드 로직 강화
  Future<void> fetchMachineNames() async {
    state = const AsyncValue.loading();
    try {
      // 1. 기본 냉장고 목록을 가져옵니다.
      final baseMachines = await _machineRepository.getMachineNames();

      // 2. 각 냉장고의 요약 정보를 계산하여 새로운 리스트를 만듭니다.
      final summaryMachines = <MachineName>[];
      for (var machine in baseMachines) {
        final totalCount = await _goodsRepository.getGoodsCount(machine.machineName!);
        final expiringCount = await _goodsRepository.getExpiringSoonCount(machine.machineName!);

        // copyWith를 사용해 기존 정보에 요약 정보를 추가한 새 객체를 생성
        summaryMachines.add(machine.copyWith(
          totalItemCount: totalCount,
          expiringItemCount: expiringCount,
        ));
      }
      
      // 3. 요약 정보가 포함된 최종 리스트를 상태로 설정합니다.
      state = AsyncValue.data(summaryMachines);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// 새로운 기기를 추가하는 메소드
  Future<void> addMachineName(String name, String icon, String type) async {
    try {
      await _machineRepository
          .addMachineName(MachineName(machineName: name, refrigIcon: icon, machineType: type));
      fetchMachineNames();
    } catch (e, s) {
      // 에러 처리 로직 (예: 사용자에게 알림)
      state = AsyncValue.error(e, s);
    }
  }

  /// 기기 정보를 수정하는 메소드
  Future<void> updateMachineName(MachineName machine) async {
    try {
      await _machineRepository.updateMachineName(machine);
      fetchMachineNames();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// 기기를 삭제하는 메소드
  Future<void> deleteMachineName(int id) async {
    try {
      await _machineRepository.deleteMachineName(id);
      fetchMachineNames();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}