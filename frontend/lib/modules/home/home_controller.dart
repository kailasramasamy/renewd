import 'package:get/get.dart';
import '../../core/utils/haptics.dart';
import '../categories/categories_screen.dart';
import '../dashboard/dashboard_controller.dart';
import '../vault/vault_controller.dart';

class HomeController extends GetxController {
  final RxInt currentTab = 0.obs;

  void changeTab(int index) {
    RenewdHaptics.light();
    currentTab.value = index;

    // Refresh data when switching tabs
    switch (index) {
      case 0:
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchRenewals();
        }
      case 1:
        if (Get.isRegistered<CategoriesController>()) {
          Get.find<CategoriesController>().fetchRenewals();
        }
      case 2:
        if (Get.isRegistered<VaultController>()) {
          Get.find<VaultController>().fetchAll();
        }
    }
  }
}
