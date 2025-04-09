import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uciberseguridad_app/src/models/lesson_content.dart';

class LessonContentService {
  final _supabase = Supabase.instance.client;

  Future<List<LessonContent>> getContents(String subjectId) async {
    try {
      final response = await _supabase
          .from('contents')
          .select()
          .eq('subject_id', subjectId)
          .eq('is_active', true)
          .order('order');

      return (response as List)
          .map((content) => LessonContent.fromMap(content, id: content['id']))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo contenidos: $e');
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

      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('contents')
          .insert({
            'subject_id': subjectId,
            'title': title,
            'content_type': contentType.toString().split('.').last,
            'content': content,
            'video_url': videoUrl,
            'order': lastOrder + 1,
            'created_at': now,
            'updated_at': now,
            'is_active': true,
          })
          .select()
          .single();

      return LessonContent.fromMap(response, id: response['id']);
    } catch (e) {
      debugPrint('Error creando contenido: $e');
      return null;
    }
  }

  Future<bool> updateContent(
      String contentId, Map<String, dynamic> data) async {
    try {
      final now = DateTime.now().toIso8601String();

      await _supabase.from('contents').update({
        ...data,
        'updated_at': now,
      }).eq('id', contentId);
      return true;
    } catch (e) {
      debugPrint('Error actualizando contenido: $e');
      return false;
    }
  }

  Future<bool> deleteContent(String contentId) async {
    try {
      await _supabase
          .from('contents')
          .update({'is_active': false}).eq('id', contentId);
      return true;
    } catch (e) {
      debugPrint('Error eliminando contenido: $e');
      return false;
    }
  }

  // Método privado para obtener el último orden
  Future<int> _getLastOrder(String subjectId) async {
    try {
      final response = await _supabase
          .from('contents')
          .select('order')
          .eq('subject_id', subjectId)
          .eq('is_active', true)
          .order('order', ascending: false)
          .limit(1)
          .single();

      return (response['order'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
