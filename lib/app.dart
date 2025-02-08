import 'package:cloud_note/l10n/l10n.dart';
import 'package:cloud_note/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controller/localization_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotesApp extends StatelessWidget {
  final LocalizationController localizationController =
      Get.put(LocalizationController());

  NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: localizationController.locale.value,
      // Use GetX locale
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Offline Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
