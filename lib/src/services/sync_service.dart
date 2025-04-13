import 'dart:async';
import 'package:flutter/foundation.dart';
import 'lesson_service.dart';
import 'lesson_content_service.dart';
import 'local_storage_service.dart';

class SyncService {
  final LessonService _lessonService;
  final LessonContentService _contentService = LessonContentService();
  final LocalStorageService _localStorage = LocalStorageService();
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._lessonService);

  void startSync() {
    // Ya no necesitamos sincronización periódica
    _syncTimer?.cancel();
  }

  void stopSync() {
    _syncTimer?.cancel();
  }

  Future<void> syncNow() async {
    // Ya no necesitamos sincronización
    return;
  }
}
