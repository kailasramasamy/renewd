import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'haptics.dart';

void showRenewdSnack({
  required String message,
  IconData? icon,
  Color? color,
  Duration duration = const Duration(seconds: 3),
}) {
  final isDark = Get.isDarkMode;
  final bg = isDark ? RenewdColors.steel : Colors.white;
  final iconColor = color ?? RenewdColors.oceanBlue;

  Get.rawSnackbar(
    messageText: Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: RenewdSpacing.md),
        ],
        Expanded(
          child: Text(message,
              style: RenewdTextStyles.bodySmall.copyWith(
                color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
              )),
        ),
      ],
    ),
    backgroundColor: bg,
    borderRadius: 14,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    padding: const EdgeInsets.symmetric(
      horizontal: RenewdSpacing.lg,
      vertical: RenewdSpacing.md,
    ),
    snackPosition: SnackPosition.BOTTOM,
    duration: duration,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

void showSuccessSnack(String message) {
  RenewdHaptics.success();
  showRenewdSnack(message: message, icon: LucideIcons.checkCircle, color: RenewdColors.emerald);
}

void showErrorSnack(String message) {
  RenewdHaptics.error();
  showRenewdSnack(message: message, icon: LucideIcons.alertTriangle, color: RenewdColors.coralRed);
}

void showInfoSnack(String message) =>
    showRenewdSnack(message: message, icon: LucideIcons.info, color: RenewdColors.oceanBlue);
