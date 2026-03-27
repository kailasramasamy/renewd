import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../dashboard/dashboard_screen.dart';
import '../categories/categories_screen.dart';
import '../vault/vault_screen.dart';
import '../profile/profile_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _tabs = [
    DashboardScreen(),
    CategoriesScreen(),
    VaultScreen(),
    ProfileScreen(),
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
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.home),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.home, color: RenewdColors.oceanBlue),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.layers),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.layers, color: RenewdColors.oceanBlue),
                ),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.fileText),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.fileText, color: RenewdColors.oceanBlue),
                ),
                label: 'Vault',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.userCircle2),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.userCircle2, color: RenewdColors.oceanBlue),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
