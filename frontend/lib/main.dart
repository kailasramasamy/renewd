import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  runApp(const MinderApp());
}

class MinderApp extends StatelessWidget {
  const MinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Minder',
      theme: MinderTheme.light,
      darkTheme: MinderTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}
