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
      color: RenewdColors.oceanBlue,
      icon: Iconsax.shield_tick,
      suggestedGroups: [
        'Car Insurance',
        'Health Insurance',
        'Life Insurance',
        'Home Insurance',
        'Travel Insurance',
        'Bike Insurance',
      ],
    ),
    RenewalCategory.subscription: _CategoryMeta(
      label: 'Subscription',
      color: RenewdColors.lavender,
      icon: Iconsax.refresh_circle,
      suggestedGroups: [
        'Entertainment',
        'Cloud Storage',
        'Music',
        'News',
        'Software',
        'Fitness',
        'Learning',
      ],
    ),
    RenewalCategory.government: _CategoryMeta(
      label: 'Government',
      color: RenewdColors.teal,
      icon: Iconsax.building,
      suggestedGroups: [
        'Driving License',
        'Passport',
        'Vehicle Registration',
        'Trade License',
        'GST Registration',
      ],
    ),
    RenewalCategory.utility: _CategoryMeta(
      label: 'Utility',
      color: RenewdColors.amber,
      icon: Iconsax.flash,
      suggestedGroups: [
        'Electricity',
        'Water',
        'Gas',
        'Internet',
        'Mobile',
        'DTH',
        'Landline',
      ],
    ),
    RenewalCategory.membership: _CategoryMeta(
      label: 'Membership',
      color: RenewdColors.rose,
      icon: Iconsax.crown,
      suggestedGroups: [
        'Gym',
        'Club',
        'Professional',
        'Co-working',
        'Loyalty Program',
      ],
    ),
    RenewalCategory.other: _CategoryMeta(
      label: 'Other',
      color: RenewdColors.slate,
      icon: Iconsax.category,
      suggestedGroups: [],
    ),
  };

  static String label(RenewalCategory cat) => _configs[cat]!.label;
  static Color color(RenewalCategory cat) => _configs[cat]!.color;
  static IconData icon(RenewalCategory cat) => _configs[cat]!.icon;
  static List<String> suggestedGroups(RenewalCategory cat) =>
      _configs[cat]!.suggestedGroups;
}

class _CategoryMeta {
  final String label;
  final Color color;
  final IconData icon;
  final List<String> suggestedGroups;

  const _CategoryMeta({
    required this.label,
    required this.color,
    required this.icon,
    this.suggestedGroups = const [],
  });
}
