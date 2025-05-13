import 'package:flutter/foundation.dart';
import '../models/subject.dart';
import '../models/local_subject.dart';
import 'local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectService {
  final LocalStorageService _localStorage = LocalStorageService();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Obtener todos los subtemas de una lección
  Future<List<Subject>> getSubjects(String lessonId) async {
    try {
      final localSubjects = await _localStorage.getSubjects(lessonId);

      return localSubjects
          .map((local) => Subject(
                id: local.remoteId,
                lessonId: local.lessonId,
                title: local.title,
                description: local.description,
                duration: local.duration,
                iconName: local.iconName,
                orderIndex: local.orderIndex,
                createdAt: local.createdAt,
                isActive: local.isActive,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo subtemas: $e');
      return [];
    }
  }

  // Crear un nuevo subtema
  Future<Subject?> createSubject({
    required String lessonId,
    required String title,
    String? description,
  }) async {
    try {
      debugPrint('\n📝 CREANDO SUBTEMA');
      debugPrint('================================');
      debugPrint('   - Lesson ID: $lessonId');
      debugPrint('   - Título: $title');
      debugPrint('   - Descripción: $description');

      // Obtener el último orden
      final lastOrder = await _getLastOrder(lessonId);
      final now = DateTime.now();

      // Crear en Supabase
      debugPrint('   - Enviando datos a Supabase...');
      final supabaseData = {
        'lesson_id': lessonId,
        'title': title,
        'description': description,
        'order_index': lastOrder + 1,
        'created_at': now.toIso8601String(),
      };
      debugPrint('      ${supabaseData.toString()}');

      final response = await _supabaseClient
          .from('subjects')
          .insert(supabaseData)
          .select()
          .single();

      debugPrint('   - Respuesta de Supabase:');
      debugPrint('      ${response.toString()}');

      // Crear tema local con el ID de Supabase
      final localSubject = LocalSubject(
        remoteId: response['id'],
        lessonId: lessonId,
        title: title,
        description: description,
        duration: null,
        iconName: null,
        orderIndex: lastOrder + 1,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        lastSyncedAt: now,
      );

      // Guardar en Isar
      debugPrint('   - Guardando en Isar...');
      await _localStorage.saveSubject(localSubject);

      // Convertir a Subject para la UI
      final subject = Subject(
        id: localSubject.remoteId,
        lessonId: localSubject.lessonId,
        title: localSubject.title,
        description: localSubject.description,
        duration: null,
        iconName: null,
        orderIndex: localSubject.orderIndex,
        createdAt: localSubject.createdAt,
        isActive: localSubject.isActive,
      );

      debugPrint('✅ Subtema creado exitosamente');
      return subject;
    } catch (e) {
      debugPrint('❌ Error creando subtema: $e');
      return null;
    }
  }

  // Actualizar un subtema existente
  Future<bool> updateSubject(String id, Map<String, dynamic> updates) async {
    try {
      final existingSubject = await _localStorage.getSubject(id);
      if (existingSubject == null) return false;

      // Actualizar en Supabase
      final supabaseData = {
        'title': updates['title'] ?? existingSubject.title,
        'description': updates['description'] ?? existingSubject.description,
        'order_index': existingSubject.orderIndex,
      };

      await _supabaseClient
          .from('subjects')
          .update(supabaseData)
          .eq('id', existingSubject.remoteId);

      // Actualizar el objeto existente
      existingSubject.title = updates['title'] ?? existingSubject.title;
      existingSubject.description =
          updates['description'] ?? existingSubject.description;
      existingSubject.duration =
          updates['duration'] ?? existingSubject.duration;
      existingSubject.iconName =
          updates['icon_name'] ?? existingSubject.iconName;
      existingSubject.updatedAt = DateTime.now();
      existingSubject.lastSyncedAt = DateTime.now();

      // Guardar los cambios en Isar
      await _localStorage.saveSubject(existingSubject);
      return true;
    } catch (e) {
      debugPrint('Error actualizando subtema: $e');
      return false;
    }
  }

  // Eliminar un subtema
  Future<bool> deleteSubject(String id) async {
    try {
      await _localStorage.deleteSubject(id);
      return true;
    } catch (e) {
      debugPrint('Error eliminando subtema: $e');
      return false;
    }
  }

  // Obtener un subtema específico
  Future<Subject?> getSubject(String id) async {
    try {
      final localSubject = await _localStorage.getSubject(id);
      if (localSubject == null) return null;

      return Subject(
        id: localSubject.remoteId,
        lessonId: localSubject.lessonId,
        title: localSubject.title,
        description: localSubject.description,
        duration: localSubject.duration,
        iconName: localSubject.iconName,
        orderIndex: localSubject.orderIndex,
        createdAt: localSubject.createdAt,
        isActive: localSubject.isActive,
      );
    } catch (e) {
      debugPrint('Error obteniendo subtema: $e');
      return null;
    }
  }

  // Método privado para obtener el último orden
  Future<int> _getLastOrder(String lessonId) async {
    try {
      final subjects = await _localStorage.getSubjects(lessonId);
      if (subjects.isEmpty) return 0;

      subjects.sort((a, b) => b.orderIndex.compareTo(a.orderIndex));
      return subjects.first.orderIndex;
    } catch (e) {
      return 0;
    }
  }
}
