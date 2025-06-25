import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../models/refrig_goods_model.dart';
import '../../providers/dashboard_providers.dart';
import '../../providers/goods_providers.dart';
import '../../providers/long_term_storage_providers.dart';
import '../../providers/machine_providers.dart';
import '../../providers/remain_use_day_providers.dart';
import '../views/screens/refrig_input.dart';

class GoodsDetailBottomSheet extends ConsumerWidget {
  final Product product;
  final String? machineType; // [추가] 공간 타입을 전달받기 위한 파라미터

  const GoodsDetailBottomSheet({
    super.key,
    required this.product,
    this.machineType, // [추가]
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.foodName ?? '이름 없음', style: Theme.of(context).textTheme.headlineSmall),
          const Divider(height: 20),
          Text('보관 장소: ${product.refrigName ?? '-'}'),
          const SizedBox(height: 8),
          Text('저장 공간: ${product.storageName ?? '-'}'),
          const SizedBox(height: 8),          
          Text('수량: ${product.amount ?? '-'}'),
          const SizedBox(height: 8),
          Text('구매일: ${product.inputDate?.toLocal().toString().split(' ')[0] ?? '-'}'),
          const SizedBox(height: 8),
          Text('소비기한: ${product.useDate?.toLocal().toString().split(' ')[0] ?? '-'}'),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text('메모: ${product.memo ?? ''}'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async { // 1. async 키워드 추가
                  // 2. Get.dialog를 사용하여 확인창을 띄우고 결과를 기다림
                  final bool? shouldDelete = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('삭제'),
                      content: Text('${product.foodName}을(를) 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false), // '취소'시 false 반환
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true), // '삭제'시 true 반환
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                        
                      ],
                    ),
                  );

                  // 3. 사용자가 '삭제'를 눌렀을 경우에만 아래 로직 실행
                  if (shouldDelete == true) {
                    if (product.id != null && product.refrigName != null) {
                      // 4. DB에서 삭제 (이때 ref는 안전함)
                      await ref
                          .read(goodsViewModelProvider(product.refrigName!).notifier)
                          .deleteGood(product.id!);
                          // [추가] 모든 요약 페이지 새로고침
    ref.invalidate(machineViewModelProvider);
                    ref.invalidate(dashboardViewModelProvider);
                    ref.invalidate(remainUseDayViewModelProvider);
                    ref.invalidate(longTermStorageViewModelProvider);
                    }
                    // 5. 모든 작업이 끝난 후 바텀시트를 닫음
                    Get.back();
                  }
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(
                    () => const RefrigInput(),
                    arguments: {
                      'refrigName': product.refrigName,
                      'product': product,
                      'machineType': machineType,
                    },
                  );
                },
                child: const Text('수정'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}