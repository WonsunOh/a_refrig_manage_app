import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/product_model.dart';
import '../../providers.dart';
import '../screens/refrig_input.dart';
import '../viewmodels/shopping_list_viewmodel.dart';
import 'food_icon.dart';

class GoodsDetailBottomSheet extends ConsumerWidget {
  final Product product;
  final String? machineType;

  const GoodsDetailBottomSheet({
    super.key,
    required this.product,
    this.machineType,
  });

  // D-Day 계산 및 위젯 반환 헬퍼 함수
  Widget _buildDDayChip() {
    if (product.useDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final useDate = product.useDate!;
    final difference = useDate.difference(today).inDays;

    String text;
    Color color;

    if (difference < 0) {
      text = '기한 만료';
      color = Colors.grey.shade600;
    } else if (difference == 0) {
      text = 'D-DAY';
      color = Colors.red.shade500;
    } else {
      text = 'D-$difference';
      color = Colors.orange.shade500;
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. 헤더 섹션 ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: FoodIcon(iconIdentifier: product.iconAdress, size: 32),
                ),
                const SizedBox(width: 16),
                Text(
                        product.foodName ?? '이름 없음',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 16),
                      _buildDDayChip(),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         product.foodName ?? '이름 없음',
                //         style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                //         maxLines: 2,
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //       const SizedBox(height: 4),
                //       _buildDDayChip(),
                //     ],
                //   ),
                // ),
              ],
            ),
            const Divider(height: 32),

            // --- 2. 상세 정보 섹션 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                
                children: [
                  _buildInfoRow(
                    icon: Icons.kitchen_outlined,
                    title: '보관 위치',
                    content: '${product.refrigName ?? '-'} / ${product.storageName ?? '-'}',
                  ),
                  _buildInfoRow(
                    icon: Icons.inventory_2_outlined,
                    title: '보관 칸',
                    content: product.containerName ?? '기본칸',
                  ),
                  _buildInfoRow(
                    icon: Icons.inbox_outlined,
                    title: '수량',
                    content: '${product.amount ?? '-'} ${product.unit ?? ''}',
                  ),
                  _buildDateInfoRow(), // 날짜 정보를 표시하는 새로운 Row
                ],
              ),
            ),

            // --- 3. 메모 섹션 ---
            if (product.memo != null && product.memo!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildMemoSection(),
            ],

            const Divider(height: 32),

            // --- 4. 액션 버튼 섹션 ---
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  // 아이콘, 제목, 내용을 포함하는 정보 행을 만드는 헬퍼 위젯
  Widget _buildInfoRow({required IconData icon, required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
          const Spacer(),
          Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 날짜 정보 행을 만드는 헬퍼 위젯
  Widget _buildDateInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDateItem(
            icon: Icons.calendar_today_outlined,
            title: '구매일',
            date: product.inputDate,
          ),
          const SizedBox(width: 50),
          _buildDateItem(
            icon: Icons.event_busy_outlined,
            title: '소비기한',
            date: product.useDate,
          ),
        ],
      ),
    );
  }
  
  // 날짜 항목 하나를 만드는 헬퍼 위젯
  Widget _buildDateItem({required IconData icon, required String title, required DateTime? date}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('yyyy-MM-dd').format(date) : '-',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
  
  // 메모 섹션을 만드는 헬퍼 위젯
  Widget _buildMemoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.notes_outlined, color: Colors.grey.shade700, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('메모', style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
              const SizedBox(height: 8),
              Text(product.memo!, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  // 액션 버튼들을 만드는 헬퍼 위젯
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.add_shopping_cart_outlined,
          label: '쇼핑 목록',
          onTap: () {
            ref.read(shoppingListViewModelProvider.notifier).addItem(product.foodName!);
            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("'${product.foodName}'을(를) 쇼핑 목록에 추가했습니다.")),
            );
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.edit_outlined,
          label: '수정',
          onTap: () {
            Get.back();
            Get.to(() => const RefrigInput(), arguments: {
              'refrigName': product.refrigName,
              'product': product,
              'machineType': machineType,
            });
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.delete_outline,
          label: '삭제',
          color: Colors.red.shade500,
          onTap: () async {
            final bool? shouldDelete = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('삭제 확인'),
                content: Text("'${product.foodName}'을(를) 삭제하시겠습니까?"),
                actions: [
                  TextButton(onPressed: () => Get.back(result: false), child: const Text('취소')),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (shouldDelete == true && context.mounted) {
              await ref.read(goodsViewModelProvider(product.refrigName!).notifier).deleteGood(product.id!);
              ref.invalidate(machineViewModelProvider);
              ref.invalidate(dashboardViewModelProvider);
              ref.invalidate(remainUseDayViewModelProvider);
              ref.invalidate(longTermStorageViewModelProvider);
              ref.invalidate(statisticsViewModelProvider);
              Get.back();
            }
          },
        ),
      ],
    );
  }

   Widget _buildActionButton({required BuildContext context, required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final themeColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: themeColor),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: themeColor)),
          ],
        ),
      ),
    );
  }
}