import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/currency.dart';
import '../../data/models/banner_model.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/skeleton_loader.dart';
import '../../data/models/renewal_model.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    final allRenewalsKey = GlobalKey();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                    RenewdSpacing.lg, RenewdSpacing.sm, RenewdSpacing.lg, 100),
                children: [
                  _Header(c: c),
                  const SizedBox(height: RenewdSpacing.lg),
                  if (c.renewals.isNotEmpty) ...[
                    _SummaryCard(c: c),
                    const SizedBox(height: RenewdSpacing.xl),
                    _UpcomingGrid(c: c, allRenewalsKey: allRenewalsKey),
                    if (c.banners.isNotEmpty) ...[
                      const SizedBox(height: RenewdSpacing.xl),
                      _BannerCarousel(c: c),
                    ],
                    const SizedBox(height: RenewdSpacing.xl),
                    _RenewalsListSection(key: allRenewalsKey, c: c),
                  ] else if (c.filteredRenewals.isEmpty &&
                      c.searchQuery.value.isEmpty)
                    _EmptyState()
                  else
                    _NoResults(),
                ],
              ),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'dashboard_fab',
          onPressed: () => _showAddOptions(context, c),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: RenewdSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: RenewdColors.oceanBlue,
              child: Text(
                _firstName[0].toUpperCase(),
                style: RenewdTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: RenewdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $_firstName',
                    style: RenewdTextStyles.h3
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('Track your renewals',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate)),
              ],
            ),
          ),
          _CircleIconButton(
            icon: LucideIcons.search,
            isDark: isDark,
            onTap: () => Get.toNamed(AppRoutes.search),
          ),
          const SizedBox(width: RenewdSpacing.sm),
          Obx(() {
            final count = c.unreadNotificationCount.value;
            return _CircleIconButton(
              icon: LucideIcons.bell,
              isDark: isDark,
              badgeCount: count,
              onTap: () async {
                await Get.toNamed(AppRoutes.notificationInbox);
                c.fetchUnreadCount();
              },
            );
          }),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final int badgeCount;

  const _CircleIconButton({
    required this.icon,
    required this.isDark,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 20,
              color:
                  isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
        ),
      ),
    );
  }
}

