import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../models/local_lesson_content.dart';
import '../models/local_subject.dart';
import 'isar_service.dart';

class LocalStorageService {
  final _isarService = IsarService.instance;
  final Dio _dio = Dio();
  late Isar _isar;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isar = await Isar.open(
      [LocalLessonContentSchema],
      directory: './isar_db',
    );
    _isInitialized = true;
  }

  // CRUD Operations
  Future<void> saveContent(LocalLessonContent content) async {
    final isar = await _isarService.isar;
    await isar.writeTxn(() async {
      await isar.localLessonContents.put(content);
    });
  }

  Future<List<LocalLessonContent>> getContents(String subjectId) async {
    final isar = await _isarService.isar;
    return await isar.localLessonContents
        .where()
        .subjectIdEqualTo(subjectId)
        .filter()
        .isActiveEqualTo(true)
        .sortByOrderIndex()
        .findAll();
  }

  Future<LocalLessonContent?> getContent(String remoteId) async {
    final isar = await _isarService.isar;
    return await isar.localLessonContents
        .where()
        .remoteIdEqualTo(remoteId)
        .findFirst();
  }

  Future<void> deleteContent(String remoteId) async {
    final isar = await _isarService.isar;
    await isar.writeTxn(() async {
      final content = await isar.localLessonContents
          .where()
          .remoteIdEqualTo(remoteId)
          .findFirst();

      if (content != null) {
        if (content.localVideoPath != null) {
          final file = File(content.localVideoPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        await isar.localLessonContents.delete(content.id);
      }
    });
  }

  // Video Download Operations
  Future<void> downloadVideo(LocalLessonContent content) async {
    if (content.videoUrl == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${content.remoteId}_video.mp4';
    final filePath = '${dir.path}/videos/$fileName';

    // Crear directorio si no existe
    await Directory('${dir.path}/videos').create(recursive: true);

    try {
      await _dio.download(
        content.videoUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Aquí puedes implementar un callback para mostrar el progreso
          }
        },
      );

      // Actualizar el contenido con la ruta local
      final isar = await _isarService.isar;
      await isar.writeTxn(() async {
        content.localVideoPath = filePath;
        content.isDownloaded = true;
        await isar.localLessonContents.put(content);
      });
    } catch (e) {
      print('Error downloading video: $e');
      rethrow;
    }
  }

  // Subject Operations
  Future<void> saveSubject(LocalSubject subject) async {
    final isar = await _isarService.isar;
    await isar.writeTxn(() async {
      await isar.localSubjects.put(subject);
    });
  }

  Future<List<LocalSubject>> getSubjects(String lessonId) async {
    final isar = await _isarService.isar;
    return await isar.localSubjects
        .where()
        .lessonIdEqualTo(lessonId)
        .filter()
        .isActiveEqualTo(true)
        .sortByOrderIndex()
        .findAll();
  }

  Future<LocalSubject?> getSubject(String remoteId) async {
    final isar = await _isarService.isar;
    return await isar.localSubjects
        .where()
        .remoteIdEqualTo(remoteId)
        .findFirst();
  }

  Future<void> deleteSubject(String remoteId) async {
    final isar = await _isarService.isar;
    await isar.writeTxn(() async {
      final subject = await isar.localSubjects
          .where()
          .remoteIdEqualTo(remoteId)
          .findFirst();

      if (subject != null) {
        // Eliminar todos los contenidos asociados
        final contents = await isar.localLessonContents
            .where()
            .subjectIdEqualTo(subject.remoteId)
            .findAll();

        for (var content in contents) {
          if (content.localVideoPath != null) {
            final file = File(content.localVideoPath!);
            if (await file.exists()) {
              await file.delete();
            }
          }
          await isar.localLessonContents.delete(content.id);
        }

        await isar.localSubjects.delete(subject.id);
      }
    });
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _isar.close();
      _isInitialized = false;
    }
  }
}
