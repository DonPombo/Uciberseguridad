import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/models/lesson_content.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class ContentTypeDialog extends StatelessWidget {
  final Function(ContentType type) onTypeSelected;

  const ContentTypeDialog({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Tipo de Contenido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTypeButton(
              context,
              'Texto',
              Icons.text_snippet,
              ContentType.text,
            ),
            const SizedBox(height: 16),
            _buildTypeButton(
              context,
              'Video de YouTube',
              Icons.video_library,
              ContentType.video,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context,
    String label,
    IconData icon,
    ContentType type,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          onTypeSelected(type);
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
} 