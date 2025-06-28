// lib/presentation/views/screens/shopping_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../viewmodels/shopping_list_viewmodel.dart';
import 'refrig_input.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel을 통해 쇼핑 목록 상태를 감시합니다.
    final shoppingList = ref.watch(shoppingListViewModelProvider);
    final viewModel = ref.read(shoppingListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('쇼핑 목록'),
        actions: [
          // 선택된 항목 삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: '구매한 상품 삭제',
            // onPressed가 null이면 버튼은 자동으로 비활성화됩니다.
            onPressed: shoppingList.isEmpty
                ? null
                : () {
                    // 확인 다이얼로그 표시
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('구매 완료 상품 삭제'),
                          content: const Text('체크된 모든 상품을 목록에서 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              child: const Text('취소'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text('삭제', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                viewModel.deleteCheckedItems();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
            },
          ),
        ],
      ),
      body: shoppingList.isEmpty
          ? const Center(
              child: Text(
                '쇼핑 목록이 비어있습니다.\n오른쪽 아래 버튼으로 추가해보세요!',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: shoppingList.length,
              itemBuilder: (context, index) {
                final item = shoppingList[index];
                final bool isChecked = item.isChecked; // 가독성을 위해 변수 사용
                return ListTile(
                  // 체크박스
                  leading: Checkbox(
                    value: item.isChecked,
                    onChanged: (bool? value) {
                      viewModel.toggleItem(item);
                    },
                    activeColor: Colors.grey,
                    checkColor: Colors.white,
                  ),
                  // 아이템 이름
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.isChecked ? Colors.grey : null,
                    ),
                  ),
                  // 아이템 삭제 버튼
                  trailing: isChecked
                      // 1. 체크된 경우: '냉장고에 추가' 버튼 표시
                      ? IconButton(
                          icon: const Icon(Icons.kitchen_outlined, color: Colors.blue),
                          tooltip: '냉장고에 추가하기',
                          onPressed: () async {
                            // RefrigInput 화면으로 이동하면서 음식 이름을 전달합니다.
                            await Get.to(() => const RefrigInput(), arguments: {
                              // 'foodName'이라는 이름으로 아이템 이름을 전달합니다.
                              // 이 부분은 RefrigInput 화면에서 받아 처리해야 합니다.
                              'prefilledFoodName': item.name,
                            });
                            // 냉장고에 추가한 후, 쇼핑 목록에서는 해당 아이템을 삭제합니다.
                            viewModel.deleteItem(item.id!);
                          },
                        )
                      // 2. 체크되지 않은 경우: 기존 '삭제' 버튼 표시
                      : IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => viewModel.deleteItem(item.id!),
                        ),
                  onTap: () => viewModel.toggleItem(item),
                );
              },
            ),
      // 새 아이템 추가 버튼
      floatingActionButton: FloatingActionButton(
        // ✅ [수정] 고유한 heroTag 추가
        heroTag: 'shopping_list_fab',
        onPressed: () => _showAddItemDialog(context, viewModel),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 아이템 추가 다이얼로그
  void _showAddItemDialog(BuildContext context, ShoppingListViewModel viewModel) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('쇼핑 목록에 추가'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: '물품 이름을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final name = textController.text;
                if (name.isNotEmpty) {
                  viewModel.addItem(name);
                  Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }
}