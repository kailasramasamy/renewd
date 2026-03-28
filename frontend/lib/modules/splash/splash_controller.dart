import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final storage = Get.find<StorageService>();

    // Show onboarding on first launch
    if (!storage.isOnboardingComplete) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    // Check if user is logged in
    final auth = Get.find<AuthService>();
    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
