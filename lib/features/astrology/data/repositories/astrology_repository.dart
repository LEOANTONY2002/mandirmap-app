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

  Future<AstrologerModel> getAstrologerDetails(String id) async {
    try {
      final response = await _dio.get('/astrologers/$id');
      return AstrologerModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitReview(String astrologerId, int rating, String? comment) async {
    try {
      await _dio.post(
        '/astrologers/$astrologerId/reviews',
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
    String astrologerId,
    String reviewId,
    int rating,
    String? comment,
  ) async {
    try {
      await _dio.put(
        '/astrologers/$astrologerId/reviews/$reviewId',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(String astrologerId, String reviewId) async {
    try {
      await _dio.delete('/astrologers/$astrologerId/reviews/$reviewId');
    } catch (e) {
      rethrow;
    }
  }
}
