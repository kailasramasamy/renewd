import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/utils/currency.dart';
import '../dashboard/dashboard_controller.dart';
import 'chat_tokens.dart';

class ChatEmptyState extends StatelessWidget {
  final bool isDark;
  final void Function(String) onSuggestion;

  const ChatEmptyState({
    super.key,
    required this.isDark,
    required this.onSuggestion,
  });

  static const _suggestions = [
    ('What\'s due this week?', 'See upcoming renewals'),
    ('How much am I spending monthly?', 'Total monthly cost'),
    ('Show my most expensive renewal', 'Biggest line item'),
    ('Which renewals expire next month?', 'Plan ahead'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(RenewdSpacing.lg, RenewdSpacing.xl,
          RenewdSpacing.lg, RenewdSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroTile(isDark: isDark),
          const SizedBox(height: RenewdSpacing.lg),
          _SnapshotCard(isDark: isDark),
          const SizedBox(height: RenewdSpacing.xl),
          Row(children: [
            Text('SUGGESTED',
                style: RenewdTextStyles.sectionHeader
                    .copyWith(color: RenewdColors.warmGray)),
            const SizedBox(width: RenewdSpacing.sm),
            Text('· tap to ask',
                style: RenewdTextStyles.caption.copyWith(
                    color: RenewdColors.warmGray
                        .withValues(alpha: RenewdOpacity.strong))),
          ]),
          const SizedBox(height: RenewdSpacing.md),
          ..._suggestions.map((s) => _SuggestionRow(
                title: s.$1,
                hint: s.$2,
                isDark: isDark,
                onTap: () => onSuggestion(s.$1),
              )),
        ],
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  final bool isDark;
  const _HeroTile({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RenewdSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          RenewdColors.lavender.withValues(alpha: RenewdOpacity.light),
          RenewdColors.accent2.withValues(alpha: RenewdOpacity.subtle),
        ]),
        borderRadius: RenewdRadius.lgAll,
        border: Border.all(
            color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.medium)),
      ),
      child: Row(children: [
        ShaderMask(
          shaderCallback: (b) => kChatGradient.createShader(b),
          child: const Icon(LucideIcons.sparkles, size: 28, color: Colors.white),
        ),
        const SizedBox(width: RenewdSpacing.md),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ask about your renewals',
                    style: RenewdTextStyles.subtitle.copyWith(
                        color: isDark
                            ? RenewdColors.warmWhite
                            : RenewdColors.deepNavy)),
                const SizedBox(height: 2),
                Text('Your AI renewal assistant is ready',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.warmGray)),
              ]),
        ),
      ]),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final bool isDark;
  const _SnapshotCard({required this.isDark});

  DashboardController? _dc() {
    try { return Get.find<DashboardController>(); } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final thisWeek = _dc()?.renewals
              .where((r) => r.daysRemaining >= 0 && r.daysRemaining <= 7)
              .toList() ?? [];
      final total = thisWeek.fold<double>(0, (s, r) => s + (r.amount ?? 0));
      final top3 = thisWeek.take(3).toList();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.lgAll,
          border: Border.all(
              color: isDark ? RenewdColors.darkBorder : RenewdColors.mist),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('THIS WEEK',
              style: RenewdTextStyles.sectionHeader
                  .copyWith(color: RenewdColors.tangerine)),
          const SizedBox(height: RenewdSpacing.sm),
          Row(children: [
            Text(
              total > 0 ? RenewdCurrency.format(total) : 'Nothing due',
              style: RenewdTextStyles.h3.copyWith(
                  color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy),
            ),
            if (thisWeek.isNotEmpty) ...[
              const SizedBox(width: RenewdSpacing.sm),
              _CountBadge(count: thisWeek.length),
            ],
          ]),
          if (top3.isNotEmpty) ...[
            const SizedBox(height: RenewdSpacing.md),
            Wrap(
              spacing: RenewdSpacing.xs,
              runSpacing: RenewdSpacing.xs,
              children: top3.map((r) => _Chip(name: r.name, isDark: isDark)).toList(),
            ),
          ] else ...[
            const SizedBox(height: RenewdSpacing.sm),
            Text("No renewals this week — you're clear!",
                style: RenewdTextStyles.caption.copyWith(color: RenewdColors.warmGray)),
          ],
        ]),
      );
    });
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: RenewdColors.tangerine.withValues(alpha: RenewdOpacity.light),
          borderRadius: RenewdRadius.smAll,
        ),
        child: Text(
          '$count renewal${count == 1 ? '' : 's'}',
          style: RenewdTextStyles.caption.copyWith(color: RenewdColors.tangerine),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String name;
  final bool isDark;
  const _Chip({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
          borderRadius: RenewdRadius.smAll,
        ),
        child: Text(name,
            style: RenewdTextStyles.caption.copyWith(
                color: isDark ? RenewdColors.silver : RenewdColors.deepNavy)),
      );
}

class _SuggestionRow extends StatelessWidget {
  final String title;
  final String hint;
  final bool isDark;
  final VoidCallback onTap;
  const _SuggestionRow(
      {required this.title,
      required this.hint,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
          padding: const EdgeInsets.symmetric(
              horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? RenewdColors.darkSlate : Colors.white,
            borderRadius: RenewdRadius.mdAll,
            border: Border.all(
                color: isDark ? RenewdColors.darkBorder : RenewdColors.mist),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: RenewdTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? RenewdColors.warmWhite
                                : RenewdColors.deepNavy)),
                    const SizedBox(height: 2),
                    Text(hint,
                        style: RenewdTextStyles.caption
                            .copyWith(color: RenewdColors.warmGray)),
                  ]),
            ),
            Icon(LucideIcons.arrowRight,
                size: 16,
                color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.strong)),
          ]),
        ),
      );
}
