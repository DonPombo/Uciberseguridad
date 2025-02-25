import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/lesson_item.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/search_bar.dart';
import 'package:uciberseguridad_app/src/widgets/appbar_screen.dart';
import 'package:uciberseguridad_app/src/widgets/side_menu.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        drawer: const SideMenu(),
        appBar: const AppBarScreen(
          title: 'Lecciones',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSearchBar(),
              const SizedBox(height: 24),
              _buildLessonsList(),
            ],
          ),
        ),
      );
    });
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
        buildLessonItem(
          'Fundamentos de Ciberseguridad',
          'Introducción y conceptos básicos',
          Icons.security,
          AppTheme.secondaryColor,
          0.0,
        ),
        buildLessonItem(
          'Contraseñas Seguras',
          'Gestión y creación de contraseñas fuertes',
          Icons.password,
          AppTheme.quaternaryColor,
          1.0,
        ),
        buildLessonItem(
          'Protección contra Phishing',
          'Identificación y prevención de estafas',
          Icons.email,
          AppTheme.tertiaryColor,
          0.78,
        ),
        buildLessonItem(
          'Privacidad Digital',
          'Protección de datos personales',
          Icons.privacy_tip,
          AppTheme.quinaryColor,
          0.35,
        ),
      ],
    );
  }
}
