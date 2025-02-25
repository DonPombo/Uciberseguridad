import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';





/// Builds a custom search bar for filtering lessons.
///
/// Features:
/// - Custom styling matching app theme
/// - Placeholder text
/// - Search icon
Widget buildSearchBar() {
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
