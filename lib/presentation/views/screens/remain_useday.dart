import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/remain_use_day_providers.dart';
import '../../widgets/app_bar_popup_menu.dart';
import '../../widgets/goods_detail_bottomsheet.dart';

// StatelessWidget을 ConsumerWidget으로 변경
class RemainUseDay extends ConsumerWidget {
  const RemainUseDay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태를 구독
    final expiringFoodsState = ref.watch(remainUseDayViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('소비기한 임박 음식'),
        actions: [
          AppBarPopupMenu(),
        ],
      ),
      body: SafeArea(
          // AsyncValue.when을 사용하여 로딩, 에러, 데이터 상태를 모두 처리
          child: expiringFoodsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다: $err')),
            data: (foods) {
              if (foods.isEmpty) {
                return const Center(child: Text('소비기한이 임박한 음식이 없습니다.'));
              }
              return ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final product = foods[index];
                  // 필터링 로직 없이 바로 ListTile을 생성
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(product.iconAdress ?? '🔔')),
                      title: Text(product.foodName ?? '이름 없음'),
                      subtitle: Text(
                          '${product.refrigName ?? '-'} / 소비기한: ${product.useDate?.toLocal().toString().split(' ')[0] ?? '-'}'),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return GoodsDetailBottomSheet(product: product);
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
    );
  }
}