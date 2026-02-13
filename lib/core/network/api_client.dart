import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  const secureStorage = FlutterSecureStorage();

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: AppConstants.authTokenKey);

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Add Language Header from SharedPreferences (not sensitive)
        final prefs = await SharedPreferences.getInstance();
        final lang = prefs.getString('locale') ?? 'en';
        options.headers['Accept-Language'] = lang;

        return handler.next(options);
      },
    ),
  );

  return dio;
});
