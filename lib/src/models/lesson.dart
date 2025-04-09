class Lesson {
  final String id;
  final String title;
  final String description;
  final int order;
  final DateTime createdAt;
  final bool isActive;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.createdAt,
    this.isActive = true,
  });

  // Crear desde Supabase
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      order: map['order'] ?? 0,
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      isActive: map['is_active'] ?? true,
    );
  }

  // Convertir a Map para Supabase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'order': order,
      'is_active': isActive,
    };
  }

  // Crear una copia del objeto con algunos campos modificados
  Lesson copyWith({
    String? title,
    String? description,
    int? order,
    bool? isActive,
  }) {
    return Lesson(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
