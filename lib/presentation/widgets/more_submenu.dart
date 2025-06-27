import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers.dart';
import '../screens/memo/memo_main_screen.dart';
import '../screens/error_inquiry.dart';
import '../screens/youtube_screen.dart';

// StatelessWidget을 ConsumerWidget으로 변경
class MoreSubMenu extends ConsumerWidget {
  const MoreSubMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태 변화를 감지하여 스낵바 등을 표시
    // ref.listen<BackupRestoreState>(backupRestoreViewModelProvider, (
    //   previous,
    //   next,
    // ) {
    //   if (next == BackupRestoreState.success) {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(const SnackBar(content: Text('작업이 성공적으로 완료되었습니다.')));
    //     ref.read(backupRestoreViewModelProvider.notifier).resetState();
    //   } else if (next == BackupRestoreState.error) {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(const SnackBar(content: Text('오류가 발생했습니다.')));
    //     ref.read(backupRestoreViewModelProvider.notifier).resetState();
    //   }
    // });

    // 현재 백업/복원 진행 상태
    final backupState = ref.watch(backupRestoreViewModelProvider);
    return Stack(
        children: [
          ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.kitchen_outlined),
                title: const Text('나의 공간 관리 (냉장고)'),
                subtitle: const Text('냉장고, 선반 등 새로운 공간을 추가하거나 관리합니다.'),
                onTap: () {
                 // [수정] Get.toNamed 대신, Riverpod Provider의 상태를 변경하여 탭을 이동시킵니다.
                  // '나의 공간' 탭의 인덱스는 1입니다.
                  ref.read(bottomNavIndexProvider.notifier).state = 1;
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('오래 보관한 음식'),
                onTap: () {
                  Get.toNamed('/longTermStorage');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: const Text('오류 및 개선 문의'),
                onTap: () {
                  Get.to(() => const ErrorInquiry());
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('유튜브 검색'),
                onTap: () {
                  Get.to(() => YouTubeScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: const Text('광고제거 구매'),
                onTap: () {
                  Get.to(() => const MemoMainPage());
                },
              ),
            ],
          ),
          // 백업/복원 진행 중일 때 로딩 인디케이터 표시
          
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      );
  }
}
