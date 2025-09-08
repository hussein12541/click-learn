
class StoryModel {
  final String id;
  final DateTime createdAt;
  final String? text;
  final int? duration;
  final String? imgUrl;
  final String? videoUrl;
  final String? delete_file_url;
  final String userId;
  final UserModel user;
  final bool isSeen;

  StoryModel( {required this.isSeen,
    required this.id,
    required this.createdAt,
    this.text,
    this.duration,
    this.imgUrl,
    this.videoUrl,
    this.delete_file_url,
    required this.userId,
    required this.user,
  });


  StoryModel copyWith({
    bool? isSeen,
    // ممكن تضيف حاجات تانية لو حبيت
  }) {
    return StoryModel(
      id: id,
      createdAt: createdAt,
      text: text,
      duration: duration,
      imgUrl: imgUrl,
      videoUrl: videoUrl,
      delete_file_url: delete_file_url,
      userId: userId,
      user: user,
      isSeen: isSeen ?? this.isSeen,
    );
  }


  factory StoryModel.fromJson(Map<String, dynamic> json,) {
    return StoryModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      text: json['text'],
      duration: json['duration'],
      imgUrl: json['img_url'],
      videoUrl: json['vedio_url'], // آه والله مكتوبة vedio_url في الـ JSON 😂
      delete_file_url: json['delete_file_url'],
      userId: json['user_id'],
      user: UserModel.fromJson(json['users']), isSeen: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'text': text,
      'duration': duration,
      'img_url': imgUrl,
      'vedio_url': videoUrl,
      'delete_file_url': delete_file_url,
      'user_id': userId,
      'users': user.toJson(),
    };
  }
}
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String parent_phone;
  final String? stageId;
  final String? password;
  final String? deviceId;
  final String? fcmToken;
  final DateTime? createdAt;
  final TeacherModel? teacher;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.parent_phone,
    this.stageId,
    this.password,
    this.deviceId,
    this.fcmToken,
    this.createdAt,
    this.teacher,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      parent_phone: json['parent_phone'],
      stageId: json['stageId'],
      password: json['password'],
      deviceId: json['device_id'],
      fcmToken: json['fcm_token'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      teacher: json['teachers'] != null ? TeacherModel.fromJson(json['teachers']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'parent_phone': parent_phone,
      'stageId': stageId,
      'password': password,
      'device_id': deviceId,
      'fcm_token': fcmToken,
      'created_at': createdAt?.toIso8601String(),
      'teachers': teacher?.toJson(),
    };
  }
}
class TeacherModel {
  final String id;
  final String imageUrl;
  final DateTime createdAt;

  TeacherModel({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // 👇 لازم نضيفهم عشان نقدر نستخدم TeacherModel كمفتاح في Map
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeacherModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

