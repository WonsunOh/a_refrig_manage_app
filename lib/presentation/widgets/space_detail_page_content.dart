import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import 'refrig_page_view_helpers.dart'; // 잠시 후 만들 헬퍼 파일

// 이 위젯은 이제 Scaffold 없이, 순수하게 내용물만 그리는 역할을 합니다.
class SpaceDetailPageContent extends ConsumerWidget {
  final String initialMachineName;
  final String? initialMachineType;

  const SpaceDetailPageContent({
    super.key,
    required this.initialMachineName,
    required this.initialMachineType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 이제 이 페이지는 상태를 직접 관리할 필요 없이,
    // 현재 machineName과 machineType만 알면 됩니다.
    final String machineName = initialMachineName;
    final String? machineType = initialMachineType;
    
    final goodsState = ref.watch(goodsViewModelProvider(machineName));

    return Scaffold(
      body: goodsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
        data: (groupedGoods) {
          if (machineType == '냉장고') {
            return buildGroupedView(context, ref, machineName, machineType, groupedGoods);
          } else {
            return buildFlatListView(context, ref, machineType, groupedGoods);
          }
        },
      ),
      
    );
  }
}