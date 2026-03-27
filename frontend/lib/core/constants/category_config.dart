import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      icon: LucideIcons.shieldCheck,
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
      icon: LucideIcons.refreshCcw,
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
      icon: LucideIcons.building2,
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
      icon: LucideIcons.zap,
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
      icon: LucideIcons.crown,
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
      icon: LucideIcons.layoutGrid,
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
