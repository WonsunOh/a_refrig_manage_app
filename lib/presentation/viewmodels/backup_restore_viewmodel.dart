import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/backup_restore_state.dart';
import '../../utils/backup_restore.dart';

// [수정] StateNotifier가 관리하는 상태 타입을 bool이 아닌 BackupRestoreState로 변경합니다.
class BackupRestoreViewModel extends StateNotifier<BackupRestoreStatus> {
  final DataBaseBackup _backupUtil = DataBaseBackup();

  BackupRestoreViewModel() : super(BackupRestoreStatus.initial);

  
  // [백업] 간편 백업
  Future<bool> internalBackup() async {
    state = BackupRestoreStatus.inProgress;
    final success = await _backupUtil.internalBackup();
    state = success ? BackupRestoreStatus.backupSuccess : BackupRestoreStatus.error;
    return success;
  }

 Future<InternalRestoreResult> internalRestore() async {
    state = BackupRestoreStatus.inProgress;
    final result = await _backupUtil.internalRestore();
    _mapResultToState(result);
    return result;
  }

  // [백업] 내보내기
  Future<bool> exportBackupFile() async {
    state = BackupRestoreStatus.inProgress;
    final success = await _backupUtil.exportBackupFile();
    state = success ? BackupRestoreStatus.exportSuccess : BackupRestoreStatus.initial;
    return success; // [수정] 성공 여부 반환
  }

   // [핵심 수정] importBackupFile 메소드의 로직을 internalRestore와 동일하게 변경
  Future<InternalRestoreResult> importBackupFile() async {
    state = BackupRestoreStatus.inProgress;
    final result = await _backupUtil.importBackupFile();
    _mapResultToState(result);
    return result;
  }

  void resetState() {
    state = BackupRestoreStatus.initial;
  }
// [신규] 중복되는 상태 변경 로직을 위한 헬퍼 메소드
  void _mapResultToState(InternalRestoreResult result) {
    switch (result) {
      case InternalRestoreResult.success:
        state = BackupRestoreStatus.restoreSuccess;
        break;
      case InternalRestoreResult.noFile:
        state = BackupRestoreStatus.restoreNoFile;
        break;
      case InternalRestoreResult.failure:
        state = BackupRestoreStatus.error;
        break;
    }
  }
}