import 'lesson_model.dart'; // لو عاملها في فايل منفصل

class CourseModel {
  final String id;
  final String name;
  final String stage_id;
  final String teacher_id;
  final DateTime createdAt;
  final List<LessonModel> lessons;

  CourseModel({
    required this.id,
    required this.name,
    required this.stage_id,
    required this.teacher_id,
    required this.createdAt,
    required this.lessons,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
      stage_id: json['stage_id'],
      teacher_id: json['teacher_id'],
      createdAt: DateTime.parse(json['created_at']),
      lessons: (json['lessons'] as List)
          .map((lessonJson) => LessonModel.fromJson(lessonJson))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'CourseModel{id: $id, name: $name, stage_id: $stage_id,teacher_id: $teacher_id, createdAt: $createdAt, lessons: $lessons}';
  }
  CourseModel copyWith({
    String? id,
    String? name,
    String? stage_id,
    String? teacher_id,
    DateTime? createdAt,
    List<LessonModel>? lessons,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      stage_id: stage_id ?? this.stage_id,
      teacher_id: teacher_id ?? this.teacher_id,
      createdAt: createdAt ?? this.createdAt,
      lessons: lessons ?? this.lessons,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stage_id': stage_id,
      'teacher_id': teacher_id,
      'created_at': createdAt.toIso8601String(),
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
