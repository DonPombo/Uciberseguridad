import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'package:uciberseguridad_app/src/services/auth_service.dart';
import 'package:uciberseguridad_app/src/services/lesson_content_service.dart';
import 'package:uciberseguridad_app/src/models/lesson_content.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/content_form.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/content_item.dart';

class LessonContentScreen extends StatefulWidget {
  final String lessonTitle;
  final String subjectId;

  const LessonContentScreen({
    super.key,
    required this.lessonTitle,
    required this.subjectId,
  });

  @override
  State<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  final LessonContentService _contentService = LessonContentService();
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  List<LessonContent> _contents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadContents();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isUserAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadContents() async {
    setState(() => _isLoading = true);
    final contents = await _contentService.getContents(widget.subjectId);
    setState(() {
      _contents = contents;
      _isLoading = false;
    });
  }

  void _showCreateContentDialog() {
    showDialog(
      context: context,
      builder: (formContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContentForm(
                onSubmit: (
                    {required String title,
                    required ContentType contentType,
                    required String content,
                    String? videoUrl}) async {
                  Navigator.pop(formContext);
                  final newContent = await _contentService.createContent(
                    subjectId: widget.subjectId,
                    title: title,
                    contentType: contentType,
                    content: content,
                    videoUrl: videoUrl,
                  );
                  if (newContent != null && mounted) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Contenido creado correctamente')),
                    );
                    _loadContents();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditContentDialog(LessonContent originalContent) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                originalContent.contentType == ContentType.text
                    ? 'Editar Contenido de Texto'
                    : 'Editar Contenido de Video',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ContentForm(
                initialTitle: originalContent.title,
                initialContent: originalContent.content,
                initialContentType: originalContent.contentType,
                initialVideoUrl: originalContent.videoUrl,
                onSubmit: (
                    {required String title,
                    required ContentType contentType,
                    required String content,
                    String? videoUrl}) async {
                  Navigator.pop(dialogContext);
                  final success = await _contentService.updateContent(
                    originalContent.id,
                    {
                      'title': title,
                      'content_type': contentType.toString().split('.').last,
                      'content': content,
                      'video_url': videoUrl,
                    },
                  );
                  if (success && mounted) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Contenido actualizado correctamente')),
                    );
                    _loadContents();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteContent(LessonContent content) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este contenido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _contentService.deleteContent(content.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contenido eliminado correctamente')),
        );
        _loadContents();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuizButton(context),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildContentList(),
                      const SizedBox(height: 32),
                      _buildBottomQuizButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showCreateContentDialog,
              backgroundColor: AppTheme.accentColor,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(color: Colors.white),
        ),
        background: Container(
          color: AppTheme.primaryColor,
          child: const Center(
            child: Icon(
              Icons.security,
              size: 64,
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implementar navegación al quiz
        },
        icon: const Icon(Icons.quiz),
        label: const Text('Iniciar Quiz'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
        ),
      ),
    );
  }

  Widget _buildContentList() {
    if (_contents.isEmpty) {
      return const Center(
        child: Text(
          'No hay contenido disponible',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: _contents.map((content) {
        return ContentItem(
          content: content,
          isAdmin: _isAdmin,
          onEdit: () => _showEditContentDialog(content),
          onDelete: () => _deleteContent(content),
        );
      }).toList(),
    );
  }

  Widget _buildBottomQuizButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implementar navegación al quiz
        },
        icon: const Icon(Icons.quiz),
        label: const Text('Iniciar Quiz'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
        ),
      ),
    );
  }
}
