class AppConstants {
  AppConstants._();

  static const String appName = 'Monetra';

  // API
  static const String baseUrlDev = 'http://localhost:5000/api';
  static const String baseUrlProd = 'https://your-production-api.com/api';

  // Secure storage keys
  static const String tokenKey = 'monetra_token';
  static const String userKey = 'monetra_user';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 20;
}
