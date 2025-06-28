import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/machine_name_model.dart';
import '../../data/models/product_model.dart';
import '../../providers.dart';
import '../widgets/icon_picker_dialog.dart';

class RefrigInput extends ConsumerStatefulWidget {
  const RefrigInput({super.key});

  @override
  ConsumerState<RefrigInput> createState() => _RefrigInputState();
}

class _RefrigInputState extends ConsumerState<RefrigInput> {
  final _formKey = GlobalKey<FormState>();

  // --- State Variables ---
  late TextEditingController _foodNameController;
  late TextEditingController _amountController;
  late TextEditingController _memoController;
  late TextEditingController _containerController;
  

  // 단위 목록
  final List<String> _unitOptions = [
    '개',
    'g',
    'kg',
    'mL',
    'L',
    '마리',
    '직접 입력...',
  ];

  Product? _editingProduct;
  late String _originalRefrigName;
  late String _selectedRefrigName;
  late String? _selectedMachineType;
  late String _selectedStorageName;
  String? _selectedUnit = '개'; // 수량 단위를 위한 변수 추가

  DateTime _inputDate = DateTime.now();
  DateTime _useDate = DateTime.now().add(const Duration(days: 7));
  String _selectedIcon = '🥩';
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
   bool _isLongTermStorage = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _editingProduct = args['product'];

