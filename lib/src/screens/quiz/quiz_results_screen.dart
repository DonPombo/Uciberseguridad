import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/src/models/quiz_model.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class QuizResultsScreen extends StatelessWidget {
  final Quiz quiz;
  final List<int> userAnswers;
  final VoidCallback onRetryQuiz;
  final String lessonTitle;

  const QuizResultsScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
    required this.onRetryQuiz,
    required this.lessonTitle,
  });

  int get correctAnswers {
    int correct = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (userAnswers[i] == quiz.questions[i].correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  double get score => (correctAnswers / quiz.questions.length) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cuestionario',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              lessonTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildScoreCard(),
              const SizedBox(height: 24),
              _buildAnswersList(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${score.toInt()}%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$correctAnswers de ${quiz.questions.length} respuestas correctas',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getScoreMessage(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revisión de Respuestas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          quiz.questions.length,
          (index) => _buildAnswerItem(index),
        ),
      ],
    );
  }

  Widget _buildAnswerItem(int index) {
    final question = quiz.questions[index];
    final isCorrect = userAnswers[index] == question.correctAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tu respuesta: ${question.options[userAnswers[index]]}',
            style: TextStyle(
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              'Respuesta correcta: ${question.options[question.correctAnswer]}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              question.explanation!,
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 400) {
          // Vista horizontal para pantallas anchas
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRetryButton(),
              const SizedBox(width: 16),
              _buildBackButton(context),
            ],
          );
        } else {
          // Vista vertical para pantallas estrechas
          return Column(
            children: [
              _buildRetryButton(),
              const SizedBox(height: 12),
              _buildBackButton(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onRetryQuiz,
        icon: const Icon(Icons.refresh),
        label: const Text('Intentar de nuevo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.go('/lessons'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver a la lección'),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.surfaceColor,
          foregroundColor: AppTheme.textColor,
          side: const BorderSide(
            color: AppTheme.accentColor,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  String _getScoreMessage() {
    if (score >= 90) {
      return '¡Excelente! Has dominado este tema.';
    } else if (score >= 70) {
      return '¡Buen trabajo! Has aprobado el cuestionario.';
    } else if (score >= 50) {
      return 'Casi lo logras. ¡Sigue estudiando!';
    } else {
      return 'Necesitas repasar más este tema.';
    }
  }
}
