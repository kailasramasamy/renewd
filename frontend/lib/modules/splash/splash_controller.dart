import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/premium_service.dart';
import '../../core/services/purchase_service.dart';
import '../../core/services/sharing_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/version_check_service.dart';
import '../../app/routes/app_routes.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // Phase 1: Core services (required before anything else)
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Get.putAsync(() => StorageService().init());
    Get.put(ApiClient());

    // Phase 2: PremiumService first (PurchaseService depends on it)
    await Get.putAsync(() => PremiumService().init());

    // Phase 3: Remaining services in parallel
    await Future.wait([
      Get.putAsync(() => PurchaseService().init()),
      Get.putAsync(() => NotificationService().init()),
      Get.putAsync(() => SharingService().init()),
    ]);

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
        await storage.deleteToken();
      }
    }

    // Check if user is logged in
    final auth = Get.find<AuthService>();
    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.find<SharingService>().processPendingShare();
      });
      Get.find<NotificationService>().registerToken();
      VersionCheckService.check();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
