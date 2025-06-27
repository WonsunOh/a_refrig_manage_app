// lib/presentation/widgets/app_bar_popup_menu.dart (최종 수정안)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../data/models/machine_name_model.dart';
import '../../providers.dart';
import 'machine_edit_dialog.dart';
import 'machine_input_dialog.dart';

class AppBarPopupMenu extends ConsumerWidget {
  // [추가] MyHome으로부터 현재 공간 목록과 선택된 탭 인덱스를 전달받습니다.
  final List<MachineName> machines;
  final int? tabIndex;

  const AppBarPopupMenu({
    super.key,
    required this.machines,
    this.tabIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        // 현재 선택된 공간 정보를 가져옵니다.
        final MachineName? currentMachine = (tabIndex != null && machines.isNotEmpty) ? machines[tabIndex!] : null;

        if (value == 'add') {
          showDialog(
            context: context,
            builder: (context) => MachineNameInputDialog(), // 수정이 아니므로 인자 없음
          );
        } else if (value == 'edit') {
          if (currentMachine != null) {
            showDialog(
              context: context,
              builder: (context) => MachineEditDialog(machineToEdit: currentMachine), // 수정할 공간 정보 전달
            );
          }
        } else if (value == 'delete') {
          if (currentMachine != null) {
            // 삭제 확인 다이얼로그를 띄웁니다.
            final bool? shouldDelete = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('공간 삭제'),
                content: Text(
                  "'${currentMachine.machineName}' 공간을 삭제하시겠습니까?\n\n⚠️ 경고: 이 공간에 저장된 모든 음식 정보도 함께 영구적으로 삭제됩니다.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            // 사용자가 '삭제'를 선택한 경우
            if (shouldDelete == true) {
              await ref.read(machineViewModelProvider.notifier).deleteMachine(currentMachine.id!, currentMachine.machineName!);
              Get.snackbar(
                '삭제 완료',
                "'${currentMachine.machineName}' 공간이 삭제되었습니다.",
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
        }
      },
      itemBuilder: (BuildContext context) {
        // 공간이 있을 때만 수정/삭제 메뉴를 활성화합니다.
        final bool canEditOrDelete = machines.isNotEmpty;

        return [
          const PopupMenuItem<String>(
            value: 'add',
            child: Text('새 공간 추가'),
          ),
          PopupMenuItem<String>(
            value: 'edit',
            enabled: canEditOrDelete, // 활성화/비활성화
            child: Text('현재 공간 수정', style: TextStyle(color: canEditOrDelete ? null : Colors.grey)),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            enabled: canEditOrDelete, // 활성화/비활성화
            child: Text('현재 공간 삭제', style: TextStyle(color: canEditOrDelete ? Colors.red : Colors.grey)),
          ),
        ];
      },
    );
  }
}