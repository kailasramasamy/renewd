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

enum _Sort { due, cost, name }

// ─── Controller ──────────────────────────────────────

class CategoriesController extends GetxController {
  final _provider = RenewalProvider();
  final renewals = <RenewalModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = Rx<RenewalCategory?>(null);
  final selectedSubcategory = ''.obs;
  final sortMode = _Sort.due.obs;

  @override
  void onInit() { super.onInit(); fetchRenewals(); }

  Future<void> fetchRenewals() async {
    isLoading.value = true;
    try { renewals.assignAll(await _provider.getAll()); }
    catch (e) { debugPrint('fetchRenewals: $e'); }
    isLoading.value = false;
  }

  List<RenewalModel> get filtered {
    var r = renewals.toList();
    final cat = selectedCategory.value;
    if (cat != null) r = r.where((x) => x.category == cat).toList();
    final sub = selectedSubcategory.value;
    if (sub.isNotEmpty) r = r.where((x) => (x.groupName ?? '') == sub).toList();
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      r = r.where((x) =>
        x.name.toLowerCase().contains(q) ||
        (x.provider?.toLowerCase().contains(q) ?? false)).toList();
    }
    switch (sortMode.value) {
      case _Sort.due:  r.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
      case _Sort.cost: r.sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0));
      case _Sort.name: r.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return r;
  }

  List<String> get availableSubcategories {
    final cat = selectedCategory.value;
    if (cat == null) return [];
    return renewals.where((r) => r.category == cat)
        .map((r) => r.groupName ?? '').where((s) => s.isNotEmpty).toSet().toList()..sort();
  }

  List<RenewalCategory> get activeCategories =>
      RenewalCategory.values.where((c) => renewals.any((r) => r.category == c)).toList();

  void selectCategory(RenewalCategory? cat) {
    selectedCategory.value = selectedCategory.value == cat ? null : cat;
    selectedSubcategory.value = '';
  }

  void selectSubcategory(String s) =>
      selectedSubcategory.value = selectedSubcategory.value == s ? '' : s;

  double get filteredAnnualCost => filtered.fold(0.0, (s, r) => s + _annualCost(r));

  double _annualCost(RenewalModel r) {
    final amount = r.amount ?? 0;
    switch (r.frequency) {
      case 'monthly': return amount * 12;
      case 'quarterly': return amount * 4;
      case 'yearly': return amount;
      case 'weekly': return amount * 52;
      case 'custom':
        final days = r.frequencyDays ?? 365;
        return amount * (365 / days);
      default: return amount;
    }
  }

  Map<String, List<RenewalModel>> get groupedByDue {
    final wk = <RenewalModel>[], mo = <RenewalModel>[], lt = <RenewalModel>[];
    for (final r in filtered) {
      final d = r.daysRemaining;
      if (d <= 7) { wk.add(r); } else if (d <= 30) { mo.add(r); } else { lt.add(r); }
    }
    return {
      if (wk.isNotEmpty) 'THIS WEEK': wk,
      if (mo.isNotEmpty) 'THIS MONTH': mo,
      if (lt.isNotEmpty) 'LATER': lt,
    };
  }
}

// ─── Screen ──────────────────────────────────────────

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CategoriesController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? RenewdColors.charcoal : RenewdColors.softWhite,
        body: Obx(() {
          if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (c.renewals.isEmpty) return _emptyState();
          return _Body(c: c);
        }),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(RenewdSpacing.xl),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.layers, size: 48, color: RenewdColors.slate),
        const SizedBox(height: RenewdSpacing.lg),
        Text('No renewals yet',
            style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.xs),
        Text('Your renewals will appear here grouped by category.',
            textAlign: TextAlign.center,
            style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate, height: 1.5)),
      ]),
    ),
  );
}

// ─── Body ────────────────────────────────────────────

class _Body extends StatelessWidget {
  final CategoriesController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDue = c.sortMode.value == _Sort.due;
      final items = c.filtered;
      final grouped = isDue ? c.groupedByDue : null;
      final hasSubs = c.availableSubcategories.isNotEmpty;

