import 'package:flutter_riverpod/flutter_riverpod.dart';

// 현재 어떤 뷰 모드인지 나타내는 enum
enum ViewMode { list, grid }

// 뷰 모드 상태를 관리하는 Provider. 기본값은 리스트 뷰.
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

// 하단 네비게이션의 현재 인덱스를 관리하는 Provider
// 단순히 int 값 하나만 관리하므로 StateProvider가 가장 적합합니다.
final bottomNavIndexProvider = StateProvider<int>((ref) => 1);