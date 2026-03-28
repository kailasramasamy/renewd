const bool _isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);

class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = _isProduction
      ? 'https://api.renewd.app/api/v1'  // Production URL (update when deployed)
      : 'http://localhost:6000/api/v1';   // Development

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
}
