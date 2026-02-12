import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/auth_repository.dart';
import '../../../../core/services/notification_service.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(() {
      return AuthController();
    });

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  String? _verificationId;
  String? get verificationId => _verificationId;

  Future<void> sendOtp(String phoneNumber, Function(String) onCodeSent) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (vId) {
          _verificationId = vId;
          onCodeSent(vId);
          state = const AsyncValue.data(null);
        },
        onVerificationFailed: (e) {
          state = AsyncValue.error(e, StackTrace.current);
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) return;

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Successfully logged in, now sync FCM token
      final token = await NotificationService.getToken();
      if (token != null) {
        await repository.updateFcmToken(token);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
