import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../services/premium_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_opacity.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PremiumGate extends StatelessWidget {
  final String feature;
  final Widget child;

  const PremiumGate({
    super.key,
    required this.feature,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final premium = Get.find<PremiumService>();

    return Obx(() {
      // Re-read config reactively
      final _ = premium.config;
      if (premium.isFeatureAvailable(feature)) {
        return child;
      }
      return _buildLockedOverlay();
    });
  }

  Widget _buildLockedOverlay() {
    return Stack(
      children: [
        IgnorePointer(
          child: Opacity(opacity: RenewdOpacity.moderate, child: child),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.premium),
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RenewdSpacing.lg,
                  vertical: RenewdSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: RenewdColors.steel,
                  borderRadius: RenewdRadius.mdAll,
                  border: Border.all(color: RenewdColors.amber, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.lock,
                        size: 16, color: RenewdColors.amber),
                    const SizedBox(width: RenewdSpacing.sm),
                    Text(
                      'Upgrade to Premium',
                      style: RenewdTextStyles.bodySmall
                          .copyWith(color: RenewdColors.amber),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
