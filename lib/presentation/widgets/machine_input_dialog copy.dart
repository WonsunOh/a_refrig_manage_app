import 'package:flutter/material.dart';

class MachineNameInputDialog extends StatefulWidget {
  final Function(String name, String icon, String type) onSubmitted;

  const MachineNameInputDialog({super.key, required this.onSubmitted});

  @override
  State<MachineNameInputDialog> createState() => _MachineNameInputDialogState();
}

class _MachineNameInputDialogState extends State<MachineNameInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = '냉장고'; // 기본 선택값

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final icon = _selectedType == '냉장고' ? '🧊' : '📦';
              widget.onSubmitted(_nameController.text, icon, _selectedType);
              Navigator.of(context).pop();
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}