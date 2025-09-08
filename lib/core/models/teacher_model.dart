
import 'package:e_learning/core/models/stage_group_schedule_model.dart';
import 'package:e_learning/core/models/user_model.dart';

class TeacherModel {
  final String id;
  final String imageUrl;
  final UserModel users;
  final List<GroupModel> groups;

  TeacherModel({
    required this.id,
    required this.imageUrl,
    required this.users,
    required this.groups,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      imageUrl: json['image_url'],
      users: UserModel.fromJson(json['users']),
      groups: (json['groups'] as List)
          .map((e) => GroupModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'users': users.toJson(),
      'groups': groups.map((e) => e.toJson()).toList(),
    };
  }

  TeacherModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    UserModel? users,
    List<GroupModel>? groups,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      users: users ?? this.users,
      groups: groups ?? this.groups,
    );
  }

  @override
  String toString() {
    return 'TeacherModel(id: $id, imageUrl: $imageUrl, users: $users, groups: $groups)';
  }
}


class GroupModel {
  final String id;
  final String name;
  final String stageId;
  final String teacherId;
  final String numberOfStudents;
  final DateTime? createdAt;
  final List<Schedules>? schedules;

  GroupModel({
    required this.id,
    required this.name,
    required this.stageId,
    required this.teacherId,
    required this.numberOfStudents,
    this.createdAt,
    this.schedules = const [],
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      stageId: json['stage_id'],
      teacherId: json['teacher_id'],
      numberOfStudents: json['number_of_students'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      schedules: json['schedules'] != null
          ? (json['schedules'] as List)
          .map((e) => Schedules.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stage_id': stageId,
      'teacher_id': teacherId,
      'number_of_students': numberOfStudents,
      'created_at': createdAt?.toIso8601String(),
      'schedules': schedules?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, schedules: $schedules)';
  }
}
