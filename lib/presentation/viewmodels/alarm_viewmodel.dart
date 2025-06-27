import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/alarm_repository.dart';
import '../../data/models/alam_model.dart';
import '../../data/service/local_notification.dart';

class AlarmViewModel extends StateNotifier<AsyncValue<List<Alam>>> {
  final AlarmRepository _repository;

  AlarmViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchAlarms();
  }

  Future<void> fetchAlarms() async {
    state = const AsyncValue.loading();
    try {
      final alarms = await _repository.getAlarms();
      state = AsyncValue.data(alarms);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addAlarm(Alam alam) async {
    final newId = await _repository.insertAlarm(alam);
    if(newId == -1) return; // DB 저장 실패 시 중단

    try {
      final dateParts = alam.alamDate!.split('-');
      final timeParts = alam.alamTime!.split(':');
      final y = int.parse(dateParts[0]), m = int.parse(dateParts[1]), d = int.parse(dateParts[2]);
      final h = int.parse(timeParts[0]), min = int.parse(timeParts[1]);

      // DB에서 반환받은 newId를 알림 ID로 사용
      await LocalNotification.scheduled(
        newId,
        '소비기한 알림',
        '${alam.alamName}의 소비기한이 오늘까지입니다!',
        y, m, d, h, min,
      );
    } catch(e) {
      // 에러 처리
    }
    fetchAlarms();
  }

  Future<void> deleteAlarm(int id) async {
    await _repository.deleteAlarm(id);
    // DB에서 삭제한 알람의 id를 사용하여 예약된 알림도 취소
    await LocalNotification.cancel(id);
    fetchAlarms();
  }
}