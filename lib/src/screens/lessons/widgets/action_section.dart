import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/screens/lessons/01-Fundamentos/subject_detail_screen.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';


 
 
 Widget buildActionSection(double progress, String buttonText, String title) {
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

