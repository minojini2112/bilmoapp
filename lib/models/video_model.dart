class VideoModel {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String description;
  final String publishedAt;
  final String duration;
  final String viewCount;
  final String likeCount;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.description,
    required this.publishedAt,
    required this.duration,
    required this.viewCount,
    required this.likeCount,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final highThumbnail = thumbnails['high'] as Map<String, dynamic>? ?? {};
    
    return VideoModel(
      videoId: json['id']?['videoId'] ?? '',
      title: snippet['title'] ?? 'Untitled',
      thumbnailUrl: highThumbnail['url'] ?? '',
      channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
      description: snippet['description'] ?? '',
      publishedAt: snippet['publishedAt'] ?? '',
      duration: '', // Will be filled by additional API call
      viewCount: '', // Will be filled by additional API call
      likeCount: '', // Will be filled by additional API call
    );
  }

  // Convert to YouTube Shorts URL
  String get shortsUrl => 'https://www.youtube.com/shorts/$videoId';
  
  // Convert to regular YouTube URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'channelTitle': channelTitle,
      'description': description,
      'publishedAt': publishedAt,
      'duration': duration,
      'viewCount': viewCount,
      'likeCount': likeCount,
    };
  }
}
