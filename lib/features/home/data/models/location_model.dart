import '../../../astrology/data/models/review_model.dart';

class LocationModel {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String addressText;
  final double latitude;
  final double longitude;
  final double averageRating;
  final int totalRatings;
  final double? distance; // In meters, from PostGIS
  final List<String> photos;
  final String? district;
  final String? districtMl;
  final String? state;
  final String? stateMl;
  final TempleModel? temple;
  final HotelModel? hotel;
  final RestaurantModel? restaurant;
  final List<AstrologerReviewModel> reviews;

  LocationModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.averageRating,
    required this.totalRatings,
    this.distance,
    required this.photos,
    this.district,
    this.districtMl,
    this.state,
    this.stateMl,
    this.temple,
    this.hotel,
    this.restaurant,
    required this.reviews,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString(),
      addressText: json['addressText']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      averageRating:
          double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      totalRatings: int.tryParse(json['totalRatings']?.toString() ?? '0') ?? 0,
      distance:
          json['distance'] != null
              ? double.tryParse(json['distance'].toString())
              : null,
      photos:
          json['media'] is List
              ? (json['media'] as List)
                  .map(
                    (m) =>
                        m is Map && m['url'] != null
                            ? m['url'].toString()
                            : null,
                  )
                  .where((url) => url != null)
                  .cast<String>()
                  .toList()
              : <String>[],
      district: json['district']?.toString(),
      districtMl: json['districtMl']?.toString(),
      state: json['state']?.toString(),
      stateMl: json['stateMl']?.toString(),
      temple:
          json['temple'] != null ? TempleModel.fromJson(json['temple']) : null,
      hotel: json['hotel'] != null ? HotelModel.fromJson(json['hotel']) : null,
      restaurant:
          json['restaurant'] != null
              ? RestaurantModel.fromJson(json['restaurant'])
              : null,
      reviews:
          json['reviews'] is List
              ? (json['reviews'] as List)
                  .map((r) => AstrologerReviewModel.fromJson(r))
                  .toList()
              : <AstrologerReviewModel>[],
    );
  }
}

class HotelModel {
  final double pricePerDay;
  final String? contactPhone;
  final String? whatsapp;
  final List<String> amenities;

  HotelModel({
    required this.pricePerDay,
    this.contactPhone,
    this.whatsapp,
    required this.amenities,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      pricePerDay:
          double.tryParse(json['pricePerDay']?.toString() ?? '0') ?? 0.0,
      contactPhone: json['contactPhone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      amenities:
          json['amenities'] is List
              ? (json['amenities'] as List).map((e) => e.toString()).toList()
              : <String>[],
    );
  }
}

class RestaurantModel {
  final bool isPureVeg;
  final List<String> menuItems;

  RestaurantModel({required this.isPureVeg, required this.menuItems});

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      isPureVeg: json['isPureVeg']?.toString().toLowerCase() == 'true',
      menuItems:
          json['menuItems'] is List
              ? (json['menuItems'] as List).map((e) => e.toString()).toList()
              : <String>[],
    );
  }
}

class TempleModel {
  final String? history;
  final String? openTime;
  final String? closeTime;
  final List<DeityModel>? deities;
  final dynamic vazhipaduData;

  TempleModel({
    this.history,
    this.openTime,
    this.closeTime,
    this.deities,
    this.vazhipaduData,
  });

  factory TempleModel.fromJson(Map<String, dynamic> json) {
    return TempleModel(
      history: json['history']?.toString(),
      openTime: json['openTime']?.toString(),
      closeTime: json['closeTime']?.toString(),
      vazhipaduData: json['vazhipaduData'], // Keep dynamic
      deities:
          json['deities'] is List
              ? (json['deities'] as List)
                  .where((i) => i is Map && i['deity'] != null)
                  .map<DeityModel>((i) => DeityModel.fromJson(i['deity']))
                  .toList()
              : <DeityModel>[],
    );
  }
}

class DeityModel {
  final int id;
  final String name;
  final String? photoUrl;

  DeityModel({required this.id, required this.name, this.photoUrl});

  factory DeityModel.fromJson(Map<String, dynamic> json) {
    return DeityModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
    );
  }
}

class FestivalModel {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? photoUrl;
  final String? locationId;
  final String? locationName;
  final String? locationDistrict;

  FestivalModel({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.photoUrl,
    this.locationId,
    this.locationName,
    this.locationDistrict,
  });

  factory FestivalModel.fromJson(Map<String, dynamic> json) {
    return FestivalModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(json['startDate'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      endDate:
          json['endDate'] != null
              ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
              : DateTime.now(),
      photoUrl: json['photoUrl']?.toString(),
      locationId: json['locationId']?.toString(),
      locationName: json['location']?['name']?.toString(),
      locationDistrict: json['location']?['district']?.toString(),
    );
  }
}
