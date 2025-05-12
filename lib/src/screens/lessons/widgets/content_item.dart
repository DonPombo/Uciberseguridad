import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/models/lesson_content.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'video_content_view.dart';

class ContentItem extends StatelessWidget {
  final LessonContent content;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContentItem({
    super.key,
    required this.content,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (content.contentType == ContentType.text)
              Text(
                content.content,
                style: const TextStyle(fontSize: 16),
              )
            else if (content.contentType == ContentType.video &&
                content.videoUrl != null)
              VideoContentView(
                videoUrl: content.videoUrl!,
                title: content.title,
              ),
            if (isAdmin) ...[
              const SizedBox(width: 16),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  color: AppTheme.accentColor,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ])
            ],
          ],
        ),
      ),
    );
  }
}
