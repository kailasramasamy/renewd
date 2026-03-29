import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/network/api_client.dart';
import 'core/services/notification_service.dart';
import 'core/services/premium_service.dart';
import 'core/services/purchase_service.dart';
import 'core/services/sharing_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Get.putAsync(() => StorageService().init());
  Get.put(ApiClient());
  await Get.putAsync(() => PremiumService().init());
  await Get.putAsync(() => PurchaseService().init());
  await Get.putAsync(() => NotificationService().init());
  await Get.putAsync(() => SharingService().init());
  runApp(const RenewdApp());
}

class RenewdApp extends StatelessWidget {
  const RenewdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Renewd',
      theme: RenewdTheme.light,
      darkTheme: RenewdTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}
