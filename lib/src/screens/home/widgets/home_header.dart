import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
}
