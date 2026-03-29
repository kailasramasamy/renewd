import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/renewal_model.dart';
import '../../widgets/minder_card.dart';
import '../../widgets/status_badge.dart';
import 'dashboard_controller.dart';

class CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const CountBadge({super.key, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: RenewdRadius.pillAll,
      ),
      child: Text('$count',
          style: RenewdTextStyles.caption.copyWith(color: color)),
    );
  }
}

class DueSoonCard extends StatelessWidget {
  final RenewalModel renewal;
  const DueSoonCard({super.key, required this.renewal});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusColor = RenewdDateUtils.statusColorFromDays(days);
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: RenewdColors.darkSlate,
        borderRadius: RenewdRadius.mdAll,
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(renewal.name,
              style: RenewdTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: RenewdSpacing.xs),
          Text(days == 0 ? 'Today' : '$days days',
              style: RenewdTextStyles.caption.copyWith(color: statusColor)),
          if (renewal.amount != null)
            Text('₹${renewal.amount!.toStringAsFixed(0)}',
                style: RenewdTextStyles.caption
                    .copyWith(color: RenewdColors.slate)),
        ],
      ),
    );
  }
}

/// Top-level category card (Insurance, Subscription, etc.)
class CategoryCard extends StatelessWidget {
  final DashboardController c;
  final RenewalCategory cat;
  final Map<String, List<RenewalModel>> groups;

  const CategoryCard({
    super.key,
    required this.c,
    required this.cat,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = c.isCategoryExpanded(cat);
      final totalItems = groups.values.fold<int>(0, (s, l) => s + l.length);
      final firstItem = _firstByUrgency();
      final catColor = CategoryConfig.color(cat);
      final catIcon = CategoryConfig.icon(cat);

      return Container(
        decoration: BoxDecoration(
          color: RenewdColors.darkSlate,
          borderRadius: RenewdRadius.xlAll,
          border: Border.all(color: RenewdColors.steel),
        ),
        child: Column(
          children: [
            _CategoryHeader(
              label: CategoryConfig.label(cat),
              color: catColor,
              icon: catIcon,
              itemCount: totalItems,
              nextDays: firstItem.daysRemaining,
              isExpanded: isExpanded,
              onTap: () => c.toggleCategory(cat),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? _SubGroupList(c: c, cat: cat, groups: groups)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  RenewalModel _firstByUrgency() {
    RenewalModel? first;
    for (final list in groups.values) {
      if (first == null || list.first.daysRemaining < first.daysRemaining) {
        first = list.first;
      }
    }
    return first!;
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final int itemCount;
  final int nextDays;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CategoryHeader({
    required this.label,
    required this.color,
    required this.icon,
    required this.itemCount,
    required this.nextDays,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysText = nextDays < 0
        ? '${nextDays.abs()}d overdue'
        : nextDays == 0
            ? 'Due today'
            : 'Next: $nextDays days';

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: RenewdTextStyles.h3),
                  Text(daysText,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
              ),
            ),
            CountBadge(count: itemCount, color: color),
            const SizedBox(width: RenewdSpacing.sm),
            Icon(
              isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16, color: RenewdColors.slate,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sub-groups within a category (Car Insurance, Health Insurance, etc.)
class _SubGroupList extends StatelessWidget {
  final DashboardController c;
  final RenewalCategory cat;
  final Map<String, List<RenewalModel>> groups;

  const _SubGroupList({
    required this.c,
    required this.cat,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => groups[a]!.first.daysRemaining
          .compareTo(groups[b]!.first.daysRemaining));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          RenewdSpacing.md, 0, RenewdSpacing.md, RenewdSpacing.md),
      child: Column(
        children: sortedKeys
            .map((g) => _SubGroupRow(c: c, cat: cat, groupName: g,
                items: groups[g]!))
            .toList(),
      ),
    );
  }
}

class _SubGroupRow extends StatelessWidget {
  final DashboardController c;
  final RenewalCategory cat;
  final String groupName;
  final List<RenewalModel> items;

  const _SubGroupRow({
    required this.c,
    required this.cat,
    required this.groupName,
    required this.items,
  });

  String get _uniqueKey => '${cat.name}:$groupName';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = c.isSubGroupExpanded(_uniqueKey);
      final nextDays = items.first.daysRemaining;
      final statusColor = RenewdDateUtils.statusColorFromDays(nextDays);

      return Column(
        children: [
          InkWell(
            onTap: () => c.toggleSubGroup(_uniqueKey),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: RenewdSpacing.sm, horizontal: RenewdSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 24,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: RenewdSpacing.md),
                  Expanded(
                    child: Text(groupName,
                        style: RenewdTextStyles.body
                            .copyWith(fontWeight: FontWeight.w500)),
                  ),
                  CountBadge(
                      count: items.length,
                      color: CategoryConfig.color(cat)),
                  const SizedBox(width: RenewdSpacing.sm),
                  Text(
                    nextDays < 0
                        ? '${nextDays.abs()}d late'
                        : '${nextDays}d',
                    style: RenewdTextStyles.caption.copyWith(
                        color: statusColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: RenewdSpacing.sm),
                  Icon(
                    isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronRight,
                    size: 14, color: RenewdColors.slate,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? _ExpandedRenewals(items: items, c: c)
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}

class _ExpandedRenewals extends StatelessWidget {
  final List<RenewalModel> items;
  final DashboardController c;
  const _ExpandedRenewals({required this.items, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: RenewdSpacing.xl),
      child: Column(
        children: items
            .map((r) => Padding(
                  padding: const EdgeInsets.only(top: RenewdSpacing.sm),
                  child: RenewalListItem(
                    renewal: r,
                    onTap: () async {
                      final result = await Get.toNamed(
                          AppRoutes.renewalDetail, arguments: r);
                      if (result == true) c.fetchRenewals();
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class RenewalListItem extends StatelessWidget {
  final RenewalModel renewal;
  final VoidCallback onTap;
  const RenewalListItem(
      {super.key, required this.renewal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusColor = RenewdDateUtils.statusColorFromDays(days);
    final statusType = _statusTypeFromDays(days);

    return RenewdCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RenewdSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(renewal.name,
                    style: RenewdTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                if (renewal.provider != null) ...[
                  const SizedBox(height: RenewdSpacing.xs),
                  Text(renewal.provider!,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
                if (renewal.amount != null) ...[
                  const SizedBox(height: RenewdSpacing.xs),
                  Text('₹${renewal.amount!.toStringAsFixed(0)}',
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                days < 0 ? '${days.abs()}d late' : '${days}d',
                style: RenewdTextStyles.caption.copyWith(
                    color: statusColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: RenewdSpacing.xs),
              StatusBadge(label: _statusLabel(days), status: statusType),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(int days) {
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Today';
    if (days <= 30) return '$days days';
    return RenewdDateUtils.formatShort(renewal.renewalDate);
  }

  StatusType _statusTypeFromDays(int days) {
    if (days < 0) return StatusType.critical;
    if (days <= 7) return StatusType.critical;
    if (days <= 30) return StatusType.urgent;
    if (days <= 60) return StatusType.warning;
    return StatusType.safe;
  }
}
