import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uciberseguridad_app/src/models/onboarding_question.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOnboardingQuestions extends OnboardingEvent {}

class AnswerQuestion extends OnboardingEvent {
  final String questionId;
  final String answer;

  const AnswerQuestion({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
}

class NextQuestion extends OnboardingEvent {}

class PreviousQuestion extends OnboardingEvent {}

class CompleteOnboarding extends OnboardingEvent {}

// State
class OnboardingState extends Equatable {
  final List<OnboardingQuestion> questions;
  final int currentQuestionIndex;
  final bool isCompleted;

  const OnboardingState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    List<OnboardingQuestion>? questions,
    int? currentQuestionIndex,
    bool? isCompleted,
  }) {
    return OnboardingState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [questions, currentQuestionIndex, isCompleted];
}

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<LoadOnboardingQuestions>(_onLoadQuestions);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  void _onLoadQuestions(
    LoadOnboardingQuestions event,
    Emitter<OnboardingState> emit,
  ) {
    final questions = [
      OnboardingQuestion(
        id: '1',
        question: '¿Cuál es tu nivel de experiencia en ciberseguridad?',
        options: ['Principiante', 'Intermedio', 'Avanzado'],
      ),
      OnboardingQuestion(
        id: '2',
        question: '¿Qué área de ciberseguridad te interesa más?',
        options: [
          'Seguridad de Redes',
          'Análisis de Malware',
          'Seguridad Web',
          'Criptografía',
          'Otro'
        ],
      ),
      OnboardingQuestion(
        id: '3',
        question: '¿Cuántas horas semanales puedes dedicar al aprendizaje?',
        options: ['1-3 horas', '4-6 horas', '7-10 horas', 'Más de 10 horas'],
      ),
    ];

    emit(state.copyWith(questions: questions));
  }

  void _onAnswerQuestion(
    AnswerQuestion event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedQuestions = state.questions.map((question) {
      if (question.id == event.questionId) {
        return question.copyWith(selectedOption: event.answer);
      }
      return question;
    }).toList();

    emit(state.copyWith(questions: updatedQuestions));
  }

  void _onNextQuestion(
    NextQuestion event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1));
    }
  }

  void _onPreviousQuestion(
    PreviousQuestion event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentQuestionIndex > 0) {
      emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  void _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(isCompleted: true));
  }
}