// ─── Summary Card ────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final DashboardController c;
  const _SummaryCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.analytics),
      child: Container(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B3BDB), Color(0xFF7C3AED)],
          ),
          borderRadius: RenewdRadius.xlAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Annual Spend',
                    style: RenewdTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: RenewdSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: RenewdRadius.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Analytics',
                          style: RenewdTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.arrowRight,
                          size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RenewdSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                RenewdCurrency.formatCompact(c.totalAnnualSpend),
                style: RenewdTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: RenewdSpacing.lg),
            Row(
              children: [
                _SummaryChip(
                  icon: LucideIcons.clock,
                  label: '${c.dueThisMonth} due this month',
                ),
                const SizedBox(width: RenewdSpacing.sm),
                _SummaryChip(
                  icon: LucideIcons.checkCircle,
                  label: '${c.totalActive} active',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: RenewdRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Text(label,
              style: RenewdTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}

// ─── Upcoming Grid (2x2) ────────────────────────────

class _UpcomingGrid extends StatelessWidget {
  final DashboardController c;
  final GlobalKey allRenewalsKey;
  const _UpcomingGrid({required this.c, required this.allRenewalsKey});

  @override
  Widget build(BuildContext context) {
    final upcoming = c.renewals.where((r) => r.daysRemaining >= 0).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final items = upcoming.take(2).toList();
    return Column(
      children: [
        _SectionHeader(
          title: 'Upcoming Renewals',
          onSeeAll: () {
            final ctx = allRenewalsKey.currentContext;
            if (ctx != null) {
              Scrollable.ensureVisible(ctx,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut);
            }
          },
        ),
        const SizedBox(height: RenewdSpacing.md),
        Row(
          children: [
            Expanded(child: _UpcomingCard(renewal: items[0])),
            const SizedBox(width: RenewdSpacing.md),
            if (items.length > 1)
              Expanded(child: _UpcomingCard(renewal: items[1]))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final RenewalModel renewal;
  const _UpcomingCard({required this.renewal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = renewal.daysRemaining;
    final statusColor = RenewdDateUtils.statusColorFromDays(days);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.renewalDetail, arguments: renewal),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.xlAll,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandLogo(renewal: renewal, size: 44),
                const Spacer(),
                Icon(LucideIcons.moreVertical,
                    size: 18, color: RenewdColors.slate),
              ],
            ),
            const Spacer(),
            Text(renewal.name,
                style: RenewdTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            if (renewal.amount != null)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: RenewdCurrency.format(renewal.amount!),
                      style: RenewdTextStyles.body.copyWith(
                        color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: '/${_freqLabel(renewal.frequency)}',
                      style: RenewdTextStyles.caption.copyWith(
                        color: RenewdColors.slate,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            Text(
              days == 0
                  ? 'Due today'
                  : days == 1
                      ? 'Tomorrow'
                      : '$days days left',
              style: RenewdTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _freqLabel(String? freq) {
    switch (freq) {
      case 'monthly':
        return 'month';
      case 'yearly':
        return 'year';
      case 'quarterly':
        return 'quarter';
      case 'weekly':
        return 'week';
      default:
        return 'year';
    }
  }
}

// ─── Renewals List ───────────────────────────────────

class _RenewalsListSection extends StatelessWidget {
  final DashboardController c;
  const _RenewalsListSection({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    // Exclude the top 2 upcoming renewals already shown in the cards above
    final upcomingCardIds = c.renewals
        .where((r) => r.daysRemaining >= 0)
        .take(2)
        .map((r) => r.id)
        .toSet();
    final all = c.filteredRenewals
        .where((r) => !upcomingCardIds.contains(r.id))
        .toList();
    final overdue = all.where((r) => r.daysRemaining < 0).toList();
    final thisWeek =
        all.where((r) => r.daysRemaining >= 0 && r.daysRemaining <= 7).toList();
    final thisMonth =
        all.where((r) => r.daysRemaining > 7 && r.daysRemaining <= 30).toList();
    final later = all.where((r) => r.daysRemaining > 30).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'All Renewals'),
        const SizedBox(height: RenewdSpacing.md),
        if (overdue.isNotEmpty)
          _UrgencyGroup(
              label: 'OVERDUE',
              color: RenewdColors.coralRed,
              items: overdue,
              c: c),
        if (thisWeek.isNotEmpty)
          _UrgencyGroup(
              label: 'THIS WEEK',
              color: RenewdColors.tangerine,
              items: thisWeek,
              c: c),
        if (thisMonth.isNotEmpty)
          _UrgencyGroup(
              label: 'THIS MONTH',
              color: RenewdColors.amber,
              items: thisMonth,
              c: c),
        if (later.isNotEmpty)
          _UrgencyGroup(
              label: 'UPCOMING',
              color: RenewdColors.emerald,
              items: later,
              c: c),
      ],
    );
  }
}

class _UrgencyGroup extends StatefulWidget {
  final String label;
  final Color color;
  final List<RenewalModel> items;
  final DashboardController c;

  const _UrgencyGroup({
    required this.label,
    required this.color,
    required this.items,
    required this.c,
  });

  @override
  State<_UrgencyGroup> createState() => _UrgencyGroupState();
}

class _UrgencyGroupState extends State<_UrgencyGroup> {
  static const _initialLimit = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visible =
        _showAll ? widget.items : widget.items.take(_initialLimit).toList();
    final hasMore = widget.items.length > _initialLimit;

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
                    color: widget.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: RenewdSpacing.sm),
              Text(widget.label,
                  style: RenewdTextStyles.sectionHeader
                      .copyWith(color: RenewdColors.slate)),
              const SizedBox(width: RenewdSpacing.sm),
              Text('${widget.items.length}',
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate)),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          ...visible.asMap().entries.map((entry) => AnimatedListItem(
                index: entry.key,
                child: _RenewalRow(
                  renewal: entry.value,
                  statusColor: widget.color,
                  onTap: () async {
                    final result = await Get.toNamed(AppRoutes.renewalDetail,
                        arguments: entry.value);
                    if (result == true) widget.c.fetchRenewals();
                  },
                ),
              )),
          if (hasMore && !_showAll)
            GestureDetector(
              onTap: () => setState(() => _showAll = true),
              child: Padding(
                padding: const EdgeInsets.only(top: RenewdSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Show ${widget.items.length - _initialLimit} more',
                      style: RenewdTextStyles.caption.copyWith(
                        color: RenewdColors.oceanBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: RenewdSpacing.xs),
                    Icon(LucideIcons.chevronDown,
                        size: 14, color: RenewdColors.oceanBlue),
                  ],
                ),
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.lgAll,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            BrandLogo(renewal: renewal, size: 44),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(renewal.name,
                      style: RenewdTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (renewal.amount != null)
                  Text(RenewdCurrency.format(renewal.amount!),
                      style: RenewdTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: RenewdSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        statusColor.withValues(alpha: RenewdOpacity.medium),
                    borderRadius: RenewdRadius.pillAll,
                  ),
                  child: Text(
                    _daysLabel(days),
                    style: RenewdTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
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

// ─── Section Header ──────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text('See all',
                style: RenewdTextStyles.caption.copyWith(
                  color: RenewdColors.oceanBlue,
                  fontWeight: FontWeight.w600,
                )),
          ),
      ],
    );
  }
}

// ─── Banner Carousel ─────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  final DashboardController c;
  const _BannerCarousel({required this.c});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  bool get _hasImageBanner => widget.c.banners
      .any((b) => b.imageUrl != null && b.imageUrl!.isNotEmpty);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banners = widget.c.banners;
      if (banners.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          SizedBox(
            height: _hasImageBanner ? 140 : 100,
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _BannerCard(banner: banners[i]),
              ),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: RenewdSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  banners.length,
                  (i) => Container(
                        width: _currentPage == i ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? RenewdColors.oceanBlue
                              : RenewdColors.slate.withValues(
                                  alpha: RenewdOpacity.moderate),
                          borderRadius: RenewdRadius.pillAll,
                        ),
                      )),
            ),
          ],
        ],
      );
    });
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  const _BannerCard({required this.banner});

  Color _parseColor(String? hex) {
    if (hex == null || hex.length != 7) return RenewdColors.oceanBlue;
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  bool get _hasImage => banner.imageUrl != null && banner.imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - RenewdSpacing.lg * 2;
    return _hasImage
        ? _buildImageBanner(cardWidth)
        : _buildGradientBanner(cardWidth);
  }

  Widget _buildImageBanner(double width) {
    final imageUrl = banner.imageUrl!.startsWith('/')
        ? '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}${banner.imageUrl}'
        : banner.imageUrl!;

    return GestureDetector(
      onTap: _handleTap,
      child: ClipRRect(
        borderRadius: RenewdRadius.lgAll,
        child: SizedBox(
          width: width,
          child: Image.network(imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildGradientBanner(width)),
        ),
      ),
    );
  }

  Widget _buildGradientBanner(double width) {
    final isDark =
        Theme.of(Get.context!).brightness == Brightness.dark;
    final startColor = _parseColor(banner.bgGradientStart ?? banner.bgColor);

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark
              ? startColor.withValues(alpha: 0.1)
              : startColor.withValues(alpha: 0.07),
          borderRadius: RenewdRadius.xlAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? startColor.withValues(alpha: 0.2)
                          : startColor.withValues(alpha: 0.12),
                      borderRadius: RenewdRadius.pillAll,
                    ),
                    child: Text(banner.type.toUpperCase(),
                        style: RenewdTextStyles.caption.copyWith(
                          color: startColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        )),
                  ),
                  const SizedBox(height: RenewdSpacing.sm),
                  Text(banner.title,
                      style: RenewdTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: RenewdSpacing.lg),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: startColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: startColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.arrowRight,
                  size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap() {
    if (banner.deeplink != null && banner.deeplink!.isNotEmpty) {
      Get.toNamed(banner.deeplink!);
    } else if (banner.externalUrl != null && banner.externalUrl!.isNotEmpty) {
      launchUrl(Uri.parse(banner.externalUrl!));
    }
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

// ─── Empty / Error ───────────────────────────────────

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
            style:
                RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
      ],
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
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(LucideIcons.sparkles,
                  size: 40, color: RenewdColors.oceanBlue),
              const SizedBox(height: RenewdSpacing.lg),
              Text('Welcome to Renewd!',
                  style: RenewdTextStyles.h2
                      .copyWith(fontWeight: FontWeight.w700)),
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
        const SizedBox(height: RenewdSpacing.xxl),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('GET STARTED',
              style: RenewdTextStyles.sectionHeader
                  .copyWith(color: RenewdColors.slate)),
        ),
        const SizedBox(height: RenewdSpacing.lg),
        _QuickStartTile(
          icon: LucideIcons.scanLine,
          title: 'Scan a document',
          subtitle: 'Point your camera at any policy or bill',
          color: RenewdColors.lavender,
          isDark: isDark,
          onTap: () async {
            final result = await Get.toNamed(AppRoutes.scanAdd);
            if (result == true) {
              Get.find<DashboardController>().fetchRenewals();
            }
          },
        ),
        const SizedBox(height: RenewdSpacing.md),
        _QuickStartTile(
          icon: LucideIcons.plus,
          title: 'Add a renewal manually',
          subtitle: 'Insurance, SIM, passport, subscription...',
          color: RenewdColors.oceanBlue,
          isDark: isDark,
          onTap: () => Get.toNamed(AppRoutes.addRenewal),
        ),
        const SizedBox(height: RenewdSpacing.md),
        _QuickStartTile(
          icon: LucideIcons.messageSquare,
          title: 'Ask AI Chat',
          subtitle: 'Get help organizing your renewals',
          color: RenewdColors.emerald,
          isDark: isDark,
          onTap: () => Get.toNamed(AppRoutes.chat),
        ),
      ],
    );
  }
}

class _QuickStartTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickStartTile({
    required this.icon,
    required this.title,
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
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.lgAll,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                  Text(title,
                      style: RenewdTextStyles.body
                          .copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
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
