import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/category_config.dart';
import '../../widgets/brand_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
        return ListView(
          padding: const EdgeInsets.all(RenewdSpacing.lg),
          children: [
            ...RenewalCategory.values.map((cat) {
              final items = c.byCategory(cat);
              if (items.isEmpty) return const SizedBox.shrink();
              return _CategoryTile(cat: cat, items: items, c: c);
            }),
          ],
        );
      }),
    );
  }
}

class CategoriesController extends GetxController {
  final _provider = RenewalProvider();
  final RxList<RenewalModel> renewals = <RenewalModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxSet<String> expandedCategories = <String>{}.obs;

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
    } catch (_) {}
    isLoading.value = false;
  }

  List<RenewalModel> byCategory(RenewalCategory cat) =>
      renewals.where((r) => r.category == cat).toList();

  double spendForCategory(RenewalCategory cat) =>
      byCategory(cat).fold(0.0, (sum, r) => sum + (r.amount ?? 0));

  bool isExpanded(RenewalCategory cat) =>
      expandedCategories.contains(cat.name);

  void toggle(RenewalCategory cat) {
    if (expandedCategories.contains(cat.name)) {
      expandedCategories.remove(cat.name);
    } else {
      expandedCategories.add(cat.name);
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final RenewalCategory cat;
  final List<RenewalModel> items;
  final CategoriesController c;

  const _CategoryTile({
    required this.cat,
    required this.items,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryConfig.color(cat);
    final icon = CategoryConfig.icon(cat);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spend = c.spendForCategory(cat);

    return Obx(() {
      final expanded = c.isExpanded(cat);
      return Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => c.toggle(cat),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(RenewdSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 20, color: color),
                    ),
                    const SizedBox(width: RenewdSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(CategoryConfig.label(cat),
                              style: RenewdTextStyles.body
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '${items.length} item${items.length != 1 ? 's' : ''}${spend > 0 ? ' · ₹${spend.toStringAsFixed(0)}' : ''}',
                            style: RenewdTextStyles.caption
                                .copyWith(color: RenewdColors.slate),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 18,
                      color: RenewdColors.slate,
                    ),
                  ],
                ),
              ),
            ),
            // Expanded items
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    RenewdSpacing.lg, 0, RenewdSpacing.lg, RenewdSpacing.md),
                child: Column(
                  children: items.map((r) => _RenewalItem(renewal: r, c: c)).toList(),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _RenewalItem extends StatelessWidget {
  final RenewalModel renewal;
  final CategoriesController c;

  const _RenewalItem({required this.renewal, required this.c});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusColor = RenewdDateUtils.statusColorFromDays(days);

    return GestureDetector(
      onTap: () async {
        final result =
            await Get.toNamed(AppRoutes.renewalDetail, arguments: renewal);
        if (result == true) c.fetchRenewals();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: RenewdSpacing.sm),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: RenewdColors.darkBorder, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            BrandLogo(renewal: renewal, size: 32),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(renewal.name,
                      style: RenewdTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (renewal.provider != null)
                    Text(renewal.provider!,
                        style: RenewdTextStyles.caption
                            .copyWith(color: RenewdColors.slate, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (renewal.amount != null)
              Text('₹${renewal.amount!.toStringAsFixed(0)}',
                  style: RenewdTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: RenewdSpacing.md),
            Text(
              _daysLabel(days),
              style: RenewdTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: RenewdSpacing.xs),
            Icon(LucideIcons.chevronRight, size: 14, color: RenewdColors.slate),
          ],
        ),
      ),
    );
  }

  String _daysLabel(int days) {
    if (days < 0) return '${days.abs()}d late';
    if (days == 0) return 'Today';
    if (days == 1) return '1d';
    if (days <= 30) return '${days}d';
    return RenewdDateUtils.formatShort(renewal.renewalDate);
  }
}
