import 'package:isar/isar.dart';

part 'local_subject.g.dart';

@collection
class LocalSubject {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String remoteId;

  @Index()
  final String lessonId;

  final String title;
  final String? description;
  final String? duration;
  final String? iconName;

  @Index()
  final int orderIndex;

  final DateTime createdAt;
  final DateTime updatedAt;

  @Index()
  final bool isActive;

  @Index()
  final DateTime lastSyncedAt;

  LocalSubject({
    required this.remoteId,
    required this.lessonId,
    required this.title,
    this.description,
    this.duration,
    this.iconName,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    required this.lastSyncedAt,
  });

  factory LocalSubject.fromRemote(Map<String, dynamic> remoteData) {
    return LocalSubject(
      remoteId: remoteData['id'],
      lessonId: remoteData['lesson_id'],
      title: remoteData['title'],
      description: remoteData['description'],
      duration: remoteData['duration'],
      iconName: remoteData['icon_name'],
      orderIndex: remoteData['order_index'] ?? 0,
      createdAt: DateTime.parse(remoteData['created_at']),
      updatedAt: DateTime.parse(remoteData['updated_at']),
      isActive: remoteData['is_active'] ?? true,
      lastSyncedAt: DateTime.now(),
    );
  }
}
