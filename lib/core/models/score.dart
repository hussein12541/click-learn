class UserWithScoresModel {
  final String id;
  final String name;
  final List<GroupModel> groups;
  final List<ScoreModel> score;

  UserWithScoresModel({
    required this.id,
    required this.name,
    required this.groups,
    required this.score,
  });

  factory UserWithScoresModel.fromJson(Map<String, dynamic> json) {
    return UserWithScoresModel(
      id: json['id'],
      name: json['name'],
      groups: (json['user_groups'] as List)
          .map((e) => GroupModel.fromJson(e['groups']))
          .toList(),
      score: (json['score'] as List)
          .map((e) => ScoreModel.fromJson(e))
          .toList(),
    );
  }

  int get totalScore => score.fold(0, (sum, s) => sum + s.score);
  int get quizCount => score.length;
}


class GroupModel {
  final String id;
  final String name;
  final String stageId;
  final String teacherId;

  GroupModel({
    required this.id,
    required this.name,
    required this.stageId,
    required this.teacherId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      stageId: json['stage_id'],
      teacherId: json['teacher_id'],
    );
  }
}


class ScoreModel {
  final String id;
  final int score;
  final String quizId;
  final String userId;
  final String createdAt;
  final QuizModel? quizzes;

  ScoreModel({
    required this.id,
    required this.score,
    required this.quizId,
    required this.userId,
    required this.createdAt,
    this.quizzes,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      id: json['id'],
      score: json['score'],
      quizId: json['quiz_id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      quizzes: json['quizzes'] != null ? QuizModel.fromJson(json['quizzes']) : null,
    );
  }
}



class QuizModel {
  final String id;
  final String tittle;
  final String stageId;
  final String createdAt;
  final int timeLimit;
  final int questionsCount;

  QuizModel({
    required this.id,
    required this.tittle,
    required this.stageId,
    required this.createdAt,
    required this.timeLimit,
    required this.questionsCount,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['questions'] != null && json['questions'] is List && json['questions'].isNotEmpty) {
      count = json['questions'].fold(0, (sum, item) => sum + (item['count'] ?? 0));
    }

    return QuizModel(
      id: json['id'],
      tittle: json['tittle'],
      stageId: json['stage_id'],
      createdAt: json['created_at'],
      timeLimit: json['time_limit'],
      questionsCount: count,
    );
  }
}



