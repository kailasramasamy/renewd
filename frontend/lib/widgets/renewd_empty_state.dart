import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class RenewdEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const RenewdEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: RenewdColors.slate),
            const SizedBox(height: RenewdSpacing.lg),
            Text(title,
                style: RenewdTextStyles.body
                    .copyWith(color: RenewdColors.slate),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: RenewdSpacing.xs),
              Text(subtitle!,
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: RenewdSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
