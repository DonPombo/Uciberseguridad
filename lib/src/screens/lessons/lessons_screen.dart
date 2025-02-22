import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/screens/lessons/subject_detail_screen.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

/// Screen that displays all available cybersecurity lessons.
/// Handles lesson navigation, progress tracking, and search functionality.
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Lecciones',
          style: TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildLessonsList(),
          ],
        ),
      ),
    );
  }

  /// Builds a custom search bar for filtering lessons.
  ///
  /// Features:
  /// - Custom styling matching app theme
  /// - Placeholder text
  /// - Search icon
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        style: const TextStyle(color: AppTheme.textColor),
        decoration: InputDecoration(
          hintText: 'Buscar lecciones...',
          hintStyle: TextStyle(color: AppTheme.textColor.withOpacity(0.5)),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppTheme.textColor.withOpacity(0.5)),
        ),
      ),
    );
  }

  /// Constructs the main scrollable list of lesson cards.
  ///
  /// Each card represents a distinct cybersecurity lesson with:
  /// - Progress tracking
  /// - Interactive elements
  /// - Visual indicators
  Widget _buildLessonsList() {
    return Column(
      children: [
        _buildLessonItem(
          'Fundamentos de Ciberseguridad',
          'Introducción y conceptos básicos',
          Icons.security,
          AppTheme.secondaryColor,
          0.0,
        ),
        _buildLessonItem(
          'Contraseñas Seguras',
          'Gestión y creación de contraseñas fuertes',
          Icons.password,
          AppTheme.quaternaryColor,
          1.0,
        ),
        _buildLessonItem(
          'Protección contra Phishing',
          'Identificación y prevención de estafas',
          Icons.email,
          AppTheme.tertiaryColor,
          0.78,
        ),
        _buildLessonItem(
          'Privacidad Digital',
          'Protección de datos personales',
          Icons.privacy_tip,
          AppTheme.quinaryColor,
          0.35,
        ),
      ],
    );
  }

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
  ///
  /// The card's action button shows different states:
  /// - "Empezar" (0% progress)
  /// - "Continuar" (1-99% progress)
  /// - "Completado" (100% progress)
  Widget _buildLessonItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
  ) {
    final String buttonText = _determineButtonText(progress);

    return InkWell(
      onTap: () {
        debugPrint('Navigating to lesson: $title');
      },
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
            _buildLessonHeader(title, subtitle, icon, color),

            const SizedBox(height: 16),

            // Progress visualization
            _buildProgressIndicator(progress, color),

            const SizedBox(height: 8),

            // Action section with responsive layout
            _buildActionSection(progress, buttonText, title),
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

  /// Builds the lesson header which includes:
  /// - Icon with custom background color
  /// - Lesson title
  /// - Descriptive subtitle
  Widget _buildLessonHeader(
      String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a custom progress indicator for the lesson.
  ///
  /// Displays a progress bar with:
  /// - Custom color based on lesson category
  /// - Rounded corners
  /// - Custom height
  Widget _buildProgressIndicator(double progress, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppTheme.backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 8,
      ),
    );
  }

  /// Builds the action section that adapts to available width.
  ///
  /// Features:
  /// - Responsive layout that switches between Row and Column
  /// - Shows progress percentage
  /// - Action button that changes based on progress state
  Widget _buildActionSection(double progress, String buttonText, String title) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const textWidth = 150.0;
        const buttonWidth = 100.0;

        if (availableWidth >= textWidth + buttonWidth + 20) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% Completado',
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              if (progress >= 1.0)
                Text(
                  buttonText,
                  style: TextStyle(
                    color: AppTheme.textColor.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectDetailScreen(
                          subjectTitle: title,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(progress * 100).toInt()}% Completado',
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              if (progress >= 1.0)
                Text(
                  buttonText,
                  style: TextStyle(
                    color: AppTheme.textColor.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectDetailScreen(
                          subjectTitle: title,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}
