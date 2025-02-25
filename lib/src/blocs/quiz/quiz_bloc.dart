import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uciberseguridad_app/src/models/quiz_model.dart';
import 'package:uciberseguridad_app/src/screens/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

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
      // Aquí cargaríamos el cuestionario desde una fuente de datos
      // Por ahora, usaremos datos de ejemplo
      final quiz = _getQuizForLesson(event.lessonId);
      emit(QuizLoaded(
        quiz: quiz,
        userAnswers: List.filled(quiz.questions.length, null),
      ));
    } catch (e) {
      emit(const QuizError('Error al cargar el cuestionario'));
    }
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final newAnswers = List<int?>.from(currentState.userAnswers);
      newAnswers[event.questionIndex] = event.selectedAnswer;

      final isCompleted = !newAnswers.contains(null);

      emit(currentState.copyWith(
        userAnswers: newAnswers,
        isCompleted: isCompleted,
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
      // Aquí podrías agregar lógica para guardar los resultados
      emit(currentState.copyWith(isCompleted: true));
    }
  }

  Quiz _getQuizForLesson(String lessonId) {
    // Aquí irían los datos de ejemplo del cuestionario
    return Quiz(
      id: 'quiz_1',
      lessonId: lessonId,
      title: 'Fundamentos de Ciberseguridad',
      questions: [
        QuizQuestion(
          question: '¿Qué es la ciberseguridad?',
          options: [
            'Protección de sistemas informáticos',
            'Un tipo de virus',
            'Una red social',
            'Un programa de computadora'
          ],
          correctAnswer: 0,
          explanation:
              'La ciberseguridad se refiere a la práctica de proteger sistemas, redes y programas de ataques digitales.',
        ),
        // Más preguntas aquí...
      ],
    );
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
