import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/alarm_repository.dart';
import '../models/alam_model.dart';
import '../presentation/viewmodels/alarm_viewmodel.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository();
});

final alarmViewModelProvider =
    // 이제 'Alam' 타입을 정상적으로 인식합니다.
    StateNotifierProvider<AlarmViewModel, AsyncValue<List<Alam>>>((ref) {
  return AlarmViewModel(ref.watch(alarmRepositoryProvider));
});