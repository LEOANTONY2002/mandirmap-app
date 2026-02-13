import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/user_model.dart';
import 'auth_state_provider.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  final isLoggedIn = ref.watch(authStateProvider);
  if (!isLoggedIn) return null;

  try {
    final dio = ref.read(dioProvider);
    // You might want an endpoint like /users/me or similar
    // For now, we can fetch profile or assume the login returns it
    // But we need a robust way to get it after restart
    final response = await dio.get('/users/profile');
    return UserModel.fromJson(response.data);
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 401) {
      ref.read(authStateProvider.notifier).logout();
    }
    return null;
  }
});
