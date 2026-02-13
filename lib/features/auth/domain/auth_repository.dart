import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../domain/user_model.dart';

import '../../../../core/config/app_constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      final user = UserModel.fromJson(data['user']);
      final token = data['token'];

      // Securely store token
      await _secureStorage.write(key: AppConstants.authTokenKey, value: token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isLoggedInKey, true);

      return {'user': user, 'token': token};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String state,
    required String district,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'state': state,
          'district': district,
        },
      );

      final data = response.data;
      final user = UserModel.fromJson(data['user']);
      final token = data['token'];

      // Securely store token
      await _secureStorage.write(key: AppConstants.authTokenKey, value: token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isLoggedInKey, true);

      return {'user': user, 'token': token};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Signup failed';
      throw Exception(message);
    }
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.authTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }
}
