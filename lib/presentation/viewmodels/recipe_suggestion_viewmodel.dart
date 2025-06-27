// lib/viewmodel/recipe_suggestion_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:a_refrig_manage_app/providers.dart'; // [중요] 중앙 프로바이더 파일 import

// --- ViewModel (StateNotifier) ---

// 사용자가 선택한 재료 목록을 관리하는 ViewModel(StateNotifier)입니다.
// 상태는 간단한 문자열 리스트(List<String>)입니다.
class SelectedIngredientsNotifier extends StateNotifier<List<String>> {
  // 초기 상태를 빈 리스트로 설정합니다.
  SelectedIngredientsNotifier() : super([]);

  // 재료를 선택하거나 선택 해제하는 메소드
  void toggleIngredient(String ingredient) {
    // 현재 상태(state)에 재료가 포함되어 있으면,
    if (state.contains(ingredient)) {
      // 그 재료를 제외한 새로운 리스트를 만들어 상태를 업데이트합니다.
      state = state.where((item) => item != ingredient).toList();
    } else {
      // 포함되어 있지 않으면, 기존 리스트에 재료를 추가하여 상태를 업데이트합니다.
      state = [...state, ingredient];
    }
  }

  // 선택된 모든 재료를 초기화하는 메소드
  void clear() {
    state = [];
  }
}


// --- Providers ---

