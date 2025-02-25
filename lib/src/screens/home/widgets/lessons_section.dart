import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'lesson_card.dart';
import 'section_header.dart';

class LessonsSection extends StatelessWidget {
  const LessonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Lecciones Populares'),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              LessonCard(
                title: 'Fundamentos',
                rating: 8.8,
                progress: 0.22,
                color: AppTheme.surfaceColor,
                icon: Icons.security,
              ),
              SizedBox(width: 16),
              LessonCard(
                title: 'Contraseñas Seguras',
                rating: 9.5,
                progress: 0.40,
                color: AppTheme.quaternaryColor,
                icon: Icons.password,
              ),
              SizedBox(width: 16),
              LessonCard(
                title: 'Phishing',
                rating: 8.3,
                progress: 0.78,
                color: AppTheme.tertiaryColor,
                icon: Icons.email,
              ),
              SizedBox(width: 16),
              LessonCard(
                title: 'Privacidad Digital',
                rating: 8.7,
                progress: 0.35,
                color: AppTheme.quinaryColor,
                icon: Icons.privacy_tip,
              ),
            ],
          ),
        ),
      ],
    );
  }
}