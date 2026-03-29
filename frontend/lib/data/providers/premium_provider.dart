import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/premium_config_model.dart';

class PremiumProvider {
  final ApiClient _client = Get.find<ApiClient>();

  Future<PremiumConfigModel> getConfig() async {
    final response = await _client.safeGet(ApiEndpoints.premiumConfig);
    final body = response.body as Map<String, dynamic>;
    return PremiumConfigModel.fromJson(body);
  }
}
