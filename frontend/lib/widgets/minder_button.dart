import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum MinderButtonVariant { primary, secondary, danger }

class MinderButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final MinderButtonVariant variant;

  const MinderButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = MinderButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.$1,
          foregroundColor: colors.$2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.$2,
                ),
              )
            : _buildContent(colors.$2),
      ),
    );
  }

  Widget _buildContent(Color fgColor) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: MinderTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      );

  (Color, Color) _resolveColors() {
    switch (variant) {
      case MinderButtonVariant.primary:
        return (MinderColors.oceanBlue, Colors.white);
      case MinderButtonVariant.secondary:
        return (MinderColors.cloudGray, MinderColors.deepNavy);
      case MinderButtonVariant.danger:
        return (MinderColors.coralRed, Colors.white);
    }
  }
}
