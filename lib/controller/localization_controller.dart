import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_setting_service.dart';

class LocalizationController extends GetxController {
  var locale = const Locale('en', '').obs; // Default to English

  @override
  void onInit() {
    _loadSavedLanguage();
    super.onInit();
  }

  void _loadSavedLanguage() async {
    String savedLanguage = await UserSettingsService.getLanguage();
    locale.value = Locale(savedLanguage, '');
    log('savedLanguage $savedLanguage');
    Get.updateLocale(locale.value); // Force locale update
  }

  void changeLanguage(String languageCode) async {
    locale.value = Locale(languageCode, '');
    await UserSettingsService.saveLanguage(languageCode);
    log('changeLanguage $languageCode');
    Get.updateLocale(locale.value);
  }
}
