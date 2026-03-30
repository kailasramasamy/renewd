import 'dart:convert';
import '../../core/utils/document_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/document_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/renewal_model.dart';
import '../../core/utils/haptics.dart';
import '../../widgets/minder_button.dart';
import '../../widgets/minder_card.dart';
import '../../widgets/status_badge.dart';
import '../vault/vault_screen.dart';
import 'renewal_detail_controller.dart';

void _showSnack(BuildContext context,
    {required IconData icon, required Color color, required String message}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: RenewdOpacity.light),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: RenewdSpacing.sm),
        Expanded(child: Text(message, style: RenewdTextStyles.bodySmall)),
      ],
    ),
    backgroundColor: isDark ? RenewdColors.steel : Colors.white,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: RenewdRadius.mdAll),
    elevation: 4,
  ));
}

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
            icon: Icon(LucideIcons.arrowLeft),
            tooltip: 'Go back',
            onPressed: () => Get.back(result: c.dataChanged),
          ),
          title: Text(renewal?.name ?? 'Detail'),
          actions: [
            if (renewal != null) ...[
              IconButton(
                icon: Icon(LucideIcons.bell),
                tooltip: 'Reminders',
                onPressed: () => _showRemindersSheet(context, c),
              ),
              IconButton(
                icon: Icon(LucideIcons.edit),
                tooltip: 'Edit renewal',
                onPressed: () async {
                  final result = await Get.toNamed(
                    AppRoutes.editRenewal,
                    arguments: renewal,
                  );
                  if (result == true) {
                    c.dataChanged = true;
                    c.fetchRenewal(renewal.id);
                  }
                },
              ),
              IconButton(
                icon: Icon(LucideIcons.trash2,
                    color: RenewdColors.coralRed),
                tooltip: 'Delete renewal',
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      child: Column(
        children: [
          _CountdownRing(renewal: renewal),
          const SizedBox(height: RenewdSpacing.xl),
          _InfoSection(renewal: renewal, documents: c.documents),
          const SizedBox(height: RenewdSpacing.xl),
          _PolicySummary(c: c),
          _PaymentHistory(c: c),
          _DocumentsSection(c: c),
          const SizedBox(height: RenewdSpacing.xl),
          Obx(() {
            if (c.showPaymentPrompt.value) {
              return _PaymentPrompt(c: c, renewal: renewal);
            }
            final days = renewal.daysRemaining;
            if (days > 7) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: RenewdSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? RenewdColors.darkSlate
                      : RenewdColors.cloudGray,
                  borderRadius: RenewdRadius.mdAll,
                ),
                child: Center(
                  child: Text('Renews in $days days',
                      style: RenewdTextStyles.bodySmall
                          .copyWith(color: RenewdColors.slate)),
                ),
              );
            }
            return RenewdButton(
              label: days < 0 ? 'Overdue — Mark Renewed' : 'Mark Renewed',
              icon: LucideIcons.checkCircle,
              isLoading: c.isLoading.value,
              onPressed: () {
                RenewdHaptics.success();
                c.markRenewed();
              },
            );
          }),
          const SizedBox(height: RenewdSpacing.xl),
        ],
      ),
    );
  }

  void _showRemindersSheet(BuildContext context, RenewalDetailController c) {
    const availableDays = [30, 14, 7, 3, 1];
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.bell, size: 20, color: RenewdColors.oceanBlue),
                const SizedBox(width: RenewdSpacing.sm),
                Text('Reminders', style: RenewdTextStyles.h3),
              ],
            ),
            const SizedBox(height: RenewdSpacing.xs),
            Text('Get notified before this renewal is due',
                style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.md),
            Obx(() => Wrap(
                  spacing: RenewdSpacing.sm,
                  runSpacing: RenewdSpacing.sm,
                  children: availableDays.map((day) {
                    final selected = c.reminderDays.contains(day);
                    final label = day == 1 ? '1 day before' : '$day days before';
                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) {
                        final updated = List<int>.from(c.reminderDays);
                        if (selected) {
                          updated.remove(day);
                        } else {
                          updated.add(day);
                        }
                        updated.sort((a, b) => b.compareTo(a));
                        c.updateReminders(updated);
                      },
                      selectedColor: RenewdColors.oceanBlue.withValues(alpha: RenewdOpacity.medium),
                      checkmarkColor: RenewdColors.oceanBlue,
                      labelStyle: RenewdTextStyles.caption.copyWith(
                        color: selected ? RenewdColors.oceanBlue : RenewdColors.slate,
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: RenewdSpacing.lg),
          ],
        ),
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
              RenewdHaptics.error();
              Navigator.of(ctx).pop();
              c.deleteRenewal();
            },
            child: const Text('Delete',
                style: TextStyle(color: RenewdColors.coralRed)),
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
    final statusColor = RenewdDateUtils.statusColorFromDays(days);
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
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? RenewdColors.steel
                    : RenewdColors.silver,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      days < 0 ? '${days.abs()}' : '$days',
                      style: RenewdTextStyles.numberMedium
                          .copyWith(color: statusColor),
                    ),
                    Text(
                      days < 0 ? 'overdue' : 'days',
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RenewdSpacing.sm),
        Text(
          days < 0 ? 'days overdue' : 'days remaining',
          style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final RenewalModel renewal;
  final List<DocumentModel> documents;
  const _InfoSection({required this.renewal, required this.documents});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusType = _statusTypeFromDays(days);
    return Column(
      children: [
        RenewdCard(
          child: Column(
            children: [
              if (renewal.provider != null) ...[
                _InfoRow(
                    icon: LucideIcons.building2,
                    label: 'Provider',
                    value: renewal.provider!),
                _Divider(),
              ],
              if (renewal.amount != null) ...[
                _InfoRow(
                    icon: LucideIcons.wallet,
                    label: 'Amount',
                    value: '${RenewdCurrency.symbol}${renewal.amount!.toStringAsFixed(2)}'),
                _Divider(),
              ],
              _InfoRow(
                  icon: LucideIcons.refreshCcw,
                  label: 'Frequency',
                  value: _formatFrequency(renewal)),
              _Divider(),
              if (renewal.category == RenewalCategory.insurance &&
                  _policyStartDate() != null) ...[
                _InfoRow(
                    icon: LucideIcons.calendarCheck,
                    label: 'Policy Start',
                    value: RenewdDateUtils.formatDate(_policyStartDate()!)),
                _Divider(),
              ],
              _InfoRow(
                  icon: LucideIcons.calendar,
                  label: renewal.category == RenewalCategory.insurance
                      ? 'Policy Expiry'
                      : 'Next Renewal',
                  value: RenewdDateUtils.formatDate(renewal.renewalDate)),
              _Divider(),
              _InfoRow(
                  icon: LucideIcons.rotateCcw,
                  label: 'Auto-renew',
                  value: renewal.autoRenew ? 'Enabled' : 'Disabled'),
              _Divider(),
              Row(
                children: [
                  Icon(CategoryConfig.icon(renewal.category),
                      size: 16, color: RenewdColors.slate),
                  const SizedBox(width: RenewdSpacing.sm),
                  Text('Category',
                      style: RenewdTextStyles.bodySmall
                          .copyWith(color: RenewdColors.slate)),
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

  /// Get policy start date from the linked document's AI-extracted issue_date
  DateTime? _policyStartDate() {
    for (final doc in documents) {
      if (doc.issueDate != null) return doc.issueDate;
    }
    return null;
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
        Icon(icon, size: 16, color: RenewdColors.slate),
        const SizedBox(width: RenewdSpacing.sm),
        SizedBox(
          width: 100,
          child: Text(label,
              style: RenewdTextStyles.bodySmall
                  .copyWith(color: RenewdColors.slate)),
        ),
        Expanded(
          child: Text(value, style: RenewdTextStyles.bodySmall,
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RenewdSpacing.sm),
      child: Divider(
        color: isDark ? RenewdColors.steel : RenewdColors.silver,
        height: 1,
      ),
    );
  }
}

class _PolicySummary extends StatelessWidget {
  final RenewalDetailController c;
  const _PolicySummary({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = c.documents
          .where((d) => d.isCurrent && d.hasAiSummary)
          .toList();
      if (current.isEmpty) return const SizedBox.shrink();
      final doc = current.first;
      final parsed = _parseOcrText(doc.ocrText!);
      if (parsed == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PolicyHeader(docType: parsed['document_type'] as String?),
          const SizedBox(height: RenewdSpacing.sm),
          if (parsed['summary'] != null)
            _SummaryText(text: parsed['summary'] as String),
          if (parsed['key_details'] != null)
            _KeyDetailsTable(
                details: parsed['key_details'] as List<dynamic>),
          const SizedBox(height: RenewdSpacing.xl),
        ],
      );
    });
  }

  Map<String, dynamic>? _parseOcrText(String text) {
    try {
      final decoded = json.decode(text);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}

class _PolicyHeader extends StatelessWidget {
  final String? docType;
  const _PolicyHeader({this.docType});

  String get _label {
    switch (docType) {
      case 'policy': return 'Policy Summary';
      case 'receipt': return 'Receipt Summary';
      case 'certificate': return 'Certificate Summary';
      case 'invoice': return 'Invoice Summary';
      case 'id': return 'ID Document Summary';
      default: return 'Document Summary';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(LucideIcons.sparkles,
            size: 16, color: RenewdColors.lavender),
        const SizedBox(width: RenewdSpacing.sm),
        Text(_label,
            style: RenewdTextStyles.h3
                .copyWith(color: RenewdColors.lavender)),
      ],
    );
  }
}

class _SummaryText extends StatelessWidget {
  final String text;
  const _SummaryText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RenewdSpacing.md),
      child: Text(text,
          style: RenewdTextStyles.bodySmall
              .copyWith(color: RenewdColors.slate)),
    );
  }
}

class _KeyDetailsTable extends StatelessWidget {
  final List<dynamic> details;
  const _KeyDetailsTable({required this.details});

  @override
  Widget build(BuildContext context) {
    return RenewdCard(
      padding: const EdgeInsets.all(RenewdSpacing.md),
      child: Column(
        children: details.asMap().entries.map((entry) {
          final detail = entry.value.toString();
          final parts = detail.split(':');
          final label = parts.first.trim();
          final value =
              parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

          return Column(
            children: [
              if (entry.key > 0)
                Divider(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? RenewdColors.steel
                      : RenewdColors.silver,
                  height: 1,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: RenewdSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(label,
                          style: RenewdTextStyles.caption
                              .copyWith(color: RenewdColors.slate)),
                    ),
                    Expanded(
                      child: Text(
                          value.isNotEmpty ? value : detail,
                          style: RenewdTextStyles.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PaymentPrompt extends StatefulWidget {
  final RenewalDetailController c;
  final RenewalModel renewal;
  const _PaymentPrompt({required this.c, required this.renewal});

  @override
  State<_PaymentPrompt> createState() => _PaymentPromptState();
}

class _PaymentPromptState extends State<_PaymentPrompt> {
  late final TextEditingController _amountCtrl;
  String? _method;
  late DateTime _paidDate;

  static const _methods = ['UPI', 'Card', 'Net Banking', 'Cash', 'Auto-debit'];

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.renewal.amount?.toStringAsFixed(0) ?? '',
    );
    _paidDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _paidDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : Colors.white,
        borderRadius: RenewdRadius.lgAll,
        border: Border.all(
          color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.moderate),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.checkCircle,
                  size: 18, color: RenewdColors.emerald),
              const SizedBox(width: RenewdSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Renewed! Log payment?',
                        style: RenewdTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    if (widget.c.renewedForDate != null)
                      Text(
                        'For period ending ${RenewdDateUtils.formatDate(widget.c.renewedForDate!)}',
                        style: RenewdTextStyles.caption
                            .copyWith(color: RenewdColors.slate),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '${RenewdCurrency.symbol} ',
              hintText: 'Amount paid',
            ),
          ),
          const SizedBox(height: RenewdSpacing.sm),
          // Date picker
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
                borderRadius: RenewdRadius.mdAll,
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.calendar,
                      size: 16, color: RenewdColors.slate),
                  const SizedBox(width: RenewdSpacing.sm),
                  Text(
                    'Paid on ${RenewdDateUtils.formatDate(_paidDate)}',
                    style: RenewdTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  Icon(LucideIcons.chevronDown,
                      size: 14, color: RenewdColors.slate),
                ],
              ),
            ),
          ),
          const SizedBox(height: RenewdSpacing.sm),
          Wrap(
            spacing: RenewdSpacing.sm,
            children: _methods.map((m) {
              final selected = _method == m;
              return ChoiceChip(
                label: Text(m, style: RenewdTextStyles.caption),
                selected: selected,
                onSelected: (_) => setState(() => _method = selected ? null : m),
                selectedColor: RenewdColors.oceanBlue.withValues(alpha: RenewdOpacity.medium),
              );
            }).toList(),
          ),
          const SizedBox(height: RenewdSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: widget.c.skipPaymentPrompt,
                  child: Text('Skip',
                      style: RenewdTextStyles.bodySmall
                          .copyWith(color: RenewdColors.slate)),
                ),
              ),
              const SizedBox(width: RenewdSpacing.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountCtrl.text);
                    if (amount == null || amount <= 0) {
                      _showSnack(context,
                          icon: LucideIcons.alertTriangle,
                          color: RenewdColors.coralRed,
                          message: 'Enter a valid amount');
                      return;
                    }
                    widget.c.logPayment(
                      amount: amount,
                      method: _method,
                      paidDate: _paidDate,
                    );
                  },
                  child: const Text('Log Payment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentHistory extends StatelessWidget {
  final RenewalDetailController c;
  const _PaymentHistory({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.payments.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.wallet, size: 16, color: RenewdColors.slate),
              const SizedBox(width: RenewdSpacing.sm),
              Text('Payment History', style: RenewdTextStyles.h3),
            ],
          ),
          const SizedBox(height: RenewdSpacing.sm),
          ...c.payments.take(5).map((p) => _PaymentRow(payment: p)),
          const SizedBox(height: RenewdSpacing.xl),
        ],
      );
    });
  }
}

