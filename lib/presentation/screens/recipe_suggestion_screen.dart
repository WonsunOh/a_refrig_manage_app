// lib/presentation/screens/recipe_suggestion_screen.dart

import 'package:a_refrig_manage_app/providers.dart'; // 중앙 관리 방식의 provider 임포트
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class RecipeSuggestionScreen extends ConsumerWidget {
  const RecipeSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 전체 재료 목록을 비동기적으로 불러옵니다.
    final allIngredients = ref.watch(foodNameListProvider);
    // 2. 사용자가 선택한 재료 목록을 감시합니다.
    final selectedIngredients = ref.watch(selectedIngredientsProvider);
    // 3. 선택 목록을 변경할 수 있는 notifier를 가져옵니다.
    final selectedIngredientsNotifier = ref.read(selectedIngredientsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('재료로 레시피 검색'),
        actions: [
          // 선택 초기화 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '선택 초기화',
            onPressed: () {
              selectedIngredientsNotifier.clear();
            },
          )
        ],
      ),
      body: allIngredients.when(
        // 데이터 로딩 중일 때
        loading: () => const Center(child: CircularProgressIndicator()),
        // 에러 발생 시
        error: (err, stack) => Center(child: Text('재료를 불러오는 데 실패했습니다: $err')),
        // 데이터 로딩 성공 시
        data: (ingredients) {
          if (ingredients.isEmpty) {
            return const Center(
              child: Text(
                '냉장고에 등록된 재료가 없습니다.\n먼저 음식을 추가해주세요.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap( // Wrap 위젯으로 공간이 부족하면 자동으로 줄바꿈
              spacing: 8.0, // 가로 간격
              runSpacing: 4.0, // 세로 간격
              children: ingredients.map((ingredient) {
                final isSelected = selectedIngredients.contains(ingredient);
                return FilterChip(
                  label: Text(ingredient),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    selectedIngredientsNotifier.toggleIngredient(ingredient);
                  },
                  backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey[200],
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.8),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                  ),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
          );
        },
      ),
      // 검색 버튼
      floatingActionButton: selectedIngredients.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // 선택된 재료들을 공백으로 연결하여 검색어 생성
                final searchQuery = selectedIngredients.join(' ');
                // 유튜브 검색 화면으로 검색어를 전달하며 이동
                Get.toNamed('/youTube', arguments: searchQuery);
              },
              label: Text('${selectedIngredients.length}개 재료로 검색'),
              icon: const Icon(Icons.search),
            )
          : null, // 선택된 재료가 없으면 버튼 숨김
    );
  }
}