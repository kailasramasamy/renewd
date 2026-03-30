import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/currency.dart';
import '../../core/widgets/premium_gate.dart';
import '../../widgets/minder_card.dart';
import 'analytics_controller.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AnalyticsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Spending Analytics',
          style: RenewdTextStyles.h3.copyWith(
            color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumGate(
        feature: 'analytics',
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.error.value.isNotEmpty && !c.hasData) {
            return _ErrorState(c: c);
          }
          if (!c.hasData && c.topRenewals.isEmpty) {
            return _EmptyState(isDark: isDark);
          }
          return RefreshIndicator(
            onRefresh: c.fetchAnalytics,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                RenewdSpacing.lg,
                RenewdSpacing.sm,
                RenewdSpacing.lg,
                RenewdSpacing.xxxl,
              ),
              children: [
                _TotalSpendCard(c: c, isDark: isDark),
                const SizedBox(height: RenewdSpacing.xl),
                if (c.categoryBreakdown.isNotEmpty) ...[
                  _SectionTitle(title: 'BY CATEGORY', isDark: isDark),
                  const SizedBox(height: RenewdSpacing.md),
                  _CategoryBreakdown(c: c, isDark: isDark),
                  const SizedBox(height: RenewdSpacing.xl),
                ],
                if (c.monthlyTrend.isNotEmpty) ...[
                  _SectionTitle(title: 'MONTHLY TREND', isDark: isDark),
                  const SizedBox(height: RenewdSpacing.md),
                  _MonthlyChart(c: c, isDark: isDark),
                  const SizedBox(height: RenewdSpacing.xl),
                ],
                if (c.topRenewals.isNotEmpty) ...[
                  _SectionTitle(title: 'TOP RENEWALS', isDark: isDark),
                  const SizedBox(height: RenewdSpacing.md),
                  _TopRenewals(c: c, isDark: isDark),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

// -- Total Spend Card --

class _TotalSpendCard extends StatelessWidget {
  final AnalyticsController c;
  final bool isDark;
  const _TotalSpendCard({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RenewdCard(
      child: Column(
        children: [
          Text(
            'Total Spend',
            style: RenewdTextStyles.caption.copyWith(
              color: isDark ? RenewdColors.warmGray : RenewdColors.slate,
            ),
          ),
          const SizedBox(height: RenewdSpacing.xs),
          Text(
            RenewdCurrency.format(c.totalSpend.value),
            style: RenewdTextStyles.numberLarge.copyWith(
              color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Section Title --

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: RenewdTextStyles.sectionHeader.copyWith(
        color: isDark ? RenewdColors.warmGray : RenewdColors.slate,
      ),
    );
  }
}

// -- Category Breakdown --

class _CategoryBreakdown extends StatelessWidget {
  final AnalyticsController c;
  final bool isDark;
  const _CategoryBreakdown({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total = c.totalSpend.value;
    return RenewdCard(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      child: Column(
        children: [
          for (int i = 0; i < c.categoryBreakdown.length; i++) ...[
            if (i > 0) const SizedBox(height: RenewdSpacing.md),
            _CategoryRow(
              item: c.categoryBreakdown[i],
              total: total,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategorySpend item;
  final double total;
  final bool isDark;
  const _CategoryRow({
    required this.item,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? item.amount / total : 0.0;
    final color = CategoryConfig.color(item.category);
    final icon = CategoryConfig.icon(item.category);
    final label = CategoryConfig.label(item.category);

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: RenewdSpacing.sm),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: RenewdTextStyles.bodySmall.copyWith(
              color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: _PercentBar(fraction: pct, color: color, isDark: isDark),
        ),
        const SizedBox(width: RenewdSpacing.sm),
        SizedBox(
          width: 72,
          child: Text(
            RenewdCurrency.format(item.amount),
            textAlign: TextAlign.right,
            style: RenewdTextStyles.caption.copyWith(
              color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PercentBar extends StatelessWidget {
  final double fraction;
  final Color color;
  final bool isDark;
  const _PercentBar({
    required this.fraction,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final barWidth = constraints.maxWidth * fraction.clamp(0.0, 1.0);
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: isDark
              ? RenewdColors.steel
              : RenewdColors.cloudGray,
          borderRadius: RenewdRadius.pillAll,
        ),
        alignment: Alignment.centerLeft,
        child: Container(
          width: barWidth,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: RenewdRadius.pillAll,
          ),
        ),
      );
    });
  }
}

// -- Monthly Chart --

class _MonthlyChart extends StatelessWidget {
  final AnalyticsController c;
  final bool isDark;
  const _MonthlyChart({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final months = c.monthlyTrend;
    final maxAmount = months.fold<double>(
      0,
      (prev, e) => max(prev, e.amount),
    );

    return RenewdCard(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < months.length; i++) ...[
                  if (i > 0) const SizedBox(width: RenewdSpacing.xs),
                  Expanded(
                    child: _MonthBar(
                      item: months[i],
                      maxAmount: maxAmount,
                      isDark: isDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: RenewdSpacing.sm),
          Row(
            children: [
              for (int i = 0; i < months.length; i++) ...[
                if (i > 0) const SizedBox(width: RenewdSpacing.xs),
                Expanded(
                  child: Text(
                    _shortMonth(months[i].month),
                    textAlign: TextAlign.center,
                    style: RenewdTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: isDark
                          ? RenewdColors.warmGray
                          : RenewdColors.slate,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _shortMonth(String month) {
    // Expects "2026-03" format; show "Mar"
    final parts = month.split('-');
    if (parts.length < 2) return month;
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx < 1 || idx > 12) return month;
    return names[idx - 1];
  }
}

class _MonthBar extends StatelessWidget {
  final MonthlySpend item;
  final double maxAmount;
  final bool isDark;
  const _MonthBar({
    required this.item,
    required this.maxAmount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxAmount > 0 ? item.amount / maxAmount : 0.0;
    final barHeight = 140.0 * fraction.clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: max(barHeight, 4),
          decoration: BoxDecoration(
            color: RenewdColors.oceanBlue,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(RenewdRadius.sm),
            ),
          ),
        ),
      ],
    );
  }
}

// -- Top Renewals --

class _TopRenewals extends StatelessWidget {
  final AnalyticsController c;
  final bool isDark;
  const _TopRenewals({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = c.topRenewals;
    return RenewdCard(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(
              height: RenewdSpacing.lg,
              color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
            ),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: CategoryConfig.color(items[i].category)
                        .withValues(alpha: 0.15),
                    borderRadius: RenewdRadius.smAll,
                  ),
                  child: Icon(
                    CategoryConfig.icon(items[i].category),
                    size: 14,
                    color: CategoryConfig.color(items[i].category),
                  ),
                ),
                const SizedBox(width: RenewdSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].name,
                        style: RenewdTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? RenewdColors.warmWhite
                              : RenewdColors.deepNavy,
                        ),
                      ),
                      if (items[i].provider != null)
                        Text(
                          items[i].provider!,
                          style: RenewdTextStyles.caption.copyWith(
                            color: RenewdColors.warmGray,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  RenewdCurrency.format(items[i].amount ?? 0),
                  style: RenewdTextStyles.subtitle.copyWith(
                    color: isDark
                        ? RenewdColors.warmWhite
                        : RenewdColors.deepNavy,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// -- Empty State --

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(
              LucideIcons.barChart3,
              size: 48,
              color: isDark ? RenewdColors.warmGray : RenewdColors.slate,
            ),
            const SizedBox(height: RenewdSpacing.lg),
            Text(
              'No payment data yet',
              style: RenewdTextStyles.body.copyWith(
                color: isDark ? RenewdColors.warmGray : RenewdColors.slate,
              ),
            ),
            const SizedBox(height: RenewdSpacing.sm),
            Text(
              'Add payments to your renewals to see analytics',
              style: RenewdTextStyles.caption.copyWith(
                color: RenewdColors.warmGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Error State --

class _ErrorState extends StatelessWidget {
  final AnalyticsController c;
  const _ErrorState({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: RenewdColors.coralRed,
            ),
            const SizedBox(height: RenewdSpacing.lg),
            Text(
              'Failed to load analytics',
              style: RenewdTextStyles.body.copyWith(
                color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
              ),
            ),
            const SizedBox(height: RenewdSpacing.lg),
            TextButton(
              onPressed: c.fetchAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
