// lib/presentation/views/my_home.dart (에러 해결 최종안)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers.dart';
import '../widgets/kebab_menu.dart';
import '../widgets/machine_input_dialog.dart';
import '../widgets/space_action_bottom_sheet.dart';
import '../widgets/space_detail_page_content.dart';
import 'refrig_input.dart';

// [수정!] StatefulWidget -> StatelessWidget으로 변경하여 setState 관련 에러 원천 차단
class MyHome extends ConsumerWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machineState = ref.watch(machineViewModelProvider);

    return machineState.when(
      loading: () => Scaffold(appBar: AppBar(title: const Text('나의 공간')), body: const Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(appBar: AppBar(title: const Text('나의 공간')), body: Center(child: Text('오류가 발생했습니다: $e'))),
      data: (machines) {
        // [핵심] DefaultTabController가 모든 탭 관련 상태를 관리합니다.
        return DefaultTabController(
          length: machines.isEmpty ? 0 : machines.length,
          child: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        title: const Text('나의 공간'),
                        actions: const [KebabMenu()], // KebabMenu는 그대로 유지
                        pinned: true,
                        floating: true,
                        forceElevated: innerBoxIsScrolled,
                        bottom: machines.isEmpty
                            ? null
                            : TabBar(
                                // controller 속성 없음 (DefaultTabController가 자동으로 제공)
                                isScrollable: true,
                                tabs: machines.map((machine) {
                                  return GestureDetector(
                                    onLongPress: () {
                                      Get.bottomSheet(
                                        SpaceActionBottomSheet(machine: machine),
                                        backgroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                      );
                                    },
                                    child: Tab(text: machine.machineName),
                                  );
                                }).toList(),
                              ),
                      ),
                    ];
                  },
                  body: machines.isEmpty
                      ? _buildEmptyHomeScreen(context)
                      : TabBarView(
                          // controller 속성 없음 (DefaultTabController가 자동으로 제공)
                          children: machines.map((machine) {
                            return SpaceDetailPageContent(
                              key: ValueKey(machine.id),
                              initialMachineName: machine.machineName!,
                              initialMachineType: machine.machineType,
                            );
                          }).toList(),
                        ),
                ),
                floatingActionButton: machines.isEmpty
                    ? null
                    : FloatingActionButton(
                        onPressed: () {
                          // DefaultTabController에서 현재 탭 인덱스를 안전하게 가져옵니다.
                          final currentIndex = DefaultTabController.of(context).index;
                          final currentMachine = machines[currentIndex];
                          Get.to(
                            () => const RefrigInput(),
                            arguments: {
                              'refrigName': currentMachine.machineName,
                              'machineType': currentMachine.machineType,
                              'product': null,
                            },
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyHomeScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GestureDetector(
          onTap: () => Get.to(() => const MachineNameInputDialog()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_home_work_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                '아직 생성된 공간이 없어요',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '오른쪽 위 메뉴 버튼(⋮)을 눌러\n새로운 저장 공간을 추가해보세요!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}