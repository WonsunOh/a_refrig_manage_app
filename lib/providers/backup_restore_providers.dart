import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/settings_repository.dart';
import '../models/backup_restore_state.dart';
import '../presentation/viewmodels/backup_restore_viewmodel.dart';

// SettingsRepository Provider (이 파일에 같이 있어도 괜찮습니다)
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final backupRestoreViewModelProvider =
    StateNotifierProvider.autoDispose<BackupRestoreViewModel, BackupRestoreStatus>((ref) {
  return BackupRestoreViewModel();
});