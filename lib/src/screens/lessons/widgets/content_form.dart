import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/models/lesson_content.dart';

class ContentForm extends StatefulWidget {
  final Function({
    required String title,
    required String content,
    required ContentType contentType,
    String? videoUrl,
  }) onSubmit;
  final String? initialTitle;
  final String? initialContent;
  final ContentType? initialContentType;
  final String? initialVideoUrl;

  const ContentForm({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialContent,
    this.initialContentType,
    this.initialVideoUrl,
  });

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late ContentType _selectedContentType;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
    _selectedContentType = widget.initialContentType ?? ContentType.text;
    _videoUrl = widget.initialVideoUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedContentType == ContentType.video) {
        _videoUrl = _contentController.text;
      }

      widget.onSubmit(
        title: _titleController.text,
        content: _contentController.text,
        contentType: _selectedContentType,
        videoUrl: _videoUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selector de tipo de contenido
            SegmentedButton<ContentType>(
              segments: const [
                ButtonSegment<ContentType>(
                  value: ContentType.text,
                  label: Text('Texto'),
                  icon: Icon(Icons.text_snippet),
                ),
                ButtonSegment<ContentType>(
                  value: ContentType.video,
                  label: Text('Video'),
                  icon: Icon(Icons.video_library),
                ),
              ],
              selected: {_selectedContentType},
              onSelectionChanged: (Set<ContentType> selected) {
                setState(() {
                  _selectedContentType = selected.first;
                  if (_selectedContentType == ContentType.video) {
                    _videoUrl = _contentController.text;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            if (_selectedContentType == ContentType.text) ...[
              // Campo de título (solo para contenido de texto)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de contenido (solo para contenido de texto)
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el contenido';
                  }
                  return null;
                },
              ),
            ] else ...[
              // Para video, solo mostrar un campo para la URL
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'URL del video de YouTube',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: https://www.youtube.com/watch?v=...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la URL del video';
                  }
                  if (!value.contains('youtube.com') &&
                      !value.contains('youtu.be')) {
                    return 'Por favor ingresa una URL válida de YouTube';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _videoUrl = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 24),

            // Botón de envío
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
