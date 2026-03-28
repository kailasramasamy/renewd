import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class IrrelevantDocSheet extends StatelessWidget {
  final String summary;
  final VoidCallback onKeep;
  final VoidCallback onDelete;

  const IrrelevantDocSheet({
    super.key,
    required this.summary,
    required this.onKeep,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: RenewdColors.slate.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: RenewdSpacing.xl),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: RenewdColors.tangerine.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(LucideIcons.alertTriangle,
                  size: 28, color: RenewdColors.tangerine),
            ),
            const SizedBox(height: RenewdSpacing.lg),
            Text('Not a renewal document',
                style: RenewdTextStyles.h3
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: RenewdSpacing.sm),
            Text(
              summary,
              textAlign: TextAlign.center,
              style: RenewdTextStyles.bodySmall.copyWith(
                color: RenewdColors.slate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: RenewdSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RenewdColors.coralRed,
                ),
                child: const Text('Remove Document'),
              ),
            ),
            const SizedBox(height: RenewdSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onKeep,
                child: Text('Keep Anyway',
                    style: RenewdTextStyles.body
                        .copyWith(color: RenewdColors.slate)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
