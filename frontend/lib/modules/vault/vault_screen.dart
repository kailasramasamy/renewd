import '../../core/utils/document_picker.dart';
import '../../widgets/skeleton_loader.dart';
import '../renewal/renewal_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
            icon: Icon(LucideIcons.refreshCw),
            onPressed: c.fetchAll,
          ),
        ],
      ),
      body: Column(
        children: [
          _SecurityBadge(),
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
                : Icon(LucideIcons.uploadCloud),
          )),
    );
  }

  Future<void> _pickAndUpload(VaultController c) async {
    final ctx = Get.context;
    if (ctx == null) return;
    final doc = await showDocumentPicker(ctx);
    if (doc == null) return;
    await c.uploadUnlinked(doc.path, doc.name);
  }
}

class _SecurityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          RenewdSpacing.lg, RenewdSpacing.sm, RenewdSpacing.lg, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? RenewdColors.emerald.withValues(alpha: 0.08)
            : RenewdColors.emerald.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.shieldCheck,
              size: 14, color: RenewdColors.emerald),
          const SizedBox(width: RenewdSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'AES-256 encrypted',
                    style: RenewdTextStyles.caption.copyWith(
                      color: RenewdColors.emerald,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  TextSpan(
                    text: '  ·  Your documents are stored securely',
                    style: RenewdTextStyles.caption.copyWith(
                      color: RenewdColors.emerald.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          prefixIcon: Icon(LucideIcons.search, size: 18),
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
        return const VaultSkeletonLoader();
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
          Icon(LucideIcons.file, size: 48, color: RenewdColors.steel),
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
      onTap: () async {
        final result = await Get.toNamed(AppRoutes.documentDetail, arguments: doc);
        if (result == true) {
          if (Get.isRegistered<VaultController>()) {
            Get.find<VaultController>().fetchAll();
          }
          if (Get.isRegistered<RenewalDetailController>()) {
            Get.find<RenewalDetailController>().fetchDocuments();
          }
        }
      },
      padding: const EdgeInsets.all(RenewdSpacing.md),
      child: Row(
        children: [
          _Thumbnail(doc: doc),
          const SizedBox(width: RenewdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(doc.fileName,
                          style: RenewdTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: doc.isCurrent ? null : RenewdColors.slate),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (doc.isCurrent) ...[
                      const SizedBox(width: RenewdSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: RenewdColors.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Current',
                            style: RenewdTextStyles.caption
                                .copyWith(color: RenewdColors.emerald, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
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
                      Icon(LucideIcons.sparkles, size: 10,
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
          Icon(LucideIcons.chevronRight, size: 16,
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
      child: Icon(LucideIcons.fileText, size: 24,
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
