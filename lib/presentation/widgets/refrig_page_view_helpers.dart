// '냉장고'를 위한 그룹화된 뷰
  import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../models/refrig_goods_model.dart';
import '../../providers/dashboard_providers.dart';
import '../../providers/goods_providers.dart';
import '../../providers/long_term_storage_providers.dart';
import '../../providers/machine_providers.dart';
import '../../providers/remain_use_day_providers.dart';
import '../../providers/ui_providers.dart';
import 'food_icon.dart';
import 'goods_detail_bottomsheet.dart';
import 'quick_add_dialog.dart';

Widget buildGroupedView(
    BuildContext context,
    WidgetRef ref,
    String machineName,
    String? machineType,
    Map<String, Map<String, List<Product>>> groupedGoods,
  ) {
    final viewMode = ref.watch(viewModeProvider);
    if (groupedGoods.isEmpty ||
        groupedGoods.values.every(
          (map) => map.isEmpty || map.values.every((list) => list.isEmpty),
        )) {
      return const Center(
        child: Text(
          '음식이 없습니다.\n아래의 \'+\' 버튼을 눌러 물품을 추가해주세요.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final sectionColors = {
      '냉장실': Colors.blue.shade50.withValues(alpha: 0.5),
      '냉동실': Colors.lightBlue.shade100.withValues(alpha: 0.5),
      '실온': Colors.orange.shade50.withValues(alpha: 0.5),
      '기타': Colors.grey.shade200,
    };

    // 이 부분은 각 스토리지 섹션(냉장/냉동)을 만드는 루프입니다.
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: groupedGoods.entries.map((storageEntry) {
        final storageName = storageEntry.key;
        final containerMap = storageEntry.value;
        if (containerMap.isEmpty ||
            containerMap.values.every((list) => list.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // [개선 3] 섹션별 배경색 적용
          color: sectionColors[storageName],
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(storageName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            initiallyExpanded: true,
            // 뷰 모드에 따라 리스트 또는 그리드 뷰를 자식으로 가집니다.
            children: [
              viewMode == ViewMode.list
                  ? buildGroupedGridViewContent(
                      context,
                      ref,
                      machineName,
                      machineType,
                      storageName,
                      containerMap,
                    )
                  : buildGroupedListViewContent(
                      context,
                      ref,
                      machineName,
                      machineType,
                      storageName,
                      containerMap,
                    ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // [핵심 수정] 그룹화된 '리스트 뷰'의 컨테이너 부분을 그리는 메소드
  Widget buildGroupedListViewContent(
    BuildContext context,
    WidgetRef ref,
    String machineName,
    String? machineType,
    String storageName,
    Map<String, List<Product>> containerMap,
  ) {
    return Column(
      children: containerMap.entries.map((containerEntry) {
        final containerName = containerEntry.key;
        final goodsList = containerEntry.value;
        return DragTarget<Product>(
          onAcceptWithDetails: (details) {
            onItemMove(
              ref,
              details.data,
              machineName,
              storageName,
              containerName,
            );
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            return DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: const Radius.circular(10),
                color: isHovering ? Colors.blue.shade300 : Colors.transparent,
                strokeWidth: 1,
                dashPattern: const [6, 5],
              ),
              child: Card(
                // [추가] 각 컨테이너를 별도의 Card(박스)로 감쌉니다.
                elevation: isHovering ? 6 : 2,
                color: isHovering ? Colors.lightBlue.shade50 : Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildContainerHeader(
                        context,
                        ref,
                        machineName,
                        storageName,
                        containerName,
                        goodsList.length,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      // 음식 목록
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: goodsList.length,
                    itemBuilder: (context, index) {
                      return buildSlidableListItem(context, ref, goodsList[index], machineType);
                    },
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                  )
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // [신규] 그룹화된 '그리드 뷰'의 컨테이너 부분을 그리는 메소드
  Widget buildGroupedGridViewContent(
    BuildContext context,
    WidgetRef ref,
    String machineName,
    String? machineType,
    String storageName,
    Map<String, List<Product>> containerMap,
  ) {
    return Column(
      children: containerMap.entries.map((containerEntry) {
        final containerName = containerEntry.key;
        final goodsList = containerEntry.value;
        return DragTarget<Product>(
          onAcceptWithDetails: (details) => onItemMove(
            ref,
            details.data,
            machineName,
            storageName,
            containerName,
          ),
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            return DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: const Radius.circular(12),
                color: candidateData.isNotEmpty
                    ? Colors.blue.shade300
                    : Colors.transparent,
                strokeWidth: 1,
                dashPattern: const [6, 5],
              ),
              child: Card(
                // margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                elevation: isHovering ? 6 : 2,
                color: isHovering ? Colors.lightBlue.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
              side: BorderSide(color: isHovering ? Colors.blue.shade300 : Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildContainerHeader(
                      context,
                      ref,
                      machineName,
                      storageName,
                      containerName,
                      goodsList.length,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: goodsList.length,
                      itemBuilder: (context, index) {
                        final product = goodsList[index];
                        return LongPressDraggable<Product>(
                          data: product,
                          feedback: Opacity(
                            opacity: 0.7,
                            child: CircleAvatar(
                              radius: 28,
                              child: FoodIcon(
                                iconIdentifier: product.iconAdress,
                                size: 28,
                              ),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => showModalBottomSheet(
                              context: context,
                              builder: (_) => GoodsDetailBottomSheet(
                                product: product,
                                machineType: machineType,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                              child: CircleAvatar(
                                radius: 35,
                                child: FoodIcon(iconIdentifier: product.iconAdress, size: 28),
                                                        ),
                            ),
                        ),);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // [신규] 컨테이너 헤더 위젯 (코드 중복 제거)
  Widget buildContainerHeader(
    BuildContext context,
    WidgetRef ref,
    String machineName,
    String storageName,
    String containerName,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$containerName ($count)',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => QuickAddDialog(
                refrigName: machineName,
                storageName: storageName,
                containerName: containerName,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // [신규] Slidable 리스트 아이템 위젯 (코드 중복 제거)
  Widget buildSlidableListItem(
    BuildContext context,
    WidgetRef ref,
    Product product,
    String? machineType,
  ) {
    return Slidable(
      key: ValueKey(product.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => showModalBottomSheet(
              context: context,
              builder: (_) => GoodsDetailBottomSheet(
                product: product,
                machineType: machineType,
              ),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '수정',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) =>
                showDeleteConfirmDialog(context, ref, product, () {
                  ref.invalidate(dashboardViewModelProvider);
                  ref.invalidate(remainUseDayViewModelProvider);
                  ref.invalidate(longTermStorageViewModelProvider);
                }),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '삭제',
          ),
        ],
      ),
      child: LongPressDraggable<Product>(
        data: product,
        feedback: Opacity(
          opacity: 0.7,
          child: Material(
            type: MaterialType.transparency,
            child: CircleAvatar(
              radius: 25,
              child: FoodIcon(iconIdentifier: product.iconAdress, size: 28),
            ),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
          leading: CircleAvatar(
            child: FoodIcon(iconIdentifier: product.iconAdress, size: 24),
          ),
          title: Text(
            product.foodName ?? '이름 없음',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '소비기한: ${product.useDate?.toLocal().toString().split(' ')[0] ?? '-'}',
          ),
          onTap: () => showModalBottomSheet(
            context: context,
            builder: (_) => GoodsDetailBottomSheet(
              product: product,
              machineType: machineType,
            ),
          ),
        ),
      ),
    );
  }

  // [신규] '실온 보관장소'를 위한 단순 리스트 뷰
  Widget buildFlatListView(
    BuildContext context,
    WidgetRef ref,
    String? machineType,
    Map<String, Map<String, List<Product>>> groupedGoods,
  ) {
    final allProducts = groupedGoods.values
        .expand((map) => map.values)
        .expand((list) => list)
        .toList();
    if (allProducts.isEmpty) {
      return const Center(
        child: Text(
          '물품이 없습니다.\n아래의 \'+\' 버튼을 눌러 물품을 추가해주세요.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: allProducts.length,
      itemBuilder: (context, index) {
        final product = allProducts[index];
        return buildSlidableListItem(context, ref, product, machineType);
      },
    );
  }

  // [신규] 아이템 이동 로직 (코드 중복 제거)
  void onItemMove(
    WidgetRef ref,
    Product product,
    String machineName,
    String storageName,
    String containerName,
  ) {
    ref
        .read(goodsViewModelProvider(machineName).notifier)
        .moveGood(product, machineName, storageName, containerName);
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(machineViewModelProvider);
    ref.invalidate(remainUseDayViewModelProvider);
    ref.invalidate(longTermStorageViewModelProvider);
  }


// [신규] 삭제 확인 다이얼로그를 별도 함수로 분리하여 재사용
void showDeleteConfirmDialog(
  BuildContext context,
  WidgetRef ref,
  Product product,
  VoidCallback onCompleted,
) {
  Get.dialog(
    AlertDialog(
      title: const Text('삭제'),
      content: Text('${product.foodName}을(를) 삭제하시겠습니까?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('취소')),
        TextButton(
          onPressed: () async {
            if (product.id != null && product.refrigName != null) {
              await ref
                  .read(goodsViewModelProvider(product.refrigName!).notifier)
                  .deleteGood(product.id!);

                   ref.invalidate(machineViewModelProvider);
              // [수정] 전달받은 콜백 함수 실행
              onCompleted();
            }
            Get.back();
          },
          child: const Text('삭제', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}