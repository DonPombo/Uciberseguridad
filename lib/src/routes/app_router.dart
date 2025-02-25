import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/src/screens/lessons/01-Fundamentos/lesson_content_screen.dart';
import 'package:uciberseguridad_app/src/screens/lessons/01-Fundamentos/subject_detail_screen.dart';
import '../screens/screens.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/lessons',
        builder: (context, state) => const LessonsScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(
          lessonId: '1',
          lessonTitle: 'Fundamentos de Ciberseguridad',
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/subject_detail',
        builder: (context, state) => SubjectDetailScreen(
          subjectTitle: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/lesson_content',
        builder: (context, state) => LessonContentScreen(
          lessonTitle: state.extra as String,
        ),
      ),
    ],
  );
}
