import 'dart:async';
import 'lesson_service.dart';
import 'lesson_content_service.dart';
import 'local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  final LessonService lessonService;
  final LessonContentService contentService;
  final LocalStorageService localStorage = LocalStorageService();
  Timer? _syncTimer;
  bool isSyncing = false;

  SyncService(this.lessonService, SupabaseClient supabaseClient)
      : contentService = LessonContentService(supabaseClient);

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
