import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/refrig_goods_model.dart';
import '../../../providers/dashboard_providers.dart';
import '../../widgets/app_bar_popup_menu.dart';
import '../../widgets/food_icon.dart';
import '../../widgets/goods_detail_bottomsheet.dart';

class DashboardScreen extends ConsumerWidget { // [수정] 다시 ConsumerWidget으로
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        automaticallyImplyLeading: false,
        actions: [
          AppBarPopupMenu(),
        ],
      ),
      body: SafeArea(
        child: dashboardState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('데이터 로딩 실패: $err')),
              data: (data) {
                // 데이터가 하나도 없을 때 안내 문구 표시
                if (data.expiringToday.isEmpty && data.expiringSoon.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        '소비기한이 임박한 음식이 없습니다.\n오른쪽 위 냉장고 아이콘을 눌러 공간을 추가하고 음식을 등록해보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    // 아래로 당겨서 새로고침 기능
                    ref.invalidate(dashboardViewModelProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // '오늘까지' 섹션
                      _buildDashboardSection(
                        context: context,
                        title: '🚨 오늘까지 드세요!',
                        color: Colors.red.shade400,
                        products: data.expiringToday,
                        machineTypeMap: data.machineTypeMap, // 공간 타입 맵 전달
                      ),
                      const SizedBox(height: 24),
                      // '3일 이내' 섹션
                      _buildDashboardSection(
                        context: context,
                        title: '👀 3일 내로 확인하세요',
                        color: Colors.orange.shade400,
                        products: data.expiringSoon,
                        machineTypeMap: data.machineTypeMap, // 공간 타입 맵 전달
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  
  }

  Widget _buildDashboardSection({
    required BuildContext context,
    required String title,
    required Color color,
    required List<Product> products,
    required Map<String, String?> machineTypeMap,
  }) {
    // 해당 섹션에 음식이 있을 때만 보이도록 수정
    if (products.isEmpty) {
      return const SizedBox.shrink(); // 음식이 없으면 아무것도 그리지 않음
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        // 가로 스크롤 ListView 대신, 세로로 쌓이는 Column 사용
        Column(
          children: products.map((product) {
            final machineType = machineTypeMap[product.refrigName];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: FoodIcon(iconIdentifier: product.iconAdress, size: 24),
                ),
                title: Text(product.foodName ?? '이름 없음', maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${product.refrigName} / ${product.containerName ?? '기본칸'}'),
                trailing: _buildDDayChip(product), // D-Day 칩 표시
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => GoodsDetailBottomSheet(
                      product: product,
                      machineType: machineType,
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // [신규] 소비기한 D-Day를 표시하는 칩 위젯을 만드는 헬퍼 메소드
  Widget _buildDDayChip(Product product) {
    if (product.useDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final useDate = DateTime(product.useDate!.year, product.useDate!.month, product.useDate!.day);
    final difference = useDate.difference(today).inDays;

    if (difference < 0) {
      return Chip(
        label: Text('기한 지남', style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    } else if (difference == 0) {
      return Chip(
        label: const Text('D-DAY', style: TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: Colors.red.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    } else {
      return Chip(
        label: Text('D-$difference', style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: Colors.orange.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    }
  }
}