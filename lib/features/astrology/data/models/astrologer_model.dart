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
      id: json['id'],
      name: json['name'],
      experienceYears: json['experienceYears'] ?? 0,
      languages:
          json['languages'] != null ? List<String>.from(json['languages']) : [],
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      bio: json['bio'],
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance:
          json['distance'] != null
              ? (json['distance'] as num).toDouble()
              : null,
    );
  }
}
