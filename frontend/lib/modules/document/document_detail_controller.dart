import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../../core/services/storage_service.dart';
import 'package:flutter/rendering.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/document_model.dart';
import '../../data/providers/document_provider.dart';

class DocumentDetailController extends GetxController {
  final _provider = DocumentProvider();

  final Rx<DocumentModel?> document = Rx<DocumentModel?>(null);
  final RxBool isParsing = false.obs;
  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is DocumentModel) document.value = arg;
  }

  String fileUrl() {
    final id = document.value?.id;
    if (id == null) return '';
    return _provider.fileUrl(id);
  }

  Map<String, dynamic>? parsedOcr() {
    final text = document.value?.ocrText;
    if (text == null || text.isEmpty) return null;
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> triggerParse() async {
    final id = document.value?.id;
    if (id == null) return;
    isParsing.value = true;
    try {
      final result = await _provider.parseDocument(id);
      document.value = await _provider.getById(id);
      final extraction = result['extraction'] as Map<String, dynamic>?;
      if (extraction != null) {
        showInfoSnack('AI Analysis Complete');
      }
    } catch (e) {
      showErrorSnack('Analysis failed');
    } finally {
      isParsing.value = false;
    }
  }

  final RxBool isSharing = false.obs;

  Future<void> shareDocument() async {
    final doc = document.value;
    if (doc == null) return;
    isSharing.value = true;
    try {
      final url = fileUrl();
      final storage = Get.find<StorageService>();
      final token = storage.readToken();
      final response = await http.get(
        Uri.parse(url),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode != 200) {
        showErrorSnack('Failed to download file');
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${doc.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      final box = Get.context?.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: doc.fileName,
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      showErrorSnack('Share failed');
    } finally {
      isSharing.value = false;
    }
  }

  Future<void> deleteDocument() async {
    final id = document.value?.id;
    if (id == null) return;
    isDeleting.value = true;
    try {
      await _provider.delete(id);
      Get.back(result: true);
    } catch (e) {
      showErrorSnack('Delete failed');
      isDeleting.value = false;
    }
  }

  Future<void> renameDocument(String newName) async {
    final id = document.value?.id;
    if (id == null) return;
    try {
      await _provider.rename(id, newName);
      document.value = await _provider.getById(id);
      showSuccessSnack('Renamed to $newName');
    } catch (_) {
      showErrorSnack('Rename failed');
    }
  }
}
