import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/action_section.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/lesson_header.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/progress_indicator.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

/// Creates an individual lesson card with dynamic states and responsive layout.
///
/// The card adapts its layout based on screen width and lesson progress state.
///
/// Parameters:
/// - [title] - The lesson's display name
/// - [subtitle] - Brief description of lesson content
/// - [icon] - MaterialIcon representing the lesson category
/// - [color] - Theme color for visual distinction
/// - [progress] - Completion percentage (0.0 to 1.0)
/// - [lessonId] - Unique identifier for the lesson
/// - [onTap] - Callback function when the card is tapped
///
/// The card's action button shows different states:
/// - "Empezar" (0% progress)
/// - "Continuar" (1-99% progress)
/// - "Completado" (100% progress)
Widget buildLessonItem(
  String title,
  String subtitle,
  IconData icon,
  Color color,
  double progress,
  String lessonId, {
  VoidCallback? onTap,
}) {
  final String buttonText = _determineButtonText(progress);

  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Header section with lesson identity
          buildLessonHeader(title, subtitle, icon, color),
          const SizedBox(height: 16),

          // Progress visualization
          buildProgressIndicator(progress, color),
          const SizedBox(height: 8),

          // Action section with responsive layout
          buildActionSection(progress, buttonText, title, lessonId),
        ],
      ),
    ),
  );
}

/// Determines the button text based on lesson progress.
String _determineButtonText(double progress) {
  if (progress >= 1.0) return 'Completado';
  if (progress > 0) return 'Continuar';
  return 'Empezar';
}
