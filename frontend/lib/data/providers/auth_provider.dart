import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class AuthProvider {
  final ApiClient _client = Get.find<ApiClient>();

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await _client.safePost(
      ApiEndpoints.sendOtp,
      {'phone': phone},
    );
    return response.body as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _client.safePost(
      ApiEndpoints.verifyOtp,
      {'phone': phone, 'otp': otp},
    );
    return response.body as Map<String, dynamic>;
  }

  Future<void> signOut() async {
    await _client.safePost(ApiEndpoints.signOut, {});
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.safeGet(ApiEndpoints.me);
    return response.body as Map<String, dynamic>;
  }
}
