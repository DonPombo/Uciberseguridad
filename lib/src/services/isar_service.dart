import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/local_lesson_content.dart';
import '../models/local_subject.dart';
import '../models/local_lesson.dart';

class IsarService {
  static final IsarService instance = IsarService._internal();
  Isar? _isar;

  IsarService._internal();

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [LocalLessonContentSchema, LocalSubjectSchema, LocalLessonSchema],
      directory: dir.path,
    );

    return _isar!;
  }

  Future<void> closeDB() async {
    final isar = _isar;
    await isar?.close();
  }

  // Método para limpiar la base de datos (útil para debugging)
  Future<void> clearDB() async {
    final isar = _isar;
    await isar?.writeTxn(() async {
      await isar.localLessonContents.clear();
      await isar.localSubjects.clear();
      await isar.localLessons.clear();
    });
  }
}
