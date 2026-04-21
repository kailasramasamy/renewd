import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/category_config.dart';
import '../categories/categories_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/renewal_model.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/skeleton_loader.dart';
import '../home/home_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (c.isLoading.value && c.renewals.isEmpty) {
            return const SkeletonLoader();
          }
          if (c.error.value.isNotEmpty && c.renewals.isEmpty) {
            return _ErrorState(c: c);
          }
          return RefreshIndicator(
            onRefresh: c.fetchRenewals,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  RenewdSpacing.lg, RenewdSpacing.sm, RenewdSpacing.lg, 140),
              children: [
                _Header(c: c),
                const SizedBox(height: RenewdSpacing.lg),
                if (c.renewals.isNotEmpty) ...[
                  _BriefCard(c: c),
                  const SizedBox(height: RenewdSpacing.lg),
                  _StatsRow(c: c),
                  const SizedBox(height: RenewdSpacing.xl),
                  _UpNextSection(c: c),
                  const SizedBox(height: RenewdSpacing.xl),
                  _ByCategorySection(c: c),
                  const SizedBox(height: RenewdSpacing.xl),
                  _WorthALookSection(c: c),
                ] else
                  _EmptyState(),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          heroTag: 'dashboard_fab',
          onPressed: () => _showAddOptions(context, Get.find<DashboardController>()),
          backgroundColor: RenewdColors.oceanBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────

class _Header extends StatelessWidget {
  final DashboardController c;
  const _Header({required this.c});

  String get _firstName {
    final storage = Get.find<StorageService>();
    final userData = storage.readUserData();
    final name = userData?['name'] as String?;
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    return 'there';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning,';
    if (hour >= 12 && hour < 17) return 'Good afternoon,';
    if (hour >= 17 && hour < 21) return 'Good evening,';
    return 'Good night,';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    return Padding(
      padding: const EdgeInsets.only(top: RenewdSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate)),
                Text(_firstName,
                    style: RenewdTextStyles.h1
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Row(
            children: [
              _SquareIconButton(
                icon: LucideIcons.search,
                isDark: isDark,
                borderColor: borderColor,
                onTap: () => Get.toNamed(AppRoutes.search),
              ),
              const SizedBox(width: RenewdSpacing.sm),
              Obx(() {
                final count = c.unreadNotificationCount.value;
                return _SquareIconButton(
                  icon: LucideIcons.bell,
                  isDark: isDark,
                  borderColor: borderColor,
                  badgeCount: count,
                  onTap: () async {
                    await Get.toNamed(AppRoutes.notificationInbox);
                    c.fetchUnreadCount();
                  },
                );
              }),
              const SizedBox(width: RenewdSpacing.sm),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.profile),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: RenewdColors.oceanBlue,
                    borderRadius: BorderRadius.circular(RenewdRadius.sm),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      _firstName[0].toUpperCase(),
                      style: RenewdTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onTap;
  final int badgeCount;

  const _SquareIconButton({
    required this.icon,
    required this.isDark,
    required this.borderColor,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Badge(
        isLabelVisible: badgeCount > 0,
        offset: const Offset(-2, 2),
        label: Text('$badgeCount',
            style: const TextStyle(fontSize: 10, color: Colors.white)),
        backgroundColor: RenewdColors.coralRed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.steel : Colors.white,
            borderRadius: BorderRadius.circular(RenewdRadius.sm),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon,
              size: 18,
              color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
        ),
      ),
    );
  }
}

// ─── Brief Card ───────────────────────────────────────

class _BriefCard extends StatelessWidget {
  final DashboardController c;
  const _BriefCard({required this.c});

  String _briefText() {
    final soon = c.dueSoon;
    if (soon.isEmpty) return 'No renewals due in the next 7 days. You\'re all clear.';
    final total = soon.fold(0.0, (sum, r) => sum + (r.amount ?? 0));
    final topRenewal = soon.reduce((a, b) => (a.amount ?? 0) >= (b.amount ?? 0) ? a : b);
    final formatted = RenewdCurrency.format(total);
    return '$formatted due in the next 7 days across ${soon.length} renewal${soon.length > 1 ? 's' : ''}. ${topRenewal.name} is the big one.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    final count = c.dueSoon.length;
    return Container(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : Colors.white,
        borderRadius: RenewdRadius.lgAll,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [RenewdColors.gradientStart, RenewdColors.gradientEnd],
                ).createShader(b),
                child: const Icon(LucideIcons.sparkles,
                    size: 14, color: Colors.white),
              ),
              const SizedBox(width: RenewdSpacing.xs),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [RenewdColors.gradientStart, RenewdColors.gradientEnd],
                ).createShader(b),
                child: Text('YOUR BRIEF',
                    style: RenewdTextStyles.sectionHeader
                        .copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          Text(_briefText(),
              style: RenewdTextStyles.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
              )),
          const SizedBox(height: RenewdSpacing.lg),
          Row(
            children: [
              _GradientButton(
                label: 'Ask a follow-up',
                onTap: () {
                  final home = Get.find<HomeController>();
                  home.changeTab(3);
                },
              ),
              const SizedBox(width: RenewdSpacing.sm),
              _GhostButton(
                label: 'View all $count',
                onTap: () {
                  final home = Get.find<HomeController>();
                  home.changeTab(1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [RenewdColors.gradientStart, RenewdColors.gradientEnd],
          ),
          borderRadius: RenewdRadius.smAll,
        ),
        child: Text(label,
            style: RenewdTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: RenewdRadius.smAll,
        ),
        child: Text(label,
            style: RenewdTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
            )),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    final catCount = c.categoryGrouped.keys.length;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            eyebrow: 'MONTHLY BURN',
            value: RenewdCurrency.formatCompact(c.monthlySpend),
            subline: '+0% vs avg',
            sublineColor: RenewdColors.emerald,
            isDark: isDark,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: RenewdSpacing.md),
        Expanded(
          child: _StatCard(
            eyebrow: 'ACTIVE',
            value: '${c.totalActive}',
            subline: '$catCount categor${catCount == 1 ? 'y' : 'ies'}',
            sublineColor: RenewdColors.slate,
            isDark: isDark,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String eyebrow;
  final String value;
  final String subline;
  final Color sublineColor;
  final bool isDark;
  final Color borderColor;

  const _StatCard({
    required this.eyebrow,
    required this.value,
    required this.subline,
    required this.sublineColor,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RenewdSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : Colors.white,
        borderRadius: RenewdRadius.lgAll,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow,
              style: RenewdTextStyles.sectionHeader
                  .copyWith(color: RenewdColors.slate)),
          const SizedBox(height: RenewdSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: RenewdTextStyles.h2),
          ),
          const SizedBox(height: 2),
          Text(subline,
              style: RenewdTextStyles.caption.copyWith(color: sublineColor)),
        ],
      ),
    );
  }
}

// ─── Up Next Section ─────────────────────────────────

class _UpNextSection extends StatelessWidget {
  final DashboardController c;
  const _UpNextSection({required this.c});

  @override
  Widget build(BuildContext context) {
    final upcoming = c.renewals.where((r) => r.daysRemaining >= 0).take(4).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('UP NEXT · ${upcoming.length}',
                style: RenewdTextStyles.sectionHeader
                    .copyWith(color: RenewdColors.slate)),
            GestureDetector(
              onTap: () => Get.find<HomeController>().changeTab(1),
              child: Text('See all →',
                  style: RenewdTextStyles.caption.copyWith(
                    color: RenewdColors.lavender,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
        const SizedBox(height: RenewdSpacing.md),
        ...upcoming.map((r) => _UpNextRow(renewal: r)),
      ],
    );
  }
}

class _UpNextRow extends StatelessWidget {
  final RenewalModel renewal;
  const _UpNextRow({required this.renewal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    final days = renewal.daysRemaining;
    final pillColor = days == 0
        ? RenewdColors.coralRed
        : days <= 7
            ? RenewdColors.amber
            : RenewdColors.emerald;

    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed(AppRoutes.renewalDetail, arguments: renewal);
        if (result == true) {
          Get.find<DashboardController>().fetchRenewals();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.mdAll,
          border: Border.all(color: borderColor),
        ),
        child: IntrinsicHeight(
          child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(color: pillColor),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.md, vertical: RenewdSpacing.md),
                child: Row(
                  children: [
                    BrandLogo(renewal: renewal, size: 40),
                    const SizedBox(width: RenewdSpacing.md),
                    Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(renewal.name,
                      style: RenewdTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${renewal.provider ?? ''}'
                    '${renewal.provider != null ? ' · ' : ''}'
                    '${CategoryConfig.label(renewal.category)}',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: RenewdSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (renewal.amount != null)
                  Text(RenewdCurrency.format(renewal.amount!),
                      style: RenewdTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: RenewdSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: pillColor.withValues(alpha: RenewdOpacity.medium),
                    borderRadius: RenewdRadius.pillAll,
                  ),
                  child: Text(
                    days == 0
                        ? 'Today'
                        : days == 1
                            ? 'Tomorrow'
                            : 'in ${days}d',
                    style: RenewdTextStyles.caption.copyWith(
                      color: pillColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── By Category Section ─────────────────────────────

class _ByCategorySection extends StatelessWidget {
  final DashboardController c;
  const _ByCategorySection({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    final grouped = c.categoryGrouped;
    if (grouped.isEmpty) return const SizedBox.shrink();

    final catSpend = <RenewalCategory, double>{};
    for (final entry in grouped.entries) {
      double total = 0;
      for (final list in entry.value.values) {
        for (final r in list) {
          total += r.amount ?? 0;
        }
      }
      catSpend[entry.key] = total;
    }
    final maxSpend = catSpend.values.fold(0.0, (a, b) => a > b ? a : b);
    final cats = catSpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BY CATEGORY · THIS MONTH',
            style: RenewdTextStyles.sectionHeader
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.darkSlate : Colors.white,
            borderRadius: RenewdRadius.lgAll,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              for (int i = 0; i < cats.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: borderColor),
                _CategoryRow(
                  category: cats[i].key,
                  amount: cats[i].value,
                  maxAmount: maxSpend,
                  onTap: () {
                    final catCtrl = Get.isRegistered<CategoriesController>()
                        ? Get.find<CategoriesController>()
                        : Get.put(CategoriesController());
                    catCtrl.selectCategory(cats[i].key);
                    Get.find<HomeController>().changeTab(1);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final RenewalCategory category;
  final double amount;
  final double maxAmount;
  final VoidCallback onTap;
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.maxAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryConfig.color(category);
    final ratio = maxAmount > 0 ? amount / maxAmount : 0.0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(CategoryConfig.label(category),
                  style: RenewdTextStyles.body),
              Text(RenewdCurrency.format(amount),
                  style: RenewdTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: RenewdSpacing.sm),
          ClipRRect(
            borderRadius: RenewdRadius.pillAll,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ─── Worth A Look Section ─────────────────────────────

class _WorthALookSection extends StatelessWidget {
  final DashboardController c;
  const _WorthALookSection({required this.c});

  List<_Insight> _buildInsights() {
    final insights = <_Insight>[];
    final soon30 = c.renewals
        .where((r) => r.daysRemaining >= 0 && r.daysRemaining <= 30)
        .toList();
    for (final r in soon30.take(2)) {
      final days = r.daysRemaining;
      insights.add(_Insight(
        title: '${r.name} renews in $days day${days == 1 ? '' : 's'}',
        subtitle: r.amount != null
            ? '${RenewdCurrency.format(r.amount!)} due ${RenewdDateUtils.formatShort(r.renewalDate)}'
            : 'Due ${RenewdDateUtils.formatShort(r.renewalDate)}',
        renewal: r,
      ));
    }
    final expiredOld = c.renewals
        .where((r) => r.daysRemaining < -30)
        .toList();
    for (final r in expiredOld.take(1)) {
      insights.add(_Insight(
        title: '${r.name} expired ${r.daysRemaining.abs()}d ago',
        subtitle: 'Consider removing or renewing',
        renewal: r,
      ));
    }
    // Pad with high-value renewals if sparse
    if (insights.length < 2) {
      final highValue = c.renewals
          .where((r) => (r.amount ?? 0) > 0 && r.daysRemaining > 30)
          .toList()
        ..sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0));
      for (final r in highValue.take(2 - insights.length)) {
        insights.add(_Insight(
          title: '${r.name} · ${RenewdCurrency.format(r.amount!)}',
          subtitle: 'Renews ${RenewdDateUtils.formatShort(r.renewalDate)}',
          renewal: r,
        ));
      }
    }
    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights();
    if (insights.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.sparkles,
                size: 14, color: RenewdColors.lavender),
            const SizedBox(width: RenewdSpacing.xs),
            Text('WORTH A LOOK',
                style: RenewdTextStyles.sectionHeader
                    .copyWith(color: RenewdColors.slate)),
          ],
        ),
        const SizedBox(height: RenewdSpacing.md),
        ...insights.map((ins) => _InsightCard(insight: ins)),
      ],
    );
  }
}

class _Insight {
  final String title;
  final String subtitle;
  final RenewalModel renewal;
  const _Insight(
      {required this.title, required this.subtitle, required this.renewal});
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed(AppRoutes.renewalDetail, arguments: insight.renewal);
        if (result == true) {
          Get.find<DashboardController>().fetchRenewals();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.mdAll,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title,
                      style: RenewdTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  Text(insight.subtitle,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
              ),
            ),
            const SizedBox(width: RenewdSpacing.sm),
            Icon(LucideIcons.chevronRight,
                size: 16, color: RenewdColors.slate),
          ],
        ),
      ),
    );
  }
}

// ─── Add Options ─────────────────────────────────────

Future<void> _showAddOptions(
    BuildContext context, DashboardController c) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(RenewdRadius.xl)),
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
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: RenewdColors.slate
                    .withValues(alpha: RenewdOpacity.moderate),
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

// ─── Empty / Error States ────────────────────────────

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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SizedBox(height: RenewdSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: RenewdSpacing.xl, vertical: RenewdSpacing.xxl),
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.darkSlate : Colors.white,
            borderRadius: RenewdRadius.lgAll,
            border: Border.all(
              color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
            ),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.sparkles,
                  size: 40, color: RenewdColors.lavender),
              const SizedBox(height: RenewdSpacing.lg),
              Text('Welcome to Renewd!',
                  style:
                      RenewdTextStyles.h2.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: RenewdSpacing.sm),
              Text(
                'Track insurance, subscriptions, government docs and never miss a renewal again.',
                textAlign: TextAlign.center,
                style: RenewdTextStyles.bodySmall
                    .copyWith(color: RenewdColors.slate, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
