import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/minder_card.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minder'),
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
        return RefreshIndicator(
          onRefresh: c.fetchRenewals,
          child: ListView(
            padding: const EdgeInsets.all(MinderSpacing.lg),
            children: [
              if (c.hasAlerts) _buildUrgencyBanner(c),
              if (c.hasAlerts) const SizedBox(height: MinderSpacing.md),
              _buildSummaryRow(c),
              const SizedBox(height: MinderSpacing.xl),
              if (c.renewals.isEmpty) _buildEmptyState(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () {},
        backgroundColor: MinderColors.oceanBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
        horizontal: MinderSpacing.lg,
        vertical: MinderSpacing.md,
      ),
      decoration: BoxDecoration(
        color: MinderColors.coralRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinderColors.coralRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2,
              color: MinderColors.coralRed, size: 20),
          const SizedBox(width: MinderSpacing.sm),
          Text(
            parts.join(' · '),
            style: MinderTextStyles.bodySmall
                .copyWith(color: MinderColors.coralRed),
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
            color: MinderColors.tangerine,
          ),
        ),
        const SizedBox(width: MinderSpacing.md),
        Expanded(
          child: _SummaryCard(
            label: 'Active',
            value: '${c.totalActive}',
            icon: Iconsax.refresh_circle,
            color: MinderColors.oceanBlue,
          ),
        ),
        const SizedBox(width: MinderSpacing.md),
        Expanded(
          child: _SummaryCard(
            label: 'Monthly',
            value: c.monthlySpend > 0
                ? '₹${c.monthlySpend.toStringAsFixed(0)}'
                : '₹0',
            icon: Iconsax.wallet_3,
            color: MinderColors.emerald,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: MinderSpacing.xxxl),
        Icon(Iconsax.document_text,
            size: 64, color: MinderColors.mist),
        const SizedBox(height: MinderSpacing.lg),
        Text(
          'No renewals yet',
          style: MinderTextStyles.h3.copyWith(color: MinderColors.slate),
        ),
        const SizedBox(height: MinderSpacing.sm),
        Text(
          'Tap + to add your first renewal\nor scan a document to get started',
          style: MinderTextStyles.bodySmall
              .copyWith(color: MinderColors.slate),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
    return MinderCard(
      padding: const EdgeInsets.all(MinderSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: MinderSpacing.sm),
          Text(
            value,
            style: MinderTextStyles.h2,
          ),
          const SizedBox(height: MinderSpacing.xs),
          Text(
            label,
            style: MinderTextStyles.caption
                .copyWith(color: MinderColors.slate),
          ),
        ],
      ),
    );
  }
}
