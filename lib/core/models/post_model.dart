import 'package:e_learning/core/models/comments_model.dart';
import 'package:e_learning/core/models/like_model.dart';
import 'package:e_learning/core/models/poll_model.dart';
import 'package:e_learning/core/models/poll_vote_model.dart';


class PostModel {
  final String id;
  final DateTime createdAt;
  final String text;
  final String? imageUrl;
  final String? deleteImageUrl;
  final String groupId;
  final String userId;
  final UserPostModel user;
  final GroupModel group;
  final List<CommentModel> comments;

  @override
  String toString() {
    return 'PostModel{id: $id, createdAt: $createdAt, text: $text, imageUrl: $imageUrl, deleteImageUrl: $deleteImageUrl, groupId: $groupId, userId: $userId, user: $user, group: $group, comments: $comments, likes: $likes, polls: $polls, pollVotes: $pollVotes}';
  }

  final List<LikeModel> likes;
  final List<PollModel> polls;
  final List<PollVoteModel> pollVotes;

  PostModel({
    required this.id,
    required this.createdAt,
    required this.text,
    this.imageUrl,
    this.deleteImageUrl,
    required this.groupId,
    required this.userId,
    required this.user,
    required this.group,
    required this.comments,
    required this.likes,
    required this.polls,
    required this.pollVotes,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      text: json['text'] as String,
      imageUrl: json['image_url'] as String?,
      deleteImageUrl: json['delete_image_url'] as String?,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      user: UserPostModel.fromJson(json['users'] as Map<String, dynamic>),
      group: json['groups'] != null
    ? GroupModel.fromJson(json['groups'] as Map<String, dynamic>)
    : GroupModel.empty(), // أو أي قيمة افتراضية مناسبة

      comments: (json['comments'] as List<dynamic>)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      likes: (json['likes'] as List<dynamic>)
          .map((e) => LikeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      polls: (json['polls'] as List<dynamic>)
          .map((e) => PollModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pollVotes: (json['poll_votes'] as List<dynamic>)
          .map((e) => PollVoteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'text': text,
    'image_url': imageUrl,
    'delete_image_url': deleteImageUrl,
    'group_id': groupId,
    'user_id': userId,
    'users': user.toJson(),
    'groups': group.toJson(),
    'comments': comments.map((e) => e.toJson()).toList(),
    'likes': likes.map((e) => e.toJson()).toList(),
    'polls': polls.map((e) => e.toJson()).toList(),
    'poll_votes': pollVotes.map((e) => e.toJson()).toList(),
  };

  PostModel copyWith({
    String? id,
    DateTime? createdAt,
    String? text,
    String? imageUrl,
    String? deleteImageUrl,
    String? groupId,
    String? userId,
    UserPostModel? user,
    GroupModel? group,
    List<CommentModel>? comments,
    List<LikeModel>? likes,
    List<PollModel>? polls,
    List<PollVoteModel>? pollVotes,
  }) {
    return PostModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      deleteImageUrl: deleteImageUrl ?? this.deleteImageUrl,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      group: group ?? this.group,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
      polls: polls ?? this.polls,
      pollVotes: pollVotes ?? this.pollVotes,
    );
  }
}
class GroupModel {
  final String id;
  final String name;
  final StageModel stages;
  final String stageId;
  final String teacher_id;
  final TeacherPostModel teacher; // 🆕
  final DateTime createdAt;
  final String numberOfStudents;

  GroupModel({
    required this.id,
    required this.name,
    required this.stages,
    required this.stageId,
    required this.teacher_id,
    required this.teacher, // 🆕
    required this.createdAt,
    required this.numberOfStudents,
  });

  factory GroupModel.empty() {
    return GroupModel(
      id: '',
      name: '',
      stages: StageModel.empty(),
      stageId: '',
      teacher_id: '',
      teacher: TeacherPostModel( // 🆕 teacher default
        id: '',
        imageUrl: '',
        createdAt: DateTime.now(),
        user: UserPostModel(id: '', name: '', email: '', phone: '', stageId: '', password: '', deviceId: '', fcmToken: '', createdAt: DateTime.now(), teachers: []),

      ),
      createdAt: DateTime.now(),
      numberOfStudents: '0',
    );
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stages: json['stages'] != null
          ? StageModel.fromJson(json['stages'])
          : StageModel.empty(),
      stageId: json['stage_id'] ?? '',
      teacher_id: json['teacher_id'] ?? '',
      teacher: json['teachers'] != null
          ? TeacherPostModel.fromJson(json['teachers'])
          : TeacherPostModel(
        id: '',
        imageUrl: '',
        createdAt: DateTime.now(),
        user: UserPostModel(id: '', name: '', email: '', phone: '', stageId: '', password: '', deviceId: '', fcmToken: '', createdAt: DateTime.now(), teachers: []),

      ),
      createdAt: DateTime.parse(json['created_at']),
      numberOfStudents: json['number_of_students'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stages': stages.toJson(),
    'stage_id': stageId,
    'teacher_id': teacher_id,
    'teachers': teacher.toJson(),
    'created_at': createdAt.toIso8601String(),
    'number_of_students': numberOfStudents,
  };

  @override
  String toString() {
    return 'GroupModel{id: $id, name: $name, stages: $stages, stageId: $stageId, teacher_id: $teacher_id, teacher: $teacher, createdAt: $createdAt, numberOfStudents: $numberOfStudents}';
  }
}

class TeacherPostModel {
  final String id;
  final String imageUrl;
  final DateTime createdAt;
  final UserPostModel user; // 🆕 دخلنا الـ user جوا المدرس

  TeacherPostModel({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    required this.user,
  });

  factory TeacherPostModel.fromJson(Map<String, dynamic> json) {
    return TeacherPostModel(
      id: json['id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      user: json['users'] != null
          ? UserPostModel.fromJson(json['users'])
          : UserPostModel.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    'users': user.toJson(),
  };

  @override
  String toString() {
    return 'TeacherModel{id: $id, imageUrl: $imageUrl, createdAt: $createdAt, user: $user}';
  }
}

class StageModel {
  final String id;
  final String name;
  final DateTime createdAt;

  StageModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  factory StageModel.empty() {
    return StageModel(
      id: '',
      name: '',
      createdAt: DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
  };
}

class UserPostModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String stageId;
  final String password;
  final String deviceId;
  final String fcmToken;
  final DateTime createdAt;
  final List<TeacherPostModel> teachers;

  UserPostModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.stageId,
    required this.password,
    required this.deviceId,
    required this.fcmToken,
    required this.createdAt,
    required this.teachers,
  });


  factory UserPostModel.empty() {
    return UserPostModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      stageId: '',
      password: '',
      deviceId: '',
      fcmToken: '',
      createdAt: DateTime.now(),
      teachers: [],
    );
  }


  factory UserPostModel.fromJson(Map<String, dynamic> json) {
    final teacherData = json['teachers'];

    List<TeacherPostModel> parsedTeachers = [];

    if (teacherData != null) {
      if (teacherData is List) {
        parsedTeachers = teacherData
            .map((e) => TeacherPostModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (teacherData is Map<String, dynamic>) {
        parsedTeachers = [TeacherPostModel.fromJson(teacherData)];
      }
    }

    return UserPostModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      stageId: json['stageId'],
      password: json['password'],
      deviceId: json['device_id'],
      fcmToken: json['fcm_token'],
      createdAt: DateTime.parse(json['created_at']),
      teachers: parsedTeachers,
    );
  }



  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'stageId': stageId,
    'password': password,
    'device_id': deviceId,
    'fcm_token': fcmToken,
    'created_at': createdAt.toIso8601String(),
    'teachers': teachers.map((e) => e.toJson()).toList(),
  };
}
