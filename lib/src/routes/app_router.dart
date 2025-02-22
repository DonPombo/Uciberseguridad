import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import '../screens/screens.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomBar(child: child);
        },
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
            builder: (context, state) => const QuizScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

// Widget for bottom navigation bar
class ScaffoldWithBottomBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavegationBar(),
    );
  }
}
