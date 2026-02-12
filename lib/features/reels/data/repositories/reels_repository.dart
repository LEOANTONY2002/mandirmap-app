import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/media_model.dart';

final reelsRepositoryProvider = Provider<ReelsRepository>((ref) {
  return ReelsRepository(ref.watch(dioProvider));
});

class ReelsRepository {
  final Dio _dio;
  ReelsRepository(this._dio);

  Future<List<MediaModel>> getReels({int skip = 0, int take = 10}) async {
    try {
      final response = await _dio.get(
        '/media/reels',
        queryParameters: {'skip': skip, 'take': take},
      );

      return (response.data as List)
          .map((json) => MediaModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
