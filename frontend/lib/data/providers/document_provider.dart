import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/services/storage_service.dart';
import '../models/document_model.dart';

class DocumentProvider {
  final ApiClient _client = Get.find<ApiClient>();

  Future<List<DocumentModel>> getAll() async {
    final response = await _client.safeGet(ApiEndpoints.documents);
    final body = response.body as Map<String, dynamic>;
    final list = body['documents'] as List<dynamic>? ?? [];
    return list.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DocumentModel>> getByRenewal(String renewalId) async {
    final response = await _client.safeGet(ApiEndpoints.documentsByRenewal(renewalId));
    final body = response.body as Map<String, dynamic>;
    final list = body['documents'] as List<dynamic>? ?? [];
    return list.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DocumentModel> upload({
    required String filePath,
    required String fileName,
    String? renewalId,
    String? docType,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}${ApiEndpoints.documents}/upload');
    final request = http.MultipartRequest('POST', uri);
    _addAuthHeader(request);
    request.files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));
    if (renewalId != null) request.fields['renewal_id'] = renewalId;
    if (docType != null) request.fields['doc_type'] = docType;

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) throw Exception('Upload failed: $body');

    final json = jsonDecode(body) as Map<String, dynamic>;
    return DocumentModel.fromJson(json['document'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> parseDocument(String id) async {
    final response = await _client.safePost('${ApiEndpoints.documents}/$id/parse', {});
    return response.body as Map<String, dynamic>;
  }

  Future<DocumentModel> getById(String id) async {
    final response = await _client.safeGet(ApiEndpoints.documentById(id));
    final body = response.body as Map<String, dynamic>;
    return DocumentModel.fromJson(body['document'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.safeDelete(ApiEndpoints.documentById(id));
  }

  String fileUrl(String id) =>
      '${AppConstants.apiBaseUrl}${ApiEndpoints.documents}/$id/file';

  void _addAuthHeader(http.MultipartRequest request) {
    final storage = Get.find<StorageService>();
    final token = storage.readToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
  }
}
