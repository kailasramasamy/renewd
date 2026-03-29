import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../dashboard/dashboard_screen.dart';
import '../categories/categories_screen.dart';
import '../chat/chat_screen.dart';
import '../vault/vault_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _tabs = [
    DashboardScreen(),
    CategoriesScreen(),
    VaultScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentTab.value,
          children: _tabs,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? RenewdColors.darkBorder
                    : RenewdColors.mist,
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentTab.value,
            onTap: controller.changeTab,
            selectedLabelStyle: RenewdTextStyles.caption.copyWith(fontSize: 11),
            unselectedLabelStyle:
                RenewdTextStyles.caption.copyWith(fontSize: 11),
            selectedItemColor: RenewdColors.oceanBlue,
            items: [
              _navItem(LucideIcons.home, 'Home'),
              _navItem(LucideIcons.layers, 'Categories'),
              _navItem(LucideIcons.fileText, 'Vault'),
              _navItem(LucideIcons.sparkles, 'AI Chat'),
            ],
          ),
        ),
      ),
    );
  }

  static BottomNavigationBarItem _navItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg,
          vertical: RenewdSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: RenewdColors.oceanBlue.withValues(alpha: RenewdOpacity.light),
          borderRadius: RenewdRadius.pillAll,
        ),
        child: Icon(icon, color: RenewdColors.oceanBlue),
      ),
      label: label,
    );
  }
}
