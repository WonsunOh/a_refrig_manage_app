import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/youtube_repository.dart';
import '../models/youtube_model.dart';
import '../presentation/viewmodels/Youtube_viewmodel.dart';

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) {
  return YoutubeRepository();
});

final youtubeSearchViewModelProvider = StateNotifierProvider.autoDispose<
    YoutubeSearchViewModel, AsyncValue<List<YoutubeSearchResult>>>((ref) {
  // autoDispose를 사용하면, 화면을 벗어났을 때 검색 결과가 자동으로 초기화되어 메모리를 절약합니다.
  return YoutubeSearchViewModel(ref.watch(youtubeRepositoryProvider));
});