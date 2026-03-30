import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/category_config.dart';
import '../../widgets/brand_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/renewal_provider.dart';
import '../../app/routes/app_routes.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CategoriesController());
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.renewals.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(RenewdSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.layers, size: 48, color: RenewdColors.slate),
                  const SizedBox(height: RenewdSpacing.lg),
                  Text('No categories yet',
                      style: RenewdTextStyles.body
                          .copyWith(color: RenewdColors.slate)),
                  const SizedBox(height: RenewdSpacing.xs),
                  Text(
                    'Your renewals will be grouped here by category — insurance, subscriptions, utilities, and more.',
                    textAlign: TextAlign.center,
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
              RenewdSpacing.lg, 0, RenewdSpacing.lg, 100),
          children: [
            const SizedBox(height: RenewdSpacing.md),
            _SearchBar(c: c),
            const SizedBox(height: RenewdSpacing.lg),
            _CategoryChips(c: c),
            const SizedBox(height: RenewdSpacing.sm),
            _SubcategoryChips(c: c),
            const SizedBox(height: RenewdSpacing.lg),
            _SummaryBar(c: c),
            const SizedBox(height: RenewdSpacing.lg),
            ...c.filtered.map((r) => _RenewalRow(renewal: r, c: c)),
          ],
        );
      }),
    );
  }
}

// ─── Controller ──────────────────────────────────────

class CategoriesController extends GetxController {
  final _provider = RenewalProvider();
  final RxList<RenewalModel> renewals = <RenewalModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<RenewalCategory?> selectedCategory = Rx(null);
  final RxString selectedSubcategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRenewals();
  }

  Future<void> fetchRenewals() async {
    isLoading.value = true;
    try {
      renewals.assignAll(await _provider.getAll());
      renewals.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    } catch (e) {
      debugPrint('fetchRenewals failed: $e');
    }
    isLoading.value = false;
  }

  List<RenewalModel> get filtered {
    var result = renewals.toList();

    // Filter by category
    final cat = selectedCategory.value;
    if (cat != null) {
      result = result.where((r) => r.category == cat).toList();
    }

    // Filter by subcategory
    final sub = selectedSubcategory.value;
    if (sub.isNotEmpty) {
      result = result.where((r) => (r.groupName ?? '') == sub).toList();
    }

    // Filter by search
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((r) =>
          r.name.toLowerCase().contains(q) ||
          (r.provider?.toLowerCase().contains(q) ?? false) ||
          (r.groupName?.toLowerCase().contains(q) ?? false)).toList();
    }

    return result;
  }

  /// Get subcategories available for current category filter
  List<String> get availableSubcategories {
    final cat = selectedCategory.value;
    if (cat == null) return [];
    final items = renewals.where((r) => r.category == cat);
    final subs = <String>{};
    for (final r in items) {
      if (r.groupName != null && r.groupName!.isNotEmpty) {
        subs.add(r.groupName!);
      }
    }
    return subs.toList()..sort();
  }

  /// Categories that have at least one renewal
  List<RenewalCategory> get activeCategories =>
      RenewalCategory.values.where((cat) =>
          renewals.any((r) => r.category == cat)).toList();

  void selectCategory(RenewalCategory? cat) {
    if (selectedCategory.value == cat) {
      selectedCategory.value = null;
    } else {
      selectedCategory.value = cat;
    }
    selectedSubcategory.value = '';
  }

  void selectSubcategory(String sub) {
    if (selectedSubcategory.value == sub) {
      selectedSubcategory.value = '';
    } else {
      selectedSubcategory.value = sub;
    }
  }

  double get filteredSpend =>
      filtered.fold(0.0, (sum, r) => sum + (r.amount ?? 0));
}

// ─── Search Bar ──────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final CategoriesController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
          hintStyle:
              RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate),
          prefixIcon:
              Icon(LucideIcons.search, size: 18, color: RenewdColors.slate),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: false,
        ),
      ),
    );
  }
}

// ─── Category Chips ──────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final CategoriesController c;
  const _CategoryChips({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final active = c.activeCategories;
      if (active.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: active.length,
          separatorBuilder: (_, _) => const SizedBox(width: RenewdSpacing.sm),
          itemBuilder: (_, i) {
            final cat = active[i];
            final isSelected = c.selectedCategory.value == cat;
            final color = CategoryConfig.color(cat);

            return GestureDetector(
              onTap: () => c.selectCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: RenewdOpacity.medium)
                      : isDark ? RenewdColors.steel : RenewdColors.cloudGray,
                  borderRadius: RenewdRadius.pillAll,
                  border: Border.all(
                    color: isSelected ? color : isDark ? RenewdColors.darkBorder : RenewdColors.silver,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CategoryConfig.icon(cat), size: 14, color: isSelected ? color : RenewdColors.slate),
                    const SizedBox(width: RenewdSpacing.xs),
                    Text(
                      CategoryConfig.label(cat),
                      style: RenewdTextStyles.caption.copyWith(
                        color: isSelected ? color : RenewdColors.slate,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── Subcategory Chips ───────────────────────────────

class _SubcategoryChips extends StatelessWidget {
  final CategoriesController c;
  const _SubcategoryChips({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final subs = c.availableSubcategories;
      if (subs.isEmpty) return const SizedBox.shrink();

      final catColor = c.selectedCategory.value != null
          ? CategoryConfig.color(c.selectedCategory.value!)
          : RenewdColors.oceanBlue;

      return SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: subs.length,
          separatorBuilder: (_, _) => const SizedBox(width: RenewdSpacing.sm),
          itemBuilder: (_, i) {
            final sub = subs[i];
            final isSelected = c.selectedSubcategory.value == sub;

            return GestureDetector(
              onTap: () => c.selectSubcategory(sub),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.md, vertical: RenewdSpacing.xs),
                decoration: BoxDecoration(
                  color: isSelected
                      ? catColor.withValues(alpha: RenewdOpacity.light)
                      : Colors.transparent,
                  borderRadius: RenewdRadius.pillAll,
                  border: Border.all(
                    color: isSelected ? catColor : isDark ? RenewdColors.darkBorder : RenewdColors.silver,
                  ),
                ),
                child: Text(
                  sub,
                  style: RenewdTextStyles.caption.copyWith(
                    color: isSelected ? catColor : RenewdColors.slate,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── Summary Bar ─────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final CategoriesController c;
  const _SummaryBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = c.filtered;
      final spend = c.filteredSpend;
      return Row(
        children: [
          Text(
            '${items.length} renewal${items.length != 1 ? 's' : ''}',
            style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate),
          ),
          if (spend > 0) ...[
            Text(' · ', style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate)),
            Text(
              '${RenewdCurrency.symbol}${spend.toStringAsFixed(0)}',
              style: RenewdTextStyles.caption.copyWith(
                color: RenewdColors.emerald,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ─── Renewal Row (same layout as dashboard) ──────────

class _RenewalRow extends StatelessWidget {
  final RenewalModel renewal;
  final CategoriesController c;

  const _RenewalRow({required this.renewal, required this.c});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = RenewdDateUtils.statusColorFromDays(days);

    return GestureDetector(
      onTap: () async {
        final result =
            await Get.toNamed(AppRoutes.renewalDetail, arguments: renewal);
        if (result == true) c.fetchRenewals();
      },
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
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    [
                      renewal.provider ?? CategoryConfig.label(renewal.category),
                      if (renewal.groupName != null) renewal.groupName!,
                    ].join(' · '),
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
                    '${RenewdCurrency.symbol}${renewal.amount!.toStringAsFixed(0)}',
                    style: RenewdTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
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
