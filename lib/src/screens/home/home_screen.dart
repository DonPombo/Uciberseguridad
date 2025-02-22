import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/src/blocs/blocs.dart';
import 'package:uciberseguridad_app/src/screens/home/widgets/progress_chart.dart';
import 'package:uciberseguridad_app/src/screens/home/widgets/study_plan_item.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'widgets/lesson_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildLessonsSection(),
              const SizedBox(height: 24),
              _buildStudyPlanSection(),
              const SizedBox(height: 24),
              _buildStatisticsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.accentColor,
          child: Icon(Icons.person, color: AppTheme.backgroundColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Usuario',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.55,
                  backgroundColor: AppTheme.surfaceColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Progreso de hoy: 55%',
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppTheme.textColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLessonsSection() {
    return Column(
      children: [
        _buildSectionHeader('Lecciones Populares'),
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

  Widget _buildStudyPlanSection() {
    return Column(
      children: [
        _buildSectionHeader('Plan de estudio'),
        const SizedBox(height: 16),
        const StudyPlanItem(
          icon: Icons.security,
          title: 'Fundamentos de Ciberseguridad',
          subtitle: 'Introducción y conceptos básicos',
          progress: 22,
          color: AppTheme.accentColor,
        ),
        const StudyPlanItem(
          icon: Icons.password,
          title: 'Contraseñas Seguras',
          subtitle: 'Gestión y creación de contraseñas fuertes',
          progress: 40,
          color: AppTheme.quaternaryColor,
        ),
        const StudyPlanItem(
          icon: Icons.email,
          title: 'Protección contra Phishing',
          subtitle: 'Identificación y prevención de estafas',
          progress: 78,
          color: AppTheme.tertiaryColor,
        ),
        const StudyPlanItem(
          icon: Icons.privacy_tip,
          title: 'Privacidad Digital',
          subtitle: 'Protección de datos personales',
          progress: 35,
          color: AppTheme.quinaryColor,
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      children: [
        _buildSectionHeader('Estadísticas'),
        const SizedBox(height: 16),
        const ProgressChart(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          // Calculamos el ancho disponible
          final availableWidth = constraints.maxWidth;
          // Estimamos el ancho del título y el botón
          final titleWidth =
              title.length * 12.0; // Aproximación del ancho del texto
          const buttonWidth = 80.0; // Ancho aproximado del botón

          // Si el espacio es suficiente, mostramos en fila
          if (availableWidth >= titleWidth + buttonWidth + 20) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<NavigationBloc>()
                        .add(const NavigationIndexChanged(1));
                    context.go('/lessons');
                  },
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Si no hay espacio suficiente, mostramos en columna
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    context
                        .read<NavigationBloc>()
                        .add(const NavigationIndexChanged(1));
                    context.go('/lessons');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
