import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/user_model.dart';
import 'auth_state_provider.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  // Watch authState so this re-runs on login/logout
  final isLoggedIn = ref.watch(authStateProvider);
  if (!isLoggedIn) return null;

  try {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/users/profile');
    return UserModel.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      ref.read(authStateProvider.notifier).logout();
    }
    return null;
  } catch (_) {
    return null;
  }
});
