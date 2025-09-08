class PollModel {
  final String id;
  final String postId;
  final DateTime createdAt;
  final String optionText;

  PollModel({
    required this.id,
    required this.postId,
    required this.createdAt,
    required this.optionText,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      optionText: json['option_text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'created_at': createdAt.toIso8601String(),
    'option_text': optionText,
  };
}