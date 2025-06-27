// lib/presentation/widgets/space_detail_page_content.dart (최종 개선안)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/product_model.dart';
import '../../providers.dart';
import 'food_icon.dart';
import 'goods_detail_bottomsheet.dart';

class SpaceDetailPageContent extends ConsumerWidget {
  final String initialMachineName;
  final String? initialMachineType;

  const SpaceDetailPageContent({
    super.key,
    required this.initialMachineName,
    required this.initialMachineType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goodsState = ref.watch(goodsViewModelProvider(initialMachineName));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(goodsViewModelProvider(initialMachineName));
      },
      child: goodsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
        data: (groupedGoods) {
          // '냉장고' 타입일 때와 '실온' 타입일 때를 분기
          if (initialMachineType == '냉장고') {
            return _buildGroupedView(context, ref, groupedGoods);
          } else {
            // '실온 보관장소'는 그룹 없이 전체 목록을 보여줍니다.
            final allProducts = groupedGoods['실온']?['기본칸'] ?? [];
            if (allProducts.isEmpty) {
              return _buildEmptyListInfo();
            }
            return ListView(
              padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
              children: allProducts.map((p) => _buildFoodListItem(context, ref, p, initialMachineType)).toList(),
            );
          }
        },
      ),
    );
  }

  // [핵심 수정] 그룹화된 뷰를 ExpansionTile을 사용하여 구성
  Widget _buildGroupedView(
      BuildContext context, WidgetRef ref, Map<String, Map<String, List<Product>>> groupedGoods) {
    final storageSections = ['냉장실', '냉동실'];
    final allProducts = groupedGoods.values.expand((map) => map.values.expand((list) => list)).toList();

    if (allProducts.isEmpty) {
      return _buildEmptyListInfo();
    }
    
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: storageSections.map((storageName) {
        final containerMap = groupedGoods[storageName] ?? {};
        final totalItemsInStorage = containerMap.values.fold<int>(0, (sum, list) => sum + list.length);

        if (totalItemsInStorage == 0) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          elevation: 1.5,
          child: ExpansionTile(
            title: Text('$storageName ($totalItemsInStorage개)', style: const TextStyle(fontWeight: FontWeight.bold)),
            children: containerMap.entries.map((entry) {
              final containerName = entry.key;
              final productsInContainer = entry.value;
              return ExpansionTile(
                tilePadding: const EdgeInsets.only(left: 32, right: 16),
                title: Text('$containerName (${productsInContainer.length}개)', style: const TextStyle(fontSize: 15)),
                children: productsInContainer.map((product) {
                  return _buildFoodListItem(context, ref, product, initialMachineType);
                }).toList(),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // 목록이 비어있을 때 안내 위젯
  Widget _buildEmptyListInfo() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // 내용이 없어도 새로고침 가능하도록
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '이 공간이 비어있네요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 음식 목록 아이템 위젯 (디자인 개선)
  Widget _buildFoodListItem(BuildContext context, WidgetRef ref, Product product, String? machineType) {
    final dDay = _calculateDDay(product.useDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Dismissible(
        key: ValueKey(product.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red.shade400,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
        ),
        onDismissed: (direction) {
          ref.read(goodsViewModelProvider(product.refrigName!).notifier).deleteGood(product.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("'${product.foodName}'을(를) 삭제했습니다.")),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          onTap: () {
            Get.bottomSheet(
              GoodsDetailBottomSheet(product: product, machineType: machineType),
              backgroundColor: Colors.white,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            );
          },
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: FoodIcon(iconIdentifier: product.iconAdress, size: 24),
          ),
          title: Text(product.foodName ?? '이름 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${product.amount ?? ''} ${product.unit ?? ''}'),
          trailing: Text(
            dDay.text,
            style: TextStyle(color: dDay.color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // D-Day 계산 로직
  ({String text, Color color}) _calculateDDay(DateTime? useDate) {
    if (useDate == null) return (text: '', color: Colors.grey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = useDate.difference(today).inDays;
    if (difference < 0) return (text: '만료', color: Colors.grey.shade700);
    if (difference == 0) return (text: 'D-DAY', color: Colors.red.shade600);
    if (difference <= 3) return (text: 'D-$difference', color: Colors.orange.shade700);
    return (text: 'D-$difference', color: Colors.green.shade700);
  }
}