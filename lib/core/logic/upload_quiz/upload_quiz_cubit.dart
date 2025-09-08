import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:mime/mime.dart'; // لتحديد نوع الملف تلقائياً
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../models/questions_for_upload.dart';
import '../../models/stage_group_schedule_model.dart';
import '../../notification/cloud_messaging.dart';
import 'package:http_parser/http_parser.dart';

import '../upload_posts/post_cubit.dart';

part 'upload_quiz_state.dart';

class UploadQuizCubit extends Cubit<UploadQuizState> {
  UploadQuizCubit() : super(UploadQuizInitial());


  final ApiServices _api=ApiServices();



  List<StageGroupScheduleModel> StageGroupScheduleList = [];
  List<DataList> dataListDropdownItems = [];

  Future<void> getAllStages() async {
    try {
      dataListDropdownItems = [];
      emit(GetStagesLoading());
      Response response = await _api.getData(
        path: 'stages?select=*,groups(*,schedules(*))',
      );
      StageGroupScheduleList.clear();
      StageGroupScheduleList.add(
        StageGroupScheduleModel.fromJson(response.data),
      );

      // Flatten all DataList from the StageGroupScheduleModel list
      dataListDropdownItems.clear();
      for (var stage in StageGroupScheduleList) {
        if (stage.dataListList != null) {
          dataListDropdownItems.addAll(stage.dataListList!);
        }
      }

      print(response.data.toString());
      emit(GetStageSuccess(dataListDropdownItems: dataListDropdownItems));
    } catch (e) {
      log("getAllStages error: $e");
      emit(GetStagesError());
    }
  }





  Future<Map<String, String?>> uploadFileToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final bucketName = 'postsimages';

    var uuid = Uuid();
    String uniqueId = uuid.v4();
    String fileExtension = file.path.split('.').last;
    String fileName = '$uniqueId.$fileExtension';

    await supabase.storage.from(bucketName).upload(fileName, file);

    String imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
    String deleteImageUrl = fileName;

    print('✅ Uploaded with UUID! URL: $imageUrl');
    return {'imageUrl': imageUrl, 'deleteImageUrl': deleteImageUrl};
  }

  Future<Map<String, String?>> uploadImageToImgBB(File imageFile) async {
    final dio = Dio();
    final apiKey = 'cc7a90a66b3de75b4769a57876a44395';

    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      "key": apiKey,
    });

    final response = await dio.post(
      'https://api.imgbb.com/1/upload',
      data: formData,
    );

    String imageUrl = response.data['data']['url'];
    String deleteImageUrl = response.data['data']['delete_url'];

    return {'imageUrl': imageUrl, 'deleteImageUrl': deleteImageUrl};
  }

  Future<Map<String, String?>> uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'dejh4tnml';
    final uploadPreset = 'flutter_unsigned_preset';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])?.split('/');

    final imageUploadRequest = http.MultipartRequest('POST', uri);
    imageUploadRequest.fields['upload_preset'] = uploadPreset;

    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
    );

    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Upload failed: ${response.body}');
        return {'imageUrl': null, 'deleteImageUrl': null};
      }

      final responseData = response.body;
      print('Upload success: $responseData');

      final Map<String, dynamic> data = jsonDecode(responseData);
      String imageUrl = data['secure_url'];

      return {'imageUrl': imageUrl, 'deleteImageUrl': null}; // Cloudinary لا يوفر delete_url مباشرة
    } catch (e) {
      print('Upload error: $e');
      return {'imageUrl': null, 'deleteImageUrl': null};
    }
  }




  // Future<void> sendNotifications({
  //   required String body,
  //   required String title,
  //   required String stage_id,
  //   required String teacherId,
  // }) async {
  //   List<UserModel> users = [];
  //
  //   // 🟢 جلب المستخدمين مع بيانات الجروبات والجروب
  //   Response response = await _api.getData(
  //     path: 'users?select=*,user_groups(*,groups(*))',
  //   );
  //
  //   for (var userJson in response.data) {
  //     users.add(UserModel.fromJson(userJson));
  //   }
  //
  //   List<Future> futures = [];
  //
  //   for (var user in users) {
  //     if (user.fcmToken != null && user.fcmToken!.isNotEmpty) {
  //       // ✅ فلترة حسب المدرس والمرحلة من داخل الجروب
  //       final isInSameStageAndTeacher = user.user_groups.any(
  //             (ug) =>
  //         ug.group != null &&
  //             ug.group!.teacher_id == teacherId &&
  //             ug.group!.stage_id == stage_id,
  //       );
  //
  //       if (isInSameStageAndTeacher) {
  //         futures.add(NotificationService.sendNotification(
  //           user.fcmToken!,
  //           title,
  //           body,
  //         ));
  //       }
  //     }
  //   }
  //
  //   await Future.wait(futures);
  // }



  Future<void> uploadQuiz({
    required String title,
    required String teacherName,
    required int timeLimit,
    required String stageId,
    required List<Question> questions,
  }) async {
    emit(UploadQuizLoading());

    try {
      String quizId = Uuid().v4();

      // 1. رفع الكويز
      await _api.postData(path: 'quizzes', data: {
        "id": quizId,
        "teacher_id": Supabase.instance.client.auth.currentUser!.id,
        "tittle": title,
        "time_limit": timeLimit,
        "stage_id": stageId,
      });

      // 2. رفع كل سؤال
      for (var question in questions) {
        String? imageUrl;
        String? deleteImageUrl;

        if (question.image != null) {
          try {
            var result = await uploadImageToCloudinary(question.image!);
            imageUrl = result['imageUrl'];
            deleteImageUrl = result['deleteImageUrl'];
            print('✅ تم رفع الصورة من Cloudinary');
          } catch (e) {
            print('⚠️ فشل الرفع على Cloudinary: $e');
            try {
              var result = await uploadFileToSupabase(question.image!);
              imageUrl = result['imageUrl'];
              deleteImageUrl = result['deleteImageUrl'];
              print('✅ تم رفع الصورة من Supabase');
            } catch (e) {
              print('⚠️ فشل الرفع على Supabase: $e');
              try {
                var result = await uploadImageToImgBB(question.image!);
                imageUrl = result['imageUrl'];
                deleteImageUrl = result['deleteImageUrl'];
                print('✅ تم رفع الصورة من ImgBB');
              } catch (e) {
                print('❌ فشل الرفع في كل المحاولات: $e');
                emit(UploadQuizError());
                rethrow;
              }
            }
          }
        }

        String questionId = Uuid().v4();

        await _api.postData(path: 'questions', data: {
          "id": questionId,
          "text": question.text,
          "quiz_id": quizId,
          "image_url": imageUrl,
          "delete_image_url": deleteImageUrl,
        });

        // 3. رفع الخيارات
        for (var choice in question.choices) {
          await _api.postData(path: 'choices', data: {
            "question_id": questionId,
            "text": choice.text,
            "is_correct": choice.isCorrect,
          });
        }
      }

      try {
        // await sendNotifications(
        //   body: 'لقد قام $teacherName بإضافة اختبار جديد',
        //   title:title,
        //   stage_id: stageId,
        //   teacherId: Supabase.instance.client.auth.currentUser!.id,
        // );
      } on Exception catch (e) {
        log(e.toString());
      }

      emit(UploadQuizSuccess());
    } catch (e) {
      log('❌ Error uploading quiz: $e');
      emit(UploadQuizError());
    }
  }





}


