import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/models/quiz_model.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/stage_group_schedule_model.dart';

part 'get_quizzes_state.dart';

class GetQuizzesCubit extends Cubit<GetQuizzesState> {
  GetQuizzesCubit() : super(GetQuizzesInitial());

  List<QuizModel> quizzes=[];
  final ApiServices _api=ApiServices();
  Future<void> getAllQuizzes({
    required bool isTeacher,
    required String teacherId,
    required List<String> teacherIdsForStudent,
  }) async {
    quizzes = [];
    emit(GetQuizzesLoading());

    try {
      dataListDropdownItems = [];
      log('[LOG] Fetching stages...');

      Response stages = await _api.getData(
        path: 'stages?select=*,groups(*,schedules(*))&order=created_at.asc',
      );

      log('[LOG] Stages response data: ${stages.data.runtimeType}');

      StageGroupScheduleList.clear();
      if (stages.data is List) {
        StageGroupScheduleList.add(StageGroupScheduleModel.fromJsonList(stages.data));
      } else {
        log('[ERROR] stages.data is not a List: ${stages.data}');
        throw Exception('Invalid stages data format');
      }

      log('[LOG] Flattening stages into dropdown items...');
      dataListDropdownItems.clear();
      for (var stage in StageGroupScheduleList) {
        if (stage.dataListList != null) {
          dataListDropdownItems.addAll(stage.dataListList!);
        }
      }

      // 🔍 فلترة حسب نوع المستخدم
      String filter;
      if (isTeacher) {
        filter = '&teacher_id=eq.$teacherId';
      } else {
        // الطالب مشترك في كذا جروب، فمعاه كذا مدرس
        if (teacherIdsForStudent.isEmpty) {
          emit(GetQuizzesSuccess(quizzes: []));
          return;
        }
        final encodedIds = teacherIdsForStudent.map((e) => '"$e"').join(',');
        filter = '&teacher_id=in.($encodedIds)';
      }

      log('[LOG] Fetching quizzes with filter: $filter');

      Response response = await _api.getData(
        path: 'quizzes?select=*,questions(*,choices(*))$filter&order=created_at.asc',
      );

      log('[LOG] Quizzes response received. Parsing...');
      if(isTeacher)
        {for (var item in response.data) {
        try {
          quizzes.add(QuizModel.fromJson(item));
        } catch (e) {
          log('[ERROR] Failed to parse quiz item: $item\nError: $e');
        }
      }}else{
        for (var item in response.data) {
          try {
            final quiz = QuizModel.fromJson(item);
            if (quiz.isShown == true) {
              quizzes.add(quiz);
            }

          } catch (e) {
            log('[ERROR] Failed to parse quiz item: $item\nError: $e');
          }
        }
      }

      emit(GetQuizzesSuccess(quizzes: quizzes));
      log('[SUCCESS] Quizzes loaded successfully: ${quizzes.length}');
    } catch (e, stack) {
      emit(GetQuizzesError());
      log('[EXCEPTION] getAllQuizzes failed: $e');
      log('[STACK TRACE] $stack');
    }
  }


  Future<void> deleteImageFromSupabase(String fileName) async {
    final supabase = Supabase.instance.client;

    const bucketName = 'postsimages'; // غيرها لو انت مسمي الـ bucket باسم مختلف

    final response = await supabase.storage
        .from(bucketName)
        .remove([fileName]);

    print('✅ الصورة اتحذفت يا ريس!');

  }

  Future<void>deleteQuiz({required QuizModel quiz})async{
    emit(GetQuizzesLoading());
    for(var item in quiz.questions){
      if (!item.delete_image_url.startsWith('http')) {
        await deleteImageFromSupabase(item.delete_image_url);
      }
        }
    await _api.deleteData(path: 'quizzes?id=eq.${quiz.id}');
    await getAllQuizzes(isTeacher: true, teacherId:Supabase.instance.client.auth.currentUser!.id, teacherIdsForStudent: []);
  }

  Future<void>showOrHideQuiz({required QuizModel quiz})async{
    emit(GetQuizzesLoading());
    await _api.patchData(path: 'quizzes?id=eq.${quiz.id}', data: {
      "isShown":!quiz.isShown
    });
    await getAllQuizzes(isTeacher: true, teacherId:Supabase.instance.client.auth.currentUser!.id, teacherIdsForStudent: []);
  }



  List<StageGroupScheduleModel> StageGroupScheduleList = [];
  List<DataList> dataListDropdownItems = [];


}
