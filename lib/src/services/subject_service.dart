import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject.dart';

class SubjectService {
  final _supabase = Supabase.instance.client;

  // Obtener todos los subtemas de una lección
  Future<List<Subject>> getSubjects(String lessonId) async {
    try {
      final response = await _supabase
          .from('subjects')
          .select()
          .eq('lesson_id', lessonId)
          .eq('is_active', true)
          .order('order_index');

      return (response as List)
          .map((subject) => Subject.fromMap(subject))
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

      final response = await _supabase
          .from('subjects')
          .insert({
            'lesson_id': lessonId,
            'title': title,
            'description': description,
            'duration': duration,
            'icon_name': iconName,
            'order_index': lastOrder + 1,
            'is_active': true,
          })
          .select()
          .single();

      return Subject.fromMap(response);
    } catch (e) {
      debugPrint('Error creando subtema: $e');
      return null;
    }
  }

  // Actualizar un subtema existente
  Future<bool> updateSubject(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('subjects').update(updates).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error actualizando subtema: $e');
      return false;
    }
  }

  // Eliminar un subtema (soft delete)
  Future<bool> deleteSubject(String id) async {
    try {
      await _supabase
          .from('subjects')
          .update({'is_active': false}).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error eliminando subtema: $e');
      return false;
    }
  }

  // Obtener un subtema específico
  Future<Subject?> getSubject(String id) async {
    try {
      final response =
          await _supabase.from('subjects').select().eq('id', id).single();

      return Subject.fromMap(response);
    } catch (e) {
      debugPrint('Error obteniendo subtema: $e');
      return null;
    }
  }

  // Método privado para obtener el último orden
  Future<int> _getLastOrder(String lessonId) async {
    try {
      final response = await _supabase
          .from('subjects')
          .select('order_index')
          .eq('lesson_id', lessonId)
          .order('order_index', ascending: false)
          .limit(1)
          .single();

      return (response['order_index'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
