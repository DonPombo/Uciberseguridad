import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
  bool _isValidVideo = true;
  bool _hasError = false;
  String _errorMessage = '';
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
      if (!mounted) return;
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
              'Error al cargar el video. Por favor, verifica tu conexión a internet o que el video exista y sea público.';
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
      ],
    );
  }
}
