import 'package:a_refrig_manage_app/data/datasources/refrig_goods_db_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/settings_state_model.dart';
import 'data/models/alam_model.dart';
import 'data/models/backup_restore_state.dart';
import 'data/models/dashboard_state_model.dart';
import 'data/models/machine_name_model.dart';
import 'data/models/product_model.dart';
import 'data/models/view_mode.dart';
import 'data/models/youtube_model.dart';
import 'data/repositories/alarm_repository.dart';
import 'data/repositories/goods_repository.dart';
import 'data/repositories/machine_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/youtube_repository.dart';
import 'presentation/viewmodels/alarm_viewmodel.dart';
import 'presentation/viewmodels/backup_restore_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/goods_viewmodel.dart';
import 'presentation/viewmodels/long_term_storage_viewmodel.dart';
import 'presentation/viewmodels/machine_viewmodel.dart';
import 'presentation/viewmodels/recipe_suggestion_viewmodel.dart';
import 'presentation/viewmodels/remain_use_day_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';
import 'presentation/viewmodels/statistics_viewmodel.dart';
import 'presentation/viewmodels/youtube_viewmodel.dart';


//============================================
//  alarmRepository Providers
//  alarmViewModelProvider
//============================================

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository();
});
final alarmViewModelProvider =
    // 이제 'Alam' 타입을 정상적으로 인식합니다.
    StateNotifierProvider<AlarmViewModel, AsyncValue<List<Alam>>>((ref) {
      return AlarmViewModel(ref.watch(alarmRepositoryProvider));
    });

//============================================
//  backupRestoreViewModel Providers
//============================================

final backupRestoreViewModelProvider =
    StateNotifierProvider.autoDispose<
      BackupRestoreViewModel,
      BackupRestoreStatus
    >((ref) {
      return BackupRestoreViewModel();
    });

//============================================
//  DashboardViewModel
//============================================

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardState>>((
      ref,
    ) {
      // 음식 데이터를 가져오기 위해 기존 GoodsRepository를 사용합니다.
      return DashboardViewModel(
        ref.watch(goodsRepositoryProvider),
        // ref.watch(machineRepositoryProvider),
      );
    });

//============================================
//  GoodsRepository Providers
//  goodsViewModelProvider
//============================================

// 1. GoodsRepository Provider
final goodsRepositoryProvider = Provider<GoodsRepository>((ref) {
  return GoodsRepository(RefrigGoodsDBHelper());
});

// [수정] StateNotifierProvider가 다루는 상태의 타입을
// ViewModel의 상태 타입과 동일하게 맞춰줍니다.
final goodsViewModelProvider =
    StateNotifierProvider.family<
      GoodsViewModel,
      AsyncValue<Map<String, Map<String, List<Product>>>>,
      String
    >((ref, refrigName) {
      return GoodsViewModel(ref.watch(goodsRepositoryProvider), refrigName);
    });

//============================================
//  foodNameListProvider
//  selectedIngredientsProvider
//=============================================

final foodNameListProvider = FutureProvider<List<String>>((ref) {
  // 중앙 providers.dart에 있는 productRepositoryProvider를 참조(watch)합니다.
  final goodsRepository = ref.watch(goodsRepositoryProvider);
  return goodsRepository.getUniqueFoodNames();
});

final selectedIngredientsProvider =
    StateNotifierProvider<SelectedIngredientsNotifier, List<String>>((ref) {
      return SelectedIngredientsNotifier();
    });

//============================================
//  longTermStorageViewModel Providers
//============================================

final longTermStorageViewModelProvider =
    StateNotifierProvider<LongTermStorageViewModel, AsyncValue<List<Product>>>((
      ref,
    ) {
      // 기존에 만들어 둔 goodsRepositoryProvider를 재사용합니다.
      return LongTermStorageViewModel(ref.watch(goodsRepositoryProvider));
    });

//============================================
//  MachineRepository Providers
//  machineViewModelProvider
//============================================

final machineRepositoryProvider = Provider<MachineRepository>((ref) {
  return MachineRepository();
});

// 2. ViewModel Provider: MachineViewModel의 인스턴스를 생성하고 상태 변화를 감지할 수 있도록 StateNotifierProvider를 사용합니다.
//    ViewModel이 생성될 때 Repository를 주입(DI)해줍니다.
final machineViewModelProvider =
    StateNotifierProvider<MachineViewModel, AsyncValue<List<MachineName>>>((
      ref,
    ) {
      return MachineViewModel(
        ref.watch(machineRepositoryProvider),
        ref.watch(goodsRepositoryProvider), // GoodsRepository 주입
      );
    });

//============================================
//  RemainUseDayViewModel Providers
//============================================

final remainUseDayViewModelProvider =
    StateNotifierProvider<RemainUseDayViewModel, AsyncValue<List<Product>>>((
      ref,
    ) {
      // 이미 만들어둔 goodsRepositoryProvider를 재사용합니다.
      return RemainUseDayViewModel(ref.watch(goodsRepositoryProvider));
    });

//============================================
//  SettingsRepository Providers
//  settingsViewModelProvider
//============================================

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, AsyncValue<SettingsState>>((ref) {
      return SettingsViewModel(ref.watch(settingsRepositoryProvider));
    });


//============================================
//  statisticsViewModel Providers 
//============================================

    final statisticsViewModelProvider = StateNotifierProvider<StatisticsViewModel, StatisticsState>((ref) {
  final goodsRepository = ref.watch(goodsRepositoryProvider);
  return StatisticsViewModel(goodsRepository);
});

//============================================
//  ViewMode Providers
//  bottomNavIndexProvider
//============================================

// 현재 어떤 뷰 모드인지 나타내는 enum
// enum ViewMode { list, grid }

// 뷰 모드 상태를 관리하는 Provider. 기본값은 리스트 뷰.
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

// 하단 네비게이션의 현재 인덱스를 관리하는 Provider
// 단순히 int 값 하나만 관리하므로 StateProvider가 가장 적합합니다.
final bottomNavIndexProvider = StateProvider<int>((ref) => 1);

//============================================
//  YoutubeRepository Providers
//  youtubeSearchViewModelProvider
//============================================

// [중요] 여기에 실제 발급받은 유튜브 API 키를 입력해야 합니다.
const String YOUTUBE_API_KEY = "AIzaSyAH1koGjB3rqqmC5-6KkLhA9e9tLZsk6O4";

final youtubeRepositoryProvider = Provider<YouTubeRepository>((ref) {
  return YouTubeRepository(apiKey: YOUTUBE_API_KEY);
});

final youtubeViewModelProvider =
    StateNotifierProvider<YouTubeViewModel, List<YouTubeModel>>((ref) {
      final repository = ref.watch(youtubeRepositoryProvider);
      return YouTubeViewModel(repository);
    });

// 검색 중 로딩 상태를 관리하기 위한 간단한 Provider
final youtubeLoadingProvider = StateProvider<bool>((ref) => false);
