import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/version_check_service.dart';
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

    // Refresh Firebase token if user has an active session
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final token = await firebaseUser.getIdToken();
        if (token != null) {
          await storage.saveToken(token);
        }
      } catch (_) {
        // Token refresh failed — clear stale token
        await storage.deleteToken();
      }
    }

    // Check if user is logged in
    final auth = Get.find<AuthService>();
    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
      // Re-register FCM token + device info (non-blocking)
      Get.find<NotificationService>().registerToken();
      // Check for updates after navigating (non-blocking)
      VersionCheckService.check();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
