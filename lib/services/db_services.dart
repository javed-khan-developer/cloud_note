import 'package:cloud_note/model/user_settings.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../model/notes.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Isar? _isar;

  DatabaseService._internal();

  static DatabaseService get instance => _instance;

  Future<Isar> get db async {
    if (_isar == null || !_isar!.isOpen) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [
            NotesSchema,
            UserSettingsSchema,
          ],
          directory: dir.path,
        );
      } catch (e) {
        throw Exception('Failed to open database: $e');
      }
    }
    return _isar!;
  }
}
