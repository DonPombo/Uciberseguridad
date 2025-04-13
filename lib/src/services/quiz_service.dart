import 'package:isar/isar.dart';
import '../models/local_quiz.dart';
import 'isar_service.dart';
import 'package:flutter/foundation.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  late final Isar _isar;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isar = await IsarService.instance.isar;
    _isInitialized = true;
  }

  Future<List<LocalQuiz>> getQuizzesByContentId(String contentId) async {
    if (!_isInitialized) await init();
    debugPrint('🔍 QuizService: Buscando cuestionarios');
    debugPrint('   - Content ID buscado: $contentId');

    // Obtener todos los cuestionarios para debugging
    final allQuizzes = await _isar.localQuizs.where().findAll();
    debugPrint('   - Total de cuestionarios en la BD: ${allQuizzes.length}');
    for (var quiz in allQuizzes) {
      debugPrint('   - Quiz encontrado:');
      debugPrint('     * ID: ${quiz.id}');
      debugPrint('     * Content ID: ${quiz.contentId}');
      debugPrint('     * Título: ${quiz.title}');
    }

    final quizzes =
        await _isar.localQuizs.filter().contentIdEqualTo(contentId).findAll();

    debugPrint(
        '   - Cuestionarios encontrados para contentId $contentId: ${quizzes.length}');
    return quizzes;
  }

  Future<LocalQuiz?> getQuizById(int id) async {
    if (!_isInitialized) await init();
    return await _isar.localQuizs.get(id);
  }

  Future<void> createQuiz({
    required String contentId,
    required String title,
    required List<LocalQuizQuestion> questions,
  }) async {
    if (!_isInitialized) await init();
    final now = DateTime.now();
    final quiz = LocalQuiz(
      contentId: contentId,
      title: title,
      questions: questions,
      createdAt: now,
      updatedAt: now,
    );

    await _isar.writeTxn(() async {
      await _isar.localQuizs.put(quiz);
    });
  }

  Future<void> updateQuiz(
    int id, {
    required String title,
    required List<LocalQuizQuestion> questions,
  }) async {
    if (!_isInitialized) await init();
    final quiz = await getQuizById(id);
    if (quiz == null) throw Exception('Quiz no encontrado');

    quiz.title = title;
    quiz.questions = questions;
    quiz.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.localQuizs.put(quiz);
    });
  }

  Future<void> deleteQuiz(int id) async {
    if (!_isInitialized) await init();
    await _isar.writeTxn(() async {
      await _isar.localQuizs.delete(id);
    });
  }
}
