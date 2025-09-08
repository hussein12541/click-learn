import 'package:e_learning/core/models/replay_model.dart';
import 'package:e_learning/core/models/user_model.dart';

class CommentModel {
  final String id;
  final String comment;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final UserModel user;
  final List<ReplayModel> replay;

  CommentModel( {required this.user,
    required this.id,
    required this.comment,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.replay,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      user: UserModel.fromJson(json['users']),
      id: json['id'],
      comment: json['comment'],
      postId: json['post_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      replay: (json['replay'] as List)
          .map((item) => ReplayModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'comment': comment,
    'post_id': postId,
    'user_id': userId,
    'users': user.toJson(),
    'created_at': createdAt.toIso8601String(),
    'replay': replay.map((e) => e.toJson()).toList(),
  };
}
