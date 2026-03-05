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
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      type: json['type']?.toString() ?? 'IMAGE',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      userName: json['user']?['fullName']?.toString() ?? 'Anonymous',
      userAvatar: json['user']?['avatarUrl']?.toString(),
      locationName: json['location']?['name']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : (json['createdAt'] != null
                  ? DateTime.tryParse(json['createdAt'].toString()) ??
                      DateTime.now()
                  : DateTime.now()),
    );
  }
}
