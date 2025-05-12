import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/local_quiz.dart';
import 'isar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  late final Isar _isar;
  bool _isInitialized = false;
  static QuizService? _instance;
  final SupabaseClient _supabaseClient;

  QuizService._(this._supabaseClient);

  static QuizService get instance {
    _instance ??= QuizService._(Supabase.instance.client);
    return _instance!;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isar = await IsarService.instance.isar;
    _isInitialized = true;
  }

  /// Crear y guardar un cuestionario
  Future<void> createQuiz({
    required String subjectId,
    required String title,
    required List<LocalQuizQuestion> questions,
  }) async {
    await init();
    final now = DateTime.now();
    try {
      debugPrint('ID de subtema usado para crear quiz: $subjectId');

      // Verificar que el subtema existe
      final quizResponse = await _supabaseClient
          .from('quizzes')
          .insert({
            'subject_id': subjectId,
            'title': title,
            'is_completed': false,
            'score': 0,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select()
          .single();
      final quizId = quizResponse['id'];
      for (var q in questions) {
        final questionData = {
          'quiz_id': quizId,
          'question': q.text,
          'options': q.options,
          'correct_answer': q.correctOptionIndex,
          'explanation': q.explanation,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
        await _supabaseClient.from('quiz_questions').insert(questionData);
      }
      final quiz = LocalQuiz(
        lessonId: subjectId,
        title: title,
        questions: questions,
        createdAt: now,
        updatedAt: now,
        supabaseId: quizId.toString(),
      );
      await _isar.writeTxn(() async {
        await _isar.localQuizs.put(quiz);
      });
    } catch (e) {
      debugPrint('❌ Error creando cuestionario: $e');
      rethrow;
    }
  }

  /// Obtener todos los cuestionarios de un subtema
  Future<List<LocalQuiz>> getQuizzesByLessonId(String subjectId) async {
    await init();
    // Primero intentamos obtener de Isar
    final localQuizzes =
        await _isar.localQuizs.filter().lessonIdEqualTo(subjectId).findAll();
    return localQuizzes;
  }

  /// Obtener un cuestionario por su ID local
  Future<LocalQuiz?> getQuizById(int id) async {
    await init();
    return await _isar.localQuizs.get(id);
  }

  /// Actualizar un cuestionario (título y preguntas)
  Future<void> updateQuiz({
    required String localId,
    required String title,
    required List<LocalQuizQuestion> questions,
  }) async {
    await init();
    final quiz = await _isar.localQuizs.get(int.parse(localId));
    if (quiz == null) throw Exception('Cuestionario no encontrado localmente');
    final now = DateTime.now();
    // Actualizar en Supabase
    await _supabaseClient.from('quizzes').update({
      'title': title,
      'updated_at': now.toIso8601String(),
    }).eq('id', quiz.supabaseId);
    // (Opcional) Actualizar preguntas en Supabase si tienes lógica para ello
    // Actualizar en Isar
    quiz.title = title;
    quiz.questions = questions;
    quiz.updatedAt = now;
    await _isar.writeTxn(() async {
      await _isar.localQuizs.put(quiz);
    });
  }

  /// Eliminar un cuestionario por su ID local
  Future<void> deleteQuiz(int localId) async {
    await init();
    final quiz = await _isar.localQuizs.get(localId);
    if (quiz == null) return;
    // Eliminar en Supabase
    await _supabaseClient.from('quizzes').delete().eq('id', quiz.supabaseId);
    // Eliminar en Isar
    await _isar.writeTxn(() async {
      await _isar.localQuizs.delete(localId);
    });
  }
}
