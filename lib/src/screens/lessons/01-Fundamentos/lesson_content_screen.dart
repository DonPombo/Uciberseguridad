import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'package:uciberseguridad_app/src/services/auth_service.dart';
import 'package:uciberseguridad_app/src/services/lesson_content_service.dart';
import 'package:uciberseguridad_app/src/models/lesson_content.dart';

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
              const Text(
                'Crear Nuevo Contenido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildContentForm(
                onSubmit: (title, contentType, content, videoUrl) async {
                  Navigator.pop(dialogContext);
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

  void _showEditContentDialog(LessonContent content) {
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
              const Text(
                'Editar Contenido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildContentForm(
                content: content,
                onSubmit: (title, contentType, contentText, videoUrl) async {
                  Navigator.pop(dialogContext);
                  final success = await _contentService.updateContent(
                    content.id,
                    {
                      'title': title,
                      'content_type': contentType.toString().split('.').last,
                      'content': contentText,
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

  Widget _buildContentForm({
    LessonContent? content,
    required Function(String title, ContentType contentType, String content,
            String? videoUrl)
        onSubmit,
  }) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: content?.title);
    final _contentController = TextEditingController(text: content?.content);
    final _videoUrlController = TextEditingController(text: content?.videoUrl);
    ContentType _selectedType = content?.contentType ?? ContentType.book;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          DropdownButtonFormField<ContentType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Contenido',
              border: OutlineInputBorder(),
            ),
            items: ContentType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          TextFormField(
            controller: _videoUrlController,
            decoration: const InputDecoration(
              labelText: 'URL del Video (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  onSubmit(
                    _titleController.text,
                    _selectedType,
                    _contentController.text,
                    _videoUrlController.text.isEmpty
                        ? null
                        : _videoUrlController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                content == null ? 'Crear Contenido' : 'Actualizar Contenido',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.accentColor),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '¿Listo para poner a prueba tus conocimientos?',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _navigateToQuiz(context),
            child: const Text(
              'Iniciar Quiz',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _contents.map((content) {
        return _buildContentItem(content);
      }).toList(),
    );
  }

  Widget _buildContentItem(LessonContent content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          ListTile(
            title: Text(
              content.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              content.contentType.toString().split('.').last,
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.6),
              ),
            ),
            trailing: _isAdmin
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.edit, color: AppTheme.accentColor),
                        onPressed: () => _showEditContentDialog(content),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteContent(content),
                      ),
                    ],
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content.contentType == ContentType.video &&
                    content.videoUrl != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
        Text(
                  content.content,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textColor.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomQuizButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _navigateToQuiz(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.quiz, size: 20),
        label: const Text(
          'Comenzar Cuestionario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context) {
    context.go('/quiz', extra: {
      'lessonId': widget.subjectId,
      'lessonTitle': widget.lessonTitle
    });
  }
}
