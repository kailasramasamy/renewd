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
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../../data/models/document_model.dart';
import 'vault_controller.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(VaultController());
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(child: _Header(c: c)),
            SliverToBoxAdapter(child: _SecurityBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: RenewdSpacing.md)),
            SliverToBoxAdapter(child: _SearchBar(c: c)),
            const SliverToBoxAdapter(child: SizedBox(height: RenewdSpacing.md)),
            SliverToBoxAdapter(child: _FilterChips(c: c)),
            const SliverToBoxAdapter(child: SizedBox(height: RenewdSpacing.md)),
            SliverFillRemaining(hasScrollBody: true, child: _Body(c: c)),
          ],
        ),
      ),
      floatingActionButton: Obx(() => _GradientFab(
            isLoading: c.isUploading.value,
            onTap: c.isUploading.value ? null : () => _pickAndUpload(c),
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

class _Header extends StatelessWidget {
  final VaultController c;
  const _Header({required this.c});

  String _fmtBytes(int b) {
    if (b == 0) return '0 B';
    if (b < 1024) return '${b}B';
    if (b < 1048576) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          RenewdSpacing.xl, RenewdSpacing.lg, RenewdSpacing.xl, RenewdSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vault',
                    style: RenewdTextStyles.h2
                        .copyWith(fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Obx(() {
                  final count = c.allDocuments.length;
                  final bytes = c.allDocuments
                      .fold<int>(0, (s, d) => s + (d.fileSize ?? 0));
                  return Text('$count doc${count == 1 ? '' : 's'} · ${_fmtBytes(bytes)}',
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate));
                }),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.refreshCw, size: 18, color: RenewdColors.slate),
            tooltip: 'Refresh',
            onPressed: c.fetchAll,
          ),
        ],
      ),
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.xl),
      child: GestureDetector(
        onTap: () => _showEncryptionSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
          decoration: BoxDecoration(
            color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.subtle),
            borderRadius: RenewdRadius.mdAll,
            border: Border.all(
                color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.light)),
          ),
          child: Row(children: [
            Icon(LucideIcons.lock, size: 15, color: RenewdColors.emerald),
            const SizedBox(width: RenewdSpacing.sm),
            Expanded(
              child: Text('AES-256 · end-to-end encrypted',
                  style: RenewdTextStyles.caption.copyWith(
                      color: RenewdColors.emerald, fontWeight: FontWeight.w600)),
            ),
            Icon(LucideIcons.chevronRight, size: 14,
                color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.strong)),
          ]),
        ),
      ),
    );
  }

  void _showEncryptionSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RenewdSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: RenewdColors.slate.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: RenewdSpacing.xl),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.light),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(LucideIcons.shieldCheck, size: 28, color: RenewdColors.emerald),
              ),
              const SizedBox(height: RenewdSpacing.lg),
              Text('Your data is protected',
                  style: RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: RenewdSpacing.md),
              _encryptionPoint(
                isDark,
                LucideIcons.lock,
                'AES-256 encryption',
                'All your documents are encrypted using AES-256, the same standard used by banks and governments worldwide.',
              ),
              const SizedBox(height: RenewdSpacing.md),
              _encryptionPoint(
                isDark,
                LucideIcons.arrowLeftRight,
                'End-to-end encrypted',
                'Your files are encrypted before they leave your device and can only be decrypted by you. We cannot read your data.',
              ),
              const SizedBox(height: RenewdSpacing.md),
              _encryptionPoint(
                isDark,
                LucideIcons.server,
                'Secure storage',
                'Documents are stored on encrypted servers with strict access controls and regular security audits.',
              ),
              const SizedBox(height: RenewdSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encryptionPoint(bool isDark, IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.subtle),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: RenewdColors.emerald),
        ),
        const SizedBox(width: RenewdSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RenewdTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(desc, style: RenewdTextStyles.caption.copyWith(
                  color: RenewdColors.slate, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VaultController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.xl),
      child: SizedBox(
        height: 44,
        child: TextField(
          onChanged: (v) => c.searchQuery.value = v,
          style: RenewdTextStyles.bodySmall,
          decoration: InputDecoration(
            hintText: 'Search documents...',
            hintStyle: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.md),
              child: Icon(LucideIcons.search, size: 17, color: RenewdColors.slate),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            filled: true,
            fillColor: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
            border: OutlineInputBorder(
                borderRadius: RenewdRadius.mdAll, borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: RenewdRadius.mdAll,
              borderSide: isDark
                  ? BorderSide(color: RenewdColors.darkBorder, width: 0.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RenewdRadius.mdAll,
              borderSide: BorderSide(
                  color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.half)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: RenewdSpacing.md),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final VaultController c;
  const _FilterChips({required this.c});

  static const _tabs = [
    (VaultTab.all, 'All'),
    (VaultTab.byRenewal, 'Linked'),
    (VaultTab.unlinked, 'Unlinked'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.xl),
          child: Row(
            children: _tabs.map((entry) {
              final (tab, label) = entry;
              final active = c.activeTab.value == tab;
              return Padding(
                padding: const EdgeInsets.only(right: RenewdSpacing.sm),
                child: GestureDetector(
                  onTap: () => c.activeTab.value = tab,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.md, vertical: RenewdSpacing.xs + 2),
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              colors: [RenewdColors.lavender, RenewdColors.accent2])
                          : null,
                      borderRadius: BorderRadius.circular(RenewdRadius.md),
                      border: active
                          ? null
                          : Border.all(
                              color: isDark
                                  ? RenewdColors.darkBorder
                                  : RenewdColors.mist),
                    ),
                    child: Text(label,
                        style: RenewdTextStyles.caption.copyWith(
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active
                              ? Colors.white
                              : (isDark ? RenewdColors.silver : RenewdColors.slate),
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

class _Body extends StatelessWidget {
  final VaultController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) return const VaultSkeletonLoader();
      final docs = c.filtered;
      if (docs.isEmpty) return const _Empty();
      return _DocList(docs: docs);
    });
  }
}

class _DocList extends StatelessWidget {
  final List<DocumentModel> docs;
  const _DocList({required this.docs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
          RenewdSpacing.xl, 0, RenewdSpacing.xl, RenewdSpacing.xxxl),
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.darkSlate : Colors.white,
            borderRadius: RenewdRadius.lgAll,
            border: Border.all(
              color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
              width: isDark ? 0.5 : 1,
            ),
            boxShadow: isDark
                ? null
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: List.generate(docs.length, (i) {
              final isLast = i == docs.length - 1;
              return Column(children: [
                _DocRow(doc: docs[i]),
                if (!isLast)
                  Divider(height: 1, indent: 72,
                      color: isDark
                          ? RenewdColors.steel.withValues(alpha: RenewdOpacity.half)
                          : RenewdColors.mist),
              ]);
            }),
          ),
        ),
      ],
    );
  }
}

class _DocRow extends StatelessWidget {
  final DocumentModel doc;
  const _DocRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: RenewdRadius.lgAll,
      onTap: () async {
        final result = await Get.toNamed(AppRoutes.documentDetail, arguments: doc);
        if (result == true) {
          if (Get.isRegistered<VaultController>()) Get.find<VaultController>().fetchAll();
          if (Get.isRegistered<RenewalDetailController>()) {
            Get.find<RenewalDetailController>().fetchDocuments();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
        child: Row(
          children: [
            _DocIcon(doc: doc),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(child: _DocMeta(doc: doc)),
            const SizedBox(width: RenewdSpacing.sm),
            Icon(LucideIcons.chevronRight, size: 16, color: RenewdColors.slate),
          ],
        ),
      ),
    );
  }
}

class _DocIcon extends StatelessWidget {
  final DocumentModel doc;
  const _DocIcon({required this.doc});

  Color get _tint =>
      doc.renewalId != null ? RenewdColors.lavender : RenewdColors.coralRed;

  Widget _box() => Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _tint.withValues(alpha: RenewdOpacity.light),
          borderRadius: RenewdRadius.smAll,
        ),
        child: Icon(LucideIcons.fileText, size: 22, color: _tint),
      );

  @override
  Widget build(BuildContext context) {
    if (!doc.isImage) return _box();
    final c = Get.find<VaultController>();
    return ClipRRect(
      borderRadius: RenewdRadius.smAll,
      child: Image.network(c.fileUrl(doc.id), width: 44, height: 44,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _box()),
    );
  }
}

