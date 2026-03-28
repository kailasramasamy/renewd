import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/providers/renewal_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<_ProfileItem> _items = [
    _ProfileItem(icon: LucideIcons.bell, label: 'Notifications'),
    _ProfileItem(icon: LucideIcons.download, label: 'Data Export'),
    _ProfileItem(icon: LucideIcons.crown, label: 'Premium', isPremium: true),
    _ProfileItem(icon: LucideIcons.info, label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
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
            backgroundColor: RenewdColors.oceanBlue.withValues(alpha: 0.12),
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

  Widget _buildItem(_ProfileItem item) => ListTile(
        leading: Icon(item.icon, color: RenewdColors.slate),
        title: Text(item.label, style: RenewdTextStyles.body),
        trailing: item.isPremium
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RenewdSpacing.sm,
                  vertical: RenewdSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: RenewdColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('PRO',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.amber)),
              )
            : Icon(LucideIcons.chevronRight, color: RenewdColors.slate),
        onTap: () => _onItemTap(item.label),
      );

  void _onItemTap(String label) {
    switch (label) {
      case 'Notifications':
        Get.toNamed(AppRoutes.notificationSettings);
      case 'Data Export':
        _exportData();
      case 'Premium':
        showInfoSnack('Premium features coming soon');
      case 'About':
        _showAbout();
      default:
        break;
    }
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
                  color: RenewdColors.slate.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: RenewdSpacing.xl),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: RenewdColors.oceanBlue,
                  borderRadius: BorderRadius.circular(16),
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
