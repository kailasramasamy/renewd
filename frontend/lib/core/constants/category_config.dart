import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_colors.dart';

enum RenewalCategory {
  insurance,
  subscription,
  government,
  utility,
  membership,
  other,
}

class CategoryConfig {
  CategoryConfig._();

  static const Map<RenewalCategory, _CategoryMeta> _configs = {
    RenewalCategory.insurance: _CategoryMeta(
      label: 'Insurance',
      color: MinderColors.oceanBlue,
      icon: Iconsax.shield_tick,
    ),
    RenewalCategory.subscription: _CategoryMeta(
      label: 'Subscription',
      color: MinderColors.lavender,
      icon: Iconsax.refresh_circle,
    ),
    RenewalCategory.government: _CategoryMeta(
      label: 'Government',
      color: MinderColors.teal,
      icon: Iconsax.building,
    ),
    RenewalCategory.utility: _CategoryMeta(
      label: 'Utility',
      color: MinderColors.amber,
      icon: Iconsax.flash,
    ),
    RenewalCategory.membership: _CategoryMeta(
      label: 'Membership',
      color: MinderColors.rose,
      icon: Iconsax.crown,
    ),
    RenewalCategory.other: _CategoryMeta(
      label: 'Other',
      color: MinderColors.slate,
      icon: Iconsax.category,
    ),
  };

  static String label(RenewalCategory cat) => _configs[cat]!.label;
  static Color color(RenewalCategory cat) => _configs[cat]!.color;
  static IconData icon(RenewalCategory cat) => _configs[cat]!.icon;
}

class _CategoryMeta {
  final String label;
  final Color color;
  final IconData icon;

  const _CategoryMeta({
    required this.label,
    required this.color,
    required this.icon,
  });
}
