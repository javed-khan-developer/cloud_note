import 'package:isar/isar.dart';

part 'user_settings.g.dart';

@Collection()
class UserSettings {
  Id id = 0; // Always a single entry, so fixed ID
  String languageCode;

  UserSettings({required this.languageCode});
}
