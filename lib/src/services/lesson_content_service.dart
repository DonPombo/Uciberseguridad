import 'package:flutter/foundation.dart';
import '../models/lesson_content.dart';
import '../models/local_lesson_content.dart';
import 'local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonContentService {
  final LocalStorageService _localStorage = LocalStorageService();
  final SupabaseClient _supabaseClient;

  LessonContentService(this._supabaseClient);

  Future<List<LessonContent>> getContents(String subjectId) async {
    debugPrint('\n🔍 OBTENIENDO CONTENIDOS');
    debugPrint('==================================');
    debugPrint('   - Subject ID: $subjectId');

    try {
      // Obtener contenidos de Isar
      debugPrint('   - Consultando Isar...');
      final localContents = await _localStorage.getContents(subjectId);
      debugPrint(
          '   - Contenidos encontrados en Isar: ${localContents.length}');

      // Convertir a LessonContent para la UI
      final contents = localContents
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

      debugPrint('✅ Contenidos obtenidos exitosamente');
      return contents;
    } catch (e) {
      debugPrint('❌ Error obteniendo contenidos: $e');
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
    debugPrint('\n📝 CREANDO CONTENIDO');
    debugPrint('================================');
    debugPrint('   - Subject ID: $subjectId');
    debugPrint('   - Título: $title');
    debugPrint('   - Tipo: ${contentType.toString()}');
    debugPrint('   - Video URL: $videoUrl');

    try {
      // Obtener el último orden
      final lastOrder = await _getLastOrder(subjectId);
      final now = DateTime.now();

      // Guardar en Supabase
      debugPrint('   - Enviando datos a Supabase...');
      final supabaseData = {
        'title': title,
        'content_type': contentType.toString().split('.').last,
        'content': content,
        'video_url': videoUrl,
        'order_index': lastOrder + 1,
      };
      debugPrint('      ${supabaseData.toString()}');

      // Primero obtener el subject_id correcto de la tabla subjects
      try {
        // Buscar el subject en Isar para obtener su remoteId
        final subject = await _localStorage.getSubject(subjectId);
        if (subject == null) {
          debugPrint('❌ Error: No se encontró el subject en Isar');
          return null;
        }

        debugPrint('   - Subject encontrado en Isar:');
        debugPrint('      * ID local: ${subject.id}');
        debugPrint('      * ID remoto: ${subject.remoteId}');

        // Buscar el subject en Supabase usando el remoteId
        final subjectResponse = await _supabaseClient
            .from('subjects')
            .select('id')
            .eq('id', subject.remoteId)
            .single();

        final supabaseSubjectId = subjectResponse['id'];
        debugPrint('   - Subject ID en Supabase: $supabaseSubjectId');

        // Actualizar el subject_id en los datos
        supabaseData['subject_id'] = supabaseSubjectId;

        final response = await _supabaseClient
            .from('lesson_contents')
            .insert(supabaseData)
            .select()
            .single();

        debugPrint('   - Respuesta de Supabase:');
        debugPrint('      ${response.toString()}');

        // Crear contenido local con el ID de Supabase
        final localContent = LocalLessonContent(
          remoteId: response['id'],
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
        debugPrint('   - Guardando en Isar...');
        await _localStorage.saveContent(localContent);

        // Convertir a LessonContent para la UI
        final lessonContent = LessonContent(
          id: response['id'],
          subjectId: subjectId,
          title: title,
          contentType: contentType,
          content: content,
          videoUrl: videoUrl,
          orderIndex: lastOrder + 1,
          createdAt: now,
          updatedAt: now,
        );

        debugPrint('✅ Contenido creado exitosamente');
        return lessonContent;
      } catch (e) {
        debugPrint('❌ Error: No se encontró el subject en Supabase: $e');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error creando contenido: $e');
      return null;
    }
  }

  Future<bool> updateContent(
      String contentId, Map<String, dynamic> data) async {
    debugPrint('\n📝 ACTUALIZANDO CONTENIDO');
    debugPrint('====================================');
    debugPrint('   - Content ID: $contentId');
    debugPrint('   - Actualizaciones:');
    data.forEach((key, value) => debugPrint('      - $key: $value'));

    try {
      // Obtener contenido existente
      debugPrint('   - Obteniendo contenido existente...');
      final existingContent = await _localStorage.getContent(contentId);
      if (existingContent == null) {
        debugPrint('❌ Contenido no encontrado en Isar');
        return false;
      }

      // Actualizar el objeto existente
      existingContent.title = data['title'] ?? existingContent.title;
      existingContent.contentType =
          data['content_type'] ?? existingContent.contentType;
      existingContent.content = data['content'] ?? existingContent.content;
      existingContent.videoUrl = data['video_url'] ?? existingContent.videoUrl;
      existingContent.updatedAt = DateTime.now();
      existingContent.lastSyncedAt = DateTime.now();

      // Guardar en Isar
      debugPrint('   - Guardando en Isar...');
      await _localStorage.saveContent(existingContent);

      // Actualizar en Supabase
      debugPrint('   - Enviando datos a Supabase...');
      final supabaseData = {
        'title': existingContent.title,
        'content_type': existingContent.contentType,
        'content': existingContent.content,
        'video_url': existingContent.videoUrl,
        'updated_at': existingContent.updatedAt.toIso8601String(),
      };
      debugPrint('      ${supabaseData.toString()}');

      await _supabaseClient
          .from('lesson_contents')
          .update(supabaseData)
          .eq('id', contentId);

      debugPrint('✅ Contenido actualizado exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error actualizando contenido: $e');
      return false;
    }
  }

  Future<bool> deleteContent(String contentId) async {
    debugPrint('\n🗑️ ELIMINANDO CONTENIDO');
    debugPrint('==================================');
    debugPrint('   - Content ID: $contentId');

    try {
      // Eliminar de Isar
      debugPrint('   - Eliminando de Isar...');
      await _localStorage.deleteContent(contentId);

      // Eliminar de Supabase
      debugPrint('   - Eliminando de Supabase...');
      await _supabaseClient
          .from('lesson_contents')
          .delete()
          .eq('id', contentId);

      debugPrint('✅ Contenido eliminado exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando contenido: $e');
      return false;
    }
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
