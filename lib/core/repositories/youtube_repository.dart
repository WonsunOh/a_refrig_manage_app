import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/youtube_model.dart';

class YoutubeRepository {
  // [중요] 0단계에서 발급받은 본인의 API 키를 여기에 붙여넣어 주세요.
  static const _apiKey = "AIzaSyAH1koGjB3rqqmC5-6KkLhA9e9tLZsk6O4";
  static const _baseUrl = "www.googleapis.com";

  Future<List<YoutubeSearchResult>> searchVideos(String query) async {
    final url = Uri.https(_baseUrl, '/youtube/v3/search', {
      'key': _apiKey,
      'part': 'snippet',
      'q': query,
      'maxResults': '15', // 검색 결과 갯수
      'type': 'video',
    });

    final response = await http.get(url);

    

    if (response.statusCode == 200) {
      final decodedBody = json.decode(response.body);
      final List<dynamic> items = decodedBody['items'];
      return items.map((item) => YoutubeSearchResult.fromJson(item)).toList();
    } else {
      throw Exception('유튜브 검색에 실패했습니다. API 키를 확인해주세요.');
    }
  }
}