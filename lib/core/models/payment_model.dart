class PaidModel {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String teacher_id;
  final String message;

  PaidModel({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.teacher_id,
    required this.message,
  });

  factory PaidModel.fromJson(Map<String, dynamic> json) {
    return PaidModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'] as String,
      teacher_id: json['teacher_id'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'teacher_id': teacher_id,
      'message': message,
    };
  }
}
