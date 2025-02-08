import 'package:cloud_note/model/user_settings.dart';
import 'package:isar/isar.dart';

import 'db_services.dart';

class UserSettingsService{

  static Future<void> saveLanguage(String langCode) async {
    final isar = await DatabaseService.instance.db;
    final existing = await isar.userSettings.where().findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        existing.languageCode = langCode;
        await isar.userSettings.put(existing);
      } else {
        await isar.userSettings.put(UserSettings(languageCode: langCode));
      }
    });
  }

  static Future<String> getLanguage() async {
    final isar = await DatabaseService.instance.db;

    final settings = await isar.userSettings.where().findFirst();
    return settings?.languageCode ?? 'en'; // Default to English if not set
  }
}