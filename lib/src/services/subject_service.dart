import 'package:flutter/foundation.dart';
import '../models/subject.dart';
import '../models/local_subject.dart';
import 'local_storage_service.dart';

class SubjectService {
  final LocalStorageService _localStorage = LocalStorageService();

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
    String? duration,
    String? iconName,
  }) async {
    try {
      // Obtener el último orden
      final lastOrder = await _getLastOrder(lessonId);
      final now = DateTime.now();

      // Crear ID único para el tema local
      final localId = DateTime.now().millisecondsSinceEpoch.toString();

      // Crear tema local
      final localSubject = LocalSubject(
        remoteId: localId,
        lessonId: lessonId,
        title: title,
        description: description,
        duration: duration,
        iconName: iconName,
        orderIndex: lastOrder + 1,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        lastSyncedAt: now,
      );

      // Guardar en Isar
      await _localStorage.saveSubject(localSubject);

      // Convertir a Subject para la UI
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
      debugPrint('Error creando subtema: $e');
      return null;
    }
  }

  // Actualizar un subtema existente
  Future<bool> updateSubject(String id, Map<String, dynamic> updates) async {
    try {
      final existingSubject = await _localStorage.getSubject(id);
      if (existingSubject == null) return false;

      final updatedSubject = LocalSubject(
        remoteId: existingSubject.remoteId,
        lessonId: existingSubject.lessonId,
        title: updates['title'] ?? existingSubject.title,
        description: updates['description'] ?? existingSubject.description,
        duration: updates['duration'] ?? existingSubject.duration,
        iconName: updates['icon_name'] ?? existingSubject.iconName,
        orderIndex: existingSubject.orderIndex,
        createdAt: existingSubject.createdAt,
        updatedAt: DateTime.now(),
        isActive: existingSubject.isActive,
        lastSyncedAt: existingSubject.lastSyncedAt,
      );

      await _localStorage.saveSubject(updatedSubject);
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
