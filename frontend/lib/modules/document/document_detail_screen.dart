import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/minder_button.dart';
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
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => Get.back(),
          ),
          title: Text(doc?.fileName ?? 'Document',
              overflow: TextOverflow.ellipsis),
        ),
        body: doc == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, c),
        bottomNavigationBar: _DeleteBar(c: c),
      );
    });
  }

  Widget _buildBody(BuildContext context, DocumentDetailController c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MinderSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DocumentPreview(c: c),
          const SizedBox(height: MinderSpacing.lg),
          _AiSummarySection(c: c),
          const SizedBox(height: MinderSpacing.xl),
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
    final url = c.fileUrl();
    if (doc.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context2, error, stack) => _PdfPlaceholder(doc: doc),
        ),
      );
    }
    return _PdfPlaceholder(doc: doc);
  }
}

class _PdfPlaceholder extends StatelessWidget {
  final dynamic doc;
  const _PdfPlaceholder({required this.doc});

  @override
  Widget build(BuildContext context) {
    return MinderCard(
      child: Row(
        children: [
          const Icon(Iconsax.document_text, size: 48, color: MinderColors.coralRed),
          const SizedBox(width: MinderSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.fileName, style: MinderTextStyles.body,
                    overflow: TextOverflow.ellipsis),
                if (doc.fileSizeLabel.isNotEmpty)
                  Text(doc.fileSizeLabel,
                      style: MinderTextStyles.caption
                          .copyWith(color: MinderColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
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
    return MinderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.magic_star, size: 16, color: MinderColors.lavender),
              const SizedBox(width: MinderSpacing.sm),
              Text('AI Analysis',
                  style: MinderTextStyles.bodySmall.copyWith(
                      color: MinderColors.lavender,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: MinderSpacing.md),
          if (parsed != null) ...[
            _AiRow('Summary', parsed['summary'] as String?),
            _AiRow('Provider', parsed['provider'] as String?),
            _AiRow('Type', parsed['document_type'] as String?),
            _AiRow('Issue Date', parsed['issue_date'] as String?),
            _AiRow('Expiry Date', parsed['expiry_date'] as String?),
            _AiRow('Amount', parsed['amount'] as String?),
            _KeyDetails(details: parsed['key_details']),
          ] else
            Text(doc.ocrText!, style: MinderTextStyles.bodySmall),
          const SizedBox(height: MinderSpacing.md),
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
      padding: const EdgeInsets.only(bottom: MinderSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: MinderTextStyles.caption
                    .copyWith(color: MinderColors.slate)),
          ),
          Expanded(child: Text(value!, style: MinderTextStyles.bodySmall)),
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
            style: MinderTextStyles.caption.copyWith(color: MinderColors.slate)),
        const SizedBox(height: MinderSpacing.xs),
        ...list.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: MinderSpacing.xs),
              child: Row(
                children: [
                  const Icon(Iconsax.arrow_right_3, size: 12,
                      color: MinderColors.lavender),
                  const SizedBox(width: MinderSpacing.xs),
                  Expanded(
                      child: Text(d.toString(),
                          style: MinderTextStyles.bodySmall)),
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
              backgroundColor: MinderColors.lavender,
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
                : const Icon(Iconsax.magic_star, size: 18),
            label: Text(c.isParsing.value ? 'Analyzing...' : 'Analyze with AI',
                style: MinderTextStyles.body
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
                      color: MinderColors.lavender))
              : const Icon(Iconsax.refresh, size: 14,
                  color: MinderColors.lavender),
          label: Text(c.isParsing.value ? 'Re-analyzing...' : 'Re-analyze',
              style: MinderTextStyles.caption
                  .copyWith(color: MinderColors.lavender)),
        ));
  }
}

class _DeleteBar extends StatelessWidget {
  final DocumentDetailController c;
  const _DeleteBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          MinderSpacing.lg, MinderSpacing.sm, MinderSpacing.lg, MinderSpacing.xl),
      child: Obx(() => MinderButton(
            label: 'Delete Document',
            icon: Iconsax.trash,
            variant: MinderButtonVariant.danger,
            isLoading: c.isDeleting.value,
            onPressed: () => _confirmDelete(context, c),
          )),
    );
  }

  void _confirmDelete(BuildContext context, DocumentDetailController c) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('This will permanently delete the document.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              c.deleteDocument();
            },
            child: const Text('Delete',
                style: TextStyle(color: MinderColors.coralRed)),
          ),
        ],
      ),
    );
  }
}
