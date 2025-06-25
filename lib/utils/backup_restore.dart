import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../core/database/alam_db_helper.dart';
import '../core/database/machine_name_db_helper.dart';
import '../core/database/refrig_goods_db_helper.dart';

// [신규] 복원 결과 상태를 나타내는 enum
enum InternalRestoreResult { success, noFile, failure }

// 다운로드 폴더 경로를 가져오는 헬퍼 함수
Future<String?> _getDownloadsPath() async {
  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }
  } catch (err) {
    print("다운로드 폴더를 찾을 수 없습니다: $err");
  }
  return directory?.path;
}

class DataBaseBackup {
  static const List<String> _dbNames = ['MachineName.db', 'RefrigGoods.db', 'Alam.db'];
  static const String _backupFileName = 'internal__backup.zip';

  // [신규] 앱 내부 문서 폴더 경로를 가져오는 헬퍼
  Future<String> get _internalBackupPath async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, _backupFileName);
  }

  // --- [신규] 간편 백업 (내부 저장) ---
  Future<bool> internalBackup() async {
    try {
      await MachineNameDBHelper().closeDatabase();
      await RefrigGoodsDBHelper().closeDatabase();
      await AlamDBHelper().closeDatabase();

      final dbPath = await getDatabasesPath();
      final archive = Archive();
      for (var dbName in _dbNames) {
        final dbFile = File(join(dbPath, dbName));
        if (await dbFile.exists()) {
          final bytes = await dbFile.readAsBytes();
          archive.addFile(ArchiveFile(dbName, bytes.length, bytes));
        }
      }
      final zipBytes = ZipEncoder().encode(archive);
      final backupFile = File(await _internalBackupPath);
      await backupFile.writeAsBytes(zipBytes);
      return true;
    } catch (e) {
      print('내부 백업 실패: $e');
      return false;
    }
  }

  // --- [수정] 간편 복원 (내부 파일 사용) ---
  Future<InternalRestoreResult> internalRestore()  async {
    try {
      final backupFile = File(await _internalBackupPath);
      if (!await backupFile.exists()) {
        return InternalRestoreResult.noFile; // '파일 없음' 상태 반환
      }
      await MachineNameDBHelper().closeDatabase();
      await RefrigGoodsDBHelper().closeDatabase();
      await AlamDBHelper().closeDatabase();
      
      final dbPath = await getDatabasesPath();
      for (var dbName in _dbNames) {
        final file = File(join(dbPath, dbName));
        if (await file.exists()) {
          await file.delete();
        }
      }

      final fileBytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(fileBytes);
      for (final file in archive) {
        if (file.isFile) {
          final filePath = join(dbPath, file.name);
          await File(filePath).writeAsBytes(file.content as List<int>);
        }
      }
      return InternalRestoreResult.success; // '성공' 상태 반환
    } catch (e) {
      print('내부 복원 실패: $e');
      return InternalRestoreResult.failure; // '실패' 상태 반환
    }
  }

  // --- 데이터베이스 백업 ---(zip 파일로 압축)
  Future<bool> exportBackupFile() async {
    try {
      // 1. 먼저 내부 백업을 최신 상태로 만듭니다.
      final internalBackupSuccess = await internalBackup();
      if (!internalBackupSuccess) throw Exception('내부 백업 생성 실패');
      
      // 2. 생성된 내부 백업 파일의 내용을 읽습니다.
      final backupFile = File(await _internalBackupPath);
      final Uint8List fileBytes = await backupFile.readAsBytes();

      // 3. 파일 저장 창을 띄워 사용자에게 위치를 선택하게 합니다.
      await FilePicker.platform.saveFile(
        dialogTitle: '백업 파일 내보내기',
        fileName: 'refrigerator_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.zip',
        bytes: fileBytes,
      );
      return true;
    } catch (e) {
      print('내보내기 실패: $e');
      return false;
    }
  }

  
  // --- 데이터베이스 복원 ---
  Future<InternalRestoreResult> importBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        initialDirectory: await _getDownloadsPath(),
      );

      if (result == null || result.files.single.path == null) {
        return InternalRestoreResult.noFile; // 사용자가 파일 선택 취소
      }
      
      await MachineNameDBHelper().closeDatabase();
      await RefrigGoodsDBHelper().closeDatabase();
      await AlamDBHelper().closeDatabase();

      final backupFilePath = result.files.single.path!;
      final dbPath = await getDatabasesPath();
      
      for (var dbName in _dbNames) {
        final file = File(join(dbPath, dbName));
        if (await file.exists()) {
          await file.delete();
        }
      }

      final fileBytes = await File(backupFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(fileBytes);

      for (final file in archive) {
        if (file.isFile) {
          final filePath = join(dbPath, file.name);
          await File(filePath).writeAsBytes(file.content as List<int>);
        }
      }
      return InternalRestoreResult.success;
    } catch (e) {
      return InternalRestoreResult.failure;
    }
  }
// [신규] 중복되는 복원 로직을 위한 헬퍼 메소드
  Future<void> _restoreFiles(Uint8List fileBytes, String dbPath) async {
    await MachineNameDBHelper().closeDatabase();
    await RefrigGoodsDBHelper().closeDatabase();
    await AlamDBHelper().closeDatabase();

    for (var dbName in _dbNames) {
      final file = File(join(dbPath, dbName));
      if (await file.exists()) {
        await file.delete();
      }
    }
    final archive = ZipDecoder().decodeBytes(fileBytes);
    for (final file in archive) {
      if (file.isFile) {
        final filePath = join(dbPath, file.name);
        await File(filePath).writeAsBytes(file.content as List<int>);
      }
    }
  }
}