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

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: RenewdRadius.xlAll,
        border: isDark
            ? Border.all(color: RenewdColors.steel, width: 0.5)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: RenewdRadius.xlAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: RenewdRadius.xlAll,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(RenewdSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
