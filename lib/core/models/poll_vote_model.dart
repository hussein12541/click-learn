

import 'package:e_learning/core/models/post_model.dart';

class PollVoteModel {
  final String id;
  final String postId;
  final String userId;
  final String optionId;
  final DateTime createdAt;
  final UserPostModel user;

  PollVoteModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.optionId,
    required this.createdAt,
    required this.user,
  });

  factory PollVoteModel.fromJson(Map<String, dynamic> json) {
    return PollVoteModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      optionId: json['option_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: UserPostModel.fromJson(json['users'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'user_id': userId,
    'option_id': optionId,
    'created_at': createdAt.toIso8601String(),
    'users': user.toJson(),
  };
}