import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers.dart';

class YouTubeScreen extends ConsumerStatefulWidget {
  const YouTubeScreen({super.key});

  @override
  ConsumerState<YouTubeScreen> createState() => _YouTubeScreenState();
}

class _YouTubeScreenState extends ConsumerState<YouTubeScreen> {
  final _searchController = TextEditingController();
  bool _isInitialSearchDone = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    // 로딩 시작
    ref.read(youtubeLoadingProvider.notifier).state = true;
    // 검색 실행
    await ref.read(youtubeViewModelProvider.notifier).search(query);
    // 로딩 끝
    ref.read(youtubeLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    // arguments를 build 메소드 안에서 한 번만 확인
    if (!_isInitialSearchDone) {
      final initialSearchQuery = Get.arguments as String?;
      if (initialSearchQuery != null && initialSearchQuery.isNotEmpty) {
        _searchController.text = initialSearchQuery;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _performSearch(initialSearchQuery);
        });
        _isInitialSearchDone = true;
      }
    }

    final videos = ref.watch(youtubeViewModelProvider);
    final isLoading = ref.watch(youtubeLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피 검색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '검색어 입력 (예: 김치찌개 레시피)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed('/youTubePlay',
                              arguments: video.videoId);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.network(
                                  video.thumbnailUrl,
                                  width: 120,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    video.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}