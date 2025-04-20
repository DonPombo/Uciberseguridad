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
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

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
  final QuizService _quizService = QuizService();
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  List<LessonContent> _contents = [];
  bool _isLoading = true;
  Map<String, LocalQuiz?> _contentQuizzes = {};
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    debugPrint('🚀 Inicializando LessonContentScreen');
    debugPrint('   - Subject ID: ${widget.subjectId}');
    debugPrint('   - Lesson Title: ${widget.lessonTitle}');
    _checkAdminStatus();
    _loadContents();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          _openFile(details.payload!);
        }
      },
    );
  }

  Future<void> _showNotification(String filePath) async {
    const androidDetails = AndroidNotificationDetails(
      'downloads_channel',
      'Descargas',
      channelDescription: 'Notificaciones de descargas de contenido',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      'Descarga completada',
      'Toca para abrir el contenido',
      const NotificationDetails(android: androidDetails),
      payload: filePath,
    );
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
    final contents = await _contentService.getContents(widget.subjectId);
    debugPrint('\n📚 Contenidos cargados: ${contents.length}');

    // Cargar los cuestionarios asociados a cada contenido
    final quizzes = <String, LocalQuiz?>{};
    debugPrint('\n🔍 INICIO DE CARGA DE CUESTIONARIOS');
    debugPrint('===================================');

    for (var content in contents) {
      debugPrint('\n   📝 Procesando contenido:');
      debugPrint('      - ID: ${content.id}');
      debugPrint('      - Título: ${content.title}');
      debugPrint('      - Tipo: ${content.contentType}');
      debugPrint('      - Orden: ${content.orderIndex}');

      final contentQuizzes =
          await _quizService.getQuizzesByContentId(content.id);
      debugPrint('      - Cuestionarios encontrados: ${contentQuizzes.length}');

      if (contentQuizzes.isNotEmpty) {
        debugPrint('      - Detalles del cuestionario:');
        debugPrint('         * ID: ${contentQuizzes.first.id}');
        debugPrint('         * Título: ${contentQuizzes.first.title}');
        debugPrint(
            '         * Preguntas: ${contentQuizzes.first.questions.length}');
        debugPrint('         * Content ID: ${contentQuizzes.first.contentId}');
      }

      quizzes[content.id] =
          contentQuizzes.isNotEmpty ? contentQuizzes.first : null;
    }

    setState(() {
      _contents = contents;
      _contentQuizzes = quizzes;
      _isLoading = false;
    });

    debugPrint('\n✅ RESUMEN DE CARGA');
    debugPrint('===================');
    debugPrint('   - Total contenidos: ${_contents.length}');
    debugPrint('   - Total cuestionarios: ${_contentQuizzes.length}');
    debugPrint('   - Estado de carga: $_isLoading');
    debugPrint('   - Es administrador: $_isAdmin');
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
          contentId: content.id,
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
    debugPrint('      * lessonId: ${content.id}');
    debugPrint('      * lessonTitle: ${quiz.title}');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          lessonId: content.id,
          lessonTitle: quiz.title,
        ),
      ),
    );
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _downloadContent(LessonContent content) async {
    try {
      debugPrint('\n📥 INICIO DE DESCARGA DE CONTENIDO');
      debugPrint('================================');
      debugPrint('   - Título: ${content.title}');
      debugPrint('   - ID: ${content.id}');
      debugPrint('   - Tipo de contenido: ${content.contentType}');

      // Solicitar permisos de almacenamiento
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception(
            'Se requieren permisos de almacenamiento para descargar el contenido');
      }

      // Obtener el directorio de descargas
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('No se pudo acceder al almacenamiento externo');
      }

      final folderPath = '${directory.path}/UCiberseguridad';
      debugPrint('   - Ruta de descarga: $folderPath');

      final dir = Directory(folderPath);
      if (!await dir.exists()) {
        debugPrint('   - Creando directorio...');
        await dir.create(recursive: true);
        debugPrint('   - Directorio creado exitosamente');
      }

      final file = File(
          '$folderPath/${content.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.txt');
      debugPrint('   - Archivo destino: ${file.path}');

      final contentToSave = '''
Título: ${content.title}
Fecha de descarga: ${DateTime.now().toString()}

${content.content}
''';

      debugPrint('   - Guardando contenido en archivo...');
      await file.writeAsString(contentToSave);
      debugPrint('   - Archivo guardado correctamente');
      debugPrint('   - Tamaño del archivo: ${await file.length()} bytes');

      if (!mounted) return;

      await _showNotification(file.path);
      debugPrint('   - Notificación mostrada');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contenido descargado correctamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Abrir',
            textColor: Colors.white,
            onPressed: () => _openFile(file.path),
          ),
        ),
      );
      debugPrint('✅ DESCARGA COMPLETADA EXITOSAMENTE\n');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR EN LA DESCARGA');
      debugPrint('   - Error: $e');
      debugPrint('   - Stack trace: $stackTrace');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
              child: const Icon(Icons.add),
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
              onDownload: content.contentType == ContentType.text
                  ? () => _downloadContent(content)
                  : null,
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
          '      * Content ID: ${_contentQuizzes[_contents.first.id]?.contentId}');
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
        label:
            Text(hasQuiz ? 'Iniciar Quiz' : 'No hay cuestionarios disponibles'),
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
            if (_contentQuizzes.isNotEmpty) ...[
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

  Future<void> _openFile(String filePath) async {
    try {
      debugPrint('\n📂 INICIO DE APERTURA DE ARCHIVO');
      debugPrint('===============================');
      debugPrint('   - Ruta del archivo: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ El archivo no existe');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El archivo no existe'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint('   - Archivo encontrado');
      debugPrint('   - Tamaño del archivo: ${await file.length()} bytes');

      if (!mounted) return;
      final navigator = Navigator.of(context);
      ScaffoldMessenger.of(context);

      debugPrint('   - Mostrando diálogo de opciones...');
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('¿Cómo deseas abrir el archivo?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Ver en la app'),
                onTap: () async {
                  debugPrint('   - Opción seleccionada: Ver en la app');
                  navigator.pop();
                  final content = await file.readAsString();
                  debugPrint(
                      '   - Contenido leído: ${content.length} caracteres');
                  if (!mounted) return;
                  await showDialog(
                    context: context,
                    builder: (contentContext) => AlertDialog(
                      title: const Text('Contenido descargado'),
                      content: SingleChildScrollView(
                        child: Text(content),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => navigator.pop(),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                  debugPrint('   - Diálogo de contenido cerrado');
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Abrir como PDF'),
                onTap: () async {
                  debugPrint('   - Opción seleccionada: Abrir como PDF');
                  navigator.pop();
                  try {
                    debugPrint('   - Generando PDF...');
                    final content = await file.readAsString();

                    final pdf = pw.Document();
                    pdf.addPage(
                      pw.Page(
                        build: (pw.Context context) => pw.Center(
                          child: pw.Text(content),
                        ),
                      ),
                    );

                    final directory = await getApplicationDocumentsDirectory();
                    final pdfPath =
                        '${directory.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf';
                    final pdfFile = File(pdfPath);
                    await pdfFile.writeAsBytes(await pdf.save());
                    debugPrint('   - PDF generado en: $pdfPath');

                    final uri = Uri.file(pdfPath);
                    debugPrint('   - URI generada: $uri');

                    if (await canLaunchUrl(uri)) {
                      debugPrint('   - URI puede ser lanzada');
                      final result = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      debugPrint('   - Resultado del lanzamiento: $result');
                    } else {
                      throw Exception(
                          'No se encontró una aplicación para abrir PDF');
                    }
                  } catch (e, stackTrace) {
                    debugPrint('❌ Error al generar/abrir PDF');
                    debugPrint('   - Error: $e');
                    debugPrint('   - Stack trace: $stackTrace');
                    if (!mounted) return;

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('No se pudo abrir el PDF'),
                        content: const Text(
                            'Parece que no hay una aplicación instalada que pueda abrir archivos PDF. Por favor, instala un lector de PDF o usa la opción "Ver en la app".'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('   - Operación cancelada por el usuario');
                navigator.pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
      debugPrint('✅ PROCESO DE APERTURA COMPLETADO\n');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR EN LA APERTURA DEL ARCHIVO');
      debugPrint('   - Error: $e');
      debugPrint('   - Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al abrir el archivo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
