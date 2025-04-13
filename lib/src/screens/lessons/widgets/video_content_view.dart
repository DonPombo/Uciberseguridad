import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VideoContentView extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoContentView({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoContentView> createState() => _VideoContentViewState();
}

class _VideoContentViewState extends State<VideoContentView> {
  late YoutubePlayerController _controller;
  final _yt = YoutubeExplode();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isValidVideo = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isPlayerReady = false;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _shouldPlay = false;
  String? _videoTitle;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isInitialized) return;

    // Validar que la URL no esté vacía
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _isValidVideo = false;
        _errorMessage = 'La URL del video está vacía';
        _isLoading = false;
      });
      return;
    }

    // Validar que sea una URL de YouTube
    if (!widget.videoUrl.contains('youtube.com') &&
        !widget.videoUrl.contains('youtu.be')) {
      setState(() {
        _isValidVideo = false;
        _errorMessage = 'La URL debe ser de YouTube';
        _isLoading = false;
      });
      return;
    }

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null) {
      setState(() {
        _isValidVideo = false;
        _errorMessage = 'No se pudo extraer el ID del video de YouTube';
        _isLoading = false;
      });
      return;
    }

    try {
      // Obtener información del video
      final video = await _yt.videos.get(widget.videoUrl);
      setState(() {
        _videoTitle = video.title;
      });
    } catch (e) {
      setState(() {
        _isValidVideo = false;
        _errorMessage =
            'No se pudo obtener la información del video. Verifica que el video exista y sea público.';
        _isLoading = false;
      });
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        useHybridComposition: true,
        disableDragSeek: true,
        hideControls: false,
        hideThumbnail: true,
        forceHD: false,
        loop: false,
        isLive: false,
      ),
    );

    _controller.addListener(() {
      if (_controller.value.hasError) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Error al cargar el video. Por favor, verifica tu conexión a internet.';
          _isLoading = false;
        });
      }
    });

    setState(() {
      _isInitialized = true;
      _isLoading = false;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _controller.toggleFullScreenMode();
    });
  }

  @override
  void dispose() {
    if (_isValidVideo && _isInitialized) {
      _controller.dispose();
    }
    _yt.close();
    super.dispose();
  }

  Future<void> _downloadVideo() async {
    if (!_isValidVideo) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL de video no válida')),
      );
      return;
    }

    try {
      if (!mounted) return;
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      // Obtener información del video
      final video = await _yt.videos.get(widget.videoUrl);
      if (!mounted) return;

      // Obtener la mejor calidad de video disponible
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      if (!mounted) return;

      final streamInfo = manifest.muxed.withHighestBitrate();

      // Obtener el directorio de documentos de la aplicación
      final directory = await getApplicationDocumentsDirectory();
      if (!mounted) return;

      final filePath = '${directory.path}/${video.title}.mp4';

      // Descargar el video
      final file = File(filePath);
      final fileStream = file.openWrite();

      final stream = _yt.videos.streamsClient.get(streamInfo);
      final len = streamInfo.size.totalBytes;
      var count = 0;

      await for (final data in stream) {
        if (!mounted) {
          await fileStream.close();
          return;
        }
        count += data.length;
        setState(() {
          _downloadProgress = count / len;
        });
        fileStream.add(data);
      }

      await fileStream.flush();
      await fileStream.close();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video descargado en: $filePath')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el video: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Widget _buildErrorMessage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isPlayerReady = false;
                  _isLoading = true;
                  _initializeVideo();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _videoTitle ?? 'Cargando título...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _shouldPlay = true;
              });
            },
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Toca para reproducir el video',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
            onReady: () {
              setState(() {
                _hasError = false;
                _isPlayerReady = true;
                _isLoading = false;
              });
            },
            onEnded: (data) {
              setState(() {
                _shouldPlay = false;
                _isFullScreen = false;
              });
            },
            topActions: [
              IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: _toggleFullScreen,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isValidVideo)
          _buildErrorMessage()
        else if (_hasError)
          _buildErrorMessage()
        else if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (!_shouldPlay)
          _buildVideoPlaceholder()
        else
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
            onReady: () {
              setState(() {
                _hasError = false;
                _isPlayerReady = true;
                _isLoading = false;
              });
            },
            onEnded: (data) {
              setState(() {
                _shouldPlay = false;
              });
            },
            topActions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _controller.reload();
                },
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: _toggleFullScreen,
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (_isValidVideo && !_hasError && _isPlayerReady && !_isLoading)
          if (_isDownloading)
            Column(
              children: [
                LinearProgressIndicator(value: _downloadProgress),
                const SizedBox(height: 8),
                Text(
                    'Descargando: ${(_downloadProgress * 100).toStringAsFixed(1)}%'),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _downloadVideo,
              icon: const Icon(Icons.download),
              label: const Text('Descargar Video'),
            ),
      ],
    );
  }
}
