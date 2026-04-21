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
import '../../widgets/brand_logo.dart';
import '../../widgets/minder_button.dart';
import '../../widgets/minder_card.dart';
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

class RenewalDetailScreen extends StatefulWidget {
  const RenewalDetailScreen({super.key});

  @override
  State<RenewalDetailScreen> createState() => _RenewalDetailScreenState();
}

class _RenewalDetailScreenState extends State<RenewalDetailScreen> {
  final _showTitle = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _showTitle.dispose();
    super.dispose();
  }

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
          title: ValueListenableBuilder<bool>(
            valueListenable: _showTitle,
            builder: (_, show, _) => AnimatedOpacity(
              opacity: show ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(renewal?.name ?? ''),
            ),
          ),
          actions: [
            if (renewal != null)
              IconButton(
                icon: Icon(LucideIcons.moreVertical),
                onPressed: () => _showActionsSheet(context, c, renewal),
              ),
          ],
        ),
        body: c.isLoading.value && renewal == null
            ? const Center(child: CircularProgressIndicator())
            : renewal == null
                ? const Center(child: Text('Renewal not found'))
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      _showTitle.value = notification.metrics.pixels > 120;
                      return false;
                    },
                    child: _buildBody(context, c, renewal),
                  ),
      );
    });
  }

  Widget _buildBody(BuildContext context, RenewalDetailController c,
      RenewalModel renewal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = renewal.daysRemaining;
    final brandColor = CategoryConfig.color(renewal.category);
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          // ─── Atmospheric Backdrop + Hero ──────────
          _HeroSection(renewal: renewal, brandColor: brandColor, isDark: isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                RenewdSpacing.lg, RenewdSpacing.xl, RenewdSpacing.lg, RenewdSpacing.xl),
            child: Column(
              children: [
                // ─── Countdown Progress Card ───────────
                _CountdownProgressCard(renewal: renewal, isDark: isDark),
                const SizedBox(height: RenewdSpacing.xl),

                // ─── Details Card ─────────────────────
                _DetailsCard(renewal: renewal, isDark: isDark),
                const SizedBox(height: RenewdSpacing.xl),

                // ─── Policy Summary (AI Insight) ───────
                _PolicySummary(c: c),

                // ─── Payment History ──────────────────
                _PaymentHistory(c: c),

                // ─── Documents ───────────────────────
                _DocumentsSection(c: c),
                const SizedBox(height: RenewdSpacing.xl),

                // ─── Action Button ────────────────────
                Obx(() {
                  if (c.showPaymentPrompt.value) {
                    return _PaymentPrompt(c: c, renewal: renewal);
                  }
                  if (days > 7) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: RenewdSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
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
          ),
        ],
      ),
    );
  }

  void _showActionsSheet(BuildContext context, RenewalDetailController c,
      RenewalModel renewal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RenewdRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RenewdSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: RenewdColors.slate
                      .withValues(alpha: RenewdOpacity.moderate),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: RenewdSpacing.xl),
              _ActionSheetItem(
                icon: LucideIcons.edit,
                label: 'Edit Renewal',
                subtitle: 'Modify details',
                color: RenewdColors.oceanBlue,
                isDark: isDark,
                onTap: () async {
                  Navigator.of(context).pop();
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
              const SizedBox(height: RenewdSpacing.sm),
              _ActionSheetItem(
                icon: LucideIcons.bell,
                label: 'Reminders',
                subtitle: 'Set notification schedule',
                color: RenewdColors.lavender,
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).pop();
                  _showRemindersSheet(context, c);
                },
              ),
              const SizedBox(height: RenewdSpacing.sm),
              _ActionSheetItem(
                icon: LucideIcons.trash2,
                label: 'Delete',
                subtitle: 'Permanently remove this renewal',
                color: RenewdColors.coralRed,
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(context, c);
                },
              ),
            ],
          ),
        ),
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

