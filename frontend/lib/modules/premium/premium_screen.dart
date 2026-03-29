import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/services/premium_service.dart';
import '../../core/utils/currency.dart';
import '../../core/services/purchase_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = Get.find<PremiumService>();
    final purchase = Get.find<PurchaseService>();
    final auth = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: const Text('Premium'),
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(RenewdSpacing.xl),
            children: [
              _PlanBadge(premium: premium, auth: auth),
              const SizedBox(height: RenewdSpacing.xl),
              if (!premium.isPremium && (premium.config?.iapEnabled ?? false)) ...[
                _PurchaseButtons(purchase: purchase, premium: premium),
                const SizedBox(height: RenewdSpacing.xl),
              ],
              _FeatureComparison(premium: premium),
              const SizedBox(height: RenewdSpacing.xl),
              if (!premium.isPremium && (premium.config?.iapEnabled ?? false))
                _RestoreButton(purchase: purchase),
              const SizedBox(height: RenewdSpacing.xl),
            ],
          )),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final PremiumService premium;
  final AuthService auth;

  const _PlanBadge({required this.premium, required this.auth});

  @override
  Widget build(BuildContext context) {
    final isPro = premium.isPremium;
    final iapEnabled = premium.config?.iapEnabled ?? false;
    final allFeaturesOpen = !iapEnabled && !isPro;
    final showPremium = isPro || allFeaturesOpen;
    final expiresAt = auth.currentUser?.premiumExpiresAt;

    return Container(
      padding: const EdgeInsets.all(RenewdSpacing.xl),
      decoration: BoxDecoration(
        gradient: showPremium
            ? const LinearGradient(
                colors: [Color(0xFFFF9F0A), Color(0xFFFFCC00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: showPremium ? null : RenewdColors.steel,
        borderRadius: RenewdRadius.xlAll,
      ),
      child: Column(
        children: [
          Icon(LucideIcons.crown,
              size: 40, color: showPremium ? Colors.white : RenewdColors.slate),
          const SizedBox(height: RenewdSpacing.md),
          if (allFeaturesOpen) ...[
            Text('All Features Unlocked',
                style: RenewdTextStyles.h2
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: RenewdSpacing.xs),
            Text('Enjoy full access to all Renewd features',
                style: RenewdTextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: RenewdOpacity.heavy))),
          ] else if (isPro) ...[
            Text('Premium',
                style: RenewdTextStyles.h2
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            if (expiresAt != null) ...[
              const SizedBox(height: RenewdSpacing.xs),
              Text('Expires ${_formatDate(expiresAt)}',
                  style: RenewdTextStyles.bodySmall
                      .copyWith(color: Colors.white.withValues(alpha: RenewdOpacity.heavy))),
            ],
            if (expiresAt == null) ...[
              const SizedBox(height: RenewdSpacing.xs),
              Text('Lifetime access',
                  style: RenewdTextStyles.bodySmall
                      .copyWith(color: Colors.white.withValues(alpha: RenewdOpacity.heavy))),
            ],
          ] else ...[
            Text('Free Plan',
                style: RenewdTextStyles.h2.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: RenewdSpacing.xs),
            Text('Upgrade to unlock all features',
                style: RenewdTextStyles.bodySmall
                    .copyWith(color: RenewdColors.slate)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _PurchaseButtons extends StatelessWidget {
  final PurchaseService purchase;
  final PremiumService premium;

  const _PurchaseButtons({required this.purchase, required this.premium});

  @override
  Widget build(BuildContext context) {
    final pricing = premium.pricing;
    final symbol = pricing.currency == 'INR' ? RenewdCurrency.inr : pricing.currency;

    return Obx(() {
      final buying = purchase.isPurchasing.value;
      final monthly = purchase.monthlyProduct;
      final yearly = purchase.yearlyProduct;
      final lifetime = purchase.lifetimeProduct;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PlanButton(
                  label: 'Monthly',
                  price: monthly?.price ?? '$symbol${pricing.monthly}',
                  period: '/month',
                  isPopular: false,
                  isLoading: buying,
                  onTap: monthly != null
                      ? () => purchase.purchase(monthly)
                      : null,
                ),
              ),
              const SizedBox(width: RenewdSpacing.md),
              Expanded(
                child: _PlanButton(
                  label: 'Yearly',
                  price: yearly?.price ?? '$symbol${pricing.yearly}',
                  period: '/year',
                  isPopular: true,
                  savings: _calcSavings(pricing.monthly, pricing.yearly),
                  isLoading: buying,
                  onTap: yearly != null
                      ? () => purchase.purchase(yearly)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: RenewdSpacing.md),
          _PlanButton(
            label: 'Lifetime',
            price: lifetime?.price ?? '${symbol}1,499',
            period: 'one-time',
            isPopular: false,
            isLoading: buying,
            onTap: lifetime != null
                ? () => purchase.purchase(lifetime)
                : null,
          ),
        ],
      );
    });
  }

  String _calcSavings(int monthly, int yearly) {
    final annualCost = monthly * 12;
    final saved = ((annualCost - yearly) / annualCost * 100).round();
    return 'Save $saved%';
  }
}

class _PlanButton extends StatelessWidget {
  final String label;
  final String price;
  final String period;
  final bool isPopular;
  final String? savings;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PlanButton({
    required this.label,
    required this.price,
    required this.period,
    required this.isPopular,
    this.savings,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: RenewdColors.steel,
          borderRadius: RenewdRadius.mdAll,
          border: isPopular
              ? Border.all(color: RenewdColors.amber, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            if (isPopular && savings != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.sm, vertical: 2),
                margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
                decoration: BoxDecoration(
                  color: RenewdColors.amber.withValues(alpha: RenewdOpacity.medium),
                  borderRadius: RenewdRadius.pillAll,
                ),
                child: Text(savings!,
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.amber)),
              ),
            Text(label,
                style: RenewdTextStyles.caption
                    .copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.xs),
            Text(price,
                style: RenewdTextStyles.h2
                    .copyWith(fontWeight: FontWeight.w700)),
            Text(period,
                style: RenewdTextStyles.caption
                    .copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: RenewdSpacing.sm),
              decoration: BoxDecoration(
                color: onTap != null
                    ? RenewdColors.amber
                    : RenewdColors.slate.withValues(alpha: RenewdOpacity.moderate),
                borderRadius: RenewdRadius.smAll,
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        onTap != null ? 'Subscribe' : 'Not Available',
                        style: RenewdTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureComparison extends StatelessWidget {
  final PremiumService premium;

  const _FeatureComparison({required this.premium});

  @override
  Widget build(BuildContext context) {
    final limit = premium.freeRenewalLimit;
    final features = [
      _FeatureRow('Renewals', 'Up to $limit', 'Unlimited'),
      _FeatureRow('Reminders', '1 day before', 'Smart (7d + 1d + custom)'),
      _FeatureRow('AI Document Scan', null, 'Included'),
      _FeatureRow('Document Vault', null, 'Included'),
      _FeatureRow('AI Chat Assistant', null, 'Included'),
      _FeatureRow('Spending Analytics', null, 'Included'),
      _FeatureRow('CSV Export', null, 'Included'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Feature Comparison',
            style:
                RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: RenewdSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: RenewdColors.steel,
            borderRadius: RenewdRadius.mdAll,
          ),
          child: Column(
            children: [
              _buildHeader(),
              ...features.map(_buildRow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('Feature',
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate))),
          Expanded(
              flex: 2,
              child: Text('Free',
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate),
                  textAlign: TextAlign.center)),
          Expanded(
              flex: 2,
              child: Text('Premium',
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.amber),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRow(_FeatureRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(color: RenewdColors.darkBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(row.feature, style: RenewdTextStyles.bodySmall)),
          Expanded(
            flex: 2,
            child: row.free != null
                ? Text(row.free!,
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate),
                    textAlign: TextAlign.center)
                : const Icon(LucideIcons.x,
                    size: 16, color: RenewdColors.coralRed),
          ),
          Expanded(
            flex: 2,
            child: row.premium != null
                ? Text(row.premium!,
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.emerald),
                    textAlign: TextAlign.center)
                : const Icon(LucideIcons.check,
                    size: 16, color: RenewdColors.emerald),
          ),
        ],
      ),
    );
  }
}

class _RestoreButton extends StatelessWidget {
  final PurchaseService purchase;

  const _RestoreButton({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextButton(
          onPressed:
              purchase.isRestoring.value ? null : purchase.restorePurchases,
          child: Text(
            purchase.isRestoring.value
                ? 'Restoring...'
                : 'Restore Purchases',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.oceanBlue),
          ),
        ));
  }
}

class _FeatureRow {
  final String feature;
  final String? free;
  final String? premium;

  const _FeatureRow(this.feature, this.free, this.premium);
}
