import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/youtube_repository.dart';
import '../../models/youtube_model.dart';

class YoutubeSearchViewModel
    extends StateNotifier<AsyncValue<List<YoutubeSearchResult>>> {
  final YoutubeRepository _repository;

  YoutubeSearchViewModel(this._repository) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final results = await _repository.searchVideos(query);
      state = AsyncValue.data(results);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}