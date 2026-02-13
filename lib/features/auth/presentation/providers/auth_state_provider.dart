import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/app_constants.dart';

class AuthStateNotifier extends Notifier<bool> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  bool build() {
    _checkLoginStatus();
    return false;
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;
    final token = await _secureStorage.read(key: AppConstants.authTokenKey);

    // Both flag and token must exist for a valid session
    state = isLoggedIn && token != null;
  }

  void login() {
    state = true;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, false);
    state = false;
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);
