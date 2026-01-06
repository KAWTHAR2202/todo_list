import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui/home_page.dart';
import 'service/notification_service.dart';
import 'controller/theme_controller.dart';
import 'controller/achievement_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Initialize controllers
  Get.put(ThemeController());
  Get.put(AchievementController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: themeController.lightTheme,
        darkTheme: themeController.darkTheme,
        themeMode: themeController.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        home: const HomePage(),
      ),
    );
  }
}
