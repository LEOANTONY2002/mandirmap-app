import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/astrologer_model.dart';

final astrologyRepositoryProvider = Provider<AstrologyRepository>((ref) {
  return AstrologyRepository(ref.watch(dioProvider));
});

class AstrologyRepository {
  final Dio _dio;

  AstrologyRepository(this._dio);

  Future<List<AstrologerModel>> getNearbyAstrologers({
    double? lat,
    double? lng,
    String? district,
    double radius = 20000,
  }) async {
    try {
      final response = await _dio.get(
        '/astrologers/nearby',
        queryParameters: {
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          if (district != null) 'district': district,
          'radius': radius,
        },
      );

      final List data = response.data;
      return data.map((json) => AstrologerModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AstrologerModel>> getAstrologers() async {
    try {
      final response = await _dio.get('/astrologers');
      final List data = response.data;
      return data.map((json) => AstrologerModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
