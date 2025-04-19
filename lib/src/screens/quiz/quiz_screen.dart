import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uciberseguridad_app/src/blocs/quiz/quiz_bloc.dart';
import 'package:uciberseguridad_app/src/models/models.dart';
import 'package:uciberseguridad_app/src/screens/quiz/quiz_results_screen.dart';
import 'package:uciberseguridad_app/src/widgets/appbar_screen.dart';
import 'package:uciberseguridad_app/src/widgets/side_menu.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class QuizScreen extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;

  const QuizScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizBloc()..add(LoadQuiz(lessonId)),
      child: Scaffold(
        drawer: const SideMenu(),
        appBar: const AppBarScreen(
          title: 'Cuestionario',
        ),
        body: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            Text(lessonTitle);
            if (state is QuizLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentColor,
                ),
              );
            }

            if (state is QuizLoaded) {
              return _QuizContent(state: state);
            }

            if (state is QuizError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _QuizContent extends StatelessWidget {
  final QuizLoaded state;

  const _QuizContent({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isCompleted) {
      return QuizResultsScreen(
        quiz: state.quiz,
        userAnswers: state.userAnswers.map((e) => e ?? -1).toList(),
        onRetryQuiz: () {
          context.read<QuizBloc>().add(LoadQuiz(state.quiz.lessonId));
        },
        lessonTitle: state.quiz.title,
      );
    }

    final currentQuestion = state.quiz.questions[state.currentQuestionIndex];
    final hasAnsweredCurrent =
        state.userAnswers[state.currentQuestionIndex] != null;

    return Column(
      children: [
        _buildProgressIndicator(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionCard(currentQuestion),
                const SizedBox(height: 24),
                _buildOptions(context, currentQuestion),
              ],
            ),
          ),
        ),
        _buildNavigationButtons(context, hasAnsweredCurrent),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta ${state.currentQuestionIndex + 1}/${state.quiz.questions.length}',
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${((state.currentQuestionIndex + 1) / state.quiz.questions.length * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (state.currentQuestionIndex + 1) /
                  state.quiz.questions.length,
              backgroundColor: AppTheme.backgroundColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.accentColor,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        question.question,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, QuizQuestion question) {
    return Column(
      children: List.generate(
        question.options.length,
        (index) => _buildOptionButton(
          context,
          question.options[index],
          index,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, bool hasAnsweredCurrent) {
    final allQuestionsAnswered = _allQuestionsAnswered();

    debugPrint('🔘 Construyendo botones de navegación:');
    debugPrint(
        '   - Es última pregunta: ${state.currentQuestionIndex == state.quiz.questions.length - 1}');
    debugPrint('   - Pregunta actual respondida: $hasAnsweredCurrent');
    debugPrint('   - Todas las preguntas respondidas: $allQuestionsAnswered');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (state.currentQuestionIndex > 0)
            ElevatedButton.icon(
              onPressed: () {
                context.read<QuizBloc>().add(PreviousQuestion());
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Anterior'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                foregroundColor: AppTheme.textColor,
              ),
            )
          else
            const SizedBox(width: 100),
          if (state.currentQuestionIndex < state.quiz.questions.length - 1)
            ElevatedButton.icon(
              onPressed: hasAnsweredCurrent
                  ? () {
                      context.read<QuizBloc>().add(NextQuestion());
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                disabledBackgroundColor: AppTheme.accentColor.withOpacity(0.3),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: allQuestionsAnswered
                  ? () {
                      debugPrint(
                          '🏁 Usuario finalizando cuestionario manualmente');
                      context.read<QuizBloc>().add(FinishQuiz());
                    }
                  : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('Finalizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                disabledBackgroundColor: AppTheme.accentColor.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }

  bool _allQuestionsAnswered() {
    return !state.userAnswers.contains(null);
  }

  Widget _buildOptionButton(
    BuildContext context,
    String option,
    int index,
  ) {
    final isSelected = state.userAnswers[state.currentQuestionIndex] == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          context.read<QuizBloc>().add(
                AnswerQuestion(state.currentQuestionIndex, index),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? AppTheme.secondaryColor : AppTheme.surfaceColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? AppTheme.secondaryColor
                  : AppTheme.textColor.withOpacity(0.2),
            ),
          ),
          disabledBackgroundColor: isSelected
              ? AppTheme.secondaryColor
              : AppTheme.surfaceColor.withOpacity(0.7),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.7)
                    : AppTheme.accentColor.withOpacity(0.1),
                border: Border.all(
                  color: isSelected
                      ? Colors.green
                      : AppTheme.accentColor.withOpacity(0.5),
                ),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.black.withOpacity(0.8)
                        : AppTheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected
                      ? Colors.black.withOpacity(0.8)
                      : AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
