import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uciberseguridad_app/src/blocs/blocs.dart';
import 'package:uciberseguridad_app/src/screens/lessons/lessons_screens/lesson_content_screen.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'package:uciberseguridad_app/src/services/auth_service.dart';
import 'package:uciberseguridad_app/src/services/subject_service.dart';
import 'package:uciberseguridad_app/src/models/subject.dart';
import 'package:uciberseguridad_app/src/services/lesson_service.dart';
import 'package:uciberseguridad_app/src/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final SubjectService _subjectService = SubjectService();
  final AuthService _authService = AuthService();
  final LessonService _lessonService = LessonService.instance;
  late final SyncService _syncService;
  bool _isAdmin = false;
  List<Subject> _subjects = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _lessonService.init();
    _syncService = SyncService(_lessonService, Supabase.instance.client);
    _syncService.startSync();
    await _checkAdminStatus();
    await _loadSubjects();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isUserAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final subjects = await _subjectService.getSubjects(widget.subjectId);
    setState(() {
      _subjects = subjects;
      _isLoading = false;
    });
  }

  Future<void> _refreshContents() async {
    setState(() => _isLoading = true);
    await _loadSubjects();
  }

  void _showCreateSubjectDialog() {
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
                'Crear Nuevo Subtema',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSubjectForm(
                onSubmit: (title, description, duration, iconName) async {
                  Navigator.pop(dialogContext);
                  final subject = await _subjectService.createSubject(
                    lessonId: widget.subjectId,
                    title: title,
                    description: description,
                  );
                  debugPrint('🟣 Subtema creado. subject.id: \\${subject?.id}');
                  if (subject != null && mounted) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Subtema creado correctamente')),
                    );
                    _loadSubjects();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSubjectDialog(Subject subject) {
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
                'Editar Subtema',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSubjectForm(
                subject: subject,
                onSubmit: (title, description, duration, iconName) async {
                  Navigator.pop(dialogContext);
                  final success = await _subjectService.updateSubject(
                    subject.id,
                    {
                      'title': title,
                      'description': description,
                      'duration': duration,
                      'icon_name': iconName,
                    },
                  );
                  if (success && mounted) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Subtema actualizado correctamente')),
                    );
                    _loadSubjects();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este subtema?'),
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
      final success = await _subjectService.deleteSubject(subject.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subtema eliminado correctamente')),
        );
        _loadSubjects();
      }
    }
  }

  Widget _buildSubjectForm({
    Subject? subject,
    required Function(String title, String? description, String? duration,
            String? iconName)
        onSubmit,
  }) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: subject?.title);
    final descriptionController =
        TextEditingController(text: subject?.description);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: titleController,
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
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onSubmit(
                    titleController.text,
                    descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    null, // duration
                    null, // iconName
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                subject == null ? 'Crear Subtema' : 'Actualizar Subtema',
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildTabSection(),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin && _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: _showCreateSubjectDialog,
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.subjectName),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background_detail_screen.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton('Lecciones', 0),
          _buildTabButton('Recursos', 1),
          _buildTabButton('Laboratorios', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : AppTheme.secondaryColor,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected ? Colors.black : AppTheme.textColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTabIndex == 0) {
      return _buildLessonsList();
    } else if (_selectedTabIndex == 1) {
      // TODO: Agregar recursos
      return const Center(child: Text('Recursos (Próximamente)'));
    } else {
      // TODO: Agregar laboratorios
      return const Center(child: Text('Laboratorios (Próximamente)'));
    }
  }

  Widget _buildLessonsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: _subjects.map((subject) {
          return _buildSubjectItem(subject);
        }).toList(),
      ),
    );
  }

  Widget _buildSubjectItem(Subject subject) {
    debugPrint('🟢 subject.id (debería ser UUID): ${subject.id}');
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonContentScreen(
                  lessonTitle: subject.title,
                  subjectId: subject.id,
                  lessonId: subject.id,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconData(subject.iconName),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            subject.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          if (subject.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subject.description!,
                              style: TextStyle(
                                color: AppTheme.textColor.withOpacity(0.6),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.edit, color: AppTheme.accentColor),
                        onPressed: () => _showEditSubjectDialog(subject),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSubject(subject),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TODO: Agregar iconos
  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.article;

    switch (iconName) {
      case 'lock_outline':
        return Icons.lock_outline;
      case 'security':
        return Icons.security;
      case 'enhanced_encryption':
        return Icons.enhanced_encryption;
      default:
        return Icons.article;
    }
  }
}
