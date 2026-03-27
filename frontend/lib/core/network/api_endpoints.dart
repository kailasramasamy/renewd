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
  static String renewalById(String id) => '/renewals/$id';

  // Documents
  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';
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

  // Payments
  static const String payments = '/payments';
  static String paymentsByRenewal(String renewalId) =>
      '/renewals/$renewalId/payments';
}
