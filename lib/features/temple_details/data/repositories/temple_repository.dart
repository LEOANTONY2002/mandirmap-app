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
      print('Fetching details for temple ID: $id');
      final response = await _dio.get('/locations/$id');
      print('Response received: ${response.data != null}');
      final model = LocationModel.fromJson(response.data);
      print('Model parsed successfully: ${model.name}');
      return model;
    } catch (e) {
      print('Error fetching temple details: $e');
      rethrow;
    }
  }
}
