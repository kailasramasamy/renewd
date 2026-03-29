import 'package:get/get.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/auth/complete_profile_screen.dart';
import '../../modules/auth/login_screen.dart';
import '../../modules/auth/otp_verify_screen.dart';
import '../../modules/document/document_detail_screen.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/chat/chat_screen.dart';
import '../../modules/profile/profile_screen.dart';
import '../../modules/features/features_screen.dart';
import '../../modules/premium/premium_screen.dart';
import '../../modules/notifications/notification_inbox_screen.dart';
import '../../modules/onboarding/onboarding_screen.dart';
import '../../modules/notifications/notification_settings_screen.dart';
import '../../modules/renewal/add_renewal_screen.dart';
import '../../modules/renewal/renewal_detail_screen.dart';
import '../../modules/renewal/edit_renewal_screen.dart';
import '../../modules/renewal/scan_add_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    // Auth flow — fade transitions
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otpVerify,
      page: () => const OtpVerifyScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => const CompleteProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),

    // Main screens — iOS native push
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      transition: Transition.cupertino,
    ),

    // Renewal flow — iOS native push
    GetPage(
      name: AppRoutes.addRenewal,
      page: () => const AddRenewalScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.renewalDetail,
      page: () => const RenewalDetailScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editRenewal,
      page: () => const EditRenewalScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.scanAdd,
      page: () => const ScanAddScreen(),
      transition: Transition.cupertino,
    ),

    // Documents
    GetPage(
      name: AppRoutes.documentDetail,
      page: () => const DocumentDetailScreen(),
      transition: Transition.cupertino,
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.notificationInbox,
      page: () => const NotificationInboxScreen(),
      transition: Transition.cupertino,
    ),

    // Info/settings screens — slide up (modal feel)
    GetPage(
      name: AppRoutes.features,
      page: () => const FeaturesScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const PremiumScreen(),
      transition: Transition.downToUp,
    ),
  ];
}
