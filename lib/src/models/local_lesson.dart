import 'package:isar/isar.dart';

part 'local_lesson.g.dart';

@collection
class LocalLesson {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String remoteId;

  String title;
  String description;
  String content;

  @Index()
  final int order;

  DateTime createdAt;
  DateTime updatedAt;

  @Index()
  bool isActive;

  @Index()
  DateTime lastSyncedAt;

  bool isDownloaded;

  LocalLesson({
    required this.remoteId,
    required this.title,
    required this.description,
    required this.content,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    required this.lastSyncedAt,
    this.isDownloaded = false,
  });

  factory LocalLesson.fromRemote(Map<String, dynamic> remoteData) {
    return LocalLesson(
      remoteId: remoteData['id'] ?? '',
      title: remoteData['title'] ?? '',
      description: remoteData['description'] ?? '',
      content: remoteData['content'] ?? '',
      order: remoteData['order'] ?? 0,
      createdAt: remoteData['created_at'] != null
          ? DateTime.parse(remoteData['created_at'])
          : DateTime.now(),
      updatedAt: remoteData['updated_at'] != null
          ? DateTime.parse(remoteData['updated_at'])
          : DateTime.now(),
      isActive: remoteData['is_active'] ?? true,
      lastSyncedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toRemote() {
    return {
      'id': remoteId,
      'title': title,
      'description': description,
      'content': content,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
