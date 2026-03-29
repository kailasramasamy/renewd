class PremiumPricing {
  final int monthly;
  final int yearly;
  final String currency;

  const PremiumPricing({
    required this.monthly,
    required this.yearly,
    required this.currency,
  });

  factory PremiumPricing.fromJson(Map<String, dynamic> json) => PremiumPricing(
        monthly: json['monthly'] as int? ?? 99,
        yearly: json['yearly'] as int? ?? 799,
        currency: json['currency'] as String? ?? 'INR',
      );
}

class PremiumConfigModel {
  final int freeRenewalLimit;
  final List<int> freeReminderDays;
  final List<int> premiumReminderDays;
  final PremiumPricing pricing;
  final Map<String, String> features;
  final bool iapEnabled;
  final Map<String, String> iapProducts;

  const PremiumConfigModel({
    required this.freeRenewalLimit,
    required this.freeReminderDays,
    required this.premiumReminderDays,
    required this.pricing,
    required this.features,
    required this.iapEnabled,
    required this.iapProducts,
  });

  factory PremiumConfigModel.fromJson(Map<String, dynamic> json) {
    final featuresRaw = json['features'] as Map<String, dynamic>? ?? {};
    final iapRaw = json['iap'] as Map<String, dynamic>? ?? {};
    final productsRaw = iapRaw['products'] as Map<String, dynamic>? ?? {};
    return PremiumConfigModel(
      freeRenewalLimit: json['free_renewal_limit'] as int? ?? 5,
      freeReminderDays: (json['free_reminder_days'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [1],
      premiumReminderDays: (json['premium_reminder_days'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [7, 1],
      pricing: PremiumPricing.fromJson(
          json['pricing'] as Map<String, dynamic>? ?? {}),
      features:
          featuresRaw.map((k, v) => MapEntry(k, v as String? ?? 'premium')),
      iapEnabled: iapRaw['enabled'] as bool? ?? false,
      iapProducts: productsRaw
          .map((k, v) => MapEntry(k, v as String? ?? '')),
    );
  }

  bool isFeatureAvailable(String feature, {required bool isPremium}) {
    final access = features[feature] ?? 'premium';
    if (access == 'all') return true;
    if (access == 'none') return false;
    return isPremium;
  }
}
