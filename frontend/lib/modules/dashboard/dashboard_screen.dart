import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/renewal_model.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    return Scaffold(
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
            padding: const EdgeInsets.fromLTRB(
                RenewdSpacing.lg, 0, RenewdSpacing.lg, 100),
            children: [
              SafeArea(
                bottom: false,
                child: _SearchBar(c: c),
              ),
              const SizedBox(height: RenewdSpacing.md),
              const _FeatureBanner(),
              const SizedBox(height: RenewdSpacing.md),
              _StatsRow(c: c),
              const SizedBox(height: RenewdSpacing.xxl),
              if (c.filteredRenewals.isEmpty && c.searchQuery.value.isEmpty)
                _EmptyState()
              else if (c.filteredRenewals.isEmpty)
                _NoResults()
              else
                _SectionedList(c: c),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => _showAddOptions(context, c),
        backgroundColor: RenewdColors.oceanBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final DashboardController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: RenewdSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? RenewdColors.darkSlate : RenewdColors.cloudGray,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                onChanged: (v) => c.searchQuery.value = v,
                style: RenewdTextStyles.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Search renewals...',
                  hintStyle: RenewdTextStyles.bodySmall
                      .copyWith(color: RenewdColors.slate),
                  prefixIcon: Icon(LucideIcons.search,
                      size: 18, color: RenewdColors.slate),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: RenewdSpacing.sm),
          IconButton(
            icon: Icon(LucideIcons.messageCircle,
                size: 22, color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
            onPressed: () => Get.toNamed(AppRoutes.chat),
          ),
          IconButton(
            icon: Icon(LucideIcons.bell,
                size: 22, color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ─── Feature Banner ───────────────────────────────────

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.features),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF3B82F6),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(LucideIcons.sparkles,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Discover Renewd',
                      style: RenewdTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text('AI scanning, smart reminders & more',
                      style: RenewdTextStyles.caption.copyWith(
                        color: Colors.white70,
                      )),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 18, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// ─── Stats ────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? RenewdColors.darkSlate : Colors.white;
    return Row(
      children: [
        _StatCard(
          value: '${c.dueThisMonth}',
          label: 'Due',
          color: c.dueThisMonth > 0 ? RenewdColors.tangerine : RenewdColors.slate,
          bg: bg,
        ),
        const SizedBox(width: RenewdSpacing.sm),
        _StatCard(value: '${c.totalActive}', label: 'Active', color: RenewdColors.oceanBlue, bg: bg),
        const SizedBox(width: RenewdSpacing.sm),
        _StatCard(
          value: '₹${c.monthlySpend.toStringAsFixed(0)}',
          label: 'Monthly',
          color: RenewdColors.emerald,
          bg: bg,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(RenewdSpacing.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value,
                style: RenewdTextStyles.h2.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label.toUpperCase(),
                style: RenewdTextStyles.caption.copyWith(
                  color: RenewdColors.slate,
                  letterSpacing: 0.8,
                  fontSize: 10,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Sectioned list by urgency ────────────────────────

class _SectionedList extends StatelessWidget {
  final DashboardController c;
  const _SectionedList({required this.c});

  @override
  Widget build(BuildContext context) {
    final all = c.filteredRenewals;
    final overdue = all.where((r) => r.daysRemaining < 0).toList();
    final thisWeek = all
        .where((r) => r.daysRemaining >= 0 && r.daysRemaining <= 7)
        .toList();
    final thisMonth = all
        .where((r) => r.daysRemaining > 7 && r.daysRemaining <= 30)
        .toList();
    final later =
        all.where((r) => r.daysRemaining > 30).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdue.isNotEmpty)
          _Section(
              label: 'OVERDUE',
              color: RenewdColors.coralRed,
              items: overdue,
              c: c),
        if (thisWeek.isNotEmpty)
          _Section(
              label: 'THIS WEEK',
              color: RenewdColors.tangerine,
              items: thisWeek,
              c: c),
        if (thisMonth.isNotEmpty)
          _Section(
              label: 'THIS MONTH',
              color: RenewdColors.amber,
              items: thisMonth,
              c: c),
        if (later.isNotEmpty)
          _Section(
              label: 'UPCOMING',
              color: RenewdColors.emerald,
              items: later,
              c: c),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Color color;
  final List<RenewalModel> items;
  final DashboardController c;

  const _Section({
    required this.label,
    required this.color,
    required this.items,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RenewdSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: RenewdSpacing.sm),
              Text(label,
                  style: RenewdTextStyles.caption.copyWith(
                    color: RenewdColors.slate,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(width: RenewdSpacing.sm),
              Text('${items.length}',
                  style: RenewdTextStyles.caption.copyWith(
                    color: RenewdColors.slate,
                  )),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          ...items.map((r) => _RenewalRow(
                renewal: r,
                statusColor: color,
                onTap: () async {
                  final result = await Get.toNamed(
                      AppRoutes.renewalDetail,
                      arguments: r);
                  if (result == true) c.fetchRenewals();
                },
              )),
        ],
      ),
    );
  }
}

class _RenewalRow extends StatelessWidget {
  final RenewalModel renewal;
  final Color statusColor;
  final VoidCallback onTap;

  const _RenewalRow({
    required this.renewal,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final catColor = CategoryConfig.color(renewal.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg,
          vertical: RenewdSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: statusColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(CategoryConfig.icon(renewal.category),
                  size: 18, color: catColor),
            ),
            const SizedBox(width: RenewdSpacing.md),
            // Name + provider
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(renewal.name,
                      style: RenewdTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    renewal.provider ??
                        CategoryConfig.label(renewal.category),
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: RenewdSpacing.sm),
            // Amount + days
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (renewal.amount != null)
                  Text('₹${renewal.amount!.toStringAsFixed(0)}',
                      style: RenewdTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      )),
                const SizedBox(height: 2),
                Text(
                  _daysLabel(days),
                  style: RenewdTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _daysLabel(int days) {
    if (days < 0) return '${days.abs()}d overdue';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days <= 30) return 'in ${days}d';
    return RenewdDateUtils.formatShort(renewal.renewalDate);
  }
}

// ─── Add options sheet ────────────────────────────────

Future<void> _showAddOptions(
    BuildContext context, DashboardController c) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _AddOptionsSheet(c: c),
  );
}

class _AddOptionsSheet extends StatelessWidget {
  final DashboardController c;
  const _AddOptionsSheet({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
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
            _SheetOption(
              icon: LucideIcons.scanLine,
              label: 'Scan Document',
              subtitle: 'AI extracts details automatically',
              color: RenewdColors.lavender,
              isDark: isDark,
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Get.toNamed(AppRoutes.scanAdd);
                if (result == true) c.fetchRenewals();
              },
            ),
            const SizedBox(height: RenewdSpacing.sm),
            _SheetOption(
              icon: LucideIcons.edit,
              label: 'Add Manually',
              subtitle: 'Enter renewal details yourself',
              color: RenewdColors.oceanBlue,
              isDark: isDark,
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Get.toNamed(AppRoutes.addRenewal);
                if (result == true) c.fetchRenewals();
              },
            ),
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
  final bool isDark;
  final VoidCallback onTap;

  const _SheetOption({
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
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: RenewdTextStyles.body
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

// ─── Empty / Error ────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final DashboardController c;
  const _ErrorState({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertTriangle,
              size: 48, color: RenewdColors.coralRed),
          const SizedBox(height: RenewdSpacing.md),
          Text('Failed to load', style: RenewdTextStyles.body),
          const SizedBox(height: RenewdSpacing.sm),
          TextButton(onPressed: c.fetchRenewals, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: RenewdSpacing.xxxl),
        Icon(LucideIcons.search, size: 40, color: RenewdColors.slate),
        const SizedBox(height: RenewdSpacing.md),
        Text('No matches found',
            style: RenewdTextStyles.body
                .copyWith(color: RenewdColors.slate)),
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
        Icon(LucideIcons.fileText, size: 48, color: RenewdColors.slate),
        const SizedBox(height: RenewdSpacing.lg),
        Text('No renewals yet',
            style: RenewdTextStyles.body
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.xs),
        Text('Tap + to add your first renewal',
            style: RenewdTextStyles.caption
                .copyWith(color: RenewdColors.slate)),
      ],
    );
  }
}
