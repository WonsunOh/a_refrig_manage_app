import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../providers/ui_providers.dart';
import '../../../providers/youtube_providers.dart';
import 'youTube_play.dart';

// StatefulWidget을 ConsumerWidget으로 변경
class YouTubeSearch extends ConsumerWidget {
  const YouTubeSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태를 구독
    final searchState = ref.watch(youtubeSearchViewModelProvider);
    final searchNotifier = ref.read(youtubeSearchViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('유튜브 레시피 검색'),
        automaticallyImplyLeading:false, // 뒤로가기 버튼 숨김
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // [핵심 수정] ManagementPage를 닫고 대시보드로 돌아갑니다.
                  ref.read(bottomNavIndexProvider.notifier).state = 1; // 대시보드로 이동
                  Get.back(); // ManagementPage 닫기
                },
              ),
            ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '요리 이름, 재료 등 검색',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              // 검색 버튼을 누르거나 입력 완료 시 ViewModel의 search 메소드 호출
              onSubmitted: (query) {
                searchNotifier.search(query);
              },
            ),
          ),
        ),
      ),
      body: searchState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다: $err')),
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(child: Text('검색 결과가 없습니다.'));
          }
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return InkWell(
                onTap: () {
                  // YouTubePlay 페이지로 이동하는 로직은 그대로 유지
                  Get.to(() => YouTubePlay(id: video.videoId, title: video.title,));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          video.thumbnailUrl,
                          width: 120.0,
                          height: 90.0,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            video.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}