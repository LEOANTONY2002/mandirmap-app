import 'review_model.dart';

class AstrologerModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final int experienceYears;
  final List<String> languages;
  final double hourlyRate;
  final String? bio;
  final double rating;
  final int totalRatings;
  final bool isVerified;
  final String? phoneNumber;
  final String? whatsappNumber;
  final List<String> photoUrls;
  final double latitude;
  final double longitude;
  final double? distance;
  final List<AstrologerReviewModel>? reviews;

  AstrologerModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.experienceYears,
    required this.languages,
    required this.hourlyRate,
    this.bio,
    required this.rating,
    required this.totalRatings,
    this.isVerified = false,
    this.phoneNumber,
    this.whatsappNumber,
    required this.photoUrls,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.reviews,
  });

  factory AstrologerModel.fromJson(Map<String, dynamic> json) {
    return AstrologerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url'])?.toString(),
      experienceYears:
          int.tryParse(
            (json['experienceYears'] ?? json['experience_years'])?.toString() ??
                '0',
          ) ??
          0,
      languages:
          json['languages'] is List
              ? (json['languages'] as List).map((e) => e.toString()).toList()
              : <String>[],
      hourlyRate:
          double.tryParse(
            (json['hourlyRate'] ?? json['hourly_rate'])?.toString() ?? '0',
          ) ??
          0.0,
      bio: json['bio']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalRatings:
          int.tryParse(
            (json['totalRatings'] ?? json['total_ratings'])?.toString() ?? '0',
          ) ??
          0,
      isVerified:
          (json['isVerified'] ?? json['is_verified'])
              ?.toString()
              .toLowerCase() ==
          'true',
      phoneNumber: (json['phoneNumber'] ?? json['phone_number'])?.toString(),
      whatsappNumber:
          (json['whatsappNumber'] ?? json['whatsapp_number'])?.toString(),
      photoUrls:
          (json['photoUrls'] ?? json['photo_urls']) is List
              ? ((json['photoUrls'] ?? json['photo_urls']) as List)
                  .map((e) => e.toString())
                  .toList()
              : <String>[],
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      distance:
          json['distance'] != null
              ? double.tryParse(json['distance'].toString())
              : null,
      reviews:
          json['reviews'] is List
              ? (json['reviews'] as List)
                  .map((e) => AstrologerReviewModel.fromJson(e))
                  .toList()
              : null,
    );
  }
}
