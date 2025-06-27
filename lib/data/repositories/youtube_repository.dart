import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/youtube_model.dart';

class YouTubeRepository {
  final String apiKey;

  YouTubeRepository({required this.apiKey});

  Future<List<YouTubeModel>> searchVideos(String query) async {
    final url =  'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&key=$apiKey&maxResults=10&type=video';

    final response = await http.get(Uri.parse(url));
   

    if (response.statusCode == 200) {
      final decodedBody = json.decode(response.body);
      final List<dynamic> items = decodedBody['items'];
      return items.map((item) => YouTubeModel.fromJson(item)).toList();
    } else {
      throw Exception('유튜브 검색에 실패했습니다. API 키를 확인해주세요.');
    }
  }
}