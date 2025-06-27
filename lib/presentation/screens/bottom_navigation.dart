import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'remain_useday.dart'; // import 추가

class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(bottomNavIndexProvider);

    // [수정] 새로운 탭 순서에 맞게 페이지 목록 변경
    const pages = <Widget>[
      MyHome(),          // 인덱스 0: 나의 공간
      DashboardScreen(), // 인덱스 1: 홈 (구 대시보드)
      RemainUseDay(),    // 인덱스 2: 소비기한
    ];


    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        // [수정] 메뉴 아이템 순서 및 이름 변경
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: '나의 공간',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: '소비기한',
          ),
        ],
      ),
    );
  }
}
