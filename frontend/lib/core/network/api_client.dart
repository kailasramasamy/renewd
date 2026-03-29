import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class ApiClient extends GetConnect {
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

    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        Get.offAllNamed('/login');
      }
      return response;
    });
  }

  Future<Response<T>> safeGet<T>(String url) async {
    final response = await get<T>(url);
    _throwIfError(response);
    return response;
  }

  Future<Response<T>> safePost<T>(String url, dynamic body) async {
    final response = await post<T>(url, body);
    _throwIfError(response);
    return response;
  }

  Future<Response<T>> safePut<T>(String url, dynamic body) async {
    final response = await put<T>(url, body);
    _throwIfError(response);
    return response;
  }

  Future<Response<T>> safeDelete<T>(String url) async {
    final response = await delete<T>(url);
    _throwIfError(response);
    return response;
  }

  void _throwIfError(Response response) {
    if (response.hasError) {
      final body = response.body as Map<String, dynamic>?;
      final message = body?['error'] as String? ?? body?['message'] as String? ?? 'Request failed';
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
