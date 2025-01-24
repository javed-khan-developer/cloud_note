import 'package:isar/isar.dart';

part 'notes.g.dart';

@collection
class Notes {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  String? title;
  String? description;
  DateTime? date;
  String? imagePath;
}
