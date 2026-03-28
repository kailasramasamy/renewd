import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'pdf_viewer_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/minder_card.dart';
import 'document_detail_controller.dart';

class DocumentDetailScreen extends StatelessWidget {
  const DocumentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DocumentDetailController());
    return Obx(() {
      final doc = c.document.value;
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft),
            onPressed: () => Get.back(),
          ),
          title: Text(doc?.fileName ?? 'Document',
              overflow: TextOverflow.ellipsis),
          actions: [
            if (doc != null)
              IconButton(
                icon: Icon(LucideIcons.moreVertical),
                onPressed: () => _showActions(context, c),
              ),
          ],
        ),
        body: doc == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, c),
      );
    });
  }

  void _showActions(BuildContext context, DocumentDetailController c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RenewdSpacing.lg),
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
              const SizedBox(height: RenewdSpacing.lg),
              ListTile(
                leading: Icon(LucideIcons.edit, color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
                title: const Text('Rename'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, c);
                },
              ),
              ListTile(
                leading: Obx(() => c.isSharing.value
                    ? const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(LucideIcons.share, color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy)),
                title: const Text('Share'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  c.shareDocument();
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.trash2, color: RenewdColors.coralRed),
                title: Text('Delete', style: TextStyle(color: RenewdColors.coralRed)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, c);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentDetailController c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('This will permanently delete the document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              c.deleteDocument();
            },
            child: Text('Delete',
                style: TextStyle(color: RenewdColors.coralRed)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, DocumentDetailController c) {
    final doc = c.document.value;
    if (doc == null) return;
    final nameCtrl = TextEditingController(
      text: doc.fileName.replaceAll(RegExp(r'\.[^.]+$'), ''),
    );
    final ext = doc.fileName.contains('.')
        ? '.${doc.fileName.split('.').last}'
        : '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            suffixText: ext,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = '${nameCtrl.text.trim()}$ext';
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              c.renameDocument(newName);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DocumentDetailController c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DocumentPreview(c: c),
          const SizedBox(height: RenewdSpacing.lg),
          _AiSummarySection(c: c),
          const SizedBox(height: RenewdSpacing.xl),
        ],
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  final DocumentDetailController c;
  const _DocumentPreview({required this.c});

  @override
  Widget build(BuildContext context) {
    final doc = c.document.value!;
    return _PdfPlaceholder(doc: doc);
  }
}

class _PdfPlaceholder extends StatelessWidget {
  final dynamic doc;
  const _PdfPlaceholder({required this.doc});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DocumentDetailController>();
    return RenewdCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(_iconForFile(doc.fileName), size: 40, color: _colorForFile(doc.fileName)),
              const SizedBox(width: RenewdSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.fileName, style: RenewdTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w500),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (doc.fileSizeLabel.isNotEmpty)
                      Text(doc.fileSizeLabel,
                          style: RenewdTextStyles.caption
                              .copyWith(color: RenewdColors.slate)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDocument(c),
              icon: Icon(LucideIcons.eye, size: 16),
              label: const Text('View Document'),
              style: OutlinedButton.styleFrom(
                foregroundColor: RenewdColors.oceanBlue,
                side: const BorderSide(color: RenewdColors.oceanBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return LucideIcons.fileText;
      case 'jpg' || 'jpeg' || 'png' || 'webp': return LucideIcons.image;
      default: return LucideIcons.file;
    }
  }

  Color _colorForFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return RenewdColors.coralRed;
      case 'jpg' || 'jpeg' || 'png' || 'webp': return RenewdColors.oceanBlue;
      default: return RenewdColors.slate;
    }
  }

  void _openDocument(DocumentDetailController c) {
    final d = c.document.value!;
    Get.to(() => PdfViewerScreen(
          url: c.fileUrl(),
          title: d.fileName,
        ));
  }
}

class _AiSummarySection extends StatelessWidget {
  final DocumentDetailController c;
  const _AiSummarySection({required this.c});

  @override
  Widget build(BuildContext context) {
    final doc = c.document.value!;
    if (!doc.hasAiSummary) return _AnalyzeButton(c: c);

    final parsed = c.parsedOcr();
    return RenewdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 16, color: RenewdColors.lavender),
              const SizedBox(width: RenewdSpacing.sm),
              Text('AI Analysis',
                  style: RenewdTextStyles.bodySmall.copyWith(
                      color: RenewdColors.lavender,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          if (parsed != null) ...[
            _AiRow('Summary', parsed['summary'] as String?),
            _AiRow('Provider', parsed['provider'] as String?),
            _AiRow('Type', parsed['document_type'] as String?),
            _AiRow('Issue Date', parsed['issue_date'] as String?),
            _AiRow('Expiry Date', parsed['expiry_date'] as String?),
            _AiRow('Amount', parsed['amount']?.toString()),
            _KeyDetails(details: parsed['key_details']),
          ] else
            Text(doc.ocrText!, style: RenewdTextStyles.bodySmall),
          const SizedBox(height: RenewdSpacing.md),
          _ReAnalyzeButton(c: c),
        ],
      ),
    );
  }
}

class _AiRow extends StatelessWidget {
  final String label;
  final String? value;
  const _AiRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: RenewdSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: RenewdTextStyles.caption
                    .copyWith(color: RenewdColors.slate)),
          ),
          Expanded(child: Text(value!, style: RenewdTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _KeyDetails extends StatelessWidget {
  final dynamic details;
  const _KeyDetails({required this.details});

  @override
  Widget build(BuildContext context) {
    if (details == null) return const SizedBox.shrink();
    final list = details as List<dynamic>;
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Details',
            style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.xs),
        ...list.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: RenewdSpacing.xs),
              child: Row(
                children: [
                  Icon(LucideIcons.chevronRight, size: 12,
                      color: RenewdColors.lavender),
                  const SizedBox(width: RenewdSpacing.xs),
                  Expanded(
                      child: Text(d.toString(),
                          style: RenewdTextStyles.bodySmall)),
                ],
              ),
            )),
      ],
    );
  }
}

class _AnalyzeButton extends StatelessWidget {
  final DocumentDetailController c;
  const _AnalyzeButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: c.isParsing.value ? null : c.triggerParse,
            style: ElevatedButton.styleFrom(
              backgroundColor: RenewdColors.lavender,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: c.isParsing.value
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: Colors.white))
                : Icon(LucideIcons.sparkles, size: 18),
            label: Text(c.isParsing.value ? 'Analyzing...' : 'Analyze with AI',
                style: RenewdTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ));
  }
}

class _ReAnalyzeButton extends StatelessWidget {
  final DocumentDetailController c;
  const _ReAnalyzeButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextButton.icon(
          onPressed: c.isParsing.value ? null : c.triggerParse,
          icon: c.isParsing.value
              ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      color: RenewdColors.lavender))
              : Icon(LucideIcons.refreshCw, size: 14,
                  color: RenewdColors.lavender),
          label: Text(c.isParsing.value ? 'Re-analyzing...' : 'Re-analyze',
              style: RenewdTextStyles.caption
                  .copyWith(color: RenewdColors.lavender)),
        ));
  }
}

