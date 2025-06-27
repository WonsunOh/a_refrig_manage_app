import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/youtube_repository.dart';
import '../../data/models/youtube_model.dart';

class YouTubeViewModel extends StateNotifier<List<YouTubeModel>> {
  final YouTubeRepository _repository;

  YouTubeViewModel(this._repository) : super([]);

  Future<void> search(String query) async {
    try {
      final videos = await _repository.searchVideos(query);
      state = videos;
    } catch (e) {
      // 에러 처리 (예: state를 빈 리스트로 만들거나, 별도 에러 상태 관리)
      state = [];
    }
  }
}