import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/payment_model.dart';

class PaymentProvider {
  final ApiClient _client = Get.find<ApiClient>();

  Future<PaymentModel> create(Map<String, dynamic> data) async {
    final response = await _client.safePost(ApiEndpoints.payments, data);
    final body = response.body as Map<String, dynamic>;
    return PaymentModel.fromJson(body['payment'] as Map<String, dynamic>);
  }

  Future<List<PaymentModel>> getByRenewal(String renewalId) async {
    final response =
        await _client.safeGet(ApiEndpoints.paymentsByRenewal(renewalId));
    final body = response.body as Map<String, dynamic>;
    final list = body['payments'] as List<dynamic>? ?? [];
    return list
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(String id) async {
    await _client.safeDelete('${ApiEndpoints.payments}/$id');
  }
}
