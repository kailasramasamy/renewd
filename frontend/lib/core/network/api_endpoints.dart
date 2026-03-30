class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';
  static const String signOut = '/auth/signout';

  // User
  static const String me = '/users/me';
  static const String updateProfile = '/users/me';

  // Renewals
  static const String renewals = '/renewals';
  static const String checkDuplicate = '/renewals/check-duplicate';
  static String renewalById(String id) => '/renewals/$id';

  // Documents
  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';
  static String documentSearch(String query) =>
      '/documents/search?q=${Uri.encodeQueryComponent(query)}';
  static String documentSuggestLink(String id) => '/documents/$id/suggest-link';
  static String documentsByRenewal(String renewalId) =>
      '/documents/by-renewal/$renewalId';

  // Notifications
  static const String fcmToken = '/users/me/fcm-token';
  static const String notificationPreferences =
      '/users/me/notification-preferences';
  static String renewalReminders(String renewalId) =>
      '/renewals/$renewalId/reminders';
  static String snoozeReminder(String renewalId, String reminderId) =>
      '/renewals/$renewalId/reminders/$reminderId/snooze';

  // Notification inbox
  static const String notificationLog = '/notifications';
  static const String notificationUnreadCount = '/notifications/unread-count';
  static const String notificationMarkAllRead = '/notifications/mark-all-read';
  static String notificationMarkRead(String id) => '/notifications/$id/read';

  // Premium
  static const String premiumConfig = '/premium-config';

  // Banners
  static const String banners = '/banners';

  // Payments
  static const String payments = '/payments';
  static String paymentsByRenewal(String renewalId) =>
      '/payments/by-renewal/$renewalId';

  // Analytics
  static const String analyticsByCategory = '/payments/analytics/by-category';
  static const String analyticsByMonth = '/payments/analytics/by-month';
}
