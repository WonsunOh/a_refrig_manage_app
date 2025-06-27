import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers.dart';
import '../screens/management_page.dart';
import 'machine_input_dialog.dart';

class DrawMenu extends ConsumerWidget {
  const DrawMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태가 'inProgress'인지 감시하여 로딩 화면을 제어합니다.

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/drawer_header_background.png',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '나의 스마트 냉장고',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '똑똑한 식재료 관리의 시작',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.add_location_outlined),
            title: const Text('새로운 공간 추가'),
            onTap: () {
              Get.back(); // 서랍 먼저 닫기
              showDialog(
                context: context,
                builder: (context) => Consumer(
                  builder: (context, ref, _) => MachineNameInputDialog(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.restaurant_menu),
            title: Text(
              '재료로 레시피 검색',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Get.back(); // 메뉴 닫기
              Get.toNamed('/recipeSuggestion'); // 새로운 라우트 이름으로 이동
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.shopping_cart_outlined), // 아이콘 변경
            title: Text(
              '쇼핑 목록',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Get.back(); // 메뉴 닫기
              Get.toNamed('/shoppingList'); // 쇼핑 목록 페이지로 이동
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text(
              '소비 통계',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Get.back(); // 메뉴 닫기
              Get.toNamed('/statistics'); // 통계 페이지로 이동
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('설정 및 관리'),
            subtitle: const Text('알림, 백업/복원, 기타 등'),
            onTap: () {
              Get.back();
              // 우리가 새로 만든 ManagementPage로 이동합니다.
              Get.to(() => const ManagementPage());
            },
          ),
        ],
      ),
    );
  }
}
