import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/category_config.dart';
import '../../core/services/premium_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/providers/renewal_provider.dart';
import '../dashboard/dashboard_controller.dart';

class AddRenewalController extends GetxController {
  final _provider = RenewalProvider();

  final RxString name = ''.obs;
  final RxString providerName = ''.obs;
  final RxString notes = ''.obs;
  final Rx<RenewalCategory> category = RenewalCategory.subscription.obs;
  final RxString groupName = ''.obs;
  final Rx<double?> amount = Rx<double?>(null);
  final Rx<DateTime?> renewalDate = Rx<DateTime?>(null);
  final RxString frequency = 'monthly'.obs;
  final RxInt frequencyDays = 30.obs;
  final RxBool autoRenew = false.obs;
  final RxBool isLoading = false.obs;

  static const List<String> frequencies = [
    'monthly', 'quarterly', 'yearly', 'weekly', 'custom',
  ];

  static const Map<String, String> frequencyLabels = {
    'monthly': 'Monthly', 'quarterly': 'Quarterly',
    'yearly': 'Yearly', 'weekly': 'Weekly', 'custom': 'Custom',
  };

  bool get isCustomFrequency => frequency.value == 'custom';

  List<String> get suggestedSubcategories =>
      CategoryConfig.suggestedSubcategories(category.value);

  String? validateAndGetError() {
    if (name.value.trim().isEmpty) {
      return 'Please enter a name for this renewal';
    }
    if (renewalDate.value == null) {
      return 'Please select the next renewal date';
    }
    if (isCustomFrequency && frequencyDays.value <= 0) {
      return 'Please enter how many days between renewals';
    }
    return null;
  }

  Future<void> save() async {
    final error = validateAndGetError();
    if (error != null) {
      showErrorSnack(error);
      return;
    }

    // Check renewal limit before saving
    if (!_checkRenewalLimit()) return;

    final data = <String, dynamic>{
      'name': name.value.trim(),
      'category': category.value.name,
      'renewal_date': renewalDate.value!.toIso8601String(),
      'frequency': frequency.value,
      'auto_renew': autoRenew.value,
      if (groupName.value.trim().isNotEmpty)
        'group_name': groupName.value.trim(),
      if (providerName.value.trim().isNotEmpty)
        'provider': providerName.value.trim(),
      if (amount.value != null) 'amount': amount.value,
      if (notes.value.trim().isNotEmpty) 'notes': notes.value.trim(),
      if (isCustomFrequency) 'frequency_days': frequencyDays.value,
    };

    // Check for duplicates before saving
    final duplicates = await _provider.checkDuplicate(data);
    if (duplicates.isNotEmpty) {
      final proceed = await _showDuplicateWarning(duplicates);
      if (proceed != true) return;
    }

    isLoading.value = true;
    try {
      await _provider.create(data);
      try {
        Get.find<DashboardController>().fetchRenewals();
      } catch (_) {}
      Get.back(result: true);
      showSuccessSnack('${name.value.trim()} added');
    } catch (e) {
      if (e is ApiException && e.statusCode == 403) {
        _showRenewalLimitReached();
      } else {
        showErrorSnack('Failed to add renewal');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool?> _showDuplicateWarning(List<String> matches) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Get.isDarkMode ? RenewdColors.darkSlate : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Possible Duplicate',
            style: RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A similar renewal already exists:',
                style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: 8),
            ...matches.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 16, color: RenewdColors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m, style: RenewdTextStyles.body)),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Text('Do you still want to add this renewal?',
                style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: RenewdColors.slate)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Add Anyway', style: TextStyle(color: RenewdColors.oceanBlue)),
          ),
        ],
      ),
    );
  }

  bool _checkRenewalLimit() {
    final premium = Get.find<PremiumService>();
    int count = 0;
    try {
      final dashboard = Get.find<DashboardController>();
      count = dashboard.totalActive;
    } catch (_) {
      return true;
    }
    if (!premium.canCreateRenewal(count)) {
      _showRenewalLimitReached();
      return false;
    }
    return true;
  }

  void _showRenewalLimitReached() {
    final premium = Get.find<PremiumService>();
    final limit = premium.freeRenewalLimit;
    Get.bottomSheet(
      SafeArea(
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
              Icon(LucideIcons.lock, size: 48, color: RenewdColors.tangerine),
              const SizedBox(height: RenewdSpacing.lg),
              Text('Renewal Limit Reached',
                  style: RenewdTextStyles.h3
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: RenewdSpacing.sm),
              Text(
                'Free plan allows up to $limit renewals. Upgrade to Premium for unlimited renewals.',
                textAlign: TextAlign.center,
                style: RenewdTextStyles.bodySmall
                    .copyWith(color: RenewdColors.slate, height: 1.5),
              ),
              const SizedBox(height: RenewdSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.premium);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RenewdColors.tangerine,
                    shape: RoundedRectangleBorder(
                        borderRadius: RenewdRadius.mdAll),
                  ),
                  child: const Text('View Premium Plans',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: RenewdSpacing.md),
            ],
          ),
        ),
      ),
      backgroundColor: Get.isDarkMode ? RenewdColors.darkSlate : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}
