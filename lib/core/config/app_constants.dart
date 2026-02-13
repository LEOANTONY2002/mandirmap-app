class AppConstants {
  static const String apiBaseUrl = 'http://192.168.29.153:5000';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Secure Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String isLoggedInKey = 'is_logged_in';
}
