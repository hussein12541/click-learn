import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:uuid/uuid.dart';
// <<-- هنا
import '../../models/stage_group_schedule_model.dart';
import '../../notification/cloud_messaging.dart';

part 'post_state.dart';

class UploadPostCubit extends Cubit<PostState> {
  UploadPostCubit() : super(PostInitial());

  final ApiServices _api=ApiServices();

  List<StageGroupScheduleModel> StageGroupScheduleList = [];
  List<DataList> dataListDropdownItems = [];

  Future<void> getAllStages({required String teacherId}) async {
    try {
      StageGroupScheduleList = [];
      emit(GetStagesLoading());

      Response response = await _api.getData(
        path: 'stages?select=*,groups(*,schedules(*))',
      );

      // Parse ال Data
      List<DataList> filteredStages = [];
      if (response.data != null) {
        for (var stageJson in response.data) {
          DataList stage = DataList.fromJson(stageJson);

          // فلترة الجروبات حسب ال teacher_id
          stage.groupsList = stage.groupsList
              ?.where((group) => group.teacher_id == teacherId)
              .toList();

          // لو فيها جروبات بعد الفلترة، ضيف المرحلة دي
          if (stage.groupsList != null && stage.groupsList!.isNotEmpty) {
            filteredStages.add(stage);
          }
        }
      }

      // حط اللي طلعناه في الموديل الكبير
      StageGroupScheduleList = [
        StageGroupScheduleModel(dataListList: filteredStages)
      ];

      // Flatten لل dropdown
      dataListDropdownItems.clear();
      dataListDropdownItems.addAll(filteredStages);

      emit(GetStagesSuccess());
    } catch (e) {
      log("getAllStages error: $e");
      emit(GetStagesError());
    }
  }


   String? imageUrl;
   String? deleteImageUrl;



  Future<void> uploadFileToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final bucketName = 'postsimages';

    // توليد UUID
    var uuid = Uuid();
    String uniqueId = uuid.v4();

    // ناخد الامتداد بتاع الملف
    String fileExtension = file.path.split('.').last;

    // نعمل اسم جديد للملف فيه UUID + الامتداد
    String fileName = '$uniqueId.$fileExtension';


      final response = await supabase.storage.from(bucketName).upload(fileName, file);


      imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
      deleteImageUrl=fileName;
        print('✅ Uploaded with UUID! URL: $imageUrl');

  }



  Future<void> uploadImageToImgBB(File imageFile) async {
      final dio = Dio();
      final apiKey = 'cc7a90a66b3de75b4769a57876a44395';

      // نحول الصورة لـ MultipartFile عشان نرفعها
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
        "key": apiKey,
      });

      final response = await dio.post(
        'https://api.imgbb.com/1/upload',
        data: formData,
      );


      imageUrl = response.data['data']['url'];
      deleteImageUrl = response.data['data']['delete_url'];



}


  Future<void> sendNotifications({
    required String body,
    required String groupId,
    required String title,
    required String teacherId,
  }) async {
    List<UserModel> users = [];

    // 🟢 جلب المستخدمين مع بيانات الجروبات والجروب
    Response response = await _api.getData(
      path: 'users?select=*,user_groups(*,groups(*))',
    );

    for (var userJson in response.data) {
      users.add(UserModel.fromJson(userJson));
    }

    List<Future> futures = [];

    for (var user in users) {
      // 🟡 شرط التوكن موجود و مش فاضي
      if (user.fcmToken != null && user.fcmToken!.isNotEmpty) {
        final belongsToMyGroup = user.user_groups.any(
              (ug) =>
          ug?.group != null &&
              ug!.group!.teacher_id == teacherId &&
              ug.group!.id == groupId, // ممكن تشيلها لو عايز تبعت لأي جروب تبع المدرس ده
        );

        if (belongsToMyGroup) {
          futures.add(NotificationService.sendNotification(
            user.fcmToken!,
            title,
            body,
          ));
        }
      }
    }

    await Future.wait(futures);
  }


  Future<void>uploadPost({required String teacherName,required File? imageFile,required String text,required String group_id,required String post_id})async{

    try {
      imageUrl=null;
      deleteImageUrl=null;
      emit(UploadPostLoading());
      if (imageFile != null) {
        try {
          // المحاولة الأولى
         await uploadImageToImgBB(imageFile);
          // لو نجح نكمل
          print('✅ تم رفع الصورة من أول مرة');
          
        } catch (e) {
          print('⚠️ فشل الرفع أول مرة: $e');
          try {
            // المحاولة الثانية
          await uploadFileToSupabase(imageFile);
            print('✅ تم رفع الصورة من المحاولة التانية');
           
          } catch (secondError) {
            emit(UploadPostError());
            print('❌ فشل الرفع مرتين: $secondError');
            rethrow; 
          }
        }
      }
     await  _api.postData(path: 'posts', data: {
       "id":post_id,
        "group_id":group_id,
        "text":text,
        "image_url":imageUrl,
       "user_id":Supabase.instance.client.auth.currentUser!.id,
        "delete_image_url":deleteImageUrl
      });

      try {

        await sendNotifications(body: 'لقد قام ${teacherName} بنشر منشور جديد', title: text, groupId: group_id,teacherId: Supabase.instance.client.auth.currentUser!.id);
      } on Exception catch (e) {
        log(e.toString());
      }

      emit(UploadPostSuccess());
    }  catch (e) {
      log(e.toString());
      emit(UploadPostError());

    }
  }




}

class GroupModel {
  final String id;
  final String name;
  final String stage_id;
  final String teacher_id;

  GroupModel({
    required this.id,
    required this.name,
    required this.stage_id,
    required this.teacher_id,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stage_id: json['stage_id'] ?? '',
      teacher_id: json['teacher_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stage_id': stage_id,
    'teacher_id': teacher_id,
  };
}

class UserGroupModel {
  final String id;
  final String userId;
  final String groupId;
  final GroupModel? group;

  UserGroupModel({
    required this.id,
    required this.userId,
    required this.groupId,
    this.group,
  });

  factory UserGroupModel.fromJson(Map<String, dynamic> json) {
    return UserGroupModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      groupId: json['group_id'] ?? '',
      group: json['groups'] != null
          ? GroupModel.fromJson(json['groups'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'group_id': groupId,
    'groups': group?.toJson(),
  };
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? fcmToken;
  final List<UserGroupModel> user_groups;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.fcmToken,
    required this.user_groups,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      fcmToken: json['fcm_token'],
      user_groups: (json['user_groups'] as List<dynamic>?)
          ?.map((e) => UserGroupModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'fcm_token': fcmToken,
    'user_groups': user_groups.map((e) => e.toJson()).toList(),
  };
}
