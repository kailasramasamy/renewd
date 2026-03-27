class AppConstants {
  AppConstants._();

  // Use your Mac's local IP for physical device testing
  // Change back to localhost for simulator/emulator
  static const String apiBaseUrl = 'http://192.168.1.14:6000/api/v1';
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
}
