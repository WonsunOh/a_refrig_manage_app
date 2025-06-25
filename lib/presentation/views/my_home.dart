import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers/machine_providers.dart';
import '../widgets/app_bar_popup_menu.dart';
import '../widgets/space_detail_page_content.dart';
import 'screens/refrig_input.dart';

class MyHome extends ConsumerStatefulWidget {
  const MyHome({super.key});

  @override
  ConsumerState<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends ConsumerState<MyHome> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _updateTabController(int length) {
    if (_tabController?.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
      _tabController!.addListener(() => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final machineState = ref.watch(machineViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 공간'),
        actions: [
          AppBarPopupMenu(),
        ],
        bottom: machineState.when(
          data: (machines) {
            _updateTabController(machines.length);
            if (machines.isEmpty) return null;
            return TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: machines.map((m) => Tab(text: m.machineName)).toList(),
            );
          },
          loading: () => const PreferredSize(preferredSize: Size.fromHeight(kTextTabBarHeight), child: LinearProgressIndicator()),
          error: (e, s) => null,
        ),
      ),
      body: machineState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('오류: $e')),
        data: (machines) {
          if (machines.isEmpty) {
            return const Center(child: Text('서랍 메뉴의 \'새로운 공간 추가\'로 공간을 만들어보세요.'));
          }
          return TabBarView(
            controller: _tabController,
            children: machines.map((machine) {
              return SpaceDetailPageContent(
                key: ValueKey(machine.id),
                initialMachineName: machine.machineName!,
                initialMachineType: machine.machineType,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: machineState.whenOrNull(
        data: (machines) {
          if (machines.isEmpty) return null;
          
          final currentIndex = _tabController?.index ?? 0;
          if (currentIndex >= machines.length) return null;
          
          return FloatingActionButton(
            heroTag: 'my_home_fab',
            tooltip: '음식/물품 추가',
            onPressed: () {
              final currentMachine = machines[currentIndex];
              Get.to(() => const RefrigInput(), arguments: {
                'refrigName': currentMachine.machineName,
                'machineType': currentMachine.machineType,
                'product': null,
              });
            }, // 이 페이지에 단 하나뿐인 FAB
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}