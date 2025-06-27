import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../screens/long_term_storage_food.dart';
import '../screens/management_page.dart';
import '../screens/shopping_list_page.dart';
import '../screens/statistics_screen.dart';
import '../screens/youtube_screen.dart';
import 'machine_input_dialog.dart';

// 팝업 메뉴의 각 항목을 나타내는 enum
enum MoreMenu { addNewSpace, longTermFood, youtubeSearch,shoppingList, statistics, settings }

class KebabMenu extends ConsumerWidget {
  const KebabMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<MoreMenu>(
      // 점 세개 아이콘
      icon: const Icon(Icons.more_vert),
      // 메뉴 항목 선택 시 호출될 콜백
      onSelected: (MoreMenu item) {
        switch (item) {
          case MoreMenu.addNewSpace:
            showDialog(
              context: context,
              builder: (_) => Consumer(
                builder: (context, ref, _) => MachineNameInputDialog(),
              ),
            );
            break;
          case MoreMenu.longTermFood:
            Get.to(() => LongTermStorageFood());
            break;
          case MoreMenu.youtubeSearch:
            Get.to(() => YouTubeScreen());
            break;
          case MoreMenu.shoppingList:
            Get.to(() => ShoppingListPage());
            break;
          case MoreMenu.statistics:
            Get.to(() => StatisticsScreen());
            break;
          case MoreMenu.settings:
            Get.to(() => const ManagementPage());
            break;
        }
      },
      // 팝업에 표시될 메뉴 항목 리스트
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MoreMenu>>[
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.addNewSpace,
          child: Text('새 저장공간 추가'),
        ),
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.longTermFood,
          child: Text('오래 보관한 음식'),
        ),
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.youtubeSearch,
          child: Text('재료로 레시피 검색'),
        ),
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.shoppingList,
          child: Text('쇼핑 목록'),
        ),
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.statistics,
          child: Text('소비 통계'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.settings,
          child: Text('설정 및 관리'),
        ),
      ],
    );
  }
}