      return CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          _headerSliver(c),
          SliverToBoxAdapter(child: _controls(context, c, hasSubs)),
          if (grouped != null)
            _GroupedSliver(grouped: grouped, c: c)
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  RenewdSpacing.lg, 0, RenewdSpacing.lg, 100),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => _RenewalRow(renewal: items[i], c: c),
                childCount: items.length,
              )),
            ),
        ],
      );
    });
  }

  Widget _headerSliver(CategoriesController c) => SliverToBoxAdapter(
    child: Obx(() {
      final n = c.filtered.length;
      final cost = c.filteredAnnualCost;
      final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
      return Padding(
        padding: EdgeInsets.fromLTRB(
            RenewdSpacing.lg,
            MediaQuery.of(Get.context!).padding.top + RenewdSpacing.lg,
            RenewdSpacing.lg,
            RenewdSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Renewals', style: RenewdTextStyles.h2),
                const SizedBox(height: RenewdSpacing.sm),
                Row(children: [
                  _HeaderChip(
                    label: '$n renewal${n != 1 ? 's' : ''}',
                    icon: LucideIcons.layers,
                    isDark: isDark,
                  ),
                  if (cost > 0) ...[
                    const SizedBox(width: RenewdSpacing.sm),
                    _HeaderChip(
                      label: '${RenewdCurrency.format(cost)} / yr',
                      icon: LucideIcons.indianRupee,
                      isDark: isDark,
                    ),
                  ],
                ]),
              ]),
            ),
            _SortButton(c: c),
          ],
        ),
      );
    }),
  );

  Widget _controls(BuildContext ctx, CategoriesController c, bool hasSubs) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(
          RenewdSpacing.lg, 0, RenewdSpacing.lg, RenewdSpacing.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SearchBar(c: c),
        const SizedBox(height: RenewdSpacing.md),
        _CategoryChips(c: c),
        if (hasSubs) ...[const SizedBox(height: RenewdSpacing.sm), _SubcategoryChips(c: c)],
        const SizedBox(height: RenewdSpacing.sm),
      ]),
    );
}

// ─── Search Bar ──────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final CategoriesController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 44,
      child: TextField(
        onChanged: (v) => c.searchQuery.value = v,
        style: RenewdTextStyles.bodySmall,
        decoration: InputDecoration(
          hintText: 'Search renewals...',
          hintStyle: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate),
          prefixIcon: Icon(LucideIcons.search, size: 18, color: RenewdColors.slate),
          filled: true,
          fillColor: isDark ? RenewdColors.darkSlate : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RenewdRadius.md),
            borderSide: BorderSide(color: isDark ? RenewdColors.darkBorder : RenewdColors.cloudGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RenewdRadius.md),
            borderSide: BorderSide(color: isDark ? RenewdColors.darkBorder : RenewdColors.cloudGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RenewdRadius.md),
            borderSide: BorderSide(
                color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.half)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

// ─── Category Chips ──────────────────────────────────

class _CategoryChips extends StatefulWidget {
  final CategoriesController c;
  const _CategoryChips({required this.c});

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  final _scrollController = ScrollController();

  CategoriesController get c => widget.c;

