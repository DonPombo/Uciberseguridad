import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uciberseguridad_app/src/models/quiz_model.dart';
import 'package:uciberseguridad_app/src/models/local_quiz.dart';
import 'package:uciberseguridad_app/src/services/quiz_service.dart';
import 'package:uciberseguridad_app/src/screens/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadQuiz extends QuizEvent {
  final String lessonId;

  const LoadQuiz(this.lessonId);

  @override
  List<Object> get props => [lessonId];
}

class AnswerQuestion extends QuizEvent {
  final int questionIndex;
  final int selectedAnswer;

  const AnswerQuestion(this.questionIndex, this.selectedAnswer);

  @override
  List<Object> get props => [questionIndex, selectedAnswer];
}

class NextQuestion extends QuizEvent {}

class PreviousQuestion extends QuizEvent {}

class FinishQuiz extends QuizEvent {}

// States
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final Quiz quiz;
  final int currentQuestionIndex;
  final List<int?> userAnswers;
  final bool isCompleted;

  const QuizLoaded({
    required this.quiz,
    this.currentQuestionIndex = 0,
    required this.userAnswers,
    this.isCompleted = false,
  });

  @override
  List<Object> get props =>
      [quiz, currentQuestionIndex, userAnswers, isCompleted];

  QuizLoaded copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    List<int?>? userAnswers,
    bool? isCompleted,
  }) {
    return QuizLoaded(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizService _quizService = QuizService();

  QuizBloc() : super(QuizInitial()) {
    on<LoadQuiz>(_onLoadQuiz);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<FinishQuiz>(_onFinishQuiz);
  }

  void _onLoadQuiz(LoadQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      debugPrint(
          '🔍 Buscando cuestionarios para el contenido ID: ${event.lessonId}');
      final quizzes = await _quizService.getQuizzesByContentId(event.lessonId);
      debugPrint('📊 Cuestionarios encontrados: ${quizzes.length}');

      if (quizzes.isEmpty) {
        debugPrint('❌ No se encontraron cuestionarios');
        emit(const QuizError(
            'No hay cuestionario disponible para este contenido'));
        return;
      }

      debugPrint('✅ Cuestionario encontrado:');
      debugPrint('   - ID: ${quizzes.first.id}');
      debugPrint('   - Título: ${quizzes.first.title}');
      debugPrint('   - Contenido ID: ${quizzes.first.contentId}');
      debugPrint('   - Número de preguntas: ${quizzes.first.questions.length}');

      final quiz = _convertLocalQuizToQuiz(quizzes.first);
      emit(QuizLoaded(
        quiz: quiz,
        userAnswers: List.filled(quiz.questions.length, null),
      ));
    } catch (e) {
      debugPrint('❌ Error cargando cuestionario: $e');
      emit(QuizError('Error al cargar el cuestionario: $e'));
    }
  }

  Quiz _convertLocalQuizToQuiz(LocalQuiz localQuiz) {
    debugPrint('🔄 Convirtiendo LocalQuiz a Quiz:');
    debugPrint('   - ID Original: ${localQuiz.id}');
    debugPrint('   - ID Convertido: ${localQuiz.id.toString()}');
    debugPrint('   - Contenido ID: ${localQuiz.contentId}');

    final quiz = Quiz(
      id: localQuiz.id.toString(),
      lessonId: localQuiz.contentId,
      title: localQuiz.title,
      questions: localQuiz.questions
          .map((q) => QuizQuestion(
                question: q.text,
                options: q.options,
                correctAnswer: q.correctOptionIndex,
                explanation: q.explanation,
              ))
          .toList(),
    );

    debugPrint('✅ Conversión completada');
    return quiz;
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      debugPrint('📝 Respondiendo pregunta:');
      debugPrint('   - Índice de pregunta: ${event.questionIndex}');
      debugPrint('   - Respuesta seleccionada: ${event.selectedAnswer}');

      final currentState = state as QuizLoaded;
      final newAnswers = List<int?>.from(currentState.userAnswers);
      newAnswers[event.questionIndex] = event.selectedAnswer;

      debugPrint(
          '   - Respuesta guardada, esperando que el usuario finalice el cuestionario');

      emit(currentState.copyWith(
        userAnswers: newAnswers,
        isCompleted: currentState.isCompleted,
      ));
    }
  }

  void _onNextQuestion(NextQuestion event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex <
          currentState.quiz.questions.length - 1) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
        ));
      }
    }
  }

  void _onPreviousQuestion(PreviousQuestion event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex > 0) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex - 1,
        ));
      }
    }
  }

  void _onFinishQuiz(FinishQuiz event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      debugPrint('🏁 Finalizando cuestionario');
      debugPrint('   - Respuestas del usuario: ${currentState.userAnswers}');
      emit(currentState.copyWith(isCompleted: true));
    }
  }

  void navigateToQuiz(
      BuildContext context, String lessonId, String lessonTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          lessonId: lessonId, // O el ID específico de la lección
          lessonTitle: lessonTitle,
        ),
      ),
    );
  }
}
