import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/location_model.dart';

final templeRepositoryProvider = Provider<TempleRepository>((ref) {
  return TempleRepository(ref.watch(dioProvider));
});

class TempleRepository {
  final Dio _dio;

  TempleRepository(this._dio);

  Future<LocationModel> getTempleDetails(String id) async {
    try {
      final response = await _dio.get('/locations/$id');
      return LocationModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
