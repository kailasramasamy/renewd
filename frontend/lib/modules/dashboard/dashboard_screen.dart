import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/minder_card.dart';
import 'dashboard_controller.dart';
import 'dashboard_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renewd'),
        actions: [
          IconButton(icon: const Icon(Iconsax.notification), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.renewals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error.value.isNotEmpty && c.renewals.isEmpty) {
          return _ErrorState(c: c);
        }
        return RefreshIndicator(
          onRefresh: c.fetchRenewals,
          child: ListView(
            padding: const EdgeInsets.all(RenewdSpacing.lg),
            children: [
              if (c.hasAlerts) _UrgencyBanner(c: c),
              if (c.hasAlerts) const SizedBox(height: RenewdSpacing.md),
              _SummaryRow(c: c),
              const SizedBox(height: RenewdSpacing.xl),
              if (c.renewals.isEmpty)
                _EmptyState()
              else ...[
                if (c.dueSoon.isNotEmpty) ...[
                  _DueSoonStrip(c: c),
                  const SizedBox(height: RenewdSpacing.xl),
                ],
                _GroupedRenewalList(c: c),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => _showAddOptions(context, c),
        backgroundColor: RenewdColors.oceanBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _showAddOptions(
    BuildContext context, DashboardController c) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: RenewdColors.darkSlate,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddOptionsSheet(c: c),
  );
}

class _AddOptionsSheet extends StatelessWidget {
  final DashboardController c;
  const _AddOptionsSheet({required this.c});

  Future<void> _onScanTap(BuildContext context) async {
    Navigator.of(context).pop();
    final result = await Get.toNamed(AppRoutes.scanAdd);
    if (result == true) c.fetchRenewals();
  }

  Future<void> _onManualTap(BuildContext context) async {
    Navigator.of(context).pop();
    final result = await Get.toNamed(AppRoutes.addRenewal);
    if (result == true) c.fetchRenewals();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RenewdColors.steel,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: RenewdSpacing.xl),
            _SheetOption(
              icon: Iconsax.scan,
              label: 'Scan Document',
              subtitle: 'AI extracts details automatically',
              color: RenewdColors.lavender,
              onTap: () => _onScanTap(context),
            ),
            const SizedBox(height: RenewdSpacing.md),
            _SheetOption(
              icon: Iconsax.edit,
              label: 'Add Manually',
              subtitle: 'Fill in renewal details yourself',
              color: RenewdColors.oceanBlue,
              onTap: () => _onManualTap(context),
            ),
            const SizedBox(height: RenewdSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: RenewdColors.charcoal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RenewdColors.steel),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(RenewdSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: RenewdTextStyles.body),
                  Text(subtitle,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3,
                color: RenewdColors.slate, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final DashboardController c;
  const _ErrorState({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.warning_2,
              size: 48, color: RenewdColors.coralRed),
          const SizedBox(height: RenewdSpacing.md),
          Text('Failed to load renewals', style: RenewdTextStyles.body),
          const SizedBox(height: RenewdSpacing.sm),
          TextButton(
              onPressed: c.fetchRenewals, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _UrgencyBanner extends StatelessWidget {
  final DashboardController c;
  const _UrgencyBanner({required this.c});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (c.overdueCount > 0) parts.add('${c.overdueCount} overdue');
    if (c.urgentCount > 0) parts.add('${c.urgentCount} due in 3 days');
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
      decoration: BoxDecoration(
        color: RenewdColors.coralRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: RenewdColors.coralRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2,
              color: RenewdColors.coralRed, size: 20),
          const SizedBox(width: RenewdSpacing.sm),
          Text(parts.join(' · '),
              style: RenewdTextStyles.bodySmall
                  .copyWith(color: RenewdColors.coralRed)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final DashboardController c;
  const _SummaryRow({required this.c});

  @override
  Widget build(BuildContext context) {
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
          Text(value, style: RenewdTextStyles.h2),
          const SizedBox(height: RenewdSpacing.xs),
          Text(label,
              style:
                  RenewdTextStyles.caption.copyWith(color: RenewdColors.slate)),
        ],
      ),
    );
  }
}

class _DueSoonStrip extends StatelessWidget {
  final DashboardController c;
  const _DueSoonStrip({required this.c});

  @override
  Widget build(BuildContext context) {
    final items = c.dueSoon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Due Soon', style: RenewdTextStyles.h3),
            const SizedBox(width: RenewdSpacing.sm),
            CountBadge(count: items.length, color: RenewdColors.coralRed),
          ],
        ),
        const SizedBox(height: RenewdSpacing.md),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: RenewdSpacing.sm),
            itemBuilder: (context, i) => DueSoonCard(renewal: items[i]),
          ),
        ),
      ],
    );
  }
}

class _GroupedRenewalList extends StatelessWidget {
  final DashboardController c;
  const _GroupedRenewalList({required this.c});

  @override
  Widget build(BuildContext context) {
    final groupNames = c.sortedGroupNames;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Your Renewals', style: RenewdTextStyles.h3),
            const SizedBox(width: RenewdSpacing.sm),
            CountBadge(count: c.totalActive, color: RenewdColors.oceanBlue),
          ],
        ),
        const SizedBox(height: RenewdSpacing.md),
        ...groupNames.map((name) => Padding(
              padding: const EdgeInsets.only(bottom: RenewdSpacing.md),
              child: GroupCard(c: c, groupName: name),
            )),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: RenewdSpacing.xxxl),
        const Icon(Iconsax.document_text,
            size: 64, color: RenewdColors.mist),
        const SizedBox(height: RenewdSpacing.lg),
        Text('No renewals yet',
            style: RenewdTextStyles.h3.copyWith(color: RenewdColors.slate)),
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
