const bool _isDev = bool.fromEnvironment('DEV', defaultValue: false);

class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = _isDev
      ? 'http://192.168.1.5:6000/api/v1'  // Development (local IP)
      : 'https://api.renewd.app/api/v1';   // Production (default)

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
}