  @override
  void initState() {
    super.initState();
    // Scroll on initial build if a category is already selected
    if (c.selectedCategory.value != null) {
      Future.delayed(const Duration(milliseconds: 150), _scrollToSelected);
    }
    c.selectedCategory.listen((_) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToSelected);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    if (!mounted) return;
    final cat = c.selectedCategory.value;
    if (cat == null) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
      return;
    }
    // Scroll to end for last category, otherwise estimate position
    final active = c.activeCategories;
    final idx = active.indexOf(cat);
    if (idx < 0) return;
    if (idx == active.length - 1) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Estimate offset: "All" chip ~70px + each chip ~110px avg
      final estimate = (idx + 1) * 110.0;
      final target = (estimate - 40).clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final active = c.activeCategories;
      if (active.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 34,
        child: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: [
            _chip(context, isDark, 'All', c.renewals.length,
                LucideIcons.layoutGrid, RenewdColors.lavender,
                c.selectedCategory.value == null, () => c.selectCategory(null)),
            const SizedBox(width: RenewdSpacing.sm),
            ...active.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(right: RenewdSpacing.sm),
              child: _chip(context, isDark,
                CategoryConfig.label(entry.value),
                c.renewals.where((r) => r.category == entry.value).length,
                CategoryConfig.icon(entry.value), CategoryConfig.color(entry.value),
                c.selectedCategory.value == entry.value,
                () => c.selectCategory(entry.value)),
            )),
          ],
        ),
      );
    });
  }

  Widget _chip(BuildContext ctx, bool isDark, String label, int count,
      IconData icon, Color color, bool sel, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.md, vertical: RenewdSpacing.xs),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: RenewdOpacity.medium)
              : isDark ? RenewdColors.steel : RenewdColors.cloudGray,
          borderRadius: RenewdRadius.pillAll,
          border: Border.all(
            color: sel ? color : isDark ? RenewdColors.darkBorder : RenewdColors.silver,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: sel ? color : RenewdColors.slate),
          const SizedBox(width: 5),
          Text(label, style: RenewdTextStyles.caption.copyWith(
            color: sel ? color : RenewdColors.slate,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
          const SizedBox(width: 4),
          Text('$count', style: RenewdTextStyles.caption.copyWith(
            color: sel ? color : RenewdColors.warmGray, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
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
      final cc = c.selectedCategory.value != null
          ? CategoryConfig.color(c.selectedCategory.value!) : RenewdColors.oceanBlue;
      return SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: subs.length,
          separatorBuilder: (context, i) => const SizedBox(width: RenewdSpacing.sm),
          itemBuilder: (_, i) {
            final sel = c.selectedSubcategory.value == subs[i];
            return GestureDetector(
              onTap: () => c.selectSubcategory(subs[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.md, vertical: RenewdSpacing.xs),
                decoration: BoxDecoration(
                  color: sel ? cc.withValues(alpha: RenewdOpacity.light) : Colors.transparent,
                  borderRadius: RenewdRadius.pillAll,
                  border: Border.all(
                      color: sel ? cc : isDark ? RenewdColors.darkBorder : RenewdColors.silver),
                ),
                child: Text(subs[i], style: RenewdTextStyles.caption.copyWith(
                  color: sel ? cc : RenewdColors.slate,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── Header Chip ─────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _HeaderChip({required this.label, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.md, vertical: RenewdSpacing.xs + 1),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.steel : RenewdColors.deepNavy.withValues(alpha: 0.08),
        borderRadius: RenewdRadius.pillAll,
        border: Border.all(
          color: isDark ? RenewdColors.darkBorder : RenewdColors.deepNavy.withValues(alpha: 0.15),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: isDark ? RenewdColors.slate : RenewdColors.deepNavy.withValues(alpha: 0.6)),
        const SizedBox(width: 5),
        Text(label, style: RenewdTextStyles.caption.copyWith(
          color: isDark ? RenewdColors.silver : RenewdColors.deepNavy,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        )),
      ]),
    );
  }
}

// ─── Sort Button ─────────────────────────────────────

class _SortButton extends StatelessWidget {
  final CategoriesController c;
  const _SortButton({required this.c});

  static const _labels = {_Sort.due: 'Due date', _Sort.cost: 'Cost', _Sort.name: 'Name (A–Z)'};
  static const _icons = {_Sort.due: LucideIcons.clock, _Sort.cost: LucideIcons.arrowDownUp, _Sort.name: LucideIcons.arrowDownAZ};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final current = c.sortMode.value;
      return GestureDetector(
        onTap: () => _showSortMenu(context, isDark),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
            borderRadius: BorderRadius.circular(RenewdRadius.sm),
            border: Border.all(
              color: current != _Sort.due
                  ? RenewdColors.lavender
                  : (isDark ? RenewdColors.darkBorder : RenewdColors.mist),
            ),
          ),
          child: Icon(
            LucideIcons.arrowUpDown,
            size: 18,
            color: current != _Sort.due ? RenewdColors.lavender : RenewdColors.slate,
          ),
        ),
      );
    });
  }

  void _showSortMenu(BuildContext context, bool isDark) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    showMenu<_Sort>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 120,
        offset.dy + renderBox.size.height + 4,
        offset.dx + renderBox.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: RenewdRadius.mdAll),
      color: isDark ? RenewdColors.darkSlate : Colors.white,
      items: _Sort.values.map((mode) {
        final active = c.sortMode.value == mode;
        return PopupMenuItem(
          value: mode,
          child: Row(children: [
            Icon(_icons[mode], size: 16,
                color: active ? RenewdColors.lavender : RenewdColors.slate),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Text(_labels[mode]!, style: RenewdTextStyles.bodySmall.copyWith(
                color: active ? RenewdColors.lavender : null,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              )),
            ),
            if (active)
              Icon(LucideIcons.check, size: 16, color: RenewdColors.lavender),
          ]),
        );
      }).toList(),
    ).then((value) {
      if (value != null) c.sortMode.value = value;
    });
  }
}

