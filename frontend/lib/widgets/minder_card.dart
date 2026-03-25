import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class MinderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const MinderCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? MinderColors.darkSlate : Colors.white;
    final shadowColor = isDark ? Colors.transparent : MinderColors.mist;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? Border.all(color: MinderColors.steel, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(MinderSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
