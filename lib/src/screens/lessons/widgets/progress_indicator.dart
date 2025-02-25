import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

Widget buildProgressIndicator(double progress, Color color) {
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
