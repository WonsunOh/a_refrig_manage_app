// lib/presentation/views/screens/remain_useday.dart (최종 개선안)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart'; // groupBy를 사용하기 위해 import

import '../../../data/models/product_model.dart';
import '../../../providers.dart';
import '../widgets/food_icon.dart';
import '../widgets/goods_detail_bottomsheet.dart';

class RemainUseDay extends ConsumerWidget {
  const RemainUseDay({super.key});

  // D-Day 계산 로직 (그룹화를 위해 int 값을 반환하도록 수정)
  int _calculateDDay(DateTime? useDate) {
    if (useDate == null) return 9999; // 날짜 없는 경우는 맨 뒤로
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return useDate.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiringFoodsState = ref.watch(remainUseDayViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('소비기한 임박!'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(remainUseDayViewModelProvider),
        child: expiringFoodsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다: $err')),
          data: (foods) {
            if (foods.isEmpty) {
              return _buildEmptyList();
            }

            // [핵심 수정] D-Day 별로 음식을 그룹화합니다.
            final groupedFoods = groupBy(foods, (Product p) => _calculateDDay(p.useDate));
            // D-Day가 빠른 순서대로 그룹을 정렬합니다.
            final sortedKeys = groupedFoods.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final dDay = sortedKeys[index];
                final productsInGroup = groupedFoods[dDay]!;
                return _buildGroupedListItem(context, ref, dDay, productsInGroup);
              },
            );
          },
        ),
      ),
    );
  }

  // D-Day별로 그룹화된 목록을 만드는 위젯
  Widget _buildGroupedListItem(BuildContext context, WidgetRef ref, int dDay, List<Product> products) {
    final dDayInfo = _getDDayInfo(dDay);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Column(
        children: [
          // 그룹 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: dDayInfo.color.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: dDayInfo.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  dDayInfo.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: dDayInfo.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // 해당 그룹의 음식 목록
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: FoodIcon(iconIdentifier: product.iconAdress, size: 22),
                ),
                title: Text(product.foodName ?? '이름 없음'),
                subtitle: Text('보관: ${product.refrigName ?? '-'}'),
                trailing: Text('${product.amount ?? ''} ${product.unit ?? ''}'),
                onTap: () {
                  Get.bottomSheet(
                    GoodsDetailBottomSheet(product: product),
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                  );
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
          ),
        ],
      ),
    );
  }

  // 소비기한 임박 음식이 없을 때 보여줄 화면
  Widget _buildEmptyList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.green.shade400),
                  const SizedBox(height: 24),
                  Text(
                    '훌륭해요!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 소비기한이 임박한 음식이 없어요.\n안심하고 오늘 하루를 즐기세요!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // D-Day 값에 따라 텍스트와 색상을 반환하는 헬퍼 함수
  ({String text, Color color}) _getDDayInfo(int dDay) {
    if (dDay < 0) return (text: '기한 만료', color: Colors.grey.shade700);
    if (dDay == 0) return (text: 'D-DAY (오늘까지!)', color: Colors.red.shade600);
    if (dDay <= 3) return (text: 'D-$dDay', color: Colors.orange.shade700);
    // 이 화면은 3일 이내의 상품만 보여주므로, 그 이상의 경우는 사실상 나타나지 않습니다.
    return (text: 'D-$dDay', color: Colors.green.shade700);
  }
}