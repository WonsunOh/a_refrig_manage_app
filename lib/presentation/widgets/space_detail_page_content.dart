import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../data/models/product_model.dart';
import '../../providers.dart';
import 'food_icon.dart';
import 'goods_detail_bottomsheet.dart';

// 이 위젯은 이제 Scaffold 없이, 순수하게 내용물만 그리는 역할을 합니다.
class SpaceDetailPageContent extends ConsumerStatefulWidget {
  final String initialMachineName;
  final String? initialMachineType;

  const SpaceDetailPageContent({
    super.key,
    required this.initialMachineName,
    required this.initialMachineType,
  });

  @override
  ConsumerState<SpaceDetailPageContent> createState() => _SpaceDetailPageContentState();
}

class _SpaceDetailPageContentState extends ConsumerState<SpaceDetailPageContent> {

  bool _isIconView = false;

  @override
  Widget build(BuildContext context) {
   
    final goodsState = ref.watch(goodsViewModelProvider(widget.initialMachineName));

    return RefreshIndicator(
      onRefresh: () async {
        // 당겨서 새로고침 기능
        ref.invalidate(goodsViewModelProvider(widget.initialMachineName));
      },
      child: goodsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
        data: (groupedGoods) {
          // 모든 제품 목록을 미리 준비합니다.
          final allProducts = groupedGoods.values.expand((map) => map.values.expand((list) => list)).toList();
          
          if (allProducts.isEmpty) {
            return _buildEmptyListInfo();
          }
            return Column(
            children: [
              // ✅ [추가] 뷰 모드 전환 토글 버튼
              _buildViewModeToggle(),
              // ✅ [수정] 뷰 모드에 따라 다른 위젯을 보여줍니다.
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isIconView
                      ? _buildGroupedIconView(groupedGoods)  // 아이콘 뷰
                      : _buildDetailedListView(groupedGoods), // 리스트 뷰
                ),
              ),
            ],
          );
          
        },
      ),
    );
  }

  // ✅ [추가] 뷰 모드 토글 위젯
  Widget _buildViewModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(_isIconView ? Icons.view_list_outlined : Icons.grid_view_outlined),
            tooltip: _isIconView ? '리스트로 보기' : '아이콘으로 보기' ,
            onPressed: () {
              setState(() {
                _isIconView = !_isIconView;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildDetailedListView(Map<String, Map<String, List<Product>>> groupedGoods) {
    // '실온' 타입일 경우 처리
    if (widget.initialMachineType != '냉장고') {
      final products = groupedGoods['실온']?['기본칸'] ?? [];
      return ListView(
        key: const ValueKey('list_view'),
        padding: const EdgeInsets.only(bottom: 80.0),
        children: products.map((p) => _buildFoodListItem(context, ref, p, widget.initialMachineType)).toList(),
      );
    }
    
    // '냉장고' 타입일 경우 처리
    final storageSections = ['냉장실', '냉동실'];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      children: storageSections.map((storageName) {
        final containerMap = groupedGoods[storageName] ?? {};
        final totalItemsInStorage = containerMap.values.fold<int>(0, (sum, list) => sum + list.length);

        if (totalItemsInStorage == 0) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ExpansionTile(
            key: PageStorageKey(storageName), // 스크롤 위치 유지를 위한 Key
            title: Text('$storageName ($totalItemsInStorage개)', style: const TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: true, // 기본적으로 펼쳐진 상태로 시작
            childrenPadding: const EdgeInsets.only(bottom: 8.0),
            children: containerMap.entries.map((entry) {
              final containerName = entry.key;
              final productsInContainer = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (containerName != '기본칸') // '기본칸'은 따로 제목 표시 안함
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 16.0, 4.0),
                      child: Text(containerName, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade700)),
                    ),
                  ...productsInContainer.map((product) => _buildFoodListItem(context, ref, product, widget.initialMachineType)),
                ],
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

   // ✅ [핵심 기능] 그룹화된 아이콘 뷰
  Widget _buildGroupedIconView(Map<String, Map<String, List<Product>>> groupedGoods) {
    if (widget.initialMachineType != '냉장고') {
      final products = groupedGoods['실온']?['기본칸'] ?? [];
      return _buildIconGrid(products); // 실온은 단일 그리드로 표시
    }
    
    final storageSections = ['냉장실', '냉동실'];
    return ListView(
      key: const ValueKey('icon_view_grouped'),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      children: storageSections.map((storageName) {
        final containerMap = groupedGoods[storageName] ?? {};
        if (containerMap.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 8.0),
                  child: Text(storageName, style: Theme.of(context).textTheme.titleLarge),
                ),
                ...containerMap.entries.map((entry) {
                  final containerName = entry.key;
                  final productsInContainer = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (containerName != '기본칸')
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                          child: Text(containerName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
                        ),
                      _buildIconGrid(productsInContainer),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // 아이콘 그리드를 생성하는 헬퍼 메소드
  Widget _buildIconGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true, // ListView 안에서 사용되므로 shrinkWrap 설정
      physics: const NeverScrollableScrollPhysics(), // ListView의 스크롤을 따름
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final dDay = _calculateDDay(product.useDate);
        return GestureDetector(
          onTap: () => _showProductDetails(product),
          child: Tooltip(
            message: product.foodName ?? '이름 없음',
            child: GridTile(
              footer: CircleAvatar(
                radius: 10,
                backgroundColor: dDay.color.withOpacity(0.9),
                child: Text(dDay.shortText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              child: FoodIcon(iconIdentifier: product.iconAdress, size: 40),
            ),
          ),
        );
      },
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
      // 옆으로 밀어서 삭제하는 기능 추가
      child: Dismissible(
        key: ValueKey(product.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red.shade400,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
        ),
        // 삭제 시 확인 팝업
        confirmDismiss: (direction) async {
          return await Get.dialog<bool>(
            AlertDialog(
              title: const Text('삭제'),
              content: Text("'${product.foodName}'을(를) 삭제하시겠습니까?"),
              actions: [
                TextButton(onPressed: () => Get.back(result: false), child: const Text('취소')),
                TextButton(onPressed: () => Get.back(result: true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          ref.read(goodsViewModelProvider(product.refrigName!).notifier).deleteGood(product.id!);
          Get.snackbar('삭제 완료', "'${product.foodName}'을(를) 삭제했습니다.", snackPosition: SnackPosition.BOTTOM);
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
          title: Text(product.foodName ?? '이름 없음', style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('수량: ${product.amount ?? ''} ${product.unit ?? ''}'),
          trailing: Text(
            dDay.text,
            style: TextStyle(color: dDay.color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // ✅ [추가] 상품 상세정보 BottomSheet를 보여주는 공통 메소드
  void _showProductDetails(Product product) {
    Get.bottomSheet(
      GoodsDetailBottomSheet(product: product, machineType: widget.initialMachineType),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    );
  }

  // ✅ [수정] D-Day 계산 로직 (아이콘 뷰를 위한 shortText 추가)
  ({String text, String shortText, Color color}) _calculateDDay(DateTime? useDate) {
    if (useDate == null) return (text: '기한 없음', shortText: '-', color: Colors.grey);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = useDate.difference(today).inDays;

    if (difference < 0) return (text: '기한 만료', shortText: '!', color: Colors.grey.shade700);
    if (difference == 0) return (text: 'D-DAY', shortText: '0', color: Colors.red.shade600);
    if (difference <= 7) return (text: 'D-$difference', shortText: '$difference', color: Colors.orange.shade700);
    return (text: 'D-$difference', shortText: '$difference', color: Colors.green.shade700);
  }
}

