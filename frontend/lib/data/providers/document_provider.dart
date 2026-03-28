import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    final mimeType = _mimeFromFileName(fileName);
    request.files.add(await http.MultipartFile.fromPath(
      'file', filePath,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    ));
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

  Future<void> linkToRenewal(String docId, String renewalId) async {
    await _client.safePost('${ApiEndpoints.documents}/$docId/link', {
      'renewal_id': renewalId,
    });
  }

  Future<List<DocumentModel>> search(String query) async {
    final response =
        await _client.safeGet(ApiEndpoints.documentSearch(query));
    final body = response.body as Map<String, dynamic>;
    final list = body['documents'] as List<dynamic>? ?? [];
    return list
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> suggestLink(String docId) async {
    final response =
        await _client.safeGet(ApiEndpoints.documentSuggestLink(docId));
    final body = response.body as Map<String, dynamic>;
    final list = body['suggestions'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> rename(String id, String newName) async {
    await _client.safePut('${ApiEndpoints.documents}/$id/rename', {
      'file_name': newName,
    });
  }

  Future<void> delete(String id) async {
    await _client.safeDelete(ApiEndpoints.documentById(id));
  }

  String fileUrl(String id) =>
      '${AppConstants.apiBaseUrl}${ApiEndpoints.documents}/$id/file';

  String _mimeFromFileName(String name) {
    final ext = name.split('.').last.toLowerCase();
    const mimeMap = {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
      'png': 'image/png', 'gif': 'image/gif',
      'webp': 'image/webp', 'pdf': 'application/pdf',
    };
    return mimeMap[ext] ?? 'application/octet-stream';
  }

  void _addAuthHeader(http.MultipartRequest request) {
    final storage = Get.find<StorageService>();
    final token = storage.readToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
  }
}
