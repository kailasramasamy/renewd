import 'package:get/get.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/auth/login_screen.dart';
import '../../modules/document/document_detail_screen.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/notifications/notification_settings_screen.dart';
import '../../modules/renewal/add_renewal_screen.dart';
import '../../modules/renewal/renewal_detail_screen.dart';
import '../../modules/renewal/edit_renewal_screen.dart';
import '../../modules/renewal/scan_add_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.addRenewal,
      page: () => const AddRenewalScreen(),
    ),
    GetPage(
      name: AppRoutes.renewalDetail,
      page: () => const RenewalDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.editRenewal,
      page: () => const EditRenewalScreen(),
    ),
    GetPage(
      name: AppRoutes.documentDetail,
      page: () => const DocumentDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.scanAdd,
      page: () => const ScanAddScreen(),
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsScreen(),
    ),
  ];
}
