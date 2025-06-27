import 'package:a_refrig_manage_app/data/service/local_notification.dart';
import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';

import '../datasources/refrig_goods_db_helper.dart';

// [수정] 이제 이 함수가 직접 백그라운드에서 호출됩니다.
@pragma('vm:entry-point')
void checkExpirationAndNotify() async {
  // 백그라운드 isolate에서 Flutter 엔진과 통신하기 위해 초기화합니다.
  WidgetsFlutterBinding.ensureInitialized();
  
  print("✅ [BACKGROUND] 소비기한 체크 작업을 시작합니다.");

  try {
    const daysBefore = 3; 
    final dbHelper = RefrigGoodsDBHelper();
    final allGoods = await dbHelper.getAllGoods();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int expiringTodayCount = 0;
    int expiringSoonCount = 0;

    for (var product in allGoods) {
      if (product.useDate != null) {
        final useDate = DateTime(product.useDate!.year, product.useDate!.month, product.useDate!.day);
        final difference = useDate.difference(today).inDays;
        if (difference == 0) { expiringTodayCount++; }
        else if (difference > 0 && difference <= daysBefore) { expiringSoonCount++; }
      }
    }
    
    String notificationBody = '';
    if (expiringTodayCount > 0) notificationBody += '오늘까지인 음식이 ${expiringTodayCount}개 있습니다. ';
    if (expiringSoonCount > 0) notificationBody += '${daysBefore}일 내로 만료되는 음식이 ${expiringSoonCount}개 있습니다.';

    if (notificationBody.isNotEmpty) {
      await LocalNotification.initialize();
      await LocalNotification.display(0, '소비기한 알림', notificationBody.trim());
      print("✅ [BACKGROUND] 알림 발송 성공: ${notificationBody.trim()}");
    } else {
      print("✅ [BACKGROUND] 알림 보낼 항목 없음.");
    }
  } catch (err) {
    print("❌ [BACKGROUND] 작업 실패: $err");
  }
}