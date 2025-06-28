// lib/presentation/screens/refrig_input.dart (최종 수정본)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 실제 프로젝트의 정확한 경로로 수정해주세요.
import '../../data/models/product_model.dart';
import '../../providers.dart';
import '../../data/models/machine_name_model.dart';
import '../widgets/icon_picker_dialog.dart';

class RefrigInput extends ConsumerStatefulWidget {
  const RefrigInput({super.key});

  @override
  ConsumerState<RefrigInput> createState() => _RefrigInputState();
}

class _RefrigInputState extends ConsumerState<RefrigInput> {
  final _formKey = GlobalKey<FormState>();

  // 상태 변수
  Product? _editingProduct;
  late String _originalRefrigName;
  late String _selectedRefrigName;
  late String? _selectedMachineType;
  late String _selectedStorageName;
  String _selectedUnit = '개';
  String _selectedIcon = '🥩';
  bool _isLongTermStorage = false;
  // ✅ [추가] 구매일 상태 변수
  late DateTime _purchaseDate;

  // 컨트롤러
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

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _editingProduct = args?['product'];

    // 상태 초기화
    _originalRefrigName = args?['refrigName'] ?? '';
    _selectedRefrigName = args?['refrigName'] ?? '';
    _selectedMachineType = args?['machineType'];
    _selectedStorageName = _editingProduct?.storageName ?? '냉장실';
    _selectedUnit = _editingProduct?.unit ?? '개';
    _selectedIcon = _editingProduct?.iconAdress ?? '🥩';
    _isLongTermStorage = _editingProduct?.isLongTermStorage ?? false;
    // ✅ [수정] 구매일 초기화 (기존 상품은 inputDate, 새 상품은 오늘 날짜)
    _purchaseDate = _editingProduct?.inputDate ?? DateTime.now();

