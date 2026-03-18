class AppConstants {
  static const String apiBaseUrl =
      'https://mandirmap-backend-production.up.railway.app';
  // static const String apiBaseUrl = 'http://localhost:5000';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Secure Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String isLoggedInKey = 'is_logged_in';
}
