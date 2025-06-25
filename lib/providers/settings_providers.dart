import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/settings_state_model.dart';
import '../core/repositories/settings_repository.dart';
import '../presentation/viewmodels/settings_viewmodel.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, AsyncValue<SettingsState>>((ref) {
  return SettingsViewModel(ref.watch(settingsRepositoryProvider));
});