
import 'refrig_goods_model.dart' show Product;

class DashboardState {
  final List<Product> expiringToday;
  final List<Product> expiringSoon;
  final Map<String, String?> machineTypeMap;

  DashboardState({
    this.expiringToday = const [],
    this.expiringSoon = const [],
    this.machineTypeMap = const {},
  });
}