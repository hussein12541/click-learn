class ChoiceModel {
  final String id;
  final String text;
  final String questionId;
  final bool isCorrect;
  final DateTime createdAt;

  ChoiceModel({
    required this.id,
    required this.text,
    required this.questionId,
    required this.isCorrect,
    required this.createdAt,
  });

  factory ChoiceModel.fromJson(Map<String, dynamic> json) => ChoiceModel(
    id: json['id'],
    text: json['text'],
    questionId: json['question_id'],
    isCorrect: json['is_correct'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'question_id': questionId,
    'is_correct': isCorrect,
    'created_at': createdAt.toIso8601String(),
  };

  ChoiceModel copyWith({
    String? id,
    String? text,
    String? questionId,
    bool? isCorrect,
    DateTime? createdAt,
  }) =>
      ChoiceModel(
        id: id ?? this.id,
        text: text ?? this.text,
        questionId: questionId ?? this.questionId,
        isCorrect: isCorrect ?? this.isCorrect,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() {
    return 'ChoiceModel(id: $id, text: $text, questionId: $questionId, isCorrect: $isCorrect, createdAt: $createdAt)';
  }
}

class QuestionModel {
  final String id;
  final String text;
  final String quizId;
  final String imageUrl;
  final String delete_image_url;
  final DateTime createdAt;
  final List<ChoiceModel> choices;

  QuestionModel({
    required this.id,
    required this.text,
    required this.quizId,
    required this.imageUrl,
    required this.delete_image_url,
    required this.createdAt,
    required this.choices,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: json['id'],
    text: json['text'],
    quizId: json['quiz_id'],
    imageUrl: json['image_url'] ?? '',
    delete_image_url: json['delete_image_url'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
    choices: (json['choices'] as List)
        .map((e) => ChoiceModel.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'quiz_id': quizId,
    'image_url': imageUrl,
    'delete_image_url': delete_image_url,
    'created_at': createdAt.toIso8601String(),
    'choices': choices.map((e) => e.toJson()).toList(),
  };

  QuestionModel copyWith({
    String? id,
    String? text,
    String? quizId,
    String? imageUrl,
    String? delete_image_url,
    DateTime? createdAt,
    List<ChoiceModel>? choices,
  }) =>
      QuestionModel(
        id: id ?? this.id,
        text: text ?? this.text,
        quizId: quizId ?? this.quizId,
        imageUrl: imageUrl ?? this.imageUrl,
        delete_image_url: delete_image_url ?? this.delete_image_url,
        createdAt: createdAt ?? this.createdAt,
        choices: choices ?? this.choices,
      );

  @override
  String toString() {
    return 'QuestionModel(id: $id, text: $text, quizId: $quizId, imageUrl: $imageUrl,delete_image_url: $delete_image_url, createdAt: $createdAt, choices: $choices)';
  }
}

class QuizModel {
  final String id;
  final String teacher_id;
  final String tittle;
  final bool isShown;
  final int timeLimit;
  final String stageId;
  final DateTime createdAt;
  final List<QuestionModel> questions;

  QuizModel({
    required this.id,
    required this.teacher_id,
    required this.tittle,
    required this.isShown,
    required this.timeLimit,
    required this.stageId,
    required this.createdAt,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    id: json['id'],
    teacher_id: json['teacher_id'],
    tittle: json['tittle'],
    isShown: json['isShown'],
    timeLimit: json['time_limit'],
    stageId: json['stage_id'],
    createdAt: DateTime.parse(json['created_at']),
    questions: (json['questions'] as List)
        .map((e) => QuestionModel.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacher_id': teacher_id,
    'tittle': tittle,
    'isShown': isShown,
    'time_limit': timeLimit,
    'stage_id': stageId,
    'created_at': createdAt.toIso8601String(),
    'questions': questions.map((e) => e.toJson()).toList(),
  };

  QuizModel copyWith({
    String? id,
    String? teacher_id,
    String? tittle,
    bool? isShown,
    int? timeLimit,
    String? stageId,
    DateTime? createdAt,
    List<QuestionModel>? questions,
  }) =>
      QuizModel(
        id: id ?? this.id,
        teacher_id: teacher_id ?? this.teacher_id,
        tittle: tittle ?? this.tittle,
        isShown: isShown ?? this.isShown,
        timeLimit: timeLimit ?? this.timeLimit,
        stageId: stageId ?? this.stageId,
        createdAt: createdAt ?? this.createdAt,
        questions: questions ?? this.questions,
      );

  @override
  String toString() {
    return 'QuizModel(id: $id,teacher_id: $teacher_id, tittle: $tittle,  isShown: $isShown, timeLimit: $timeLimit, stageId: $stageId, createdAt: $createdAt, questions: $questions)';
  }
}
