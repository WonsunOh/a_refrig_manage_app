import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers/machine_providers.dart';
import '../views/screens/long_term_storage_food.dart';
import '../views/screens/management_page.dart';
import '../views/screens/youtube.dart';
import 'machine_input_dialog.dart';

// 팝업 메뉴의 각 항목을 나타내는 enum
enum MoreMenu { addNewSpace, longTermFood, youtubeSearch, settings }

class AppBarPopupMenu extends ConsumerWidget {
  const AppBarPopupMenu({super.key});

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
                builder: (context, ref, _) => MachineNameInputDialog(
                  onSubmitted: (name, icon, type) {
                    ref.read(machineViewModelProvider.notifier).addMachineName(name, icon, type);
                  },
                ),
              ),
            );
            break;
          case MoreMenu.longTermFood:
            Get.to(() => LongTermStorageFood());
            break;
          case MoreMenu.youtubeSearch:
            Get.to(() => YouTubeSearch());
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
          child: Text('새로운 공간 추가'),
        ),
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.longTermFood,
          child: Text('오래 보관한 음식'),
        ),
        const PopupMenuItem<MoreMenu>(
          value: MoreMenu.youtubeSearch,
          child: Text('유튜브 레시피 검색'),
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