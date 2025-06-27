// lib/common/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // 이 클래스가 실수로 인스턴스화되는 것을 막기 위해 private 생성자를 만듭니다.
  AppTheme._();

  // 앱의 라이트 모드 테마 정의
  static final ThemeData lightTheme = ThemeData(
    // 앱의 기본 색상 견본
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
    
    // 앱의 배경색
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),

    // 앱바(AppBar) 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F7),
      foregroundColor: Colors.black87,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),

    // 카드(Card) 테마
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
    ),

    // 플로팅 액션 버튼(FloatingActionButton) 테마
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),

    // 텍스트 테마 (필요 시 주석 해제하여 사용)
    textTheme: TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[800]),
    ),
    
    // UI의 밀도를 조절
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
  );

  // [미래를 위한 확장] 다크 모드 테마도 이곳에 추가할 수 있습니다.
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // 다크 모드에 맞는 색상들을 이곳에 정의합니다.
    // ...
  );
}