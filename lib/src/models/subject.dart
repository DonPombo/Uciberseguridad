class Subject {
  final String id;
  final String lessonId;
  final String title;
  final String? description;
  final String? duration;
  final String? iconName;
  final int orderIndex;
  final DateTime createdAt;
  final bool isActive;

  Subject({
    required this.id,
    required this.lessonId,
    required this.title,
    this.description,
    this.duration,
    this.iconName,
    required this.orderIndex,
    required this.createdAt,
    this.isActive = true,
  });

  // Crear desde Supabase
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] ?? '',
      lessonId: map['lesson_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      duration: map['duration'],
      iconName: map['icon_name'],
      orderIndex: map['order_index'] ?? 0,
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      isActive: map['is_active'] ?? true,
    );
  }

  // Convertir a Map para Supabase
  Map<String, dynamic> toMap() {
    return {
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'duration': duration,
      'icon_name': iconName,
      'order_index': orderIndex,
      'is_active': isActive,
    };
  }

  // Crear una copia del objeto con algunos campos modificados
  Subject copyWith({
    String? title,
    String? description,
    String? duration,
    String? iconName,
    int? orderIndex,
    bool? isActive,
  }) {
    return Subject(
      id: id,
      lessonId: lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      iconName: iconName ?? this.iconName,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
