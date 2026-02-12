import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../home/data/models/location_model.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(dioProvider));
});

class FavoritesRepository {
  final Dio _dio;

  FavoritesRepository(this._dio);

  Future<List<LocationModel>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      final List data = response.data;
      // The backend returns a list of Favorite objects which contain a 'location' property
      return data
          .map((item) => LocationModel.fromJson(item['location']))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleFavorite(String locationId) async {
    try {
      final response = await _dio.post(
        '/favorites/toggle',
        data: {'locationId': locationId},
      );
      return response.data['isFavorite'];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getFavoriteStatus(String locationId) async {
    try {
      final response = await _dio.get('/favorites/status/$locationId');
      return response.data['isFavorite'];
    } catch (e) {
      rethrow;
    }
  }
}
