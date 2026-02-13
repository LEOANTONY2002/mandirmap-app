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
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      addressText: json['addressText'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      distance:
          json['distance'] != null
              ? (json['distance'] as num).toDouble()
              : null,
      photos:
          json['media'] != null
              ? (json['media'] as List).map((m) => m['url'].toString()).toList()
              : <String>[],
      district: json['district'],
      districtMl: json['districtMl'],
      state: json['state'],
      stateMl: json['stateMl'],
      temple:
          json['temple'] != null ? TempleModel.fromJson(json['temple']) : null,
      hotel: json['hotel'] != null ? HotelModel.fromJson(json['hotel']) : null,
      restaurant:
          json['restaurant'] != null
              ? RestaurantModel.fromJson(json['restaurant'])
              : null,
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
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      contactPhone: json['contactPhone'],
      whatsapp: json['whatsapp'],
      amenities:
          json['amenities'] != null
              ? List<String>.from(json['amenities'])
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
      isPureVeg: json['isPureVeg'] ?? true,
      menuItems:
          json['menuItems'] != null
              ? List<String>.from(json['menuItems'])
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
      history: json['history'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      vazhipaduData: json['vazhipaduData'],
      deities:
          json['deities'] != null
              ? (json['deities'] as List)
                  .where((i) => i['deity'] != null)
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
      id: json['id'],
      name: json['name'],
      photoUrl: json['photoUrl'],
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

  FestivalModel({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.photoUrl,
    this.locationId,
  });

  factory FestivalModel.fromJson(Map<String, dynamic> json) {
    return FestivalModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      photoUrl: json['photoUrl'],
      locationId: json['locationId'],
    );
  }
}
