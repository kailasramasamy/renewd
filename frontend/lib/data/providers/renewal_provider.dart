import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/renewal_model.dart';

class RenewalProvider {
  final ApiClient _client = Get.find<ApiClient>();

  Future<List<RenewalModel>> getAll() async {
    final response = await _client.safeGet(ApiEndpoints.renewals);
    final body = response.body as Map<String, dynamic>;
    final list = body['renewals'] as List<dynamic>? ?? [];
    return list
        .map((e) => RenewalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RenewalModel> getById(String id) async {
    final response = await _client.safeGet(ApiEndpoints.renewalById(id));
    return RenewalModel.fromJson(response.body as Map<String, dynamic>);
  }

  Future<RenewalModel> create(Map<String, dynamic> data) async {
    final response =
        await _client.safePost(ApiEndpoints.renewals, data);
    return RenewalModel.fromJson(response.body as Map<String, dynamic>);
  }

  Future<RenewalModel> update(String id, Map<String, dynamic> data) async {
    final response =
        await _client.safePut(ApiEndpoints.renewalById(id), data);
    return RenewalModel.fromJson(response.body as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.safeDelete(ApiEndpoints.renewalById(id));
  }

  Future<RenewalModel> markRenewed(String id) async {
    final response =
        await _client.safePost('${ApiEndpoints.renewals}/$id/renew', {});
    final body = response.body as Map<String, dynamic>;
    return RenewalModel.fromJson(body['renewal'] as Map<String, dynamic>);
  }
}
