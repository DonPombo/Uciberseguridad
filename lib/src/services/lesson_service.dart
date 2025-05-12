import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/lesson.dart';
import '../models/local_lesson.dart';
import 'isar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonService {
  late final Isar _isar;
  bool _isInitialized = false;
  static LessonService? _instance;
  final SupabaseClient _supabaseClient;

  // Constructor privado para singleton
  LessonService._(this._supabaseClient);

  static LessonService get instance {
    _instance ??= LessonService._(Supabase.instance.client);
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
    debugPrint('\n📝 CREANDO LECCIÓN');
    debugPrint('================================');
    debugPrint('   - Título: $title');
    debugPrint('   - Descripción: $description');

    try {
      final now = DateTime.now();

      // Crear en Supabase
      debugPrint('   - Enviando datos a Supabase...');
      final supabaseData = {
        'title': title,
        'description': description,
        'content': '',
        'order': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      debugPrint('      ${supabaseData.toString()}');

      final response = await _supabaseClient
          .from('lessons')
          .insert(supabaseData)
          .select()
          .single();

      debugPrint('   - Respuesta de Supabase:');
      debugPrint('      ${response.toString()}');
      debugPrint('🟢 UUID de lección creado en Supabase: ${response['id']}');

      // Crear en Isar con el ID de Supabase
      debugPrint('   - Guardando en Isar...');
      final lesson = LocalLesson(
        remoteId: response['id'], // Usamos el ID de Supabase como remoteId
        title: title,
        description: description,
        content: '',
        order: 0,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        lastSyncedAt: now,
        isDownloaded: false,
      );
      await _isar.writeTxn(() async {
        await _isar.localLessons.put(lesson);
      });

      debugPrint('✅ Lección creada exitosamente');
      return Lesson.fromLocal(lesson);
    } catch (e) {
      debugPrint('❌ Error creando lección: $e');
      return null;
    }
  }

  // Actualizar una lección existente
  Future<bool> updateLesson(String id, Map<String, dynamic> data) async {
    debugPrint('\n📝 ACTUALIZANDO LECCIÓN');
    debugPrint('====================================');
    debugPrint('   - ID: $id');
    debugPrint('   - Actualizaciones:');
    data.forEach((key, value) => debugPrint('      - $key: $value'));

    try {
      // Obtener lección existente
      debugPrint('   - Obteniendo lección existente...');
      final lesson =
          await _isar.localLessons.where().remoteIdEqualTo(id).findFirst();

      if (lesson == null) {
        debugPrint('❌ Lección no encontrada en Isar');
        return false;
      }

      // Actualizar en Isar
      debugPrint('   - Actualizando en Isar...');
      lesson.title = data['title'] ?? lesson.title;
      lesson.description = data['description'] ?? lesson.description;
      lesson.updatedAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.localLessons.put(lesson);
      });

      // Actualizar en Supabase
      debugPrint('   - Enviando datos a Supabase...');
      final supabaseData = {
        'title': lesson.title,
        'description': lesson.description,
        'content': lesson.content,
        'order': lesson.order,
        'updated_at': lesson.updatedAt.toIso8601String(),
      };
      debugPrint('      ${supabaseData.toString()}');

      // Primero obtener el lesson_id correcto de Supabase
      try {
        final lessonResponse = await _supabaseClient
            .from('lessons')
            .select('id')
            .eq('local_id', id)
            .single();

        final supabaseLessonId = lessonResponse['id'];
        debugPrint('   - Lesson ID en Supabase: $supabaseLessonId');

        await _supabaseClient
            .from('lessons')
            .update(supabaseData)
            .eq('id', supabaseLessonId);

        debugPrint('✅ Lección actualizada exitosamente');
        return true;
      } catch (e) {
        debugPrint('❌ Error: No se encontró la lección en Supabase');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error actualizando lección: $e');
      return false;
    }
  }

  // Eliminar una lección (soft delete)
  Future<bool> deleteLesson(String id) async {
    debugPrint('\n🗑️ ELIMINANDO LECCIÓN');
    debugPrint('==================================');
    debugPrint('   - ID: $id');

    try {
      // Obtener lección existente
      debugPrint('   - Obteniendo lección existente...');
      final lesson =
          await _isar.localLessons.where().remoteIdEqualTo(id).findFirst();

      if (lesson == null) {
        debugPrint('❌ Lección no encontrada en Isar');
        return false;
      }

      // Eliminar de Isar
      debugPrint('   - Eliminando de Isar...');
      await _isar.writeTxn(() async {
        await _isar.localLessons.delete(lesson.id);
      });

      // Eliminar de Supabase
      debugPrint('   - Eliminando de Supabase...');
      try {
        await _supabaseClient
            .from('lessons')
            .delete()
            .eq('id', lesson.remoteId);

        debugPrint('✅ Lección eliminada exitosamente');
        return true;
      } catch (e) {
        debugPrint('❌ Error: No se encontró la lección en Supabase');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error eliminando lección: $e');
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
