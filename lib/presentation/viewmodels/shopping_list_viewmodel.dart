// lib/viewmodel/shopping_list_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/shopping_list_db_helper.dart';
import '../../data/models/shopping_item_model.dart';

// 1. StateNotifier 정의
class ShoppingListViewModel extends StateNotifier<List<ShoppingItem>> {
  final ShoppingListDBHelper _dbHelper;

  ShoppingListViewModel(this._dbHelper) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    final items = await _dbHelper.getItems();
  // ✅ [추가] 정렬 로직
    // isChecked가 false인 것(아직 구매 안 한 것)이 위로, true인 것(구매한 것)이 아래로 오도록 정렬
    items.sort((a, b) {
      if (a.isChecked == b.isChecked) return 0; // 둘 다 체크됐거나 안 됐으면 순서 유지
      return a.isChecked ? 1 : -1; // a가 체크됐으면 뒤로, 아니면 앞으로
    });
    state = items;
  }

  Future<void> addItem(String name) async {
    final newItem = ShoppingItem(name: name);
    // 중복 아이템 체크
    if (state.where((item) => item.name == name).isEmpty) {
      await _dbHelper.insertItem(newItem);
      await loadItems(); // 목록 새로고침
    }
  }

  Future<void> toggleItem(ShoppingItem item) async {
    final updatedItem = ShoppingItem(
      id: item.id,
      name: item.name,
      isChecked: !item.isChecked,
    );
    await _dbHelper.updateItem(updatedItem);
    await loadItems(); // 목록 새로고침
  }

  Future<void> deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    await loadItems(); // 목록 새로고침
  }
  
  Future<void> deleteCheckedItems() async {
    await _dbHelper.deleteCheckedItems();
    await loadItems();
  }
}

// 2. Provider 정의
final shoppingListDBHelperProvider = Provider((ref) => ShoppingListDBHelper.instance);

final shoppingListViewModelProvider = StateNotifierProvider<ShoppingListViewModel, List<ShoppingItem>>((ref) {
  final dbHelper = ref.watch(shoppingListDBHelperProvider);
  return ShoppingListViewModel(dbHelper);
});