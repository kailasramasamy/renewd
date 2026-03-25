import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/document_model.dart';

class DocumentProvider {
  final ApiClient _client = Get.find<ApiClient>();

  Future<List<DocumentModel>> getByRenewal(String renewalId) async {
    final response = await _client
        .safeGet(ApiEndpoints.documentsByRenewal(renewalId));
    final list = response.body as List<dynamic>;
    return list
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DocumentModel> getById(String id) async {
    final response =
        await _client.safeGet(ApiEndpoints.documentById(id));
    return DocumentModel.fromJson(response.body as Map<String, dynamic>);
  }

  Future<DocumentModel> upload(Map<String, dynamic> data) async {
    final response = await _client.safePost(ApiEndpoints.documents, data);
    return DocumentModel.fromJson(response.body as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.safeDelete(ApiEndpoints.documentById(id));
  }
}