class _PaymentRow extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RenewdSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: RenewdColors.emerald,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: RenewdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RenewdDateUtils.formatDate(payment.paidDate),
                  style: RenewdTextStyles.bodySmall,
                ),
                if (payment.method != null)
                  Text(payment.method!,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
              ],
            ),
          ),
          Text('${RenewdCurrency.symbol}${payment.amount.toStringAsFixed(0)}',
              style: RenewdTextStyles.body
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
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
            Text('Documents', style: RenewdTextStyles.h3),
            const Spacer(),
            Obx(() => c.isUploading.value
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: RenewdColors.oceanBlue))
                : IconButton(
                    icon: Icon(LucideIcons.uploadCloud,
                        color: RenewdColors.oceanBlue),
                    onPressed: () => _pickAndUpload(c),
                    tooltip: 'Upload document',
                  )),
          ],
        ),
        Obx(() => c.isParsing.value
            ? Padding(
                padding: const EdgeInsets.only(bottom: RenewdSpacing.sm),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2,
                            color: RenewdColors.lavender)),
                    const SizedBox(width: RenewdSpacing.sm),
                    Text('Analyzing with AI...',
                        style: RenewdTextStyles.caption
                            .copyWith(color: RenewdColors.lavender)),
                  ],
                ),
              )
            : const SizedBox.shrink()),
        Obx(() {
          final docs = c.documents.toList()
            ..sort((a, b) {
              if (a.isCurrent && !b.isCurrent) return -1;
              if (!a.isCurrent && b.isCurrent) return 1;
              return b.createdAt.compareTo(a.createdAt);
            });
          if (docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: RenewdSpacing.md),
              child: Text('No documents attached',
                  style: RenewdTextStyles.bodySmall
                      .copyWith(color: RenewdColors.slate)),
            );
          }
          return Column(
            children: docs.map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: RenewdSpacing.md),
                  child: DocumentCard(doc: doc),
                )).toList(),
          );
        }),
      ],
    );
  }

  Future<void> _pickAndUpload(RenewalDetailController c) async {
    final ctx = Get.context;
    if (ctx == null) return;
    final doc = await showDocumentPicker(ctx);
    if (doc == null) return;
    final renewal = c.renewal.value;
    final prefix = renewal != null
        ? renewal.name.replaceAll(RegExp(r'[^\w\s]'), '').trim()
        : 'Doc';
    await c.uploadDocument(doc.path, '${prefix}_${doc.name}');
  }
}
