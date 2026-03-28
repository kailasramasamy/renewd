import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? RenewdColors.darkSlate : RenewdColors.cloudGray;
    final highlight = isDark ? RenewdColors.steel : Colors.white;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: List.generate(3, (_) => Expanded(
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.only(right: RenewdSpacing.sm),
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )),
            ),
            const SizedBox(height: RenewdSpacing.xxl),
            // Section header
            Container(
              width: 100, height: 12,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: RenewdSpacing.lg),
            // Cards
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: RenewdSpacing.sm),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class VaultSkeletonLoader extends StatelessWidget {
  const VaultSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? RenewdColors.darkSlate : RenewdColors.cloudGray;
    final highlight = isDark ? RenewdColors.steel : Colors.white;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        child: Column(
          children: List.generate(5, (_) => Padding(
            padding: const EdgeInsets.only(bottom: RenewdSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: RenewdSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity, height: 14,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100, height: 10,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
