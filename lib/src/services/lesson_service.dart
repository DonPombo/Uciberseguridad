import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson.dart';

class LessonService {
  final _supabase = Supabase.instance.client;

  // Obtener todas las lecciones activas
  Future<List<Lesson>> getLessons() async {
    try {
      final response = await _supabase
          .from('lessons')
          .select()
          .eq('is_active', true)
          .order('order');

      return (response as List)
          .map((lesson) => Lesson.fromMap(lesson))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo lecciones: $e');
      return [];
    }
  }

  // Crear una nueva lección
  Future<Lesson?> createLesson({
    required String title,
    required String description,
    required String content,
    String? videoUrl,
  }) async {
    try {
      // Obtener el último orden
      final lastOrder = await _getLastOrder();

      final response = await _supabase
          .from('lessons')
          .insert({
            'title': title,
            'description': description,
            'content': content,
            'video_url': videoUrl,
            'order': lastOrder + 1,
            'is_active': true,
          })
          .select()
          .single();

      return Lesson.fromMap(response);
    } catch (e) {
      debugPrint('Error creando lección: $e');
      return null;
    }
  }

  // Actualizar una lección existente
  Future<bool> updateLesson(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('lessons').update(updates).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error actualizando lección: $e');
      return false;
    }
  }

  // Eliminar una lección (soft delete)
  Future<bool> deleteLesson(String id) async {
    try {
      await _supabase.from('lessons').update({'is_active': false}).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error eliminando lección: $e');
      return false;
    }
  }

  // Obtener una lección específica
  Future<Lesson?> getLesson(String id) async {
    try {
      final response =
          await _supabase.from('lessons').select().eq('id', id).single();

      return Lesson.fromMap(response);
    } catch (e) {
      debugPrint('Error obteniendo lección: $e');
      return null;
    }
  }

  // Método privado para obtener el último orden
  Future<int> _getLastOrder() async {
    try {
      final response = await _supabase
          .from('lessons')
          .select('order')
          .order('order', ascending: false)
          .limit(1)
          .single();

      return (response['order'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
