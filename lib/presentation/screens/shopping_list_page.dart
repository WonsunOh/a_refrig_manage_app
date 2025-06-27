// lib/presentation/views/screens/shopping_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/shopping_list_viewmodel.dart';

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
            onPressed: () {
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
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => viewModel.deleteItem(item.id!),
                  ),
                  onTap: () => viewModel.toggleItem(item),
                );
              },
            ),
      // 새 아이템 추가 버튼
      floatingActionButton: FloatingActionButton(
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