// lib/presentation/widgets/space_action_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../data/models/machine_name_model.dart';
import '../../providers.dart';
import 'machine_edit_dialog.dart';

class SpaceActionBottomSheet extends ConsumerWidget {
  final MachineName machine;

  const SpaceActionBottomSheet({super.key, required this.machine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16), // 하단 여백 추가
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('공간 정보 수정'),
            onTap: () {
              Get.back(); // 먼저 BottomSheet를 닫습니다.
              // 수정을 위한 MachineEditDialog를 띄웁니다.
              showDialog(
                context: context,
                builder: (_) => MachineEditDialog(machineToEdit: machine),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
            title: Text('공간 삭제', style: TextStyle(color: Colors.red.shade700)),
            onTap: () {
              
              Get.dialog<bool>(
                AlertDialog(
                  title: const Text('공간 삭제'),
                  content: Text(
                    "'${machine.machineName}' 공간을 삭제하시겠습니까?\n\n⚠️ 경고: 이 공간에 저장된 모든 음식 정보도 함께 영구적으로 삭제됩니다.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      // [수정!] 삭제 실행 로직을 확인창의 '삭제' 버튼으로 모두 옮깁니다.
                      onPressed: () async {
                        // 1. 확인창을 닫습니다.
                        Get.back(); 
                        // 2. 그 뒤에 있던 BottomSheet를 닫습니다.
                        Get.back(); 

                        // 3. 모든 창이 닫힌 후, 안전하게 삭제 로직을 실행합니다.
                        await ref.read(machineViewModelProvider.notifier).deleteMachine(machine.id!, machine.machineName!);
                        
                        // 4. 사용자에게 피드백을 줍니다.
                        Get.snackbar(
                          '삭제 완료',
                          "'${machine.machineName}' 공간이 삭제되었습니다.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              
            },
          ),
          const Divider(),
          ListTile(
            title: const Center(child: Text('취소')),
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }
}