class AppConstants {
  static const String apiBaseUrl = 'http://192.168.1.53:5000';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Secure Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String isLoggedInKey = 'is_logged_in';
}
