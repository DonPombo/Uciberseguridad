import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

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

  Widget _buildLessonsList() {
    return Column(
      children: [
        _buildLessonItem(
          'Fundamentos de Ciberseguridad',
          'Introducción y conceptos básicos',
          Icons.security,
          AppTheme.primaryColor,
          0.22,
        ),
        _buildLessonItem(
          'Contraseñas Seguras',
          'Gestión y creación de contraseñas fuertes',
          Icons.password,
          AppTheme.quaternaryColor,
          0.40,
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

  Widget _buildLessonItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% Completado',
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
