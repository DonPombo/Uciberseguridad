import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class LessonContentScreen extends StatelessWidget {
  final String lessonTitle;

  const LessonContentScreen({
    super.key,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuizButton(context),
                      const SizedBox(height: 24),
                      _buildContent(),
                      const SizedBox(height: 32),
                      _buildBottomQuizButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          lessonTitle,
          style: const TextStyle(color: Colors.white),
        ),
        background: Container(
          color: AppTheme.primaryColor,
          child: const Center(
            child: Icon(
              Icons.security,
              size: 64,
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.accentColor),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '¿Listo para poner a prueba tus conocimientos?',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _navigateToQuiz(context),
            child: const Text(
              'Iniciar Quiz',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Introducción',
          'La ciberseguridad es fundamental en la era digital actual. Protege la información y los sistemas de posibles amenazas y ataques cibernéticos.',
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Conceptos Básicos',
          '• Confidencialidad: Garantizar que la información sea accesible solo para personas autorizadas.\n'
              '• Integridad: Mantener la exactitud y totalidad de la información.\n'
              '• Disponibilidad: Asegurar el acceso a la información cuando sea necesario.',
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Importancia',
          'La ciberseguridad es crucial para:\n'
              '• Proteger datos sensibles\n'
              '• Prevenir pérdidas financieras\n'
              '• Mantener la confianza de los usuarios\n'
              '• Cumplir con regulaciones legales',
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textColor.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomQuizButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _navigateToQuiz(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.quiz, size: 20),
        label: const Text(
          'Comenzar Cuestionario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context) {
    debugPrint('Navegando al cuestionario de: $lessonTitle');
  }
}
