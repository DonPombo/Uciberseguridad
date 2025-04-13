import 'local_lesson.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final String content;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Crear desde Supabase
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      order: map['order'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      isActive: map['is_active'] ?? true,
    );
  }

  factory Lesson.fromLocal(LocalLesson local) {
    return Lesson(
      id: local.remoteId,
      title: local.title,
      description: local.description,
      content: local.content,
      order: local.order,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      isActive: local.isActive,
    );
  }

  // Convertir a Map para Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  // Crear una copia del objeto con algunos campos modificados
  Lesson copyWith({
    String? title,
    String? description,
    String? content,
    int? order,
    bool? isActive,
  }) {
    return Lesson(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      order: order ?? this.order,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