// ─── Hero Section with Atmospheric Backdrop ──────────────────────────────────
class _HeroSection extends StatelessWidget {
  final RenewalModel renewal;
  final Color brandColor;
  final bool isDark;
  const _HeroSection({
    required this.renewal,
    required this.brandColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final amount = renewal.amount;
    final freqDays = _freqToDays(renewal.frequency, renewal.frequencyDays);
    return Stack(
      children: [
        // Atmospheric radial gradient backdrop
        Positioned(
          top: 0, left: 0, right: 0,
          child: SizedBox(
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 0.9,
                  colors: [
                    brandColor.withValues(alpha: isDark ? 0.22 : 0.14),
                    brandColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Hero content
        Padding(
          padding: const EdgeInsets.fromLTRB(
              RenewdSpacing.lg, RenewdSpacing.xl, RenewdSpacing.lg, 0),
          child: Column(
            children: [
              BrandLogo(renewal: renewal, size: 64),
              const SizedBox(height: RenewdSpacing.lg),
              Text(
                renewal.name,
                style: RenewdTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: RenewdSpacing.xs),
              Text(
                renewal.provider ?? CategoryConfig.label(renewal.category),
                style: RenewdTextStyles.bodySmall
                    .copyWith(color: RenewdColors.slate),
              ),
              const SizedBox(height: RenewdSpacing.lg),
              if (amount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: RenewdSpacing.xl, vertical: RenewdSpacing.md),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [RenewdColors.gradientStart, RenewdColors.gradientEnd],
                    ),
                    borderRadius: RenewdRadius.pillAll,
                  ),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: RenewdCurrency.format(amount),
                        style: RenewdTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' /${_freqShort(renewal.frequency)}',
                        style: RenewdTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ]),
                  ),
                ),
                if (freqDays != null && freqDays > 0) ...[
                  const SizedBox(height: RenewdSpacing.xs),
                  Text(
                    _buildBreakdown(amount, freqDays),
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _freqShort(String? freq) {
    switch (freq) {
      case 'monthly': return 'month';
      case 'yearly': return 'year';
      case 'quarterly': return 'quarter';
      case 'weekly': return 'week';
      default: return 'year';
    }
  }

  static int? _freqToDays(String? freq, int? customDays) {
    switch (freq) {
      case 'monthly': return 30;
      case 'quarterly': return 91;
      case 'yearly': return 365;
      case 'weekly': return 7;
      case 'custom': return customDays;
      default: return 365;
    }
  }

  static String _buildBreakdown(double amount, int freqDays) {
    final perDay = amount / freqDays;
    final perMonth = amount / freqDays * 30;
    final sym = RenewdCurrency.symbol;
    return '≈ $sym${perMonth.toStringAsFixed(0)}/mo · $sym${perDay.toStringAsFixed(0)}/day';
  }
}

// ─── Countdown Progress Card ──────────────────────────────────────────────────
class _CountdownProgressCard extends StatelessWidget {
  final RenewalModel renewal;
  final bool isDark;
  const _CountdownProgressCard({required this.renewal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final totalDays = _cycleLength(renewal);
    final elapsed = (totalDays - days).clamp(0, totalDays);
    final progress = totalDays > 0
        ? (elapsed / totalDays).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).round();

    final startDate = renewal.renewalDate.subtract(Duration(days: totalDays));
    final endDate = renewal.renewalDate;

    return Container(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : Colors.white,
        borderRadius: RenewdRadius.lgAll,
        border: Border.all(
          color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RENEWS IN',
                        style: RenewdTextStyles.sectionHeader
                            .copyWith(color: RenewdColors.slate)),
                    const SizedBox(height: 4),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: days < 0 ? '${days.abs()}' : '$days',
                        style: RenewdTextStyles.numberMedium.copyWith(
                          color: RenewdDateUtils.statusColorFromDays(days),
                        ),
                      ),
                      TextSpan(
                        text: days < 0 ? ' overdue' : ' days',
                        style: RenewdTextStyles.bodySmall
                            .copyWith(color: RenewdColors.slate),
                      ),
                    ])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('RENEWAL DATE',
                      style: RenewdTextStyles.sectionHeader
                          .copyWith(color: RenewdColors.slate)),
                  const SizedBox(height: 4),
                  Text(
                    RenewdDateUtils.formatDate(endDate),
                    style: RenewdTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          // Gradient progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? RenewdColors.steel : RenewdColors.mist,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            RenewdColors.lavender,
                            RenewdColors.accent2,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: RenewdSpacing.sm),
          // Sub-row
          Row(
            children: [
              Text(RenewdDateUtils.formatShort(startDate),
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate)),
              const Spacer(),
              Text('$pct% elapsed',
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate)),
              const Spacer(),
              Text(RenewdDateUtils.formatShort(endDate),
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate)),
            ],
          ),
        ],
      ),
    );
  }

  static int _cycleLength(RenewalModel r) {
    if (r.frequency == 'custom' && r.frequencyDays != null) {
      return r.frequencyDays!;
    }
    switch (r.frequency) {
      case 'weekly': return 7;
      case 'monthly': return 30;
      case 'quarterly': return 91;
      case 'yearly': return 365;
      default: return 365;
    }
  }
}

