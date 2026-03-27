import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../vault/vault_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _tabs = [
    DashboardScreen(),
    VaultScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Iconsax.element_4),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Iconsax.folder_open),
      label: 'Vault',
    ),
    BottomNavigationBarItem(
      icon: Icon(Iconsax.message_text),
      label: 'AI Chat',
    ),
    BottomNavigationBarItem(
      icon: Icon(Iconsax.user),
      label: 'Profile',
    ),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentTab.value,
          onTap: controller.changeTab,
          selectedItemColor: RenewdColors.oceanBlue,
          unselectedItemColor: RenewdColors.slate,
          type: BottomNavigationBarType.fixed,
          items: _navItems,
        ),
      ),
    );
  }
}
