// lib/presentation/screens/statistics_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // StatisticsViewModel의 상태를 감시합니다.
    final statsState = ref.watch(statisticsViewModelProvider);
    final viewModel = ref.read(statisticsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('소비 통계'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchAllStats(),
            tooltip: '새로고침',
          ),
        ],
      ),
      // RefreshIndicator를 사용하여 아래로 당겨서 새로고침 기능을 구현합니다.
      body: RefreshIndicator(
        onRefresh: () => viewModel.fetchAllStats(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 1. 월별 소비량 카드
            _buildMonthlyConsumptionCard(context, statsState.monthlyConsumption),
            const SizedBox(height: 24),

            // 2. 소비 습관 카드 (파이 차트)
            _buildConsumptionHabitCard(context, statsState.consumptionHabits),
            const SizedBox(height: 24),

            // 3. 가장 많이 구매한 상품 TOP 5 카드
            _buildTopPurchasedItemsCard(context, statsState.topPurchasedItems),
          ],
        ),
      ),
    );
  }

  // 월별 소비량 막대 차트 위젯
  Widget _buildMonthlyConsumptionCard(BuildContext context, AsyncValue<Map<String, int>> monthlyConsumption) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('월별 소비량', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            // AsyncValue의 when을 사용하여 로딩/에러/데이터 상태를 처리합니다.
            monthlyConsumption.when(
              data: (data) {
                if (data.isEmpty) return const Center(child: Text('소비 기록이 없습니다.'));
                // 차트 데이터 생성
                final barGroups = data.entries.map((entry) {
                  final monthIndex = int.parse(entry.key.split('-')[1]);
                  return BarChartGroupData(
                    x: monthIndex,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: Theme.of(context).primaryColor,
                        width: 16,
                        borderRadius: BorderRadius.circular(4)
                      ),
                    ],
                  );
                }).toList();

                return SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text('${value.toInt()}월'),
                            reservedSize: 28
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true, drawVerticalLine: false)
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다: $err')),
            ),
          ],
        ),
      ),
    );
  }

  // 소비 습관 파이 차트 위젯
  Widget _buildConsumptionHabitCard(BuildContext context, AsyncValue<Map<String, int>> consumptionHabits) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('나의 소비 습관', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            consumptionHabits.when(
              data: (data) {
                final consumedOnTime = data['consumedOnTime']?.toDouble() ?? 0;
                final expired = data['expired']?.toDouble() ?? 0;
                if (consumedOnTime == 0 && expired == 0) {
                  return const Center(child: Text('분석할 데이터가 없습니다.'));
                }
                
                return Row(
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: consumedOnTime,
                              title: '${consumedOnTime.toInt()}',
                              radius: 50,
                              titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.red,
                              value: expired,
                              title: '${expired.toInt()}',
                              radius: 50,
                              titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegend(color: Colors.green, text: '기간 내 소비'),
                          const SizedBox(height: 8),
                          _buildLegend(color: Colors.red, text: '소비기한 만료'),
                        ],
                      ),
                    )
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다: $err')),
            )
          ],
        ),
      ),
    );
  }

  // 파이 차트 범례 위젯
  Widget _buildLegend({required Color color, required String text}) {
    return Row(children: [
      Container(width: 16, height: 16, color: color),
      const SizedBox(width: 8),
      Text(text),
    ]);
  }

  // 가장 많이 구매한 상품 리스트 위젯
  Widget _buildTopPurchasedItemsCard(BuildContext context, AsyncValue<List<Map<String, dynamic>>> topItems) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('가장 많이 산 상품 TOP 5', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            topItems.when(
              data: (items) {
                if (items.isEmpty) return const Center(child: Text('구매 기록이 없습니다.'));
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(item['foodName'].toString()),
                      trailing: Text('${item['count']}회 구매'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다: $err')),
            ),
          ],
        ),
      ),
    );
  }
}