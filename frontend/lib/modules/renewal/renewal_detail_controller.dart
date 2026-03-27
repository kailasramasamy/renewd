import 'package:get/get.dart';
import '../../data/models/document_model.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/document_provider.dart';
import '../../data/providers/renewal_provider.dart';

class RenewalDetailController extends GetxController {
  final _provider = RenewalProvider();
  final _docProvider = DocumentProvider();

  final Rx<RenewalModel?> renewal = Rx<RenewalModel?>(null);
  final RxBool isLoading = false.obs;
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxList<int> reminderDays = <int>[].obs;
  final RxBool isUploading = false.obs;
  final RxBool isParsing = false.obs;
  bool dataChanged = false;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is RenewalModel) {
      renewal.value = arg;
      fetchDocuments();
      fetchReminders();
    } else if (arg is String) {
      fetchRenewal(arg);
    }
  }

  Future<void> fetchRenewal(String id) async {
    isLoading.value = true;
    try {
      renewal.value = await _provider.getById(id);
      await fetchDocuments();
      await fetchReminders();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDocuments() async {
    final id = renewal.value?.id;
    if (id == null) return;
    try {
      documents.assignAll(await _docProvider.getByRenewal(id));
    } catch (_) {
      // documents are supplementary — silent fail
    }
  }

  Future<void> fetchReminders() async {
    final id = renewal.value?.id;
    if (id == null) return;
    try {
      final reminders = await _provider.getReminders(id);
      final unsent = reminders
          .where((r) => r['is_sent'] != true)
          .map((r) => r['days_before'] as int)
          .toList();

      if (unsent.isEmpty) {
        // Pre-existing renewal with no reminders — create defaults
        const defaults = [7, 1];
        await _provider.updateReminders(id, defaults);
        reminderDays.assignAll(defaults);
      } else {
        reminderDays.assignAll(unsent);
      }
    } catch (_) {
      // reminders are supplementary — silent fail
    }
  }

  Future<void> updateReminders(List<int> days) async {
    final id = renewal.value?.id;
    if (id == null) return;
    try {
      await _provider.updateReminders(id, days);
      reminderDays.assignAll(days);
      Get.snackbar('Updated', 'Reminders updated',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> markRenewed() async {
    final id = renewal.value?.id;
    if (id == null) return;
    isLoading.value = true;
    try {
      renewal.value = await _provider.markRenewed(id);
      Get.snackbar('Renewed', 'Next renewal date updated',
          snackPosition: SnackPosition.BOTTOM);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRenewal() async {
    final id = renewal.value?.id;
    if (id == null) return;
    isLoading.value = true;
    try {
      await _provider.delete(id);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
    }
  }

  Future<void> uploadDocument(String filePath, String fileName) async {
    final id = renewal.value?.id;
    if (id == null) return;
    isUploading.value = true;
    try {
      final doc = await _docProvider.upload(
        filePath: filePath,
        fileName: fileName,
        renewalId: id,
      );
      documents.add(doc);
      await parseDocument(doc.id);
    } catch (e) {
      Get.snackbar('Upload failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> parseDocument(String docId) async {
    isParsing.value = true;
    try {
      final result = await _docProvider.parseDocument(docId);
      await fetchDocuments();
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
}
