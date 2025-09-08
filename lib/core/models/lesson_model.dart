class LessonModel {
  final String id;
  final String name;
  final bool isShown;
  final String courseId;
  final String? vedioUrl;
  final String? pdf_url;
  final DateTime createdAt;

  LessonModel({
    required this.id,
    required this.name,
    required this.isShown,
    required this.courseId,
    required this.vedioUrl,
    required this.pdf_url,
    required this.createdAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      name: json['name'],
      isShown: json['isShown'],
      courseId: json['course_id'],
      vedioUrl: json['vedio_url'],
      pdf_url: json['pdf_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  LessonModel copyWith({
    String? id,
    String? name,
    bool? isShown,
    String? vedioUrl,
    String? pdf_url,
    String? courseId,
    DateTime? createdAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isShown: isShown ?? this.isShown,
      vedioUrl: vedioUrl ?? this.vedioUrl,
      pdf_url: pdf_url ?? this.pdf_url,
      courseId: courseId ?? this.courseId,
      createdAt: createdAt ?? this.createdAt,
    );
  }


Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isShown': isShown,
      'course_id': courseId,
      'vedio_url': vedioUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
