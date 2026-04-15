import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
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
