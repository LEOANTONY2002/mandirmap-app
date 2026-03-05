class AstrologerModel {
  final String id;
  final String name;
  final int experienceYears;
  final List<String> languages;
  final double hourlyRate;
  final String? bio;
  final double rating;
  final double latitude;
  final double longitude;
  final double? distance;

  AstrologerModel({
    required this.id,
    required this.name,
    required this.experienceYears,
    required this.languages,
    required this.hourlyRate,
    this.bio,
    required this.rating,
    required this.latitude,
    required this.longitude,
    this.distance,
  });

  factory AstrologerModel.fromJson(Map<String, dynamic> json) {
    return AstrologerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      languages:
          json['languages'] is List
              ? (json['languages'] as List).map((e) => e.toString()).toList()
              : <String>[],
      hourlyRate:
          json['hourlyRate'] is num
              ? (json['hourlyRate'] as num).toDouble()
              : double.tryParse(json['hourlyRate']?.toString() ?? '0') ?? 0.0,
      bio: json['bio']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}
