class Quiz {
  final String id;
  final String lessonId;
  final String title;
  final List<QuizQuestion> questions;
  final bool isCompleted;
  final int score;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.questions,
    this.isCompleted = false,
    this.score = 0,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });
}
