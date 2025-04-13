import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/local_lesson_content.dart';
import '../models/local_subject.dart';
import '../models/local_lesson.dart';
import '../models/local_quiz.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  static IsarService get instance => _instance;
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        LocalLessonContentSchema,
        LocalSubjectSchema,
        LocalLessonSchema,
        LocalQuizSchema,
      ],
      directory: dir.path,
    );
    return _isar!;
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  // Método para limpiar la base de datos (útil para debugging)
  Future<void> clearDB() async {
    final isarInstance = await isar;
    await isarInstance.writeTxn(() async {
      await isarInstance.localLessonContents.clear();
      await isarInstance.localSubjects.clear();
      await isarInstance.localLessons.clear();
      await isarInstance.localQuizs.clear();
    });
  }
}