    // 컨트롤러 초기화
    _foodNameController = TextEditingController(
      text: _editingProduct?.foodName,
    );
    _amountController = TextEditingController(text: _editingProduct?.amount);
    _memoController = TextEditingController(text: _editingProduct?.memo);
    _containerController = TextEditingController(
      text: _editingProduct?.containerName,
    );
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _containerController.dispose();
    super.dispose();
  }

  // --- UI 빌드 ---
  @override
  Widget build(BuildContext context) {
    final allMachinesState = ref.watch(machineViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingProduct != null ? '음식 수정' : '음식 추가'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _submit)],
      ),
      body: allMachinesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text('공간 목록을 불러올 수 없습니다.')),
        data: (machines) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildIconPicker(),
              const SizedBox(height: 24),
              _buildLocationFields(machines),
              const SizedBox(height: 16),
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: '음식 이름 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? '이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              _buildAmountAndUnitFields(),
              const SizedBox(height: 16),
              // ✅ [추가] 구매일 선택 필드
              _buildPurchaseDateField(context),
              _buildLongTermStorageCheckbox(),
              const SizedBox(height: 16),
              _buildUseByDateField(context),
              const SizedBox(height: 16),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 위젯 빌더 헬퍼 메소드들 ---

  Widget _buildIconPicker() {
    return GestureDetector(
      onTap: _showIconPicker,
      child: Center(
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade200,
          child: Text(_selectedIcon, style: const TextStyle(fontSize: 40)),
        ),
      ),
    );
  }

  Widget _buildLocationFields(List<MachineName> machines) {
    // if (_selectedMachineType != '냉장고') {
    //   return ListTile(
    //     leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
    //     title: const Text('저장 공간'),
    //     subtitle: Text(_selectedRefrigName),
    //     contentPadding: EdgeInsets.zero,
    //   );
    // }
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value:
              _selectedRefrigName.isNotEmpty &&
                  machines.any((m) => m.machineName == _selectedRefrigName)
              ? _selectedRefrigName
              : null,
          hint: const Text('공간을 선택하세요'), // 기본 안내 텍스트
          decoration: const InputDecoration(
            labelText: '저장 공간 *',
            border: OutlineInputBorder(),
          ),
          items: machines
              .map(
                (m) => DropdownMenuItem(
                  value: m.machineName,
                  child: Text(m.machineName!),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            // 선택된 공간의 타입을 찾아서 상태를 업데이트합니다.
            final selectedMachine = machines.firstWhere(
              (m) => m.machineName == value,
            );
            setState(() {
              _selectedRefrigName = value;
              _selectedMachineType = selectedMachine.machineType;
              // 만약 냉장고가 아니라면, 보관 장소를 '실온' 등으로 초기화
              if (_selectedMachineType != '냉장고') {
                _selectedStorageName = '실온';
              } else {
                _selectedStorageName = '냉장실'; // 냉장고의 경우 기본값
              }
            });
          },
          validator: (value) => value == null ? '저장 공간을 선택해주세요.' : null,
        ),
        const SizedBox(height: 16),
        // ✅ [추가] 선택된 공간 타입이 '냉장고'일 때만 '보관 장소'와 '보관 칸' 필드를 보여줍니다.
        if (_selectedMachineType == '냉장고')
          Column(
            children: [
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStorageName,
                decoration: const InputDecoration(labelText: '보관 장소 *', border: OutlineInputBorder()),
                items: ['냉장실', '냉동실'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                onChanged: (value) => setState(() => _selectedStorageName = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _containerController,
                decoration: const InputDecoration(labelText: '보관 칸 이름 (예: 신선칸)', border: OutlineInputBorder()),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAmountAndUnitFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 세로 정렬을 위로 맞춥니다.
      children: [
        // 1. 수량 입력 필드가 남는 공간을 모두 차지하도록 합니다.
        Expanded(
          child: TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '수량',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        // 2. 단위 선택 필드는 내용물에 맞는 만큼의 너비만 차지하도록 합니다.
        // DropdownButtonFormField 대신 일반 DropdownButton을 사용하고 InputDecorator로 감싸
        // 더 유연한 UI를 구성합니다.
        Container(
          width: 130, // 너비를 충분히 확보해줍니다.
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _unitOptions.contains(_selectedUnit)
                  ? _selectedUnit
                  : '직접 입력...',
              isExpanded: true,
              items: _unitOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
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
        ),
      ],
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

  // ✅ [추가] 구매일 선택 필드를 만드는 위젯
  Widget _buildPurchaseDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectPurchaseDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '구매일',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(DateFormat('yyyy-MM-dd').format(_purchaseDate)),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildUseByDateField(BuildContext context) {
    return InkWell(
      // ✅ 장기보관 체크 시 탭 비활성화
      onTap: _isLongTermStorage ? null : () => _selectDate(context),
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
            Text(
              _editingProduct?.useDate != null
                  ? DateFormat('yyyy-MM-dd').format(_editingProduct!.useDate!)
                  : '날짜를 선택하세요',
              style: TextStyle(
                color: _isLongTermStorage ? Colors.grey.shade500 : Colors.black,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: _isLongTermStorage ? Colors.grey.shade500 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // --- 기능 메소드들 ---

  // ✅ [추가] 구매일을 선택하는 메소드
  Future<void> _selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      // 구매일은 오늘 이후 날짜를 선택할 수 없도록 설정
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _editingProduct?.useDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _editingProduct = (_editingProduct ?? Product()).copyWith(
          useDate: picked,
        );
      });
    }
  }

  void _showIconPicker() async {
    final String? icon = await showDialog<String>(
      context: context,
      builder: (_) => const IconPickerDialog(),
    );
    if (icon != null) {
      setState(() => _selectedIcon = icon);
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final finalStorageName = _selectedMachineType == '냉장고'
          ? _selectedStorageName
          : '실온';
      final finalContainerName = (_selectedMachineType == '냉장고' && _containerController.text.isNotEmpty)
      ? _containerController.text : '기본칸';

      final productData = Product(
        id: _editingProduct?.id,
        refrigName: _selectedRefrigName,
        storageName: finalStorageName,
        containerName: finalContainerName,
        foodName: _foodNameController.text,
        amount: _amountController.text,
        unit: _selectedUnit,
        memo: _memoController.text,
        inputDate: _editingProduct?.inputDate ?? DateTime.now(),
        // 장기보관이 체크되면 useDate는 null로, 아니면 선택된 날짜로 저장
        useDate: _isLongTermStorage ? null : _editingProduct?.useDate,
        iconAdress: _selectedIcon,
        isLongTermStorage: _isLongTermStorage,
      );

      final goodsNotifier = ref.read(
        goodsViewModelProvider(_originalRefrigName).notifier,
      );
      if (_editingProduct != null) {
        goodsNotifier.updateGood(productData);
        if (_originalRefrigName != _selectedRefrigName) {
          ref.invalidate(goodsViewModelProvider(_originalRefrigName));
          ref.invalidate(goodsViewModelProvider(_selectedRefrigName));
        }
      } else {
        goodsNotifier.addGood(productData);
      }

      // 관련된 모든 Provider 새로고침
      ref.invalidate(machineViewModelProvider);
      ref.invalidate(dashboardViewModelProvider);
      ref.invalidate(remainUseDayViewModelProvider);
      ref.invalidate(longTermStorageViewModelProvider);
      ref.invalidate(statisticsViewModelProvider);
      Get.back();
    }
  }
}
