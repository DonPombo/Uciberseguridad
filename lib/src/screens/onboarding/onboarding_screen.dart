import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/src/blocs/onboarding/onboarding_bloc.dart';
import 'package:uciberseguridad_app/src/models/onboarding_question.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(LoadOnboardingQuestions()),
      child: const Scaffold(
        body: OnboardingView(),
      ),
    );
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state.questions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentColor,
            ),
          );
        }

        final currentQuestion = state.questions[state.currentQuestionIndex];

        return Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Ayúdanos a mejorar tu experiencia',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionCard(currentQuestion),
                      const SizedBox(height: 24),
                      _buildOptions(context, currentQuestion),
                      const SizedBox(height: 32),
                      _buildProgressDots(state),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressDots(OnboardingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        state.questions.length,
        (index) => Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == state.currentQuestionIndex
                ? AppTheme.accentColor
                : AppTheme.accentColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(OnboardingQuestion question) {
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

  Widget _buildOptions(BuildContext context, OnboardingQuestion question) {
    return Column(
      children: List.generate(
        question.options.length,
        (index) => _buildOptionButton(
          context,
          question.options[index],
          index,
          question,
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String option,
    int index,
    OnboardingQuestion question,
  ) {
    final isSelected = question.selectedOption == option;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          context.read<OnboardingBloc>().add(
                AnswerQuestion(
                  questionId: question.id,
                  answer: option,
                ),
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

  Widget _buildNavigationButtons(BuildContext context, OnboardingState state) {
    final hasAnsweredCurrent =
        state.questions[state.currentQuestionIndex].selectedOption != null;

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
                context.read<OnboardingBloc>().add(PreviousQuestion());
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
          if (state.currentQuestionIndex < state.questions.length - 1)
            ElevatedButton.icon(
              onPressed: hasAnsweredCurrent
                  ? () {
                      context.read<OnboardingBloc>().add(NextQuestion());
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
              onPressed: () {
                context.read<OnboardingBloc>().add(CompleteOnboarding());
                try {
                  context.go('/');
                } catch (e) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
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
}
