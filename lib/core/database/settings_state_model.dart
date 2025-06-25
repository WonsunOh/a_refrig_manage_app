import 'package:flutter/material.dart';

class SettingsState {
  final bool notificationsEnabled;
  final TimeOfDay notificationTime;

  SettingsState({
    required this.notificationsEnabled,
    required this.notificationTime,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    TimeOfDay? notificationTime,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }
}