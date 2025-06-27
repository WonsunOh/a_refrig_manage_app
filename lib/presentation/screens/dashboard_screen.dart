// lib/presentation/screens/dashboard_screen.dart (최종 수정안)

import 'package:a_refrig_manage_app/presentation/screens/long_term_storage_food.dart';
import 'package:a_refrig_manage_app/presentation/screens/recipe_suggestion_screen.dart';
import 'package:a_refrig_manage_app/presentation/screens/remain_useday.dart';
import 'package:a_refrig_manage_app/presentation/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers.dart';
import 'home_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [수정!] MyHomeScreen을 위한 라우팅을 명시적으로 추가합니다.
    // 이는 MyHomeScreen이 GetX 라우팅 테이블에 등록되어 있지 않을 경우를 대비합니다.
    final routes = {
      '/myHome': (context) => const MyHome(),
      // 다른 라우트들...
    };
    
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final machineState = ref.watch(machineViewModelProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardViewModelProvider);
          ref.invalidate(machineViewModelProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('나의 스마트 냉장고', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(child: Icon(Icons.kitchen_rounded, color: Colors.white54, size: 100)),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: dashboardState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const Center(child: Text('요약 정보를 불러올 수 없습니다.')),
                  data: (summary) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        // [수정!] summary.imminentExpiry.length 와 같이 리스트의 길이를 사용합니다.
                        _buildSummaryCard(
                          context,
                          title: '소비기한 임박',
                          count: summary.imminentExpiry.length,
                          icon: Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          onTap: () => Get.to(() => const RemainUseDay()),
                        ),
                        _buildSummaryCard(
                          context,
                          title: '장기 보관',
                          count: summary.longTermStorage.length,
                          icon: Icons.inventory_2_outlined,
                          color: Colors.brown.shade600,
                          onTap: () => Get.to(() => const LongTermStorageFood()),
                        ),
                        _buildSummaryCard(
                          context,
                          title: '레시피 제안',
                          count: null, // 레시피는 개수가 없음
                          icon: Icons.restaurant_menu,
                          color: Colors.green.shade600,
                          onTap: () => Get.to(() => const RecipeSuggestionScreen()),
                        ),
                        _buildSummaryCard(
                          context,
                          title: '통계 보기',
                          count: null,
                          icon: Icons.bar_chart,
                          color: Colors.purple.shade600,
                          onTap: () => Get.to(() => const StatisticsScreen()),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('나의 공간', style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () => Get.to(() => const MyHome()),
                      child: const Text('전체 보기'),
                    )
                  ],
                ),
              ),
            ),
            machineState.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, s) => const SliverFillRemaining(child: Center(child: Text('공간 목록을 불러올 수 없습니다.'))),
              data: (machines) {
                if (machines.isEmpty) {
                  return const SliverFillRemaining(child: Center(child: Text('새 공간을 추가해보세요.')));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final machine = machines[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(machine.refrigIcon ?? '📦')),
                          title: Text(machine.machineName ?? '이름 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('총 ${machine.totalItemCount ?? 0}개 | 소비임박 ${machine.expiringItemCount ?? 0}개'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () {
                             Get.to(() => const MyHome(), arguments: {'initialIndex': index});
                          },
                        ),
                      );
                    },
                    childCount: machines.length > 3 ? 3 : machines.length, // 최대 3개까지만 보여줌
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 요약 정보 카드를 만드는 헬퍼 위젯
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    int? count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  if (count != null)
                    Text('$count 개', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}