// ─── Details Card ─────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final RenewalModel renewal;
  final bool isDark;
  const _DetailsCard({required this.renewal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : Colors.white,
        borderRadius: RenewdRadius.lgAll,
        border: Border.all(
          color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _EyebrowRow(
            label: 'NEXT RENEWAL',
            value: RenewdDateUtils.formatDate(renewal.renewalDate),
            isDark: isDark,
          ),
          _RowDivider(isDark: isDark),
          _EyebrowRow(
            label: 'BILLING CYCLE',
            value: _formatFrequency(renewal),
            isDark: isDark,
          ),
          _RowDivider(isDark: isDark),
          _EyebrowRow(
            label: 'CATEGORY',
            isDark: isDark,
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CategoryConfig.icon(renewal.category),
                    size: 14, color: RenewdColors.slate),
                const SizedBox(width: RenewdSpacing.xs),
                Text(CategoryConfig.label(renewal.category),
                    style: RenewdTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _RowDivider(isDark: isDark),
          Padding(
            padding: const EdgeInsets.all(RenewdSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AUTO-RENEW',
                          style: RenewdTextStyles.sectionHeader
                              .copyWith(color: RenewdColors.slate)),
                      const SizedBox(height: 4),
                      Text(
                        renewal.autoRenew
                            ? 'Renewal is active'
                            : 'Renewal is off',
                        style: RenewdTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  renewal.autoRenew
                      ? LucideIcons.toggleRight
                      : LucideIcons.toggleLeft,
                  size: 28,
                  color: renewal.autoRenew
                      ? RenewdColors.oceanBlue
                      : RenewdColors.slate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatFrequency(RenewalModel r) {
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
}

class _EyebrowRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isDark;

  const _EyebrowRow({
    required this.label,
    required this.isDark,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: RenewdTextStyles.sectionHeader
                    .copyWith(color: RenewdColors.slate)),
          ),
          if (valueWidget != null)
            valueWidget!
          else if (value != null)
            Text(value!,
                style: RenewdTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  final bool isDark;
  const _RowDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
      height: 1,
      indent: RenewdSpacing.lg,
      endIndent: RenewdSpacing.lg,
    );
  }
}

class _ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionSheetItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
          borderRadius: RenewdRadius.lgAll,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: RenewdOpacity.light),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: RenewdTextStyles.body
                          .copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                color: RenewdColors.slate, size: 16),
          ],
        ),
      ),
    );
  }
}

