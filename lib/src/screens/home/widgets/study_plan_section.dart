import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'section_header.dart';
import 'study_plan_item.dart';

class StudyPlanSection extends StatelessWidget {
  const StudyPlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SectionHeader(title: 'Plan de estudio'),
        SizedBox(height: 16),
        StudyPlanItem(
          icon: Icons.security,
          title: 'Fundamentos de Ciberseguridad',
          subtitle: 'Introducción y conceptos básicos',
          progress: 22,
          color: AppTheme.accentColor,
        ),
        StudyPlanItem(
          icon: Icons.password,
          title: 'Contraseñas Seguras',
          subtitle: 'Gestión y creación de contraseñas fuertes',
          progress: 40,
          color: AppTheme.quaternaryColor,
        ),
        StudyPlanItem(
          icon: Icons.email,
          title: 'Protección contra Phishing',
          subtitle: 'Identificación y prevención de estafas',
          progress: 78,
          color: AppTheme.tertiaryColor,
        ),
        StudyPlanItem(
          icon: Icons.privacy_tip,
          title: 'Privacidad Digital',
          subtitle: 'Protección de datos personales',
          progress: 35,
          color: AppTheme.quinaryColor,
        ),
      ],
    );
  }
}