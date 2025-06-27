import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/product_model.dart';
import '../../providers.dart';

class QuickAddDialog extends ConsumerStatefulWidget {
  final String refrigName;
  final String storageName;
  final String containerName;

  const QuickAddDialog({
    super.key,
    required this.refrigName,
    required this.storageName,
    required this.containerName,
  });

  @override
  ConsumerState<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends ConsumerState<QuickAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _useDate = DateTime.now().add(const Duration(days: 7));
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        refrigName: widget.refrigName,
        storageName: widget.storageName,
        containerName: widget.containerName,
        foodName: _nameController.text,
        iconAdress: '⭐', // 간편 추가 아이콘은 별도로 지정
        inputDate: DateTime.now(), // 구매일은 오늘 날짜로 자동 설정
        useDate: _useDate,
      );

      ref.read(goodsViewModelProvider(widget.refrigName).notifier).addGood(newProduct);
      Navigator.of(context).pop(); // 다이얼로그 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('간편 추가'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '음식 이름'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '음식 이름을 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("소비기한"),
              subtitle: Text(_dateFormat.format(_useDate)),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _useDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  setState(() {
                    _useDate = pickedDate;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
        ElevatedButton(onPressed: _submit, child: const Text('저장')),
      ],
    );
  }
}