class _PolicySummary extends StatelessWidget {
  final RenewalDetailController c;
  const _PolicySummary({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final current = c.documents
          .where((d) => d.isCurrent && d.hasAiSummary)
          .toList();
      if (current.isEmpty) return const SizedBox.shrink();
      final doc = current.first;
      final parsed = _parseOcrText(doc.ocrText!);
      if (parsed == null) return const SizedBox.shrink();

      final docType = parsed['document_type'] as String?;
      final summary = parsed['summary'] as String?;
      final keyDetails = parsed['key_details'] as List<dynamic>?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Insight card
          Container(
            decoration: BoxDecoration(
              color: isDark ? RenewdColors.darkSlate : Colors.white,
              borderRadius: RenewdRadius.lgAll,
              border: Border.all(
                color: RenewdColors.lavender.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Soft gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: RenewdRadius.lgAll,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          RenewdColors.lavender.withValues(alpha: isDark ? 0.08 : 0.05),
                          RenewdColors.accent2.withValues(alpha: isDark ? 0.04 : 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(RenewdSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.sparkles,
                              size: 14, color: RenewdColors.lavender),
                          const SizedBox(width: RenewdSpacing.xs),
                          Text('RENEWD AI',
                              style: RenewdTextStyles.sectionHeader
                                  .copyWith(color: RenewdColors.lavender)),
                          const SizedBox(width: RenewdSpacing.sm),
                          Text(
                            _PolicyHeader._labelFor(docType),
                            style: RenewdTextStyles.caption
                                .copyWith(color: RenewdColors.slate),
                          ),
                        ],
                      ),
                      if (summary != null) ...[
                        const SizedBox(height: RenewdSpacing.sm),
                        _SummaryText(text: summary),
                      ],
                      if (keyDetails != null) ...[
                        const SizedBox(height: RenewdSpacing.xs),
                        _KeyDetailsTable(details: keyDetails),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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

class _GhostButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const _GhostButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: Icon(icon, size: 13),
      label: Text(label, style: RenewdTextStyles.caption),
      style: OutlinedButton.styleFrom(
        foregroundColor: RenewdColors.lavender,
        side: BorderSide(
            color: RenewdColors.lavender.withValues(alpha: 0.4), width: 1),
        padding: const EdgeInsets.symmetric(
            horizontal: RenewdSpacing.md, vertical: RenewdSpacing.xs),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(borderRadius: RenewdRadius.smAll),
      ),
    );
  }
}

class _PolicyHeader {
  static String _labelFor(String? docType) {
    switch (docType) {
      case 'policy': return 'Policy Summary';
      case 'receipt': return 'Receipt Summary';
      case 'certificate': return 'Certificate Summary';
      case 'invoice': return 'Invoice Summary';
      case 'id': return 'ID Document Summary';
      default: return 'Document Summary';
    }
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(label,
                          style: RenewdTextStyles.caption
                              .copyWith(color: RenewdColors.slate)),
                    ),
                    const SizedBox(width: RenewdSpacing.md),
                    Expanded(
                      flex: 3,
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
          Text(RenewdCurrency.format(payment.amount),
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
            children: docs.map((doc) => _DocItem(doc: doc)).toList(),
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

class _DocItem extends StatelessWidget {
  final DocumentModel doc;
  const _DocItem({required this.doc});

  bool get _hasAi => doc.ocrText != null && doc.ocrText!.isNotEmpty;

  String get _size {
    final bytes = doc.fileSize ?? 0;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.documentDetail, arguments: doc),
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        padding: const EdgeInsets.all(RenewdSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.lgAll,
          border: Border.all(
            color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: RenewdColors.lavender.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(LucideIcons.fileText,
                  size: 20, color: RenewdColors.lavender),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.fileName,
                      style: RenewdTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(_size,
                          style: RenewdTextStyles.caption
                              .copyWith(color: RenewdColors.warmGray)),
                      if (doc.isCurrent) ...[
                        const SizedBox(width: RenewdSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: RenewdColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Current',
                              style: RenewdTextStyles.caption.copyWith(
                                color: RenewdColors.emerald,
                                fontSize: 10,
                              )),
                        ),
                      ],
                      if (_hasAi) ...[
                        const SizedBox(width: RenewdSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                RenewdColors.gradientStart,
                                RenewdColors.gradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('AI',
                              style: RenewdTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 16, color: RenewdColors.warmGray),
          ],
        ),
      ),
    );
  }
}
