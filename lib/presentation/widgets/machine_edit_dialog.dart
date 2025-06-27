// lib/presentation/widgets/machine_edit_dialog.dart (수정 기능 전용)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../data/models/machine_name_model.dart';
import '../../providers.dart';

class MachineEditDialog extends ConsumerStatefulWidget {
  // 수정할 공간의 정보를 반드시 받아옵니다.
  final MachineName machineToEdit;

  const MachineEditDialog({super.key, required this.machineToEdit});

  @override
  ConsumerState<MachineEditDialog> createState() => _MachineEditDialogState();
}

class _MachineEditDialogState extends ConsumerState<MachineEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    // 전달받은 정보로 위젯의 상태를 초기화합니다.
    _nameController = TextEditingController(text: widget.machineToEdit.machineName);
    _selectedType = widget.machineToEdit.machineType ?? '냉장고';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 기존 MachineName 객체를 복사하여 수정된 내용으로 새 객체를 만듭니다.
      final updatedMachine = widget.machineToEdit.copyWith(
        machineName: _nameController.text,
        machineType: _selectedType,
      );
      // ViewModel의 updateMachine 메소드를 호출합니다.
      ref.read(machineViewModelProvider.notifier).updateMachine(updatedMachine);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('공간 수정'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '공간 이름'),
              validator: (value) => (value == null || value.isEmpty) ? '이름을 입력하세요.' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: '공간 타입'),
              items: ['냉장고', '실온 보관장소']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() { _selectedType = value; });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('취소')),
        ElevatedButton(onPressed: _submit, child: const Text('저장')),
      ],
    );
  }
}