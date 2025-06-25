import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/machine_name_model.dart';
import '../../../models/refrig_goods_model.dart';
import '../../../providers/dashboard_providers.dart';
import '../../../providers/goods_providers.dart';
import '../../../providers/long_term_storage_providers.dart';
import '../../../providers/machine_providers.dart';
import '../../../providers/remain_use_day_providers.dart';
import '../../widgets/icon_picker_dialog.dart';

class RefrigInput extends ConsumerStatefulWidget {
  const RefrigInput({super.key});

  @override
  ConsumerState<RefrigInput> createState() => _RefrigInputState();
}

class _RefrigInputState extends ConsumerState<RefrigInput> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foodNameController;
  late TextEditingController _amountController;
  late TextEditingController _memoController;
  late TextEditingController _containerController;

  Product? _editingProduct;

  // [수정] 위치 정보를 담을 상태 변수들
  late String _originalRefrigName; // 수정 전 원래 냉장고 이름
  late String _selectedRefrigName; // 현재 선택된 냉장고 이름
  late String? _selectedMachineType; // 현재 선택된 공간의 타입
  late String _selectedStorageName; // 현재 선택된 보관장소 (냉장/냉동/실온)

  // late String _refrigName;
  // late String? _machineType;
  // String _storageName = '냉장실'; // '보관장소' 상태 변수
  DateTime _inputDate = DateTime.now();
  DateTime _useDate = DateTime.now().add(const Duration(days: 7));
  String _selectedIcon = '🥩';
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _editingProduct = args['product'];

    // [수정] 초기 위치 정보 설정
    _originalRefrigName = args['refrigName'];
    _selectedRefrigName = args['refrigName'];
    _selectedMachineType = args['machineType'];
    _selectedStorageName = _editingProduct?.storageName ?? '냉장실';

    _foodNameController = TextEditingController(
      text: _editingProduct?.foodName,
    );
    _amountController = TextEditingController(text: _editingProduct?.amount);
    _memoController = TextEditingController(text: _editingProduct?.memo);
    _containerController = TextEditingController(
      text: _editingProduct?.containerName,
    );
    _inputDate = _editingProduct?.inputDate ?? DateTime.now();
    _useDate =
        _editingProduct?.useDate ?? DateTime.now().add(const Duration(days: 7));
    _selectedIcon = _editingProduct?.iconAdress ?? '🥩';
  }

  // ... (dispose, _selectDate, _showIconPicker 메소드는 동일) ...
  @override
  void dispose() {
    _foodNameController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _containerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isInputDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInputDate ? _inputDate : _useDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isInputDate) {
          _inputDate = picked;
        } else {
          _useDate = picked;
        }
      });
    }
  }

  void _showIconPicker() async {
    final String? icon = await showDialog<String>(
      context: context,
      builder: (_) => const IconPickerDialog(),
    );

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
        // '냉장고'가 아닐 경우, storageName을 '실온'으로 강제
        final finalStorageName = _selectedMachineType == '냉장고'
            ? _selectedStorageName
            : '실온';

// [수정] 공간 타입이 '냉장고'일 때만 컨테이너 이름을 사용하고, 아니면 '기본칸'으로 저장
      final finalContainerName = (_selectedMachineType == '냉장고' && _containerController.text.isNotEmpty)
          ? _containerController.text
          : '기본칸';

        final productData = Product(
          id: _editingProduct?.id,
          refrigName: _selectedRefrigName, // 새로 선택된 냉장고 이름으로 저장
          storageName: finalStorageName,
          containerName: finalContainerName,
          foodName: _foodNameController.text,
          amount: _amountController.text,
          memo: _memoController.text,
          inputDate: _inputDate,
          useDate: _useDate,
          iconAdress: _selectedIcon,
        );

        // [수정] 업데이트 로직
        if (_editingProduct != null) {
          // ViewModel의 updateGood 메소드를 호출
          await ref
              .read(goodsViewModelProvider(_originalRefrigName).notifier)
              .updateGood(productData);
          // 만약 냉장고가 변경되었다면, 이전 냉장고와 새로운 냉장고의 목록을 모두 새로고침
          if (_originalRefrigName != _selectedRefrigName) {
            ref.invalidate(goodsViewModelProvider(_originalRefrigName));
            ref.invalidate(goodsViewModelProvider(_selectedRefrigName));
          }
        } else {
          // 추가 로직은 기존과 동일
          await ref
              .read(goodsViewModelProvider(_selectedRefrigName).notifier)
              .addGood(productData);
        }
        // [핵심 수정] 관련된 모든 요약 페이지를 새로고침하도록 무효화합니다.
        ref.invalidate(machineViewModelProvider);
      ref.invalidate(dashboardViewModelProvider);
      ref.invalidate(remainUseDayViewModelProvider);
      ref.invalidate(longTermStorageViewModelProvider);
        Get.back();
      
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] 공간 목록을 가져오기 위해 machineViewModelProvider를 watch
    final allMachinesState = ref.watch(machineViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_editingProduct != null ? '음식 수정' : '음식 추가')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: allMachinesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('공간 목록을 불러올 수 없습니다.')),
              data: (machines) {
                return Column(
                children: [
                  GestureDetector(
                    onTap: _showIconPicker,
                    child: CircleAvatar(radius: 40, backgroundColor: Colors.grey.shade200, child: Text(_selectedIcon, style: const TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 24),
                  
                  // [수정] '냉장고' 타입일 때만 위치 선택 UI를 보여줌
                  if (_selectedMachineType == '냉장고')
                    ..._buildRefrigeratorLocationFields(machines)
                  else
                    // '실온 보관장소'일 때는 위치 정보를 텍스트로만 보여줌
                    ListTile(
                      leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                      title: const Text('저장 공간'),
                      subtitle: Text(_selectedRefrigName),
                      contentPadding: EdgeInsets.zero,
                    ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _foodNameController,
                    decoration: const InputDecoration(labelText: '음식 이름', border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.isEmpty) ? '이름을 입력하세요.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: '수량', border: OutlineInputBorder())),
                  const SizedBox(height: 16),

                  // [수정] 날짜 선택 UI를 한 줄에 나란히 배치
                  _buildDateSelectionRow(context),

                  const SizedBox(height: 16),
                  TextFormField(controller: _memoController, decoration: const InputDecoration(labelText: '메모', border: OutlineInputBorder()), maxLines: 3),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _submit, child: const Text('저장하기')),
                ],
              );
              },
            ),
          ),
        ),
      ),
    );
  }
  // [신규] 냉장고 타입일 때 보여줄 위치 선택 필드들을 묶은 메소드
  List<Widget> _buildRefrigeratorLocationFields(List<MachineName> machines) {
    return [
      DropdownButtonFormField<String>(
        value: _selectedRefrigName,
        decoration: const InputDecoration(labelText: '저장 공간', border: OutlineInputBorder()),
        items: machines.map((machine) {
          return DropdownMenuItem(value: machine.machineName, child: Text(machine.machineName!));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedRefrigName = value;
              final selectedMachine = machines.firstWhere((m) => m.machineName == value);
              _selectedMachineType = selectedMachine.machineType;
              _selectedStorageName = '냉장실'; 
            });
          }
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _selectedStorageName,
        decoration: const InputDecoration(labelText: '보관 장소', border: OutlineInputBorder()),
        items: ['냉장실', '냉동실'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() { _selectedStorageName = value; });
          }
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _containerController,
        decoration: const InputDecoration(labelText: '보관 칸 이름 (예: 신선칸)', border: OutlineInputBorder()),
      ),
    ];
  }

  // [신규] 날짜 선택 UI를 만드는 메소드
  Widget _buildDateSelectionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, true),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '구매일',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dateFormat.format(_inputDate)),
                  const Icon(Icons.calendar_today_outlined, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, false),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '소비기한',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dateFormat.format(_useDate)),
                  const Icon(Icons.calendar_today_outlined, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}
