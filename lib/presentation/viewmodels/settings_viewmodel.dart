import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/settings_state_model.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsViewModel extends StateNotifier<AsyncValue<SettingsState>> {
  final SettingsRepository _repository;

  SettingsViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final isEnabled = await _repository.getNotificationSetting();
      final time = await _repository.getNotificationTime();
      state = AsyncValue.data(SettingsState(notificationsEnabled: isEnabled, notificationTime: time));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> updateNotificationSetting(bool isEnabled) async {
    await _repository.saveNotificationSetting(isEnabled);
    loadSettings(); // 설정 저장 후 다시 불러와서 UI 갱신
  }

  Future<void> updateNotificationTime(TimeOfDay time) async {
    await _repository.saveNotificationTime(time);
    loadSettings();
  }
}