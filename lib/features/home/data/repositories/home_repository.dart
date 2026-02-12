import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/location_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(dioProvider));
});

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<List<LocationModel>> getNearbyTemples({
    required double lat,
    required double lng,
    double radius = 5000,
  }) async {
    try {
      final response = await _dio.get(
        '/locations/nearby',
        queryParameters: {'lat': lat, 'lng': lng, 'radius': radius},
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

  Future<List<FestivalModel>> getFestivals({String? district}) async {
    try {
      final response = await _dio.get(
        '/locations/festivals',
        queryParameters: district != null ? {'district': district} : null,
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

  Future<List<LocationModel>> getLocationsByCategory(String category) async {
    try {
      final response = await _dio.get(
        '/locations',
        queryParameters: {'category': category},
      );
      final List data = response.data;
      return data.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
