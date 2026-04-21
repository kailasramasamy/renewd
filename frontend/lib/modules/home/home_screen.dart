import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
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

  static const _navItems = [
    (LucideIcons.home, 'Home'),
    (LucideIcons.layers, 'Renewals'),
    (LucideIcons.fileText, 'Vault'),
    (LucideIcons.sparkles, 'AI Chat'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Obx(
      () => Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: controller.currentTab.value,
          children: _tabs,
        ),
        bottomNavigationBar: _FloatingTabBar(
          currentIndex: controller.currentTab.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  const _FloatingTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  static const _navItems = HomeScreen._navItems;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? RenewdColors.charcoal.withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.72);

    return Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).padding.bottom > 0 ? 8 : 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: RenewdColors.darkBorder.withValues(alpha: 0.40),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _navItems.length; i++)
                    Expanded(
                      child: _TabItem(
                        icon: _navItems[i].$1,
                        label: _navItems[i].$2,
                        isActive: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive
        ? (isDark ? Colors.white : RenewdColors.lavender)
        : RenewdColors.warmGray;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconSlot(color),
          const SizedBox(height: 2),
          Text(
            label,
            style: RenewdTextStyles.caption.copyWith(
              fontSize: 10,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIconSlot(Color iconColor) {
    if (!isActive) {
      return Icon(icon, size: 20, color: iconColor);
    }

    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RenewdColors.lavender, RenewdColors.accent2],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: RenewdColors.lavender.withValues(alpha: 0.45),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }
}
