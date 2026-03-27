import 'dart:convert';
import 'package:get/get.dart';
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
        Get.snackbar(
          'AI Analysis Complete',
          extraction['summary'] as String? ?? 'Document analyzed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar('Analysis failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isParsing.value = false;
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
      Get.snackbar('Delete failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      isDeleting.value = false;
    }
  }
}
