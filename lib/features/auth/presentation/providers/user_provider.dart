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
    if (response.data == null) {
      print('[UserProvider] API returned null data');
      return null;
    }
    final user = UserModel.fromJson(response.data);
    if (user.id.isEmpty) {
      print('[UserProvider] User ID is empty in response');
      return null;
    }
    return user;
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      print('[UserProvider] 401 Unauthorized - logging out');
      Future.microtask(() => ref.read(authStateProvider.notifier).logout());
    }
    rethrow;
  } catch (e) {
    print('[UserProvider] Unexpected error: $e');
    rethrow;
  }
});
