class YouTubeModel {
  final String title;
  final String thumbnailUrl;
  final String videoId;

  YouTubeModel({
    required this.title,
    required this.thumbnailUrl,
    required this.videoId,
  });

  factory YouTubeModel.fromJson(Map<String, dynamic> json) {
    return YouTubeModel(
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      videoId: json['id']['videoId'],
    );
  }
}