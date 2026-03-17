import '../../../auth/domain/user_model.dart';

class AstrologerReviewModel {
  final String id;
  final String userId;
  final UserModel? user;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  AstrologerReviewModel({
    required this.id,
    required this.userId,
    this.user,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory AstrologerReviewModel.fromJson(Map<String, dynamic> json) {
    return AstrologerReviewModel(
      id: json['id']?.toString() ?? '',
      userId: (json['userId'] ?? json['user_id'])?.toString() ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      rating: int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now()
              : (json['created_at'] != null
                  ? DateTime.tryParse(json['created_at'].toString()) ??
                      DateTime.now()
                  : DateTime.now()),
    );
  }
}
