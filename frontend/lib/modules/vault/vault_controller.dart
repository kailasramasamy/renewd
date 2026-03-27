import 'package:get/get.dart';
import '../../data/models/document_model.dart';
import '../../data/providers/document_provider.dart';

enum VaultTab { all, byRenewal, unlinked }

class VaultController extends GetxController {
  final _provider = DocumentProvider();

  final RxList<DocumentModel> allDocuments = <DocumentModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<VaultTab> activeTab = VaultTab.all.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      allDocuments.assignAll(await _provider.getAll());
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<DocumentModel> get filtered {
    final q = searchQuery.value.toLowerCase();
    final tab = activeTab.value;

    Iterable<DocumentModel> docs = allDocuments;
    if (tab == VaultTab.unlinked) {
      docs = docs.where((d) => d.renewalId == null);
    }
    if (q.isEmpty) return docs.toList();
    return docs
        .where((d) =>
            d.fileName.toLowerCase().contains(q) ||
            (d.docType?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Map<String, List<DocumentModel>> get groupedByRenewal {
    final q = searchQuery.value.toLowerCase();
    final grouped = <String, List<DocumentModel>>{};
    for (final doc in allDocuments) {
      if (doc.renewalId == null) continue;
      if (q.isNotEmpty &&
          !doc.fileName.toLowerCase().contains(q) &&
          !(doc.docType?.toLowerCase().contains(q) ?? false)) {
        continue;
      }
      grouped.putIfAbsent(doc.renewalId!, () => []).add(doc);
    }
    return grouped;
  }

  Future<void> uploadUnlinked(String filePath, String fileName) async {
    isUploading.value = true;
    try {
      final doc = await _provider.upload(
          filePath: filePath, fileName: fileName);
      allDocuments.insert(0, doc);
    } catch (e) {
      Get.snackbar('Upload failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  String fileUrl(String id) => _provider.fileUrl(id);
}