    // 기존 데이터 로직은 그대로 유지
    _originalRefrigName = args['refrigName'] ?? '';
    _selectedRefrigName = args['refrigName'] ?? '';
    _selectedMachineType = args['machineType'];
    _selectedStorageName = _editingProduct?.storageName ?? '냉장실';
    _selectedUnit = _editingProduct?.unit ?? '개';

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
    _isLongTermStorage = _editingProduct?.isLongTermStorage ?? false;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _containerController.dispose();
    super.dispose();
  }

  // --- UI Helper Methods ---

  Future<void> _selectDate(BuildContext context, bool isInputDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInputDate ? _inputDate : _useDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != (isInputDate ? _inputDate : _useDate)) {
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

  void _showAddUnitDialog() {
    final unitController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 단위 추가'),
        content: TextField(
          controller: unitController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '단위를 입력하세요'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              final newUnit = unitController.text.trim();
              if (newUnit.isNotEmpty && !_unitOptions.contains(newUnit)) {
                setState(() {
                  _unitOptions.insert(_unitOptions.length - 1, newUnit);
                  _selectedUnit = newUnit;
                });
              }
              Get.back();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // --- Submit Logic ---
  // 기존 로직을 그대로 사용하여 안정성을 유지합니다.
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final finalStorageName = _selectedMachineType == '냉장고'
          ? _selectedStorageName
          : '실온';
      final finalContainerName =
          (_selectedMachineType == '냉장고' &&
              _containerController.text.isNotEmpty)
          ? _containerController.text
          : '기본칸';

      final productData = Product(
        id: _editingProduct?.id,
        refrigName: _selectedRefrigName,
        storageName: finalStorageName,
        containerName: finalContainerName,
        foodName: _foodNameController.text,
        amount: _amountController.text,
        unit: _selectedUnit, // 단위 추가
        memo: _memoController.text,
        inputDate: _inputDate,
        useDate: _useDate,
        iconAdress: _selectedIcon,
      );

      if (_editingProduct != null) {
        await ref
            .read(goodsViewModelProvider(_originalRefrigName).notifier)
            .updateGood(productData);
        if (_originalRefrigName != _selectedRefrigName) {
          ref.invalidate(goodsViewModelProvider(_originalRefrigName));
          ref.invalidate(goodsViewModelProvider(_selectedRefrigName));
        }
      } else {
        await ref
            .read(goodsViewModelProvider(_selectedRefrigName).notifier)
            .addGood(productData);
      }

      // 관련된 모든 요약/통계 Provider를 새로고침합니다.
      ref.invalidate(machineViewModelProvider);
      ref.invalidate(dashboardViewModelProvider);
      ref.invalidate(remainUseDayViewModelProvider);
      ref.invalidate(longTermStorageViewModelProvider);
      ref.invalidate(statisticsViewModelProvider); // 통계 Provider 추가

      Get.back();
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final allMachinesState = ref.watch(machineViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingProduct != null ? '음식 수정' : '새로운 음식 추가'),
        // actions: [
        //   IconButton(icon: const Icon(Icons.save), 
        //   iconSize: 25
        //   onPressed: _submit),
        //   ],
      ),
      body: allMachinesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text('공간 목록을 불러오는 데 실패했습니다.')),
        data: (machines) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 아이콘 선택 섹션 ---
                  Center(
                    child: GestureDetector(
                      onTap: _showIconPicker,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          _selectedIcon,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- 기본 정보 카드 ---
                  _buildSectionCard(
                    title: '기본 정보',
                    children: [
                      TextFormField(
                        controller: _foodNameController,
                        decoration: const InputDecoration(
                          labelText: '음식 이름 *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? '이름을 입력해주세요.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: '수량 *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? '수량을 입력해주세요.'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _unitOptions
                                  .map(
                                    (label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? newValue) {
                                if (newValue == '직접 입력...') {
                                  _showAddUnitDialog();
                                } else {
                                  setState(() {
                                    _selectedUnit = newValue!;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // --- 보관 위치 카드 ---
                  _buildSectionCard(
                    title: '보관 위치',
                    children: _selectedMachineType == '냉장고'
                        ? _buildRefrigeratorLocationFields(machines)
                        : [_buildRoomTemperatureLocationField()],
                  ),

                  // --- 날짜 정보 카드 ---
                  _buildSectionCard(
                    title: '날짜',
                    children: [_buildDateSelectionRow(context)],
                  ),

                  // --- 메모 카드 ---
                  _buildSectionCard(
                    title: '메모',
                    children: [
                      TextFormField(
                        controller: _memoController,
                        decoration: const InputDecoration(
                          hintText: '메모를 입력하세요...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: const Text('저장하기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- UI Builder Widgets ---

  

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRefrigeratorLocationFields(List<MachineName> machines) {
    return [
      DropdownButtonFormField<String>(
        value: _selectedRefrigName,
        decoration: const InputDecoration(
          labelText: '저장 공간',
          border: OutlineInputBorder(),
        ),
        items: machines
            .map(
              (machine) => DropdownMenuItem(
                value: machine.machineName,
                child: Text(machine.machineName!),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedRefrigName = value;
              final selectedMachine = machines.firstWhere(
                (m) => m.machineName == value,
              );
              _selectedMachineType = selectedMachine.machineType;
              _selectedStorageName = '냉장실';
            });
          }
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _selectedStorageName,
        decoration: const InputDecoration(
          labelText: '보관 장소',
          border: OutlineInputBorder(),
        ),
        items: ['냉장실', '냉동실']
            .map((label) => DropdownMenuItem(value: label, child: Text(label)))
            .toList(),
        onChanged: (value) => setState(() => _selectedStorageName = value!),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _containerController,
        decoration: const InputDecoration(
          labelText: '보관 칸 이름 (예: 신선칸)',
          border: OutlineInputBorder(),
        ),
      ),
    ];
  }

  Widget _buildRoomTemperatureLocationField() {
    return ListTile(
      leading: const Icon(Icons.inventory_2_outlined),
      title: const Text('저장 공간'),
      subtitle: Text(_selectedRefrigName),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDateSelectionRow(BuildContext context) {
    return Column(
      children: [
        _buildBuyDateField(context),
         const SizedBox(width: 16),
         _buildLongTermStorageCheckbox(),
        const SizedBox(width: 16),
         _buildUseByDateField(context),
        // InkWell(
        //   onTap: () => _selectDate(context, false),
        //   child: InputDecorator(
        //     decoration: const InputDecoration(
        //       labelText: '사용예정일',
        //       border: OutlineInputBorder(),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(_dateFormat.format(_useDate)),
        //         const Icon(Icons.calendar_today_outlined, size: 20),
        //       ],
        //     ),
        //   ),
        // ),
      
      ],
    );
  }

  Widget _buildBuyDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context, true),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '구매일',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_dateFormat.format(_inputDate)),
                  const Icon(Icons.calendar_today_outlined, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLongTermStorageCheckbox() {
    return CheckboxListTile(
      title: const Text('장기보관 음식 (사용예정일 없음)'),
      value: _isLongTermStorage,
      onChanged: (bool? value) {
        setState(() => _isLongTermStorage = value!);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildUseByDateField(BuildContext context) {
    return InkWell(
      // ✅ 장기보관 체크 시 탭 비활성화
      onTap: _isLongTermStorage ? null : () => _selectDate(context, false),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '사용예정일', // ✅ 용어 변경
          border: const OutlineInputBorder(),
          // ✅ 장기보관 체크 시 비활성화된 것처럼 보이게 처리
          filled: _isLongTermStorage,
          fillColor: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_dateFormat.format(_useDate),
            style: TextStyle(
                color: _isLongTermStorage ? Colors.grey.shade500 : Colors.black,
              ),),
            Icon(
              Icons.calendar_today_outlined,
              color: _isLongTermStorage ? Colors.grey.shade500 : Colors.black,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
