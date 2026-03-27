import 'dart:io';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class NotificationProvider {
  final ApiClient _client = Get.find<ApiClient>();

  Future<void> registerFcmToken(String token) async {
    await _client.safePut(
      ApiEndpoints.fcmToken,
      {
        'fcm_token': token,
        'device_os': Platform.isIOS ? 'iOS' : 'Android',
        'device_os_version': Platform.operatingSystemVersion,
        'device_model': Platform.localHostname,
        'app_version': '1.0.0',
      },
    );
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final response =
        await _client.safeGet(ApiEndpoints.notificationPreferences);
    final body = response.body as Map<String, dynamic>;
    return body['preferences'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> data) async {
    final response =
        await _client.safePut(ApiEndpoints.notificationPreferences, data);
    final body = response.body as Map<String, dynamic>;
    return body['preferences'] as Map<String, dynamic>;
  }

  Future<void> snoozeReminder(String renewalId, String reminderId) async {
    await _client.safePost(
      ApiEndpoints.snoozeReminder(renewalId, reminderId),
      {'snooze_days': 1},
    );
  }
}
