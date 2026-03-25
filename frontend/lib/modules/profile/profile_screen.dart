import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<_ProfileItem> _items = [
    _ProfileItem(icon: Iconsax.notification, label: 'Notifications'),
    _ProfileItem(icon: Iconsax.export, label: 'Data Export'),
    _ProfileItem(icon: Iconsax.crown, label: 'Premium', isPremium: true),
    _ProfileItem(icon: Iconsax.info_circle, label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          const SizedBox(height: MinderSpacing.xl),
          _buildAvatar(),
          const SizedBox(height: MinderSpacing.xl),
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

  Widget _buildAvatar() => Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: MinderColors.cloudGray,
            child: const Icon(Iconsax.user, size: 36, color: MinderColors.slate),
          ),
          const SizedBox(height: MinderSpacing.sm),
          Text('Your Name',
              style: MinderTextStyles.h3.copyWith(color: MinderColors.deepNavy)),
        ],
      );

  Widget _buildItem(_ProfileItem item) => ListTile(
        leading: Icon(item.icon, color: MinderColors.slate),
        title: Text(item.label, style: MinderTextStyles.body),
        trailing: item.isPremium
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MinderSpacing.sm,
                  vertical: MinderSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: MinderColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('PRO',
                    style: MinderTextStyles.caption
                        .copyWith(color: MinderColors.amber)),
              )
            : const Icon(Iconsax.arrow_right_3, color: MinderColors.slate),
        onTap: () {},
      );

  Widget _buildSignOut() => ListTile(
        leading: const Icon(Iconsax.logout, color: MinderColors.coralRed),
        title: Text('Sign Out',
            style: MinderTextStyles.body.copyWith(color: MinderColors.coralRed)),
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
