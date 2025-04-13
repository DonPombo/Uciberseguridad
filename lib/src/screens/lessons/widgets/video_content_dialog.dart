import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoContentDialog extends StatefulWidget {
  const VideoContentDialog({super.key});

  @override
  State<VideoContentDialog> createState() => _VideoContentDialogState();
}

class _VideoContentDialogState extends State<VideoContentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  String? _videoId;
  String? _videoTitle;
  bool _isValidating = false;
  final _yt = YoutubeExplode();

  @override
  void dispose() {
    _urlController.dispose();
    _yt.close();
    super.dispose();
  }

  Future<void> _validateVideo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isValidating = true;
    });

    try {
      final videoId = YoutubePlayer.convertUrlToId(_urlController.text);
      if (videoId != null) {
        // Obtener información del video
        final video = await _yt.videos.get(_urlController.text);

        setState(() {
          _videoId = videoId;
          _videoTitle = video.title;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al validar el video')),
        );
      }
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _videoId != null) {
      Navigator.of(context).pop({
        'url': _urlController.text,
        'title': _videoTitle,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Video de YouTube'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL del video',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
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
              ),
              const SizedBox(height: 16),
              if (_videoId != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _videoTitle ?? 'Video de YouTube',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Video válido',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (_videoId == null)
          ElevatedButton(
            onPressed: _isValidating ? null : _validateVideo,
            child: _isValidating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Validar'),
          )
        else
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('Agregar'),
          ),
      ],
    );
  }
}
