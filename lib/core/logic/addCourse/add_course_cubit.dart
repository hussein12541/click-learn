import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/models/lesson_model.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api_services/api_services.dart';
import '../../models/stage_group_schedule_model.dart';
import '../../notification/cloud_messaging.dart';
import '../upload_posts/post_cubit.dart';

part 'add_course_state.dart';

class AddCourseCubit extends Cubit<AddCourseState> {
  AddCourseCubit() : super(AddCourseInitial());

  final ApiServices _api = ApiServices();


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

      emit(GetStageSuccess(dataListDropdownItems:dataListDropdownItems ));
    } catch (e) {
      log("getAllStages error: $e");
      emit(GetStagesError());
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


  Future<void> addCourse({
    required String stage_id,
    required String teacher_id,
    required String teacher_name,
    required String course_name,
    required List<LessonModel> lessons,
  }) async {
    try {
      String id = Uuid().v4();
      emit(AddCourseLoading());
      await _api.postData(
        path: 'courses',
        data: {"id": id, "name": course_name, "stage_id": stage_id, "teacher_id": teacher_id},
      );
      for(var lesson in lessons){
        await _api.postData(path: 'lessons', data: {
          "vedio_url":lesson.vedioUrl,
          "name":lesson.name,
          "course_id":id
        });
      }

      try {
        // await sendNotifications(body: 'لقد قام ${teacher_name} بإضافة كورس جديد', title: course_name, stage_id: stage_id, teacherId: Supabase.instance.client.auth.currentUser!.id);

      } on Exception catch (e) {
        log(e.toString());
      }
      emit(AddCourseSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(AddCourseError());
    }
  }

  Future<void> addLesson({required String vedioUrl,required String pdfUrl,required String teacher_name,required String id,required String name,required String course_id,required String stage_id,}) async {
    try {
      emit(AddLessonLoading());
      await _api.postData(path: 'lessons', data: {
        "id":id,
        "vedio_url":vedioUrl,
        "name":name,
        "course_id":course_id,
        "pdf_url":pdfUrl
      });
      try {
        // await sendNotifications(body: 'لقد قام ${teacher_name} بإضافة درس جديد', title: name, stage_id: stage_id, teacherId: Supabase.instance.client.auth.currentUser!.id);
      } on Exception catch (e) {
        log(e.toString());
      }
      emit(AddLessonSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(AddCourseError());
    }
  }


  Future<void>deleteLesson({required String id})async{
    try {
      emit(DeleteLessonLoading());
      await _api.deleteData(path: 'lessons?id=eq.$id');
      emit(DeleteLessonSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(DeleteLessonError());
    }
  }
  Future<void>showOrHideLesson({required String id,required bool isShown})async{
    try {
      emit(DeleteLessonLoading());
      await _api.patchData(path: 'lessons?id=eq.$id', data: {
        "isShown":!isShown
      });
      emit(DeleteLessonSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(DeleteLessonError());
    }
  }


  Future<void>updateLesson({required String id,required String name,required String vedio_url,required String pdfUrl})async{
    try {
      emit(UpdateLessonLoading());
      await _api.patchData(path: 'lessons?id=eq.$id', data: {
        "name":name,
        "vedio_url":vedio_url,
        "pdf_url":pdfUrl,
      });
      emit(UpdateLessonSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(UpdateLessonError());
    }
  }



}
