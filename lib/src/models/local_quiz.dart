import 'package:isar/isar.dart';

part 'local_quiz.g.dart';

@embedded
class LocalQuizQuestion {
  late String text;
  late List<String> options;
  late int correctOptionIndex;
  String? explanation;

  LocalQuizQuestion({
    this.text = '',
    this.options = const [],
    this.correctOptionIndex = 0,
    this.explanation,
  });
}

@collection
@Name('localQuizs')
class LocalQuiz {
  Id id = Isar.autoIncrement;

  @Index()
  late String lessonId;

  late String title;

  late List<LocalQuizQuestion> questions;

  late DateTime createdAt;

  late DateTime updatedAt;

  String supabaseId;

  LocalQuiz({
    required this.lessonId,
    required this.title,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
    required this.supabaseId,
  });
}
