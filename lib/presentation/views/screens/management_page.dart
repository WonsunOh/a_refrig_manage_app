import 'package:a_refrig_manage_app/presentation/views/screens/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../adMob/memo_main_page.dart';
import '../../../models/backup_restore_state.dart';
import '../../../providers/backup_restore_providers.dart';
import '../../../providers/machine_providers.dart';
import '../../../providers/ui_providers.dart';
import '../../widgets/machine_input_dialog.dart';
import 'error_inquiry.dart';

class ManagementPage extends ConsumerWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태가 'inProgress'인지 감시하여 로딩 화면을 제어합니다.
    final isProcessing =
        ref.watch(backupRestoreViewModelProvider) ==
        BackupRestoreStatus.inProgress;

    // [핵심] 앱 전역의 백업/복원 상태를 감시하고 피드백을 보여주는 최종 리스너
    ref.listen<BackupRestoreStatus>(backupRestoreViewModelProvider, (
      previous,
      next,
    ) {
      final notifier = ref.read(backupRestoreViewModelProvider.notifier);

      // 작업이 끝난 후에만 피드백을 보여주도록 필터링
      if (next == BackupRestoreStatus.inProgress ||
          next == BackupRestoreStatus.initial) {
        return;
      }

      // 작업이 끝난 후 로딩 상태를 해제하기 위해 상태를 초기화
      // 피드백을 보여준 후 초기화하면, 팝업이 닫히는 등 문제가 생길 수 있으므로 먼저 처리
      notifier.resetState();

      switch (next) {
        case BackupRestoreStatus.backupSuccess:
        case BackupRestoreStatus.exportSuccess:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('성공적으로 처리되었습니다.')));
          break;
        case BackupRestoreStatus.restoreSuccess:
          _showRestartDialog(context);
          break;
        case BackupRestoreStatus.restoreNoFile:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('선택된 파일이 없거나, 복원할 파일이 없습니다.')),
          );
          break;
        case BackupRestoreStatus.error:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('오류가 발생했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        default:
          break;
      }
    });

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('설정 및 관리'),
            automaticallyImplyLeading:false, // 뒤로가기 버튼 숨김
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // [핵심 수정] ManagementPage를 닫고 대시보드로 돌아갑니다.
                  ref.read(bottomNavIndexProvider.notifier).state = 1; // 대시보드로 이동
                  Get.back(); // ManagementPage 닫기
                },
              ),
            ],
          ),
          
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.add_location_outlined,
                  color: Colors.grey,
                ),
                title: const Text('새로운 공간 추가'),
                onTap: () {
                  Get.back();
                  showDialog(
                    context: context,
                    builder: (context) => Consumer(
                      builder: (context, ref, _) {
                        return MachineNameInputDialog(
                          onSubmitted: (name, icon, type) {
                            ref
                                .read(machineViewModelProvider.notifier)
                                .addMachineName(name, icon, type);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.grey,
                ),
                title: const Text('알림 설정'),
                onTap: () {
                  Get.back();
                  Get.toNamed('/settings');
                },
              ),
              const Divider(),
              ExpansionTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('백업 / 복원'),
                initiallyExpanded: false,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.save_alt_outlined,
                      color: Colors.grey,
                    ),
                    title: const Text('간편 백업 (앱 내부에 덮어쓰기)'),
                    onTap: () async{
                      final success = await ref.read(backupRestoreViewModelProvider.notifier)
                          .internalBackup();
                     if (context.mounted) {
                          if (success) {
                            // [핵심 수정] 1. 바텀 탭을 0번(대시보드)으로 변경합니다.
                            ref.read(bottomNavIndexProvider.notifier).state = 0;
                            // [핵심 수정] 2. 현재 페이지(ManagementPage)를 닫아 대시보드로 돌아갑니다.
                            Get.back();
                            // [핵심 수정] 3. 대시보드 화면 위에 성공 스낵바를 표시합니다.
                            Get.snackbar('간편 백업 성공', '백업 파일이 성공적으로 저장되었습니다.');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('간편 백업이 취소되었거나 실패했습니다.')));
                          }
                        }
                      },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_backup_restore_outlined,
                      color: Colors.grey,
                    ),
                    title: const Text('간편 복원'),
                    onTap: () async {
                      // Get.back();
                      final confirm = await _showConfirmDialog(
                        context,
                        '간편 복원 실행',
                        '가장 최근의 간편 백업으로 데이터를 되돌립니다. 계속하시겠습니까?',
                      );
                      if (confirm == true) {
                        // 확인 후, 명령만 내리고 끝
                        ref
                            .read(backupRestoreViewModelProvider.notifier)
                            .internalRestore();
                      }
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.file_upload_outlined,
                      color: Colors.grey,
                    ),
                    title: const Text('백업 파일 내보내기'),
                    subtitle: const Text('기기 변경, 앱 재설치 대비 안전한 곳(클라우드 등)에 영구 보관'),
                    onTap: () async {
                        final success = await ref.read(backupRestoreViewModelProvider.notifier).exportBackupFile();
                        
                        if (context.mounted) {
                          if (success) {
                            // [핵심 수정] 1. 바텀 탭을 0번(대시보드)으로 변경합니다.
                            ref.read(bottomNavIndexProvider.notifier).state = 0;
                            // [핵심 수정] 2. 현재 페이지(ManagementPage)를 닫아 대시보드로 돌아갑니다.
                            Get.back();
                            // [핵심 수정] 3. 대시보드 화면 위에 성공 스낵바를 표시합니다.
                            Get.snackbar('내보내기 성공', '백업 파일이 성공적으로 저장되었습니다.');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('내보내기가 취소되었거나 실패했습니다.')));
                          }
                        }
                      },
                    ),
                  ListTile(
                    leading: const Icon(
                      Icons.file_download_outlined,
                      color: Colors.grey,
                    ),
                    title: const Text('외부 파일에서 복원하기'),
                    onTap: () async {
                      final confirm = await _showConfirmDialog(
                        context,
                        '외부 파일로 복원',
                        '선택한 백업 파일로 현재 데이터를 덮어씁니다. 계속하시겠습니까?',
                      );
                      if (confirm == true) {
                        ref
                            .read(backupRestoreViewModelProvider.notifier)
                            .importBackupFile();
                      }
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.more_horiz),
                title: const Text('기타'),
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.grey,
                    ),
                    title: const Text('광고제거 구매'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const MemoMainPage());
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.report_problem_outlined,
                      color: Colors.grey,
                    ),
                    title: const Text('오류 및 개선 문의'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const ErrorInquiry());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // 작업 진행 중일 때 전체 화면에 로딩 인디케이터 표시
        if (isProcessing)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // 이 헬퍼 메소드들은 이제 Get.dialog 대신 showDialog를 사용합니다.
  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('실행'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestartDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false, // 뒤로가기 방지
          child: AlertDialog(
            title: const Text('복원 완료'),
            content: const Text('데이터가 성공적으로 복원되었습니다.\n앱을 재시작하여 변경사항을 적용합니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  // 팝업을 먼저 닫고 재시작
                  Navigator.of(dialogContext).pop();
                  Phoenix.rebirth(context);
                  Get.to(()=> BottomNavigation()); // 대시보드로 이동
                },
                child: const Text('앱 재시작'),
              ),
            ],
          ),
        );
      },
    );
  }
}
