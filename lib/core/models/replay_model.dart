import 'package:e_learning/core/models/user_model.dart';

class ReplayModel {
  final String id;
  final String replay;
  final String userId;
  final String commentId;
  final UserModel user;
  final DateTime createdAt;

  ReplayModel( {required this.user,
    required this.id,
    required this.replay,
    required this.userId,
    required this.commentId,
    required this.createdAt,
  });

  factory ReplayModel.fromJson(Map<String, dynamic> json) {
    return ReplayModel(
      user: UserModel.fromJson(json['users']),
      id: json['id'],
      replay: json['replay'],
      userId: json['user_id'],
      commentId: json['comment_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'users': user.toJson(),
    'replay': replay,
    'user_id': userId,
    'comment_id': commentId,
    'created_at': createdAt.toIso8601String(),
  };
}
