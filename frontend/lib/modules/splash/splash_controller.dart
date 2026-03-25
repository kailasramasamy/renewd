import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // Dev mode: skip auth, go straight to home
    if (AppConstants.apiBaseUrl.contains('localhost')) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    final auth = Get.find<AuthService>();
    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
