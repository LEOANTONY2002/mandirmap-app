import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/auth_repository.dart';
import 'auth_state_provider.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(() {
      return AuthController();
    });

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(email: email, password: password);

      // Update state
      ref.read(authStateProvider.notifier).login();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String stateAttr,
    required String district,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signup(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            password: password,
            state: stateAttr,
            district: district,
          );

      // Update state
      ref.read(authStateProvider.notifier).login();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      ref.read(authStateProvider.notifier).logout();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
