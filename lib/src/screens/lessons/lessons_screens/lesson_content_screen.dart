import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'package:uciberseguridad_app/src/services/auth_service.dart';
import 'package:uciberseguridad_app/src/services/lesson_content_service.dart';
import 'package:uciberseguridad_app/src/services/quiz_service.dart';
import 'package:uciberseguridad_app/src/models/lesson_content.dart';
import 'package:uciberseguridad_app/src/models/local_quiz.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/content_form.dart';
import 'package:uciberseguridad_app/src/screens/lessons/widgets/content_item.dart';
import 'package:uciberseguridad_app/src/screens/admin/quiz_editor_screen.dart';
import 'package:uciberseguridad_app/src/screens/quiz/quiz_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonContentScreen extends StatefulWidget {
  final String lessonTitle;
  final String subjectId;
  final String lessonId;

  const LessonContentScreen({
    super.key,
    required this.lessonTitle,
    required this.subjectId,
    required this.lessonId,
  });

  @override
  State<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  late final LessonContentService _contentService;
  final QuizService _quizService = QuizService.instance;
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  List<LessonContent> _contents = [];
  bool _isLoading = true;
  Map<String, LocalQuiz?> _contentQuizzes = {};

  @override
  void initState() {
    super.initState();
    _contentService = LessonContentService(Supabase.instance.client);
    debugPrint('🚀 Inicializando LessonContentScreen');
    debugPrint('   - Subject ID: ${widget.subjectId}');
    debugPrint('   - Lesson Title: ${widget.lessonTitle}');
    _checkAdminStatus();
    _loadContents();
  }

  Future<void> _checkAdminStatus() async {
    debugPrint('👤 Verificando estado de administrador');
    final isAdmin = await _authService.isUserAdmin();
    debugPrint('   - Es administrador: $isAdmin');
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadContents() async {
    debugPrint('\n🔄 INICIO DE CARGA DE CONTENIDOS');
    debugPrint('=================================');
    debugPrint('📌 Datos de la lección:');
    debugPrint('   - Subject ID: ${widget.subjectId}');
    debugPrint('   - Lesson Title: ${widget.lessonTitle}');

    setState(() => _isLoading = true);

    try {
      final contents = await _contentService.getContents(widget.subjectId);
      debugPrint('\n📚 Contenidos cargados: ${contents.length}');

      // Cargar los cuestionarios asociados a cada contenido
      final quizzes = <String, LocalQuiz?>{};
      debugPrint('\n🔍 INICIO DE CARGA DE CUESTIONARIOS');
      debugPrint('===================================');

      // Cargar el quiz del subtema una sola vez
      final subjectQuizzes =
          await _quizService.getQuizzesByLessonId(widget.subjectId);
      debugPrint('\n   📝 Procesando quiz del subtema:');
      debugPrint('      - Subject ID: ${widget.subjectId}');
      debugPrint('      - Cuestionarios encontrados: ${subjectQuizzes.length}');

      if (subjectQuizzes.isNotEmpty) {
        debugPrint('      - Detalles del cuestionario:');
        debugPrint('         * ID: ${subjectQuizzes.first.id}');
        debugPrint('         * Título: ${subjectQuizzes.first.title}');
        debugPrint(
            '         * Preguntas: ${subjectQuizzes.first.questions.length}');
        debugPrint('         * Subject ID: ${subjectQuizzes.first.lessonId}');

        // Asignar el mismo quiz a todos los contenidos del subtema
        for (var content in contents) {
          quizzes[content.id] = subjectQuizzes.first;
        }
      }

      if (mounted) {
        setState(() {
          _contents = contents;
          _contentQuizzes = quizzes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando contenidos: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                        content: Text('Contenido creado correctamente'),
                      ),
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

  Future<void> _createOrEditQuiz(LessonContent content) async {
    final existingQuiz = _contentQuizzes[content.id];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizEditorScreen(
          lessonId: widget.subjectId,
          contentTitle: content.title,
          existingQuiz: existingQuiz,
        ),
      ),
    );

    if (result == true) {
      await _loadContents(); // Recargar para mostrar el nuevo cuestionario
    }
  }

  Future<void> _startQuiz(LessonContent content) async {
    debugPrint('🚀 Iniciando quiz:');
    debugPrint('   - Contenido ID: ${content.id}');
    debugPrint('   - Contenido Título: ${content.title}');

    final quiz = _contentQuizzes[content.id];
    debugPrint('   - Quiz encontrado: ${quiz != null}');

    if (quiz == null) {
      debugPrint('❌ No se encontró cuestionario para el contenido');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No hay cuestionario disponible para este contenido')),
      );
      return;
    }

    if (!mounted) return;
    debugPrint('   - Navegando a QuizScreen con:');
    debugPrint('      * lessonId: ${widget.subjectId}');
    debugPrint('      * lessonTitle: ${quiz.title}');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          lessonId: widget.subjectId,
          lessonTitle: quiz.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('\n🏗️ CONSTRUYENDO INTERFAZ');
    debugPrint('=======================');
    debugPrint('   - Contenidos disponibles: ${_contents.length}');
    debugPrint('   - Cuestionarios disponibles: ${_contentQuizzes.length}');
    debugPrint('   - Estado de carga: $_isLoading');
    debugPrint('   - Es administrador: $_isAdmin');

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
              onPressed: () => _showAddOptionsDialog(context),
              backgroundColor: AppTheme.accentColor,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Agregar Contenido'),
              onTap: () {
                Navigator.pop(context);
                _showCreateContentDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Gestionar Cuestionarios'),
              onTap: () {
                Navigator.pop(context);
                _showQuizManagementDialog();
              },
            ),
          ],
        ),
      ),
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

  Widget _buildContentList() {
    debugPrint('\n📋 CONSTRUYENDO LISTA DE CONTENIDOS');
    debugPrint('=================================');

    if (_contents.isEmpty) {
      debugPrint('   ❌ No hay contenidos disponibles');
      return const Center(
        child: Text(
          'No hay contenido disponible',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    debugPrint('   ✅ Construyendo lista con ${_contents.length} contenidos');
    return Column(
      children: _contents.map((content) {
        final hasQuiz = _contentQuizzes[content.id] != null;
        debugPrint('\n      📝 Contenido:');
        debugPrint('         - ID: ${content.id}');
        debugPrint('         - Título: ${content.title}');
        debugPrint('         - Tiene cuestionario: $hasQuiz');

        return Column(
          children: [
            ContentItem(
              content: content,
              isAdmin: _isAdmin,
              onEdit: () => _showEditContentDialog(content),
              onDelete: () => _deleteContent(content),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBottomQuizButton(BuildContext context) {
    debugPrint('\n🔘 CONSTRUYENDO BOTÓN INFERIOR DE QUIZ');
    debugPrint('=====================================');

    final hasQuiz = _contentQuizzes.isNotEmpty;
    debugPrint('   - Hay cuestionarios disponibles: $hasQuiz');

    if (hasQuiz && _contents.isNotEmpty) {
      debugPrint('   - Primer contenido:');
      debugPrint('      * ID: ${_contents.first.id}');
      debugPrint('      * Título: ${_contents.first.title}');
      debugPrint('   - Cuestionario asociado:');
      debugPrint('      * ID: ${_contentQuizzes[_contents.first.id]?.id}');
      debugPrint(
          '      * Título: ${_contentQuizzes[_contents.first.id]?.title}');
      debugPrint(
          '      * Content ID: ${_contentQuizzes[_contents.first.id]?.lessonId}');
    }

    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: hasQuiz
            ? () {
                debugPrint('🎯 Intentando iniciar quiz para contenido:');
                debugPrint('   - ID del contenido: ${_contents.first.id}');
                debugPrint(
                    '   - Título del contenido: ${_contents.first.title}');
                debugPrint(
                    '   - Cuestionarios asociados: ${_contentQuizzes.length}');
                _startQuiz(_contents.first);
              }
            : null,
        icon: const Icon(Icons.quiz),
        label: Text(hasQuiz
            ? 'Iniciar Cuestionario'
            : 'No hay cuestionarios disponibles'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }

  void _showQuizManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestión de Cuestionarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Qué deseas hacer?'),
            const SizedBox(height: 16),
            if (_contentQuizzes.isEmpty) ...[
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Crear nuevo cuestionario'),
                onTap: () {
                  Navigator.pop(context);
                  if (_contents.isNotEmpty) {
                    _createOrEditQuiz(_contents.first);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Primero debes crear contenido para poder agregar un cuestionario'),
                      ),
                    );
                  }
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar cuestionario existente'),
                onTap: () {
                  Navigator.pop(context);
                  _createOrEditQuiz(_contents.first);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar cuestionario',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteQuiz(_contentQuizzes[_contents.first.id]!);
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuiz(LocalQuiz quiz) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este cuestionario?'),
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
      await _quizService.deleteQuiz(quiz.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuestionario eliminado correctamente')),
        );
        _loadContents();
      }
    }
  }
}
