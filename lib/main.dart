import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'modules/not_found/not_found_page.dart';
import 'routes/app_pages.dart';
import 'services/assets_service.dart';
import 'services/localization_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalizationService.init();

  // Initialize StorageService
  await Get.putAsync(() => StorageService().init());

  // Initialize AssetsService
  await Get.putAsync(() => AssetsService().init().then((_) => AssetsService()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final isLoggedIn = storageService.getToken() != null;

    return ScreenUtilInit(
      designSize: const Size(
        428,
        926,
      ), // Design size from Figma (iPhone 13 Pro Max approx)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Traffic App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: isLoggedIn ? Routes.HOME : AppPages.INITIAL,
          getPages: AppPages.routes,
          unknownRoute: GetPage(name: '/404', page: () => NotFoundPage()),
          translations: LocalizationService(),
          locale: LocalizationService.locale,
          fallbackLocale: LocalizationService.fallbackLocale,
        );
      },
    );
  }
}
