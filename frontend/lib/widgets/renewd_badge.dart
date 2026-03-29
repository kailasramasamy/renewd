import 'package:flutter/material.dart';
import '../core/theme/app_opacity.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class RenewdBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const RenewdBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RenewdSpacing.sm,
        vertical: RenewdSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: RenewdOpacity.medium),
        borderRadius: RenewdRadius.pillAll,
      ),
      child: Text(
        label,
        style: RenewdTextStyles.caption
            .copyWith(color: textColor ?? color),
      ),
    );
  }
}
