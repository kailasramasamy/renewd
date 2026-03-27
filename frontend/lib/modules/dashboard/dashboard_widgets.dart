import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
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
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(12),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
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

class GroupCard extends StatelessWidget {
  final DashboardController c;
  final String groupName;
  const GroupCard({super.key, required this.c, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final groups = c.groupedRenewals;
    final items = groups[groupName] ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final first = items.first;
    final catColor = CategoryConfig.color(first.category);
    final catIcon = CategoryConfig.icon(first.category);
    final nextDays = first.daysRemaining;
    final totalAmount =
        items.fold<double>(0, (sum, r) => sum + (r.amount ?? 0));
    final isExpanded = c.isGroupExpanded(groupName);

    return Container(
      decoration: BoxDecoration(
        color: RenewdColors.darkSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RenewdColors.steel),
      ),
      child: Column(
        children: [
          GroupHeader(
            groupName: groupName,
            catColor: catColor,
            catIcon: catIcon,
            itemCount: items.length,
            nextDays: nextDays,
            totalAmount: totalAmount,
            isExpanded: isExpanded,
            onTap: () => c.toggleGroup(groupName),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? ExpandedItems(items: items, c: c)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class GroupHeader extends StatelessWidget {
  final String groupName;
  final Color catColor;
  final IconData catIcon;
  final int itemCount;
  final int nextDays;
  final double totalAmount;
  final bool isExpanded;
  final VoidCallback onTap;

  const GroupHeader({
    super.key,
    required this.groupName,
    required this.catColor,
    required this.catIcon,
    required this.itemCount,
    required this.nextDays,
    required this.totalAmount,
    required this.isExpanded,
    required this.onTap,
  });

  String get _subtitle {
    final daysText = nextDays < 0
        ? '${nextDays.abs()}d overdue'
        : nextDays == 0
            ? 'Today'
            : 'Next: $nextDays days';
    if (totalAmount > 0) {
      return '$daysText · ₹${totalAmount.toStringAsFixed(0)}/yr';
    }
    return daysText;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(catIcon, size: 16, color: catColor),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(groupName, style: RenewdTextStyles.h3),
                  Text(_subtitle,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
              ),
            ),
            CountBadge(count: itemCount, color: catColor),
            const SizedBox(width: RenewdSpacing.sm),
            Icon(
              isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
              size: 16,
              color: RenewdColors.slate,
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedItems extends StatelessWidget {
  final List<RenewalModel> items;
  final DashboardController c;
  const ExpandedItems({super.key, required this.items, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          RenewdSpacing.md, 0, RenewdSpacing.md, RenewdSpacing.md),
      child: Column(
        children: items
            .map((r) => Padding(
                  padding: const EdgeInsets.only(top: RenewdSpacing.sm),
                  child: RenewalListItem(
                    renewal: r,
                    onTap: () async {
                      final result = await Get.toNamed(
                          AppRoutes.renewalDetail,
                          arguments: r);
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
  const RenewalListItem({super.key, required this.renewal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = renewal.daysRemaining;
    final statusColor = RenewdDateUtils.statusColorFromDays(days);
    final statusType = _statusTypeFromDays(days);
    final catColor = CategoryConfig.color(renewal.category);
    final catIcon = CategoryConfig.icon(renewal.category);

    return RenewdCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RenewdSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(catIcon, size: 18, color: catColor),
          ),
          const SizedBox(width: RenewdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(renewal.name,
                    style: RenewdTextStyles.h3.copyWith(fontSize: 15)),
                if (renewal.provider != null) ...[
                  const SizedBox(height: RenewdSpacing.xs),
                  Text(renewal.provider!,
                      style: RenewdTextStyles.bodySmall
                          .copyWith(color: RenewdColors.slate)),
                ],
                const SizedBox(height: RenewdSpacing.xs),
                Text(RenewdDateUtils.formatDate(renewal.renewalDate),
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate)),
              ],
            ),
          ),
          const SizedBox(width: RenewdSpacing.sm),
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
