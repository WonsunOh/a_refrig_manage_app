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
    state = await _dbHelper.getItems();
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