class _DocMeta extends StatelessWidget {
  final DocumentModel doc;
  const _DocMeta({required this.doc});

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text('·', style: RenewdTextStyles.caption
            .copyWith(color: RenewdColors.slate, fontSize: 11)));

  @override
  Widget build(BuildContext context) {
    final dt = doc.createdAt;
    final dateStr = '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(doc.fileName,
            style: RenewdTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis, maxLines: 1),
        const SizedBox(height: 3),
        Row(children: [
          if (doc.fileSizeLabel.isNotEmpty) ...[
            Text(doc.fileSizeLabel, style: RenewdTextStyles.caption
                .copyWith(color: RenewdColors.slate, fontSize: 11)),
            _dot(),
          ],
          Text(dateStr, style: RenewdTextStyles.caption
              .copyWith(color: RenewdColors.slate, fontSize: 11)),
          if (doc.hasAiSummary) ...[_dot(), _AiPill()],
        ]),
        if (doc.renewalId != null) ...[
          const SizedBox(height: 4),
          _LinkedPill(),
        ],
      ],
    );
  }
}
class _AiPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [RenewdColors.lavender, RenewdColors.accent2]),
        borderRadius: BorderRadius.circular(RenewdRadius.pill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.sparkles, size: 9, color: Colors.white),
        const SizedBox(width: 3),
        Text('AI', style: RenewdTextStyles.caption.copyWith(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
class _LinkedPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.subtle),
        borderRadius: BorderRadius.circular(RenewdRadius.pill),
        border: Border.all(
            color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.light),
            width: 0.5),
      ),
      child: Text('Linked renewal',
          style: RenewdTextStyles.caption.copyWith(
              color: RenewdColors.lavender, fontSize: 10,
              fontWeight: FontWeight.w500)),
    );
  }
}
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileText, size: 48, color: RenewdColors.slate),
            const SizedBox(height: RenewdSpacing.lg),
            Text('No documents yet',
                style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.xs),
            Text(
              'Your insurance policies, bills, and certificates will appear here.'
              ' Tap + to upload a document.',
              textAlign: TextAlign.center,
              style: RenewdTextStyles.caption
                  .copyWith(color: RenewdColors.slate, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  const _GradientFab({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [RenewdColors.lavender, RenewdColors.accent2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.moderate),
              blurRadius: 14, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Center(child: SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
            : const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
