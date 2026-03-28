import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/document_model.dart';
import '../../data/providers/document_provider.dart';

enum VaultTab { all, byRenewal, unlinked }

class VaultController extends GetxController {
  final _provider = DocumentProvider();

  final RxList<DocumentModel> allDocuments = <DocumentModel>[].obs;
  final RxList<DocumentModel> searchResults = <DocumentModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<VaultTab> activeTab = VaultTab.all.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    debounce(searchQuery, _onSearchChanged,
        time: const Duration(milliseconds: 400));
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      allDocuments.assignAll(await _provider.getAll());
    } catch (e) {
      showErrorSnack('Failed to load documents');
    } finally {
      isLoading.value = false;
    }
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    _performSearch(query.trim());
  }

  Future<void> _performSearch(String query) async {
    isSearching.value = true;
    try {
      searchResults.assignAll(await _provider.search(query));
    } catch (_) {
      // Fall back to local search
      searchResults.assignAll(_localFilter(query));
    } finally {
      isSearching.value = false;
    }
  }

  List<DocumentModel> _localFilter(String query) {
    final q = query.toLowerCase();
    return allDocuments
        .where((d) =>
            d.fileName.toLowerCase().contains(q) ||
            (d.docType?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  List<DocumentModel> get filtered {
    final q = searchQuery.value.trim();
    final tab = activeTab.value;

    Iterable<DocumentModel> docs =
        q.isNotEmpty ? searchResults : allDocuments;
    if (tab == VaultTab.unlinked) {
      docs = docs.where((d) => d.renewalId == null);
    }
    return docs.toList();
  }

  Map<String, List<DocumentModel>> get groupedByRenewal {
    final q = searchQuery.value.trim();
    final source = q.isNotEmpty ? searchResults : allDocuments;
    final grouped = <String, List<DocumentModel>>{};
    for (final doc in source) {
      if (doc.renewalId == null) continue;
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
      showErrorSnack('Upload failed');
    } finally {
      isUploading.value = false;
    }
  }

  String fileUrl(String id) => _provider.fileUrl(id);
}
