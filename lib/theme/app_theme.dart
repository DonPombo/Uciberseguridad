import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0A192F); // Azul oscuro profundo
  static const backgroundColor = Color(0xFF0D1B2A); // Fondo
  static const surfaceColor = Color(0xFF162B3C); // Fuperficies
  static const textColor = Color(0xFFE0E7FF); // Texto claro
  static const accentColor = Color(0xFF00FF9C); // Elementos interactivos principales
  static const secondaryColor = Color(0xFF64FFDA); // Botones secundarios, enlaces o estados pasivos
  static const tertiaryColor = Color(0xFF3BC2B7); // Destacados adicionales, subtítulos o íconos
  static const quaternaryColor = Color(0xFFFF8A65); // Alertas, notificaciones o mensajes críticos
  static const quinaryColor = Color(0xFF2ECC71); // Mensajes de éxito o detalles informativos

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      onPrimary: textColor,
      onSecondary: backgroundColor,
      onSurface: textColor,
    ),

    // Personalización de AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
    ),

    // Personalización de botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: backgroundColor,
        backgroundColor: accentColor,
      ),
    ),

    // Personalización de textos
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textColor),
      headlineMedium: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
    ),

    // Personalización de iconos
    iconTheme: const IconThemeData(
      color: accentColor,
    ),
  );
}
