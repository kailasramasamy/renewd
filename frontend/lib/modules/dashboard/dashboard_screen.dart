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
import '../../widgets/minder_card.dart';
import '../../widgets/status_badge.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renewd'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.renewals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error.value.isNotEmpty && c.renewals.isEmpty) {
          return _buildError(c);
        }
        return RefreshIndicator(
          onRefresh: c.fetchRenewals,
          child: ListView(
            padding: const EdgeInsets.all(RenewdSpacing.lg),
            children: [
              if (c.hasAlerts) _buildUrgencyBanner(c),
              if (c.hasAlerts) const SizedBox(height: RenewdSpacing.md),
              _buildSummaryRow(c),
              const SizedBox(height: RenewdSpacing.xl),
              if (c.renewals.isEmpty)
                _buildEmptyState()
              else
                _buildRenewalList(c),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.addRenewal);
          if (result == true) c.fetchRenewals();
        },
        backgroundColor: RenewdColors.oceanBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildError(DashboardController c) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.warning_2, size: 48, color: RenewdColors.coralRed),
          const SizedBox(height: RenewdSpacing.md),
          Text('Failed to load renewals',
              style: RenewdTextStyles.body),
          const SizedBox(height: RenewdSpacing.sm),
          TextButton(
            onPressed: c.fetchRenewals,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBanner(DashboardController c) {
    final overdue = c.overdueCount;
    final urgent = c.urgentCount;
    final parts = <String>[];
    if (overdue > 0) parts.add('$overdue overdue');
    if (urgent > 0) parts.add('$urgent due in 3 days');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RenewdSpacing.lg,
        vertical: RenewdSpacing.md,
      ),
      decoration: BoxDecoration(
        color: RenewdColors.coralRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RenewdColors.coralRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2,
              color: RenewdColors.coralRed, size: 20),
          const SizedBox(width: RenewdSpacing.sm),
          Text(
            parts.join(' · '),
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.coralRed),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(DashboardController c) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Due This Month',
            value: '${c.dueThisMonth}',
            icon: Iconsax.calendar,
            color: RenewdColors.tangerine,
          ),
        ),
        const SizedBox(width: RenewdSpacing.md),
        Expanded(
          child: _SummaryCard(
            label: 'Active',
            value: '${c.totalActive}',
            icon: Iconsax.refresh_circle,
            color: RenewdColors.oceanBlue,
          ),
        ),
        const SizedBox(width: RenewdSpacing.md),
        Expanded(
          child: _SummaryCard(
            label: 'Monthly',
            value: c.monthlySpend > 0
                ? '₹${c.monthlySpend.toStringAsFixed(0)}'
                : '₹0',
            icon: Iconsax.wallet_3,
            color: RenewdColors.emerald,
          ),
        ),
      ],
    );
  }

  Widget _buildRenewalList(DashboardController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Renewals',
            style: RenewdTextStyles.h3),
        const SizedBox(height: RenewdSpacing.md),
        ...c.renewals.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: RenewdSpacing.md),
              child: _RenewalListItem(
                renewal: r,
                onTap: () async {
                  final result = await Get.toNamed(
                    AppRoutes.renewalDetail,
                    arguments: r,
                  );
                  if (result == true) c.fetchRenewals();
                },
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: RenewdSpacing.xxxl),
        const Icon(Iconsax.document_text,
            size: 64, color: RenewdColors.mist),
        const SizedBox(height: RenewdSpacing.lg),
        Text(
          'No renewals yet',
          style: RenewdTextStyles.h3.copyWith(color: RenewdColors.slate),
        ),
        const SizedBox(height: RenewdSpacing.sm),
        Text(
          'Tap + to add your first renewal\nor scan a document to get started',
          style: RenewdTextStyles.bodySmall
              .copyWith(color: RenewdColors.slate),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RenewalListItem extends StatelessWidget {
  final RenewalModel renewal;
  final VoidCallback onTap;

  const _RenewalListItem({required this.renewal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusColor = RenewdDateUtils.statusColorFromDays(days);
    final statusType = _statusTypeFromDays(days);
    final catColor = CategoryConfig.color(renewal.category);
    final catIcon = CategoryConfig.icon(renewal.category);

    return RenewdCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RenewdSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(catIcon, size: 18, color: catColor),
          ),
          const SizedBox(width: RenewdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(renewal.name, style: RenewdTextStyles.h3.copyWith(
                    fontSize: 15)),
                if (renewal.provider != null) ...[
                  const SizedBox(height: RenewdSpacing.xs),
                  Text(renewal.provider!,
                      style: RenewdTextStyles.bodySmall.copyWith(
                          color: RenewdColors.slate)),
                ],
                const SizedBox(height: RenewdSpacing.xs),
                Text(
                  RenewdDateUtils.formatDate(renewal.renewalDate),
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(width: RenewdSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                days < 0 ? '${days.abs()}d late' : '${days}d',
                style: RenewdTextStyles.caption.copyWith(
                    color: statusColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: RenewdSpacing.xs),
              StatusBadge(
                label: _statusLabel(days),
                status: statusType,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(int days) {
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Today';
    if (days <= 7) return '$days days';
    if (days <= 30) return '$days days';
    return RenewdDateUtils.formatShort(renewal.renewalDate);
  }

  StatusType _statusTypeFromDays(int days) {
    if (days < 0) return StatusType.critical;
    if (days <= 7) return StatusType.critical;
    if (days <= 30) return StatusType.urgent;
    if (days <= 60) return StatusType.warning;
    return StatusType.safe;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RenewdCard(
      padding: const EdgeInsets.all(RenewdSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: RenewdSpacing.sm),
          Text(
            value,
            style: RenewdTextStyles.h2,
          ),
          const SizedBox(height: RenewdSpacing.xs),
          Text(
            label,
            style: RenewdTextStyles.caption
                .copyWith(color: RenewdColors.slate),
          ),
        ],
      ),
    );
  }
}
