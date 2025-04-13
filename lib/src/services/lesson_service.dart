import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/lesson.dart';
import '../models/local_lesson.dart';
import 'isar_service.dart';

class LessonService {
  late final Isar _isar;
  bool _isInitialized = false;
  static LessonService? _instance;

  // Constructor privado para singleton
  LessonService._();

  // Factory constructor para obtener la instancia
  static LessonService get instance {
    _instance ??= LessonService._();
    return _instance!;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _isar = await IsarService.instance.isar;
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando Isar: $e');
      rethrow;
    }
  }

  // Obtener todas las lecciones activas
  Future<List<Lesson>> getLessons() async {
    try {
      if (!_isInitialized) await init();

      final localLessons = await _isar.localLessons
          .where()
          .isActiveEqualTo(true)
          .sortByOrder()
          .findAll();

      return localLessons.map((local) => Lesson.fromLocal(local)).toList();
    } catch (e) {
      debugPrint('Error obteniendo lecciones: $e');
      return [];
    }
  }

  // Crear una nueva lección
  Future<Lesson?> createLesson({
    required String title,
    required String description,
  }) async {
    try {
      if (!_isInitialized) await init();

      // Obtener el último orden
      final lastOrder = await _getLastOrder();

      final now = DateTime.now();
      final localId = now.millisecondsSinceEpoch.toString();

      final localLesson = LocalLesson(
        remoteId: localId,
        title: title,
        description: description,
        content: '',
        order: lastOrder + 1,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        lastSyncedAt: now,
        isDownloaded: false,
      );

      await _isar.writeTxn(() async {
        await _isar.localLessons.put(localLesson);
      });

      return Lesson.fromLocal(localLesson);
    } catch (e) {
      debugPrint('Error creando lección: $e');
      return null;
    }
  }

  // Actualizar una lección existente
  Future<bool> updateLesson(String id, Map<String, dynamic> updates) async {
    try {
      if (!_isInitialized) await init();

      final localLesson =
          await _isar.localLessons.where().remoteIdEqualTo(id).findFirst();

      if (localLesson != null) {
        final isarId = localLesson.id;
        await _isar.writeTxn(() async {
          final updatedLesson = LocalLesson(
            remoteId: localLesson.remoteId,
            title: updates['title'] ?? localLesson.title,
            description: updates['description'] ?? localLesson.description,
            content: localLesson.content,
            order: localLesson.order,
            createdAt: localLesson.createdAt,
            updatedAt: DateTime.now(),
            isActive: localLesson.isActive,
            lastSyncedAt: DateTime.now(),
            isDownloaded: localLesson.isDownloaded,
          );
          updatedLesson.id = isarId;
          await _isar.localLessons.put(updatedLesson);
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error actualizando lección: $e');
      return false;
    }
  }

  // Eliminar una lección (soft delete)
  Future<bool> deleteLesson(String id) async {
    try {
      if (!_isInitialized) await init();

      final localLesson =
          await _isar.localLessons.where().remoteIdEqualTo(id).findFirst();

      if (localLesson != null) {
        final isarId = localLesson.id;
        await _isar.writeTxn(() async {
          final updatedLesson = LocalLesson(
            remoteId: localLesson.remoteId,
            title: localLesson.title,
            description: localLesson.description,
            content: localLesson.content,
            order: localLesson.order,
            createdAt: localLesson.createdAt,
            updatedAt: DateTime.now(),
            isActive: false,
            lastSyncedAt: DateTime.now(),
            isDownloaded: localLesson.isDownloaded,
          );
          updatedLesson.id = isarId;
          await _isar.localLessons.put(updatedLesson);
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error eliminando lección: $e');
      return false;
    }
  }

  // Obtener una lección específica
  Future<Lesson?> getLesson(String id) async {
    try {
      if (!_isInitialized) await init();

      final localLesson =
          await _isar.localLessons.where().remoteIdEqualTo(id).findFirst();

      if (localLesson != null) {
        return Lesson.fromLocal(localLesson);
      }

      return null;
    } catch (e) {
      debugPrint('Error obteniendo lección: $e');
      return null;
    }
  }

  // Método privado para obtener el último orden
  Future<int> _getLastOrder() async {
    try {
      if (!_isInitialized) await init();

      final lastLocalLesson =
          await _isar.localLessons.where().sortByOrderDesc().findFirst();
      return lastLocalLesson?.order ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
