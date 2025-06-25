import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
   @override
  void initState() {
    super.initState();
    // 페이지가 처음 열릴 때 권한 상태를 확인합니다.
    _checkAndRequestPermission();
  }

  // [신규] 알람 권한을 확인하고 요청하는 함수
  Future<void> _checkAndRequestPermission() async {
    // 안드로이드 12 (SDK 31) 이상에서만 이 권한이 필요합니다.
    var status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      // 권한이 거부된 상태라면, 사용자에게 요청합니다.
      await Permission.scheduleExactAlarm.request();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final settingsNotifier = ref.read(settingsViewModelProvider.notifier);

    // 시간을 선택하는 로직을 별도의 함수로 분리
    void selectTime(BuildContext context) async {
      final currentTime =
          ref.read(settingsViewModelProvider).value?.notificationTime ??
          TimeOfDay.now();
      final newTime = await showTimePicker(
        context: context,
        initialTime: currentTime,
      );
      if (newTime != null) {
        settingsNotifier.updateNotificationTime(newTime);
      }
    }
    final nowT = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('알림 설정, 현재시각: ${nowT.hour}:${nowT.minute}')),
      body: settingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('설정을 불러오지 못했습니다: $err')),
        data: (settings) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('소비기한 알림 받기'),
                subtitle: const Text('매일 정해진 시간에 소비기한 만료 알림을 받습니다.'),
                value: settings.notificationsEnabled,
                onChanged: (bool value) async {
                  if (value) {
                    await _checkAndRequestPermission();
                  }
                  settingsNotifier.updateNotificationSetting(value);
          
                },
              ),
              ListTile(
                title: const Text('알림 시간 설정'),
                subtitle: const Text(
                  '시간을 지정하시면 매일 이 시간에 소비기한을 알려드려요. ',
                ),
                enabled: settings.notificationsEnabled,
                onTap: () => selectTime(context), // ListTile 전체를 탭해도 동작
                trailing: TextButton(
                  onPressed: () => selectTime(context), // 버튼을 눌러도 동작
                  child: Text(
                    settings.notificationTime.format(context), // 예: 오전 9:00
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
