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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
                RenewdSpacing.lg, RenewdSpacing.sm, RenewdSpacing.lg, 100),
            children: [
              _SearchBar(c: c),
              if (c.banners.isNotEmpty) ...[
                const SizedBox(height: RenewdSpacing.lg),
                _BannerCarousel(c: c),
              ],
              const SizedBox(height: RenewdSpacing.lg),
              _StatsRow(c: c),
              const SizedBox(height: RenewdSpacing.xl),
              if (c.filteredRenewals.isEmpty && c.searchQuery.value.isEmpty)
                _EmptyState()
              else if (c.filteredRenewals.isEmpty)
                _NoResults()
              else
                _SectionedList(c: c),
            ],
          ),
        );
      })),
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

// ─── Search Bar ───────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final DashboardController c;
  const _SearchBar({required this.c});

  String get _greeting {
    final storage = Get.find<StorageService>();
    final userData = storage.readUserData();
    final name = userData?['name'] as String?;
    if (name != null && name.isNotEmpty) {
      final firstName = name.split(' ').first;
      return 'Hi, $firstName';
    }
    return 'Hi there';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Profile row
        Padding(
          padding: const EdgeInsets.only(top: RenewdSpacing.sm),
          child: Row(
            children: [
              Semantics(
                label: 'Profile',
                button: true,
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profile),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
                        child: Icon(LucideIcons.user, size: 18,
                            color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: RenewdSpacing.md),
              Expanded(
                child: Text(_greeting,
                    style: RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w600)),
              ),
              Obx(() {
                final count = c.unreadNotificationCount.value;
                return IconButton(
                  tooltip: 'Notifications',
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count',
                        style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: RenewdColors.coralRed,
                    child: Icon(LucideIcons.bell,
                        size: 22, color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
                  ),
                  onPressed: () async {
                    await Get.toNamed(AppRoutes.notificationInbox);
                    c.fetchUnreadCount();
                  },
                );
              }),
            ],
          ),
        ),
        // Search field
        const SizedBox(height: RenewdSpacing.md),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.darkSlate : RenewdColors.cloudGray,
            borderRadius: RenewdRadius.pillAll,
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: false,
            ),
          ),
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
            height: 140,
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
              children: List.generate(banners.length, (i) => Container(
                width: _currentPage == i ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? RenewdColors.oceanBlue
                      : RenewdColors.slate.withValues(alpha: RenewdOpacity.moderate),
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

    if (_hasImage) {
      return _buildImageBanner(cardWidth);
    }
    return _buildGradientBanner(cardWidth);
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
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildGradientBanner(width),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBanner(double width) {
    final startColor = _parseColor(banner.bgGradientStart ?? banner.bgColor);
    final endColor = _parseColor(banner.bgGradientEnd ?? banner.bgColor);

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          borderRadius: RenewdRadius.lgAll,
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: RenewdOpacity.subtle),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: 40,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: RenewdOpacity.subtle),
                ),
              ),
            ),
            // Content
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RenewdSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: RenewdOpacity.medium),
                          borderRadius: RenewdRadius.pillAll,
                        ),
                        child: Text(
                          banner.type.toUpperCase(),
                          style: RenewdTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: RenewdSpacing.sm),
                      Text(banner.title,
                          style: RenewdTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (banner.subtitle != null) ...[
                        const SizedBox(height: RenewdSpacing.xs),
                        Text(banner.subtitle!,
                            style: RenewdTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: RenewdOpacity.strong),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: RenewdSpacing.md),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: RenewdOpacity.medium),
                    borderRadius: RenewdRadius.mdAll,
                  ),
                  child: Icon(LucideIcons.arrowRight, size: 22, color: Colors.white),
                ),
              ],
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

