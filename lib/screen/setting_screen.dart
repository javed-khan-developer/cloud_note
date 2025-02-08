import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/localization_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LocalizationController localizationController =
        Get.find<LocalizationController>();

    return Scaffold(
      appBar: AppBar(title: const Text('')), // Localized title
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Language', // Localized text
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Obx(() => DropdownButton<String>(
                  value: localizationController.locale.value.languageCode,
                  onChanged: (String? newLanguage) {
                    if (newLanguage != null) {
                      localizationController.changeLanguage(newLanguage);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
