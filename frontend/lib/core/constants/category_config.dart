import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

enum RenewalCategory {
  insurance,
  subscription,
  government,
  utility,
  membership,
  finance,
  digital,
  education,
  other,
}

class CategoryConfig {
  CategoryConfig._();

  static const Map<RenewalCategory, _CategoryMeta> _configs = {
    RenewalCategory.insurance: _CategoryMeta(
      label: 'Insurance',
      color: RenewdColors.oceanBlue,
      icon: LucideIcons.shieldCheck,
      suggestedSubcategories: [
        'Car Insurance',
        'Bike Insurance',
        'Health Insurance',
        'Life Insurance',
        'Home Insurance',
        'Travel Insurance',
        'Term Insurance',
        'Commercial Vehicle',
      ],
    ),
    RenewalCategory.subscription: _CategoryMeta(
      label: 'Subscription',
      color: RenewdColors.lavender,
      icon: LucideIcons.refreshCcw,
      suggestedSubcategories: [
        'Entertainment',
        'Cloud Storage',
        'Music',
        'News',
        'Software',
        'Fitness',
        'Gaming',
        'VPN',
      ],
    ),
    RenewalCategory.government: _CategoryMeta(
      label: 'Government',
      color: RenewdColors.teal,
      icon: LucideIcons.building2,
      suggestedSubcategories: [
        'Driving License',
        'Passport',
        'Vehicle Registration',
        'PUC Certificate',
        'Trade License',
        'GST Registration',
        'Aadhaar',
        'PAN Card',
      ],
    ),
    RenewalCategory.utility: _CategoryMeta(
      label: 'Utility',
      color: RenewdColors.amber,
      icon: LucideIcons.zap,
      suggestedSubcategories: [
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
      suggestedSubcategories: [
        'Gym',
        'Club',
        'Professional Body',
        'Co-working',
        'Loyalty Program',
        'Library',
        'Association',
      ],
    ),
    RenewalCategory.finance: _CategoryMeta(
      label: 'Finance',
      color: RenewdColors.emerald,
      icon: LucideIcons.wallet,
      suggestedSubcategories: [
        'Loan EMI',
        'Credit Card',
        'Fixed Deposit',
        'Recurring Deposit',
        'SIP',
        'Mutual Fund',
        'Insurance Premium',
        'Tax Payment',
      ],
    ),
    RenewalCategory.digital: _CategoryMeta(
      label: 'Digital',
      color: RenewdColors.tangerine,
      icon: LucideIcons.globe,
      suggestedSubcategories: [
        'Domain',
        'Hosting',
        'Cloud Service',
        'SaaS Tool',
        'SSL Certificate',
        'Email Service',
      ],
    ),
    RenewalCategory.education: _CategoryMeta(
      label: 'Education',
      color: RenewdColors.oceanBlue,
      icon: LucideIcons.graduationCap,
      suggestedSubcategories: [
        'School Fees',
        'Tuition',
        'Course Subscription',
        'Certification',
        'Library',
      ],
    ),
    RenewalCategory.other: _CategoryMeta(
      label: 'Other',
      color: RenewdColors.slate,
      icon: LucideIcons.layoutGrid,
      suggestedSubcategories: [
        'Warranty',
        'Service Contract',
        'Lease',
        'Rental',
      ],
    ),
  };

  static String label(RenewalCategory cat) => _configs[cat]!.label;
  static Color color(RenewalCategory cat) => _configs[cat]!.color;
  static IconData icon(RenewalCategory cat) => _configs[cat]!.icon;
  static List<String> suggestedSubcategories(RenewalCategory cat) =>
      _configs[cat]!.suggestedSubcategories;
}

class _CategoryMeta {
  final String label;
  final Color color;
  final IconData icon;
  final List<String> suggestedSubcategories;

  const _CategoryMeta({
    required this.label,
    required this.color,
    required this.icon,
    this.suggestedSubcategories = const [],
  });
}
