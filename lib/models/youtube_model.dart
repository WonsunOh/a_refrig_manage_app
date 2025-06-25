class YoutubeSearchResult {
  final String videoId;
  final String title;
  final String thumbnailUrl;

  YoutubeSearchResult({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
  });

  factory YoutubeSearchResult.fromJson(Map<String, dynamic> json) {
    return YoutubeSearchResult(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
    );
  }
}