import 'package:e_learning/core/models/post_model.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String parent_phone;
  final String stageId;
  final List<GroupModel?> user_groups;
  final String? fcmToken;
  final String? device_id;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.parent_phone,
    required this.stageId,
    required this.user_groups,
    this.fcmToken,
    this.device_id,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      parent_phone: json['parent_phone'],
      stageId: json['stageId'] ?? json['stageId'],
      fcmToken: json['fcm_token'],
      user_groups: (json['user_groups'] as List?)?.map((e) => GroupModel.fromJson(e)).toList() ?? [],


      device_id: json['device_id'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'parent_phone': parent_phone,
      'stageId': stageId,
      'user_groups': user_groups,
      'fcm_token': fcmToken,
      'device_id': device_id,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, name: $name, phone: $phone,  parent_phone: $parent_phone, stageId: $stageId,user_groups: $user_groups, fcmToken: $fcmToken, device_id: $device_id, createdAt: $createdAt}';
  }
}
