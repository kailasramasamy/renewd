import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/renewal_model.dart';
import '../../widgets/minder_button.dart';
import '../../widgets/minder_card.dart';
import '../../widgets/status_badge.dart';
import '../vault/vault_screen.dart';
import 'renewal_detail_controller.dart';

class RenewalDetailScreen extends StatelessWidget {
  const RenewalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(RenewalDetailController());
    return Obx(() {
      final renewal = c.renewal.value;
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => Get.back(),
          ),
          title: Text(renewal?.name ?? 'Detail'),
          actions: [
            if (renewal != null) ...[
              IconButton(
                icon: const Icon(Iconsax.edit),
                onPressed: () => Get.toNamed(AppRoutes.editRenewal,
                    arguments: renewal),
              ),
              IconButton(
                icon: const Icon(Iconsax.trash,
                    color: MinderColors.coralRed),
                onPressed: () => _confirmDelete(context, c),
              ),
            ],
          ],
        ),
        body: c.isLoading.value && renewal == null
            ? const Center(child: CircularProgressIndicator())
            : renewal == null
                ? const Center(child: Text('Renewal not found'))
                : _buildBody(context, c, renewal),
      );
    });
  }

  Widget _buildBody(BuildContext context, RenewalDetailController c,
      RenewalModel renewal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MinderSpacing.lg),
      child: Column(
        children: [
          _CountdownRing(renewal: renewal),
          const SizedBox(height: MinderSpacing.xl),
          _InfoSection(renewal: renewal),
          const SizedBox(height: MinderSpacing.xl),
          _DocumentsSection(c: c),
          const SizedBox(height: MinderSpacing.xl),
          Obx(() => MinderButton(
                label: 'Mark Renewed',
                icon: Iconsax.tick_circle,
                isLoading: c.isLoading.value,
                onPressed: c.markRenewed,
              )),
          const SizedBox(height: MinderSpacing.xl),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, RenewalDetailController c) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Renewal'),
        content: const Text(
            'This will permanently delete the renewal. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              c.deleteRenewal();
            },
            child: const Text('Delete',
                style: TextStyle(color: MinderColors.coralRed)),
          ),
        ],
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  final RenewalModel renewal;
  const _CountdownRing({required this.renewal});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusColor = MinderDateUtils.statusColorFromDays(days);
    final progress = days <= 0 ? 1.0 : (days / 365.0).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1 - progress,
                strokeWidth: 8,
                backgroundColor: MinderColors.steel,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      days < 0 ? '${days.abs()}' : '$days',
                      style: MinderTextStyles.numberMedium
                          .copyWith(color: statusColor),
                    ),
                    Text(
                      days < 0 ? 'overdue' : 'days',
                      style: MinderTextStyles.caption
                          .copyWith(color: MinderColors.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: MinderSpacing.sm),
        Text(
          days < 0 ? 'days overdue' : 'days remaining',
          style: MinderTextStyles.bodySmall.copyWith(color: MinderColors.slate),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final RenewalModel renewal;
  const _InfoSection({required this.renewal});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusType = _statusTypeFromDays(days);
    return Column(
      children: [
        MinderCard(
          child: Column(
            children: [
              if (renewal.provider != null) ...[
                _InfoRow(
                    icon: Iconsax.building,
                    label: 'Provider',
                    value: renewal.provider!),
                _Divider(),
              ],
              if (renewal.amount != null) ...[
                _InfoRow(
                    icon: Iconsax.wallet_3,
                    label: 'Amount',
                    value: '₹${renewal.amount!.toStringAsFixed(2)}'),
                _Divider(),
              ],
              _InfoRow(
                  icon: Iconsax.refresh_circle,
                  label: 'Frequency',
                  value: _formatFrequency(renewal)),
              _Divider(),
              _InfoRow(
                  icon: Iconsax.calendar,
                  label: 'Next Renewal',
                  value: MinderDateUtils.formatDate(renewal.renewalDate)),
              _Divider(),
              _InfoRow(
                  icon: Iconsax.autobrightness,
                  label: 'Auto-renew',
                  value: renewal.autoRenew ? 'Enabled' : 'Disabled'),
              _Divider(),
              Row(
                children: [
                  Icon(CategoryConfig.icon(renewal.category),
                      size: 16, color: MinderColors.slate),
                  const SizedBox(width: MinderSpacing.sm),
                  Text('Category',
                      style: MinderTextStyles.bodySmall
                          .copyWith(color: MinderColors.slate)),
                  const Spacer(),
                  StatusBadge(
                    label: CategoryConfig.label(renewal.category),
                    status: statusType,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatFrequency(RenewalModel r) {
    if (r.frequency == 'custom' && r.frequencyDays != null) {
      return 'Every ${r.frequencyDays} days';
    }
    const labels = {
      'monthly': 'Monthly',
      'quarterly': 'Quarterly',
      'yearly': 'Yearly',
      'weekly': 'Weekly',
    };
    return labels[r.frequency] ?? (r.frequency ?? 'Unknown');
  }

  StatusType _statusTypeFromDays(int days) {
    if (days < 0) return StatusType.critical;
    if (days <= 7) return StatusType.critical;
    if (days <= 30) return StatusType.urgent;
    if (days <= 60) return StatusType.warning;
    return StatusType.safe;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: MinderColors.slate),
        const SizedBox(width: MinderSpacing.sm),
        Text(label,
            style: MinderTextStyles.bodySmall
                .copyWith(color: MinderColors.slate)),
        const Spacer(),
        Text(value, style: MinderTextStyles.bodySmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: MinderSpacing.sm),
      child: Divider(color: MinderColors.steel, height: 1),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  final RenewalDetailController c;
  const _DocumentsSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Documents', style: MinderTextStyles.h3),
            const Spacer(),
            Obx(() => c.isUploading.value
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: MinderColors.oceanBlue))
                : IconButton(
                    icon: const Icon(Iconsax.document_upload,
                        color: MinderColors.oceanBlue),
                    onPressed: () => _pickAndUpload(c),
                    tooltip: 'Upload document',
                  )),
          ],
        ),
        Obx(() => c.isParsing.value
            ? Padding(
                padding: const EdgeInsets.only(bottom: MinderSpacing.sm),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2,
                            color: MinderColors.lavender)),
                    const SizedBox(width: MinderSpacing.sm),
                    Text('Analyzing with AI...',
                        style: MinderTextStyles.caption
                            .copyWith(color: MinderColors.lavender)),
                  ],
                ),
              )
            : const SizedBox.shrink()),
        Obx(() {
          final docs = c.documents;
          if (docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: MinderSpacing.md),
              child: Text('No documents attached',
                  style: MinderTextStyles.bodySmall
                      .copyWith(color: MinderColors.slate)),
            );
          }
          return Column(
            children: docs.map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: MinderSpacing.md),
                  child: DocumentCard(doc: doc),
                )).toList(),
          );
        }),
      ],
    );
  }

  Future<void> _pickAndUpload(RenewalDetailController c) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    await c.uploadDocument(file.path!, file.name);
  }
}