// ─── Grouped Sliver ──────────────────────────────────

class _GroupedSliver extends StatelessWidget {
  final Map<String, List<RenewalModel>> grouped;
  final CategoriesController c;
  const _GroupedSliver({required this.grouped, required this.c});

  @override
  Widget build(BuildContext context) {
    final sections = grouped.entries.toList();
    final total = sections.fold(0, (s, e) => s + 1 + e.value.length);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(RenewdSpacing.lg, 0, RenewdSpacing.lg, 100),
      sliver: SliverList(delegate: SliverChildBuilderDelegate((_, idx) {
        int offset = 0;
        for (final entry in sections) {
          if (idx == offset) return _SectionHeader(label: entry.key, count: entry.value.length);
          offset++;
          final i = idx - offset;
          if (i < entry.value.length) return _RenewalRow(renewal: entry.value[i], c: c);
          offset += entry.value.length;
        }
        return null;
      }, childCount: total)),
    );
  }
}

// ─── Section Header ──────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label; final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: RenewdSpacing.lg, bottom: RenewdSpacing.sm),
    child: Row(children: [
      Text(label, style: RenewdTextStyles.sectionHeader.copyWith(color: RenewdColors.slate)),
      const SizedBox(width: RenewdSpacing.sm),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: RenewdColors.slate.withValues(alpha: RenewdOpacity.light),
          borderRadius: RenewdRadius.pillAll,
        ),
        child: Text('$count', style: RenewdTextStyles.caption
            .copyWith(color: RenewdColors.slate, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}

// ─── Renewal Row ─────────────────────────────────────

class _RenewalRow extends StatelessWidget {
  final RenewalModel renewal;
  final CategoriesController c;
  const _RenewalRow({required this.renewal, required this.c});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sc = RenewdDateUtils.statusColorFromDays(days);
    final subline = [
      renewal.provider ?? CategoryConfig.label(renewal.category),
      if (renewal.groupName != null) renewal.groupName!,
    ].join(' · ');

    return GestureDetector(
      onTap: () async {
        final res = await Get.toNamed(AppRoutes.renewalDetail, arguments: renewal);
        if (res == true) c.fetchRenewals();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.mdAll,
          border: Border.all(color: isDark ? RenewdColors.darkBorder : RenewdColors.cloudGray),
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            // 3px urgency bar
            Container(width: 3, decoration: BoxDecoration(
              color: sc,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(RenewdRadius.md),
                bottomLeft: Radius.circular(RenewdRadius.md),
              ),
            )),
            const SizedBox(width: RenewdSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: RenewdSpacing.md),
              child: BrandLogo(renewal: renewal, size: 40),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: RenewdSpacing.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(renewal.name, style: RenewdTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subline, style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  RenewdSpacing.sm, RenewdSpacing.md, RenewdSpacing.md, RenewdSpacing.md),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                if (renewal.amount != null)
                  Text(RenewdCurrency.format(renewal.amount!),
                      style: RenewdTextStyles.subtitle
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                _duePill(days, sc),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _duePill(int days, Color sc) {
    final String label;
    if (days < 0) {
      label = '${days.abs()}d overdue';
    } else if (days == 0) {
      label = 'Today';
    } else if (days == 1) {
      label = 'Tomorrow';
    } else if (days <= 30) {
      label = 'in ${days}d';
    } else {
      label = RenewdDateUtils.formatShort(renewal.renewalDate);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: sc.withValues(alpha: RenewdOpacity.medium),
        borderRadius: RenewdRadius.pillAll,
      ),
      child: Text(label, style: RenewdTextStyles.caption.copyWith(
          color: sc, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}
