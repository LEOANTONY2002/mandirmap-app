class MediaModel {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final String type; // IMAGE, VIDEO
  final int likes;
  final String? userName;
  final String? userAvatar;
  final String? locationName;
  final DateTime createdAt;

  MediaModel({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    required this.type,
    required this.likes,
    this.userName,
    this.userAvatar,
    this.locationName,
    required this.createdAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      type: json['type'],
      likes: json['likes'] ?? 0,
      userName: json['user']?['fullName'],
      userAvatar: json['user']?['avatarUrl'],
      locationName: json['location']?['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
