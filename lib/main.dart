//#### 냉장고 관리앱 V1.0####
//#### 앱이름 - 우리집, 냉장고, 식자재, 관리, 식품, 정보

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/alam_db_helper.dart';
import 'core/database/machine_name_db_helper.dart';
import 'core/database/refrig_goods_db_helper.dart';
import 'core/repositories/settings_repository.dart';
import 'presentation/views/screens/bottom_navigation.dart';
import 'presentation/views/screens/error_inquiry.dart';
import 'presentation/views/screens/long_term_storage_food.dart';
import 'presentation/views/screens/remain_useday.dart';
import 'presentation/views/screens/settings_page.dart';
import 'presentation/views/screens/splash_screen.dart';
import 'presentation/views/screens/youtube.dart';
import 'service/background_service.dart';
import 'service/local_notification.dart';

void main() async {
  try {
    // WFB 는 비동기 함수를 사용할 때 사용한다. 플러터앱과 각종 플랫폼
    // (android, ios, 등등)을 연결해준다.
    WidgetsFlutterBinding.ensureInitialized();

    

    // [수정] AndroidAlarmManager 초기화
    await AndroidAlarmManager.initialize();

    

    // 가로모드 금지
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Theme Color 와 Alam Time 는 저장소가 하나만 필요하므로 간단한 GetStorage 를 사용하였다.
    // GetStorage 초기화
    await GetStorage.init();

    // Sqflite 의 데이터베이스 초기화
    // 확실치는 않지만 각 데이터베이스의 이름을 달리 해야 하는 것 같다
    await MachineNameDBHelper().database;
    await RefrigGoodsDBHelper().database;
    await AlamDBHelper().database;

    // LocalNotification 초기화
    await LocalNotification.initialize();
    LocalNotification.requestPermissions();

    runApp(
      Phoenix(
        child: ProviderScope(
          child: MyApp(),
          ),
          ),
          );

     // [수정] 설정된 시간을 기준으로 다음 실행 시간을 계산하는 함수
DateTime getScheduledDateTime(SharedPreferences prefs) {
  final timeString = prefs.getString(SettingsRepository.notificationTimeKey) ?? '09:00';
  final parts = timeString.split(':');
  final scheduledTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

  final now = DateTime.now();
  var scheduledDateTime = DateTime(now.year, now.month, now.day, scheduledTime.hour, scheduledTime.minute);
  if (scheduledDateTime.isBefore(now)) {
    scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
  }
  return scheduledDateTime;
}

    // [수정] 앱이 실행된 후, 주기적인 알람을 등록합니다.
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(SettingsRepository.notificationsEnabledKey) ?? false;
    if (notificationsEnabled) {
      // 매일 한 번 실행되는 알람 등록
      await AndroidAlarmManager.periodic(
        const Duration(days: 1), // 주기
        0, // 알람의 고유 ID
        checkExpirationAndNotify, // 실행할 함수
        startAt: getScheduledDateTime(prefs), // 시작 시간
        exact: true, // 정확한 시간에 실행
        wakeup: true, // 화면이 꺼져있어도 깨워서 실행
      );
    }

  } catch (e, s) {
   
    debugPrint("오류 내용: $e");
    debugPrint("스택 트레이스: $s");
  }
 


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [수정] 기본 테마를 먼저 정의합니다.
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal.shade400,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.teal.shade400, // AppBar와 동일한 색상으로 통일감 부여
        selectedItemColor: Colors.white, // 선택된 아이템 색상 (흰색)
        unselectedItemColor: Colors.teal.shade100, // 선택되지 않은 아이템 색상 (연한 청록색)
        elevation: 2,
      ),
    );
    return GetMaterialApp(
      // 앱의 폰트의 크기를 기기에 상관없이 유지
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1)),
          child: child!,
        );
      },
      title: '스마트 냉장고',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.notoSansKrTextTheme(baseTheme.textTheme),
      ),

      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/navi', page: () => const BottomNavigation()),        
        GetPage(name: '/remain', page: () => const RemainUseDay()),
        GetPage(name: '/ysearch', page: () => const YouTubeSearch()),
        GetPage(name: '/longterm', page: () => const LongTermStorageFood()),
        GetPage(name: '/settings', page: () => const SettingsPage()),
        GetPage(name: '/ErrorInquiry', page: () => const ErrorInquiry()),
      ],

      // localization 선언
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
    );
  }
}

// // [추가] 다음 알림 시간까지의 지연 시간을 계산하는 함수
// Duration _calculateInitialDelay(TimeOfDay scheduledTime) {
//   final now = DateTime.now();
//   var scheduledDateTime = DateTime(now.year, now.month, now.day, scheduledTime.hour, scheduledTime.minute);
//   if (scheduledDateTime.isBefore(now)) {
//     scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
//   }
//   return scheduledDateTime.difference(now);
// }
