import 'package:isar/isar.dart';

part 'local_lesson_content.g.dart';

@collection
class LocalLessonContent {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String remoteId;

  @Index()
  final String subjectId;

  String title;
  String contentType;
  String content;
  String? videoUrl;
  String? localVideoPath;

  @Index()
  final int orderIndex;

  final DateTime createdAt;
  DateTime updatedAt;

  @Index()
  bool isActive;

  bool isDownloaded;

  @Index()
  DateTime lastSyncedAt;

  LocalLessonContent({
    required this.remoteId,
    required this.subjectId,
    required this.title,
    required this.contentType,
    required this.content,
    this.videoUrl,
    this.localVideoPath,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isDownloaded = false,
    required this.lastSyncedAt,
  });

  factory LocalLessonContent.fromRemote(Map<String, dynamic> remoteData) {
    return LocalLessonContent(
      remoteId: remoteData['id'],
      subjectId: remoteData['subject_id'],
      title: remoteData['title'],
      contentType: remoteData['content_type'],
      content: remoteData['content'],
      videoUrl: remoteData['video_url'],
      orderIndex: remoteData['order_index'] ?? 0,
      createdAt: DateTime.parse(remoteData['created_at']),
      updatedAt: DateTime.parse(remoteData['updated_at']),
      isActive: remoteData['is_active'] ?? true,
      lastSyncedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toRemote() {
    return {
      'id': remoteId,
      'subject_id': subjectId,
      'title': title,
      'content_type': contentType,
      'content': content,
      'video_url': videoUrl,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
