// lib/model/shopping_item_model.dart

class ShoppingItem {
  int? id;
  String name;
  bool isChecked;

  ShoppingItem({
    this.id,
    required this.name,
    this.isChecked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked ? 1 : 0,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      isChecked: map['isChecked'] == 1,
    );
  }
}