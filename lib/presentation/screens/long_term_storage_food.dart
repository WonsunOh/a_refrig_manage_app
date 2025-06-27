// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers.dart';
import '../widgets/goods_detail_bottomsheet.dart';

// StatelessWidget을 ConsumerWidget으로 변경
class LongTermStorageFood extends ConsumerWidget {
  const LongTermStorageFood({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태를 구독
    final longTermFoodsState = ref.watch(longTermStorageViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오래 보관한 음식'),
        automaticallyImplyLeading:false, // 뒤로가기 버튼 숨김
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // [핵심 수정] ManagementPage를 닫고 대시보드로 돌아갑니다.
                  ref.read(bottomNavIndexProvider.notifier).state = 1; // 대시보드로 이동
                  Get.back(); // ManagementPage 닫기
                },
              ),
            ],
      ),
      body: SafeArea(
        // AsyncValue.when을 사용하여 로딩, 에러, 데이터 상태를 모두 처리
        child: longTermFoodsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다: $err')),
          data: (foods) {
            if (foods.isEmpty) {
              return const Center(child: Text('오래 보관한 음식이 없습니다.'));
            }
            return ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final product = foods[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(product.iconAdress ?? '📦')),
                    title: Text(product.foodName ?? '이름 없음'),
                    subtitle: Text(
                        '${product.refrigName ?? '-'} / 구매일: ${product.inputDate?.toLocal().toString().split(' ')[0] ?? '-'}'),
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