import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/document_model.dart';
import '../../widgets/minder_card.dart';
import 'vault_controller.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(VaultController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: c.fetchAll,
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(c: c),
          _TabRow(c: c),
          Expanded(child: _Body(c: c)),
        ],
      ),
      floatingActionButton: Obx(() => FloatingActionButton(
            heroTag: 'vault_fab',
            onPressed: c.isUploading.value ? null : () => _pickAndUpload(c),
            backgroundColor: RenewdColors.oceanBlue,
            foregroundColor: Colors.white,
            child: c.isUploading.value
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: Colors.white))
                : const Icon(Iconsax.document_upload),
          )),
    );
  }

  Future<void> _pickAndUpload(VaultController c) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await c.uploadUnlinked(image.path, image.name);
  }
}

class _SearchBar extends StatelessWidget {
  final VaultController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          RenewdSpacing.lg, RenewdSpacing.md, RenewdSpacing.lg, 0),
      child: TextField(
        onChanged: (v) => c.searchQuery.value = v,
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: const Icon(Iconsax.search_normal, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: RenewdColors.steel),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
        ),
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  final VaultController c;
  const _TabRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
          child: Row(
            children: VaultTab.values.map((tab) {
              final active = c.activeTab.value == tab;
              return Padding(
                padding: const EdgeInsets.only(right: RenewdSpacing.sm),
                child: FilterChip(
                  label: Text(_tabLabel(tab)),
                  selected: active,
                  onSelected: (_) => c.activeTab.value = tab,
                  selectedColor: RenewdColors.oceanBlue,
                  labelStyle: RenewdTextStyles.caption.copyWith(
                    color: active ? Colors.white : RenewdColors.slate,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ));
  }

  String _tabLabel(VaultTab tab) {
    switch (tab) {
      case VaultTab.all: return 'All';
      case VaultTab.byRenewal: return 'By Renewal';
      case VaultTab.unlinked: return 'Unlinked';
    }
  }
}

class _Body extends StatelessWidget {
  final VaultController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.activeTab.value == VaultTab.byRenewal) {
        return _GroupedList(c: c);
      }
      final docs = c.filtered;
      if (docs.isEmpty) return _Empty();
      return _DocumentList(docs: docs);
    });
  }
}

class _GroupedList extends StatelessWidget {
  final VaultController c;
  const _GroupedList({required this.c});

  @override
  Widget build(BuildContext context) {
    final grouped = c.groupedByRenewal;
    if (grouped.isEmpty) return _Empty();
    return ListView(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: RenewdSpacing.sm),
              child: Text('Renewal: ${entry.key.substring(0, 8)}...',
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate)),
            ),
            ...entry.value.map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: RenewdSpacing.md),
                  child: DocumentCard(doc: doc),
                )),
            const SizedBox(height: RenewdSpacing.md),
          ],
        );
      }).toList(),
    );
  }
}

class _DocumentList extends StatelessWidget {
  final List<DocumentModel> docs;
  const _DocumentList({required this.docs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      itemCount: docs.length,
      separatorBuilder: (context2, index) => const SizedBox(height: RenewdSpacing.md),
      itemBuilder: (context2, i) => DocumentCard(doc: docs[i]),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.document, size: 48, color: RenewdColors.steel),
          const SizedBox(height: RenewdSpacing.md),
          Text('No documents yet',
              style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
        ],
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  const DocumentCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return RenewdCard(
      onTap: () => Get.toNamed(AppRoutes.documentDetail, arguments: doc),
      padding: const EdgeInsets.all(RenewdSpacing.md),
      child: Row(
        children: [
          _Thumbnail(doc: doc),
          const SizedBox(width: RenewdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.fileName,
                    style: RenewdTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: RenewdSpacing.xs),
                Row(
                  children: [
                    if (doc.docType != null) _DocTypeBadge(type: doc.docType!),
                    if (doc.docType != null && doc.fileSizeLabel.isNotEmpty)
                      const SizedBox(width: RenewdSpacing.sm),
                    if (doc.fileSizeLabel.isNotEmpty)
                      Text(doc.fileSizeLabel,
                          style: RenewdTextStyles.caption
                              .copyWith(color: RenewdColors.slate)),
                  ],
                ),
                if (doc.hasAiSummary) ...[
                  const SizedBox(height: RenewdSpacing.xs),
                  Row(
                    children: [
                      const Icon(Iconsax.magic_star, size: 10,
                          color: RenewdColors.lavender),
                      const SizedBox(width: RenewdSpacing.xs),
                      Text('AI analyzed',
                          style: RenewdTextStyles.caption.copyWith(
                              color: RenewdColors.lavender)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, size: 16,
              color: RenewdColors.slate),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final DocumentModel doc;
  const _Thumbnail({required this.doc});

  @override
  Widget build(BuildContext context) {
    if (doc.isImage) {
      final c = Get.find<VaultController>();
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          c.fileUrl(doc.id),
          width: 48, height: 48, fit: BoxFit.cover,
          errorBuilder: (context2, error, stack) => _PdfIcon(),
        ),
      );
    }
    return _PdfIcon();
  }
}

class _PdfIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: RenewdColors.coralRed.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Iconsax.document_text, size: 24,
          color: RenewdColors.coralRed),
    );
  }
}

class _DocTypeBadge extends StatelessWidget {
  final String type;
  const _DocTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: RenewdColors.oceanBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(type,
          style: RenewdTextStyles.caption
              .copyWith(color: RenewdColors.oceanBlue)),
    );
  }
}
