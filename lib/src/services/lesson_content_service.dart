import 'package:flutter/foundation.dart';
import '../models/lesson_content.dart';
import '../models/local_lesson_content.dart';
import 'local_storage_service.dart';

class LessonContentService {
  final LocalStorageService _localStorage = LocalStorageService();

  Future<List<LessonContent>> getContents(String subjectId) async {
    try {
      // Obtener contenidos de Isar
      final localContents = await _localStorage.getContents(subjectId);

      // Convertir a LessonContent para la UI
      return localContents
          .map((local) => LessonContent(
                id: local.remoteId,
                subjectId: local.subjectId,
                title: local.title,
                contentType: ContentType.values.firstWhere(
                  (e) => e.toString().split('.').last == local.contentType,
                ),
                content: local.content,
                videoUrl: local.videoUrl,
                orderIndex: local.orderIndex,
                createdAt: local.createdAt,
                updatedAt: local.updatedAt,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo contenidos de Isar: $e');
      return [];
    }
  }

  Future<LessonContent?> createContent({
    required String subjectId,
    required String title,
    required ContentType contentType,
    required String content,
    String? videoUrl,
  }) async {
    try {
      // Obtener el último orden
      final lastOrder = await _getLastOrder(subjectId);

      final now = DateTime.now();

      // Crear ID único para el contenido local
      final localId = DateTime.now().millisecondsSinceEpoch.toString();

      // Crear contenido local
      final localContent = LocalLessonContent(
        remoteId: localId,
        subjectId: subjectId,
        title: title,
        contentType: contentType.toString().split('.').last,
        content: content,
        videoUrl: videoUrl,
        orderIndex: lastOrder + 1,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        lastSyncedAt: now,
      );

      // Guardar en Isar
      await _localStorage.saveContent(localContent);

      // Convertir a LessonContent para la UI
      return LessonContent(
        id: localContent.remoteId,
        subjectId: localContent.subjectId,
        title: localContent.title,
        contentType: contentType,
        content: localContent.content,
        videoUrl: localContent.videoUrl,
        orderIndex: localContent.orderIndex,
        createdAt: localContent.createdAt,
        updatedAt: localContent.updatedAt,
      );
    } catch (e) {
      debugPrint('Error creando contenido: $e');
      return null;
    }
  }

  Future<bool> updateContent(String contentId, Map<String, dynamic> data) async {
    try {
      // Obtener contenido existente
      final existingContent = await _localStorage.getContent(contentId);
      if (existingContent == null) return false;

      // Crear contenido actualizado
      final updatedContent = LocalLessonContent(
        remoteId: existingContent.remoteId,
        subjectId: existingContent.subjectId,
        title: data['title'] ?? existingContent.title,
        contentType: data['content_type'] ?? existingContent.contentType,
        content: data['content'] ?? existingContent.content,
        videoUrl: data['video_url'] ?? existingContent.videoUrl,
        orderIndex: existingContent.orderIndex,
        createdAt: existingContent.createdAt,
        updatedAt: DateTime.now(),
        isActive: existingContent.isActive,
        isDownloaded: existingContent.isDownloaded,
        localVideoPath: existingContent.localVideoPath,
        lastSyncedAt: DateTime.now(),
      );

      // Guardar en Isar
      await _localStorage.saveContent(updatedContent);

      return true;
    } catch (e) {
      debugPrint('Error actualizando contenido: $e');
      return false;
    }
  }

  Future<bool> deleteContent(String contentId) async {
    try {
      // Eliminar de Isar
      await _localStorage.deleteContent(contentId);
      return true;
    } catch (e) {
      debugPrint('Error eliminando contenido: $e');
      return false;
    }
  }

  // Método para descargar contenido
  Future<void> downloadContent(LessonContent content) async {
    final localContent = LocalLessonContent.fromRemote({
      'id': content.id,
      'subject_id': content.subjectId,
      'title': content.title,
      'content_type': content.contentType.toString().split('.').last,
      'content': content.content,
      'video_url': content.videoUrl,
      'order_index': content.orderIndex,
      'created_at': content.createdAt.toIso8601String(),
      'updated_at': content.updatedAt.toIso8601String(),
      'is_active': true,
    });

    await _localStorage.downloadVideo(localContent);
  }

  // Método privado para obtener el último orden
  Future<int> _getLastOrder(String subjectId) async {
    try {
      final contents = await _localStorage.getContents(subjectId);
      if (contents.isEmpty) return 0;

      // Ordenar por orderIndex y obtener el último
      contents.sort((a, b) => b.orderIndex.compareTo(a.orderIndex));
      return contents.first.orderIndex;
    } catch (e) {
      return 0;
    }
  }
}
