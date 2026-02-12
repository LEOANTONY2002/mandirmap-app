import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:5000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          // Dev Mode: Provide a mock token if no user is signed in
          options.headers['Authorization'] = 'Bearer dev-token';
        }

        // Add Language Header
        final prefs = await SharedPreferences.getInstance();
        final lang = prefs.getString('locale') ?? 'en';
        options.headers['Accept-Language'] = lang;

        return handler.next(options);
      },
    ),
  );

  return dio;
});
