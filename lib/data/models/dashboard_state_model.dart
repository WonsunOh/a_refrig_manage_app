// lib/data/models/dashboard_state_model.dart (최종 수정안)

import 'product_model.dart';

class DashboardState {
  // [수정!] 숫자(count)가 아닌, 실제 Product 리스트를 상태로 가집니다.
  final List<Product> imminentExpiry; // 사용예정일 임박 상품 목록
  final List<Product> longTermStorage; // 장기 보관 상품 목록

  DashboardState({
    this.imminentExpiry = const [],
    this.longTermStorage = const [],
  });

  DashboardState copyWith({
    List<Product>? imminentExpiry,
    List<Product>? longTermStorage,
  }) {
    return DashboardState(
      imminentExpiry: imminentExpiry ?? this.imminentExpiry,
      longTermStorage: longTermStorage ?? this.longTermStorage,
    );
  }
}
