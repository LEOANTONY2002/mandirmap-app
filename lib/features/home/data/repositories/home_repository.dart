import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../../../../core/network/api_client.dart';
import '../models/location_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(dioProvider));
});

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<List<DistrictModel>> getDistricts({String? state}) async {
    try {
      final response = await _dio.get(
        '/locations/districts',
        queryParameters: state != null ? {'state': state} : null,
      );
      final List data = response.data;
      return data.map((json) => DistrictModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationModel>> getNearbyTemples({
    required double lat,
    required double lng,
    double radius = 5000,
  }) async {
    try {
      final response = await _dio.get(
        '/locations/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
          'category': 'TEMPLE',
        },
      );

      final List data = response.data;
      return data.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DeityModel>> getDeities() async {
    try {
      final response = await _dio.get('/locations/deities');
      final List data = response.data;
      return data.map((json) => DeityModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FestivalModel>> getFestivals({
    String? district,
    String? state,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (district != null) queryParams['district'] = district;
      if (state != null) queryParams['state'] = state;

      final response = await _dio.get(
        '/locations/festivals',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final List data = response.data;
      return data.map((json) => FestivalModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      final response = await _dio.get(
        '/locations/search',
        queryParameters: {'q': query},
      );
      final List data = response.data;
      return data.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationModel>> getNearbyLocations({
    required double lat,
    required double lng,
    required String category,
    double radius = 10000,
  }) async {
    try {
      final response = await _dio.get(
        '/locations/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
          'category': category,
        },
      );

      final List data = response.data;
      return data.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationModel>> getLocationsByCategory(
    String category, {
    String? district,
    int? deityId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'category': category};
      if (district != null) queryParams['district'] = district;
      if (deityId != null) queryParams['deityId'] = deityId;

      final response = await _dio.get(
        '/locations',
        queryParameters: queryParams,
      );
      final List data = response.data;
      return data.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationModel>> getTemplesByDeity(
    int deityId,
    double lat,
    double lng,
  ) async {
    try {
      final response = await _dio.get(
        '/locations/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': 50000, // 50km radius
          'category': 'TEMPLE',
          'deityId': deityId,
        },
      );
      final List data = response.data;
      return data.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<LocationModel> getLocationDetails(String id) async {
    try {
      final response = await _dio.get('/locations/$id');
      return LocationModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitReview(String locationId, int rating, String? comment) async {
    try {
      await _dio.post(
        '/locations/$locationId/reviews',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReview(
    String locationId,
    String reviewId,
    int rating,
    String? comment,
  ) async {
    try {
      await _dio.put(
        '/locations/$locationId/reviews/$reviewId',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(String locationId, String reviewId) async {
    try {
      await _dio.delete('/locations/$locationId/reviews/$reviewId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadLocationImage(String locationId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: path.basename(filePath),
        ),
      });
      await _dio.post(
        '/media/upload',
        queryParameters: {'type': 'IMAGE', 'locationId': locationId},
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class DistrictModel {
  final String id;
  final String name;

  DistrictModel({required this.id, required this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