// ─── Stats ────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '${c.dueThisMonth}',
          label: 'Due',
          icon: LucideIcons.clock,
          color: c.dueThisMonth > 0 ? RenewdColors.tangerine : RenewdColors.slate,
        ),
        const SizedBox(width: RenewdSpacing.sm),
        _StatCard(
          value: '${c.totalActive}',
          label: 'Active',
          icon: LucideIcons.checkCircle,
          color: RenewdColors.oceanBlue,
        ),
        const SizedBox(width: RenewdSpacing.sm),
        _StatCard(
          value: '${RenewdCurrency.symbol}${c.monthlySpend.toStringAsFixed(0)}',
          label: 'Monthly',
          icon: LucideIcons.wallet,
          color: RenewdColors.emerald,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(RenewdSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: RenewdOpacity.subtle)
              : color.withValues(alpha: RenewdOpacity.light),
          borderRadius: RenewdRadius.lgAll,
          border: Border.all(
            color: isDark
                ? color.withValues(alpha: RenewdOpacity.light)
                : color.withValues(alpha: RenewdOpacity.medium),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            Text(value,
                style: RenewdTextStyles.h3.copyWith(
                  color: isDark ? color : color.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label.toUpperCase(),
                style: RenewdTextStyles.caption.copyWith(
                  color: color.withValues(alpha: RenewdOpacity.strong),
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

class _Section extends StatefulWidget {
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
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  static const _initialLimit = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visible = _showAll
        ? widget.items
        : widget.items.take(_initialLimit).toList();
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
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: RenewdSpacing.sm),
              Text(widget.label,
                  style: RenewdTextStyles.sectionHeader.copyWith(
                    color: RenewdColors.slate,
                  )),
              const SizedBox(width: RenewdSpacing.sm),
              Text('${widget.items.length}',
                  style: RenewdTextStyles.caption.copyWith(
                    color: RenewdColors.slate,
                  )),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          ...visible.asMap().entries.map((entry) => AnimatedListItem(
                index: entry.key,
                child: _RenewalRow(
                  renewal: entry.value,
                  statusColor: widget.color,
                  onTap: () async {
                    final result = await Get.toNamed(
                        AppRoutes.renewalDetail,
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
        padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg,
          vertical: RenewdSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.lgAll,
          border: Border(
            left: BorderSide(color: statusColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            // Brand logo or category icon
            BrandLogo(renewal: renewal, size: 40),
            const SizedBox(width: RenewdSpacing.md),
            // Name + provider
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
            // Amount + status pill
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (renewal.amount != null)
                  Text('${RenewdCurrency.symbol}${renewal.amount!.toStringAsFixed(0)}',
                      style: RenewdTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: RenewdOpacity.medium),
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

// ─── Add options sheet ────────────────────────────────

Future<void> _showAddOptions(
    BuildContext context, DashboardController c) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(RenewdRadius.xl)),
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
                color: RenewdColors.slate.withValues(alpha: RenewdOpacity.moderate),
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
              width: 40, height: 40,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? RenewdColors.darkSlate : Colors.white;

    return Column(
      children: [
        const SizedBox(height: RenewdSpacing.xl),
        // Welcome message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: RenewdSpacing.xl,
            vertical: RenewdSpacing.xxl,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: RenewdRadius.lgAll,
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
                'Track insurance, subscriptions, government docs and never miss a renewal again. Your data is encrypted with AES-256.',
                textAlign: TextAlign.center,
                style: RenewdTextStyles.bodySmall
                    .copyWith(color: RenewdColors.slate, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: RenewdSpacing.xxl),
        // Quick-start suggestions
        Align(
          alignment: Alignment.centerLeft,
          child: Text('GET STARTED',
              style: RenewdTextStyles.sectionHeader.copyWith(
                color: RenewdColors.slate,
              )),
        ),
        const SizedBox(height: RenewdSpacing.lg),
        AnimatedListItem(
          index: 0,
          child: _QuickStartTile(
            icon: LucideIcons.scanLine,
            title: 'Scan a document',
            subtitle: 'Point your camera at any policy or bill',
            color: RenewdColors.lavender,
            isDark: isDark,
            onTap: () async {
              final result = await Get.toNamed(AppRoutes.scanAdd);
              if (result == true) Get.find<DashboardController>().fetchRenewals();
            },
          ),
        ),
        const SizedBox(height: RenewdSpacing.md),
        AnimatedListItem(
          index: 1,
          child: _QuickStartTile(
            icon: LucideIcons.plus,
            title: 'Add a renewal manually',
            subtitle: 'Insurance, SIM, passport, subscription...',
            color: RenewdColors.oceanBlue,
            isDark: isDark,
            onTap: () => Get.toNamed(AppRoutes.addRenewal),
          ),
        ),
        const SizedBox(height: RenewdSpacing.md),
        AnimatedListItem(
          index: 2,
          child: _QuickStartTile(
            icon: LucideIcons.messageSquare,
            title: 'Ask AI Chat',
            subtitle: 'Get help organizing your renewals',
            color: RenewdColors.emerald,
            isDark: isDark,
            onTap: () => Get.toNamed(AppRoutes.chat),
          ),
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
