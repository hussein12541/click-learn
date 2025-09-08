import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/models/course_model.dart';
import 'package:meta/meta.dart';

import '../../models/stage_group_schedule_model.dart';

part 'get_courses_state.dart';

class GetCoursesCubit extends Cubit<GetCoursesState> {
  GetCoursesCubit() : super(GetCoursesInitial());

  final ApiServices _api = ApiServices();

  List<StageGroupScheduleModel> StageGroupScheduleList = [];
  List<DataList> dataListDropdownItems = [];

  Future<void> getAllStages() async {
    try {
      dataListDropdownItems = [];
      emit(GetStagesLoading());
      Response response = await _api.getData(
        path: 'stages?select=*,groups(*,schedules(*))&order=created_at.asc',
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
      emit(GetStagesSuccess(dataListDropdownItems: dataListDropdownItems));
    } catch (e) {
      log("getAllStages error: $e");
      emit(GetStagesError());
    }
  }

  List<CourseModel> courses = [];

  Future<void> getAllCourses({
    required bool isTeacher,
    required String teacher_id,
    required List<String> teacherIdsForStudent,
  }) async {
    try {
      courses = [];
      emit(GetCoursesLoading());

      String filter = '';

      if (isTeacher) {
        // لو مدرس: هات الكورسات اللي هو صاحبها
        filter = '&teacher_id=eq.$teacher_id';
      } else {
        // لو طالب: هات الكورسات للمدرسين المشترك معاهم
        if (teacherIdsForStudent.isNotEmpty) {
          final encoded = teacherIdsForStudent
              .map((id) => 'teacher_id.eq.$id')
              .join(',');

          filter = '&or=($encoded)';
        } else {
          // لو مفيش مدرسين مرتبطين بالطالب
          emit(GetCoursesSuccess(courses: []));
          return;
        }
      }

      final path = 'courses?select=*,lessons(*)$filter&order=created_at.asc';

      Response response = await _api.getData(path: path);

      if (isTeacher) {
        for (var course in response.data) {
          courses.add(CourseModel.fromJson(course));
        }
      } else {
        for (var item in response.data) {
          CourseModel course = CourseModel.fromJson(item);

          // فلترة الدروس الظاهرة فقط
          final visibleLessons = course.lessons
              .where((lesson) => lesson.isShown)
              .toList();

          // إذا كان في دروس ظاهرة فقط، نضيف الكورس
          if (visibleLessons.isNotEmpty) {
            courses.add(course.copyWith(lessons: visibleLessons));
          }
        }
      }

      emit(GetCoursesSuccess(courses: courses));
      emit(GetStagesSuccess(dataListDropdownItems: dataListDropdownItems));
    } catch (e) {
      log('getAllCourses error: $e');
      emit(GetCoursesError());
    }
  }

  Future<void> updateCourse({required String id, required String name}) async {
    try {
      emit(UpdateCourseLoading());
      await _api.patchData(path: 'courses?id=eq.$id', data: {"name": name});
      emit(UpdateCourseSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(UpdateCourseError());
    }
  }

  Future<void> deleteCourse({required String id}) async {
    try {
      emit(DeleteCourseLoading());
      await _api.deleteData(path: 'courses?id=eq.$id');
      emit(DeleteCourseSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(GetCoursesError());
    }
  }
}
