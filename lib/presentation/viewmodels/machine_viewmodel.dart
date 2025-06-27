import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goods_repository.dart';
import '../../data/repositories/machine_repository.dart';
import '../../data/models/machine_name_model.dart';

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
  Future<void> addMachine(MachineName machine) async {
    try {
      await _machineRepository
          .addMachineName(machine);
      fetchMachineNames();
    } catch (e, s) {
      // 에러 처리 로직 (예: 사용자에게 알림)
      state = AsyncValue.error(e, s);
    }
  }

  /// 기기 정보를 수정하는 메소드
  Future<void> updateMachine(MachineName machine) async {
    try {
      await _machineRepository.updateMachineName(machine);
      fetchMachineNames();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // /// 기기를 삭제하는 메소드
  // Future<void> deleteMachine(int id, String machineName) async {
  //   try {
  //     await _goodsRepository.deleteGoodsByRefrigName(machineName);
  //     await _machineRepository.deleteMachineName(id);
  //     fetchMachineNames();
  //   } catch (e, s) {
  //     state = AsyncValue.error(e, s);
  //   }
  // }
  // [수정!] 공간 삭제 로직에 디버깅 로그를 추가합니다.
  Future<void> deleteMachine(int id, String machineName) async {
    debugPrint("--- 공간 삭제 프로세스 시작: $machineName (ID: $id) ---");
    try {
      // 1. 해당 공간에 속한 모든 음식 데이터를 먼저 삭제합니다.
      debugPrint("1단계: '$machineName'에 속한 음식물 삭제 시작...");
      final deletedRows = await _goodsRepository.deleteGoodsByRefrigName(machineName);
      debugPrint("1단계 완료: $deletedRows 개의 음식물 데이터 삭제됨.");

      // 2. 음식 데이터 삭제가 성공하면, 공간 자체를 삭제합니다.
      debugPrint("2단계: '$machineName' 공간 자체 삭제 시작...");
      await _machineRepository.deleteMachineName(id);
      debugPrint("2단계 완료: 공간 삭제 성공.");

      // 3. 모든 DB 작업이 성공적으로 끝나면, UI를 새로고침합니다.
      debugPrint("3단계: 공간 목록 새로고침 시작...");
      fetchMachineNames();
      debugPrint("--- 공간 삭제 프로세스 성공 ---");
    } catch (e, stack) {
      debugPrint("!!! 공간 삭제 중 에러 발생: $e");
      debugPrint(stack.toString());
      state = AsyncValue.error(e, stack);
    }
  }
}