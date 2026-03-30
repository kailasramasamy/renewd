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
import '../../data/models/renewal_model.dart';
import '../../widgets/brand_logo.dart';
import '../dashboard/dashboard_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _query = ''.obs;

  late final DashboardController _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = Get.find<DashboardController>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<RenewalModel> get _results {
    final q = _query.value.toLowerCase().trim();
    if (q.isEmpty) return [];
    return _dashboard.renewals.where((r) =>
        r.name.toLowerCase().contains(q) ||
        (r.provider?.toLowerCase().contains(q) ?? false) ||
        CategoryConfig.label(r.category).toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Search bar row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    RenewdSpacing.md, RenewdSpacing.sm, RenewdSpacing.lg, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, size: 22),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: RenewdSpacing.xs),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? RenewdColors.darkSlate
                              : RenewdColors.cloudGray,
                          borderRadius: RenewdRadius.pillAll,
                        ),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          onChanged: (v) => _query.value = v,
                          style: RenewdTextStyles.bodySmall,
                          decoration: InputDecoration(
                            hintText: 'Search renewals...',
                            hintStyle: RenewdTextStyles.bodySmall
                                .copyWith(color: RenewdColors.slate),
                            prefixIcon: Icon(LucideIcons.search,
                                size: 18, color: RenewdColors.slate),
                            suffixIcon: Obx(() => _query.value.isNotEmpty
                                ? IconButton(
                                    icon: Icon(LucideIcons.x,
                                        size: 16, color: RenewdColors.slate),
                                    onPressed: () {
                                      _controller.clear();
                                      _query.value = '';
                                    },
                                  )
                                : const SizedBox.shrink()),
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
                  ],
                ),
              ),
              const SizedBox(height: RenewdSpacing.md),
              // Results
              Expanded(
                child: Obx(() {
                  final q = _query.value.trim();
                  if (q.isEmpty) {
                    return _EmptyHint();
                  }
                  final results = _results;
                  if (results.isEmpty) {
                    return _NoResults();
                  }
                  return ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.lg),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final r = results[i];
                      return _ResultRow(
                        renewal: r,
                        onTap: () async {
                          final changed = await Get.toNamed(
                              AppRoutes.renewalDetail,
                              arguments: r);
                          if (changed == true) _dashboard.fetchRenewals();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final RenewalModel renewal;
  final VoidCallback onTap;

  const _ResultRow({required this.renewal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(days);

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
            BrandLogo(renewal: renewal, size: 40),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(renewal.name,
                      style: RenewdTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
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
                  Text(
                    RenewdCurrency.format(renewal.amount!),
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
                    color: statusColor
                        .withValues(alpha: RenewdOpacity.medium),
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

  Color _statusColor(int days) {
    if (days < 0) return RenewdColors.coralRed;
    if (days <= 7) return RenewdColors.tangerine;
    if (days <= 30) return RenewdColors.amber;
    return RenewdColors.emerald;
  }

  String _daysLabel(int days) {
    if (days < 0) return '${days.abs()}d overdue';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days <= 30) return 'in ${days}d';
    return RenewdDateUtils.formatShort(renewal.renewalDate);
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.search, size: 40, color: RenewdColors.slate),
          const SizedBox(height: RenewdSpacing.md),
          Text('Search by name, provider, or category',
              style: RenewdTextStyles.bodySmall
                  .copyWith(color: RenewdColors.slate)),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.searchX, size: 40, color: RenewdColors.slate),
          const SizedBox(height: RenewdSpacing.md),
          Text('No matches found',
              style: RenewdTextStyles.body
                  .copyWith(color: RenewdColors.slate)),
        ],
      ),
    );
  }
}
