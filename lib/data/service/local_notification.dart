import 'dart:io'; // Platform 확인을 위해 import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  LocalNotification._();

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      // 앱이 포그라운드에 있을 때 알림을 받을지 여부
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // [신규 추가] 알림 권한을 요청하는 메소드
  static Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // Android 13 이상을 위한 알림 권한 요청
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // requestPermission() 대신 requestNotificationsPermission() 사용
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  static display(int id, String title, String body) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  static scheduled(
      int id, String title, String body, int y, int m, int d, int h, int min) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'scheduled channel id',
        'scheduled channel name',
        channelDescription: 'scheduled channel description',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // zonedSchedule 호출 부분에서 문제가 되는 파라미터들을 모두 삭제
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime(tz.local, y, m, d, h, min),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // [삭제] uiLocalNotificationDateInterpretation 파라미터가 최신 버전에선 제거됨
    );
  }

  static cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}