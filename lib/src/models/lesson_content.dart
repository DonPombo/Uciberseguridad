enum ContentType { text, video }

class LessonContent {
  final String id;
  final String title;
  final ContentType contentType;
  final String content;
  final String? videoUrl;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonContent({
    required this.id,
    required this.title,
    required this.contentType,
    required this.content,
    this.videoUrl,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonContent.fromMap(Map<String, dynamic> map,
      {required String id}) {
    return LessonContent(
      id: id,
      title: map['title'] as String,
      contentType: ContentType.values.firstWhere(
        (e) => e.toString() == 'ContentType.${map['content_type']}',
      ),
      content: map['content'] as String,
      videoUrl: map['video_url'] as String?,
      orderIndex: map['order_index'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content_type': contentType.toString().split('.').last,
      'content': content,
      'video_url': videoUrl,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LessonContent copyWith({
    String? id,
    String? title,
    ContentType? contentType,
    String? content,
    String? videoUrl,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonContent(
      id: id ?? this.id,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
