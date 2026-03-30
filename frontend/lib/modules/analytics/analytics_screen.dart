import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
        title: const Text('Spending Analytics'),
      ),
      body: PremiumGate(
        feature: 'spending_analytics',
        child: Obx(() {
          if (!c.hasData) {
            return _EmptyState(isDark: isDark);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              RenewdSpacing.lg, RenewdSpacing.sm, RenewdSpacing.lg, 100,
            ),
            children: [
              _AnnualSummary(c: c, isDark: isDark),
              const SizedBox(height: RenewdSpacing.xl),
              _SectionTitle('CATEGORY BREAKDOWN', isDark),
              const SizedBox(height: RenewdSpacing.md),
              _DonutChart(c: c, isDark: isDark),
              const SizedBox(height: RenewdSpacing.lg),
              _CategoryList(c: c, isDark: isDark),
              const SizedBox(height: RenewdSpacing.xl),
              _SectionTitle('TOP RENEWALS BY ANNUAL COST', isDark),
              const SizedBox(height: RenewdSpacing.md),
              _TopRenewals(c: c, isDark: isDark),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle(this.title, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: RenewdTextStyles.sectionHeader
            .copyWith(color: isDark ? RenewdColors.warmGray : RenewdColors.slate));
  }
}

// ─── Annual Summary ─────────────────────────────────

class _AnnualSummary extends StatelessWidget {
  final AnalyticsController c;
  final bool isDark;
  const _AnnualSummary({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RenewdCard(
      padding: const EdgeInsets.all(RenewdSpacing.xl),
      child: Column(
        children: [
          Text('Estimated Annual Spend',
              style: RenewdTextStyles.caption.copyWith(
                color: RenewdColors.slate,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: RenewdSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              RenewdCurrency.format(c.totalAnnualSpend),
              style: RenewdTextStyles.numberLarge.copyWith(
                color: isDark ? Colors.white : RenewdColors.deepNavy,
              ),
            ),
          ),
          const SizedBox(height: RenewdSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat('Monthly', RenewdCurrency.format(c.monthlySpend), isDark),
              Container(
                width: 1, height: 24,
                margin: const EdgeInsets.symmetric(horizontal: RenewdSpacing.lg),
                color: isDark ? RenewdColors.steel : RenewdColors.silver,
              ),
              _MiniStat('Yearly', RenewdCurrency.format(c.yearlySpend), isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _MiniStat(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: RenewdTextStyles.caption.copyWith(
              color: RenewdColors.slate, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: RenewdTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : RenewdColors.deepNavy,
            )),
      ],
    );
  }
}

// ─── Donut Chart ─────────────────────────────────────

class _DonutChart extends StatelessWidget {
  final AnalyticsController c;
  final bool isDark;
  const _DonutChart({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final breakdown = c.categoryBreakdown;
    final total = c.totalAnnualSpend;

    return RenewdCard(
      padding: const EdgeInsets.all(RenewdSpacing.xl),
      child: SizedBox(
        height: 200,
        child: CustomPaint(
          painter: _DonutPainter(
            segments: breakdown.map((s) => _Segment(
              fraction: total > 0 ? s.annualCost / total : 0,
              color: CategoryConfig.color(s.category),
            )).toList(),
            isDark: isDark,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${breakdown.length}',
                    style: RenewdTextStyles.h2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : RenewdColors.deepNavy,
                    )),
                Text('categories',
                    style: RenewdTextStyles.caption.copyWith(
                      color: RenewdColors.slate,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment {
  final double fraction;
  final Color color;
  const _Segment({required this.fraction, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  final bool isDark;
  _DonutPainter({required this.segments, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final strokeWidth = 24.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = isDark ? RenewdColors.steel : RenewdColors.cloudGray;
    canvas.drawCircle(center, radius, bgPaint);

    // Segments
    double startAngle = -pi / 2;
    for (final seg in segments) {
      final sweep = seg.fraction * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = seg.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}

// ─── Category List ───────────────────────────────────

class _CategoryList extends StatelessWidget {
  final AnalyticsController c;
  final bool isDark;
  const _CategoryList({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final breakdown = c.categoryBreakdown;
    final total = c.totalAnnualSpend;

    return Column(
      children: breakdown.map((item) {
        final pct = total > 0 ? (item.annualCost / total * 100) : 0;
        final color = CategoryConfig.color(item.category);

        return Padding(
          padding: const EdgeInsets.only(bottom: RenewdSpacing.sm),
          child: RenewdCard(
            padding: const EdgeInsets.all(RenewdSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(CategoryConfig.icon(item.category),
                      size: 18, color: color),
                ),
                const SizedBox(width: RenewdSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(CategoryConfig.label(item.category),
                          style: RenewdTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : RenewdColors.deepNavy,
                          )),
                      const SizedBox(height: 2),
                      Text('${item.count} renewal${item.count > 1 ? 's' : ''} · ${pct.toStringAsFixed(0)}%',
                          style: RenewdTextStyles.caption.copyWith(
                            color: RenewdColors.slate,
                          )),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(RenewdCurrency.format(item.annualCost),
                        style: RenewdTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : RenewdColors.deepNavy,
                        )),
                    Text('/year',
                        style: RenewdTextStyles.caption.copyWith(
                          color: RenewdColors.slate, fontSize: 10,
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Top Renewals ────────────────────────────────────

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
              height: RenewdSpacing.xl,
              color: isDark ? RenewdColors.steel : RenewdColors.silver,
            ),
            Row(
              children: [
                Container(
                  width: 24, height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _rankColor(i).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${i + 1}',
                      style: RenewdTextStyles.caption.copyWith(
                        color: _rankColor(i),
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const SizedBox(width: RenewdSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[i].name,
                          style: RenewdTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : RenewdColors.deepNavy,
                          )),
                      Text(
                        '${items[i].provider ?? CategoryConfig.label(items[i].category)}'
                        ' · ${RenewdCurrency.format(items[i].amount ?? 0)}${c.frequencyLabel(items[i].frequency)}',
                        style: RenewdTextStyles.caption.copyWith(
                          color: RenewdColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(RenewdCurrency.format(c.annualCostOf(items[i])),
                        style: RenewdTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : RenewdColors.deepNavy,
                        )),
                    Text('/year',
                        style: RenewdTextStyles.caption.copyWith(
                          color: RenewdColors.slate, fontSize: 10,
                        )),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _rankColor(int i) {
    switch (i) {
      case 0: return RenewdColors.tangerine;
      case 1: return RenewdColors.oceanBlue;
      case 2: return RenewdColors.emerald;
      default: return RenewdColors.slate;
    }
  }
}

// ─── Empty State ─────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.pieChart, size: 48, color: RenewdColors.slate),
            const SizedBox(height: RenewdSpacing.lg),
            Text('No renewals yet',
                style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.sm),
            Text('Add renewals to see your spending breakdown',
                textAlign: TextAlign.center,
                style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate)),
          ],
        ),
      ),
    );
  }
}
