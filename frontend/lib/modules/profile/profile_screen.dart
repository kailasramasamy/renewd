import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/routes/app_routes.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/premium_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/providers/renewal_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<_ProfileItem> _items = [
    _ProfileItem(icon: LucideIcons.bell, label: 'Notifications'),
    _ProfileItem(icon: LucideIcons.download, label: 'Data Export'),
    _ProfileItem(icon: LucideIcons.banknote, label: 'Currency'),
    _ProfileItem(icon: LucideIcons.crown, label: 'Premium', isPremium: true),
    _ProfileItem(icon: LucideIcons.sparkles, label: 'Features'),
    _ProfileItem(icon: LucideIcons.info, label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          tooltip: 'Go back',
          onPressed: () => Get.back(),
        ),
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          const SizedBox(height: RenewdSpacing.xl),
          _buildAvatar(),
          const SizedBox(height: RenewdSpacing.xl),
          Expanded(
            child: ListView(
              children: [
                ..._items.map(_buildItem),
                _buildSignOut(),
                _buildDeleteAccount(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final storage = Get.find<StorageService>();
    final userData = storage.readUserData();
    final name = userData?['name'] as String? ?? 'Your Name';
    final email = userData?['email'] as String?;

    return Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: RenewdColors.oceanBlue.withValues(alpha: RenewdOpacity.light),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: RenewdTextStyles.h1.copyWith(
                color: RenewdColors.oceanBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: RenewdSpacing.sm),
          Text(name, style: RenewdTextStyles.h3),
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: RenewdSpacing.xs),
            Text(email, style: RenewdTextStyles.caption
                .copyWith(color: RenewdColors.slate)),
          ],
        ],
      );
  }

  Widget _buildItem(_ProfileItem item) {
    final premiumService = Get.find<PremiumService>();
    final isUserPremium = item.isPremium && premiumService.isPremium;
    final allOpen = item.isPremium && !(premiumService.config?.iapEnabled ?? false);
    final showActive = isUserPremium || allOpen;

    return ListTile(
      leading: Icon(item.icon, color: RenewdColors.slate),
      title: Text(item.label, style: RenewdTextStyles.body),
      trailing: item.isPremium
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RenewdSpacing.sm,
                vertical: RenewdSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: showActive
                    ? RenewdColors.emerald.withValues(alpha: RenewdOpacity.medium)
                    : RenewdColors.slate.withValues(alpha: RenewdOpacity.medium),
                borderRadius: RenewdRadius.pillAll,
              ),
              child: Text(
                showActive ? 'ACTIVE' : 'FREE',
                style: RenewdTextStyles.caption.copyWith(
                  color: showActive ? RenewdColors.emerald : RenewdColors.slate,
                ),
              ),
            )
          : Icon(LucideIcons.chevronRight, color: RenewdColors.slate),
      onTap: () => _onItemTap(item.label),
    );
  }

  void _onItemTap(String label) {
    switch (label) {
      case 'Notifications':
        Get.toNamed(AppRoutes.notificationSettings);
      case 'Data Export':
        _exportData();
      case 'Currency':
        _showCurrencyPicker();
      case 'Premium':
        Get.toNamed(AppRoutes.premium);
      case 'Features':
        Get.toNamed(AppRoutes.features);
      case 'About':
        _showAbout();
      default:
        break;
    }
  }

  void _showCurrencyPicker() {
    final isDark = Get.isDarkMode;
    final currentCurrency = RenewdCurrency.userCurrency;
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
                  color: RenewdColors.slate.withValues(alpha: RenewdOpacity.moderate),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: RenewdSpacing.xl),
              Text('Default Currency',
                  style: RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: RenewdSpacing.lg),
              ...RenewdCurrency.labels.entries.map((entry) => ListTile(
                    leading: Text(
                      RenewdCurrency.symbolFor(entry.key),
                      style: RenewdTextStyles.h3.copyWith(color: RenewdColors.oceanBlue),
                    ),
                    title: Text(entry.value, style: RenewdTextStyles.body),
                    trailing: entry.key == currentCurrency
                        ? Icon(LucideIcons.check, color: RenewdColors.emerald, size: 20)
                        : null,
                    onTap: () async {
                      Get.back();
                      try {
                        final client = Get.find<ApiClient>();
                        await client.safePut(ApiEndpoints.updateProfile, {
                          'default_currency': entry.key,
                        });
                        final storage = Get.find<StorageService>();
                        final userData = storage.readUserData() ?? {};
                        userData['default_currency'] = entry.key;
                        storage.saveUserData(userData);
                        showSuccessSnack('Currency set to ${entry.value}');
                      } catch (_) {
                        showErrorSnack('Failed to update currency');
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
      backgroundColor: isDark ? RenewdColors.darkSlate : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _showAbout() {
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
                  color: RenewdColors.slate.withValues(alpha: RenewdOpacity.moderate),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: RenewdSpacing.xl),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: RenewdColors.oceanBlue,
                  borderRadius: RenewdRadius.xlAll,
                ),
                child: Icon(LucideIcons.refreshCcw, size: 32, color: Colors.white),
              ),
              const SizedBox(height: RenewdSpacing.lg),
              Text('Renewd', style: RenewdTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: RenewdSpacing.xs),
              Text('Version 1.0.0', style: RenewdTextStyles.caption
                  .copyWith(color: RenewdColors.slate)),
              const SizedBox(height: RenewdSpacing.md),
              Text(
                'AI-powered personal renewal tracking.\nNever miss a renewal again.',
                textAlign: TextAlign.center,
                style: RenewdTextStyles.bodySmall.copyWith(
                  color: RenewdColors.slate, height: 1.5),
              ),
              const SizedBox(height: RenewdSpacing.xl),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final renewals = await RenewalProvider().getAll();
      if (renewals.isEmpty) {
        showInfoSnack('No renewals to export');
        return;
      }

      final csv = StringBuffer();
      csv.writeln('Name,Category,Provider,Amount,Renewal Date,Frequency,Auto-Renew,Status');
      for (final r in renewals) {
        csv.writeln(
          '"${r.name}","${r.category.name}","${r.provider ?? ''}",${r.amount ?? ''},"${r.renewalDate.toIso8601String().split('T')[0]}","${r.frequency ?? ''}",${r.autoRenew},"${r.status}"',
        );
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/renewd_export.csv');
      await file.writeAsString(csv.toString());

      final box = Get.context?.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Renewd Data Export',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (_) {
      showErrorSnack('Export failed');
    }
  }

  Widget _buildSignOut() => ListTile(
        leading: Icon(LucideIcons.logOut, color: RenewdColors.coralRed),
        title: Text('Sign Out',
            style: RenewdTextStyles.body.copyWith(color: RenewdColors.coralRed)),
        onTap: () => Get.find<AuthService>().signOut(),
      );

  Widget _buildDeleteAccount() => ListTile(
        leading: Icon(LucideIcons.trash2, color: RenewdColors.slate),
        title: Text('Delete Account',
            style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
        onTap: () => _confirmDeleteAccount(),
      );

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        backgroundColor: RenewdColors.darkSlate,
        shape: RoundedRectangleBorder(borderRadius: RenewdRadius.xlAll),
        title: Text('Delete Account?',
            style: RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete your account and all data — renewals, documents, payments, and settings. This cannot be undone.',
          style: RenewdTextStyles.bodySmall
              .copyWith(color: RenewdColors.slate, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
          ),
          TextButton(
            onPressed: () {
              RenewdHaptics.error();
              _deleteAccount();
            },
            child: Text('Delete',
                style: RenewdTextStyles.body
                    .copyWith(color: RenewdColors.coralRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final client = Get.find<ApiClient>();
      await client.safeDelete(ApiEndpoints.me);
      Get.find<StorageService>().clearAll();
      Get.offAllNamed(AppRoutes.login);
      showSuccessSnack('Account deleted');
    } catch (_) {
      showErrorSnack('Failed to delete account');
    }
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final bool isPremium;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.isPremium = false,
  });
}
