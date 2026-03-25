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
      '/renewals/$renewalId/documents';

  // Payments
  static const String payments = '/payments';
  static String paymentsByRenewal(String renewalId) =>
      '/renewals/$renewalId/payments';
}
