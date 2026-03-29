import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

enum RenewdButtonVariant { primary, secondary, danger }

class RenewdButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final RenewdButtonVariant variant;

  const RenewdButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = RenewdButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.$1,
          foregroundColor: colors.$2,
          shape: RoundedRectangleBorder(
            borderRadius: RenewdRadius.mdAll,
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
            style: RenewdTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      );

  (Color, Color) _resolveColors() {
    switch (variant) {
      case RenewdButtonVariant.primary:
        return (RenewdColors.oceanBlue, Colors.white);
      case RenewdButtonVariant.secondary:
        return (RenewdColors.cloudGray, RenewdColors.deepNavy);
      case RenewdButtonVariant.danger:
        return (RenewdColors.coralRed, Colors.white);
    }
  }
}
