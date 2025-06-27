// lib/presentation/widgets/machine_input_dialog.dart (추가 기능 전용)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../data/models/machine_name_model.dart';
import '../../providers.dart';

class MachineNameInputDialog extends ConsumerStatefulWidget {
  const MachineNameInputDialog({super.key});

  @override
  ConsumerState<MachineNameInputDialog> createState() => _MachineNameInputDialogState();
}

class _MachineNameInputDialogState extends ConsumerState<MachineNameInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = '냉장고';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {

      final icon = _selectedType == '냉장고' ? '🧊' : '📦';
      final newMachine = MachineName(
        machineName: _nameController.text,
        machineType: _selectedType,
        refrigIcon: icon,
      );
      // ViewModel을 직접 호출하여 새 공간을 추가합니다.
      ref.read(machineViewModelProvider.notifier).addMachine(newMachine);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 공간 추가'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름 (예: 주방 냉장고, 싱크대 밑)'),
              validator: (value) => (value == null || value.isEmpty) ? '이름을 입력하세요.' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: '공간 타입'),
              items: ['냉장고', '실온 보관장소']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
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
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
        ElevatedButton(onPressed: _submit, child: const Text('추가')),
      ],
    );
  }
}