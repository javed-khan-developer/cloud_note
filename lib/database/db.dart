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
          [NotesSchema],
          directory: dir.path,
        );
      } catch (e) {
        throw Exception('Failed to open database: $e');
      }
    }
    return _isar!;
  }

  /// Function to create a notes in the database
  static Future<void> createNotes(Notes note) async {
    final isar = await DatabaseService.instance.db;
    try {
      await isar.writeTxn(() async {
        await isar.notes.put(note); // Insert or update the notes
      });
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  /// Function to read a notes by ID from the database
  static Future<Notes?> readNote(int id) async {
    final isar = await DatabaseService.instance.db;
    try {
      return await isar.notes.get(id); // Fetch note by ID
    } catch (e) {
      throw Exception('Failed to read note with ID $id: $e');
    }
  }

  /// Function to read all notes from the database
  static Future<List<Notes>> readAllNotes() async {
    final isar = await DatabaseService.instance.db;
    try {
      return await isar.notes.where().findAll(); // Fetch note by ID
    } catch (e) {
      throw Exception('Failed to read notes : $e');
    }
  }

  /// Function to update a note's details in the database
  static Future<void> updateNotes(
    int id, {
    String? title,
    String? description,
    DateTime? date,
    String? imagePath,
  }) async {
    final isar = await DatabaseService.instance.db;
    try {
      final note = await isar.notes.get(id);
      if (note != null) {
        if (title != null) note.title = title;
        if (description != null) note.description = description;
        if (date != null) note.date = date;
        if (imagePath != null) note.imagePath = imagePath;

        await isar.writeTxn(() async {
          await isar.notes.put(note); // Update the note
        });
      } else {
        throw Exception('Note with ID $id not found');
      }
    } catch (e) {
      throw Exception('Failed to update note with ID $id: $e');
    }
  }

  /// Function to delete a note by ID from the database
  static Future<void> deleteNote(int id) async {
    final isar = await DatabaseService.instance.db;
    try {
      await isar.writeTxn(() async {
        await isar.notes.delete(id); // Delete the note by ID
      });
    } catch (e) {
      throw Exception('Failed to delete note with ID $id: $e');
    }
  }
}
