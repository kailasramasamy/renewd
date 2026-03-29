import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class ApiClient extends GetConnect {
  bool _isRefreshing = false;

  @override
  void onInit() {
    httpClient.baseUrl = AppConstants.apiBaseUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 30);
    _addAuthInterceptor();
    super.onInit();
  }

  void _addAuthInterceptor() {
    httpClient.addRequestModifier<dynamic>((request) {
      final storage = Get.find<StorageService>();
      final token = storage.readToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
  }

  /// Refresh Firebase token and persist it
  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken(true);
      if (token == null) return false;

      await Get.find<StorageService>().saveToken(token);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Execute request with retry for transient failures and token refresh on 401
  Future<Response<T>> _withRetry<T>(
    Future<Response<T>> Function() request, {
    int maxRetries = 2,
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      final response = await request();

      // On 401, try refreshing token once and retry
      if (response.statusCode == 401 && attempt == 0) {
        final refreshed = await _refreshToken();
        if (refreshed) continue;
        // Refresh failed — force logout
        await Get.find<StorageService>().deleteToken();
        Get.offAllNamed('/login');
        return response;
      }

      // On network/server error, retry with backoff
      if (_isRetryable(response) && attempt < maxRetries) {
        final delay = Duration(milliseconds: 500 * pow(2, attempt).toInt());
        await Future.delayed(delay);
        continue;
      }

      return response;
    }

    // Should not reach here, but return last attempt
    return request();
  }

  bool _isRetryable(Response response) {
    if (response.statusCode == null) return true; // Network error
    return response.statusCode! >= 500; // Server error
  }

  Future<Response<T>> safeGet<T>(String url) async {
    final response = await _withRetry(() => get<T>(url));
    _throwIfError(response);
    return response;
  }

  Future<Response<T>> safePost<T>(String url, dynamic body) async {
    final response = await _withRetry(() => post<T>(url, body));
    _throwIfError(response);
    return response;
  }

  Future<Response<T>> safePut<T>(String url, dynamic body) async {
    final response = await _withRetry(() => put<T>(url, body));
    _throwIfError(response);
    return response;
  }

  Future<Response<T>> safeDelete<T>(String url) async {
    final response = await _withRetry(() => delete<T>(url));
    _throwIfError(response);
    return response;
  }

  void _throwIfError(Response response) {
    if (response.hasError) {
      final body = response.body as Map<String, dynamic>?;
      final message = body?['error'] as String? ??
          body?['message'] as String? ??
          'Request failed';
      throw ApiException(message, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
