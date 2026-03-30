import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';

class RenewdCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const RenewdCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RenewdColors.darkSlate : Colors.white;

    return Material(
      color: bgColor,
      borderRadius: RenewdRadius.xlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: RenewdRadius.xlAll,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: RenewdRadius.xlAll,
            border: Border.all(
              color: isDark ? RenewdColors.steel : RenewdColors.silver,
              width: 1,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(RenewdSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
