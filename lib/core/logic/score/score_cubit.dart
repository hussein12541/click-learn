import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/score.dart';

part 'score_state.dart';

class ScoreCubit extends Cubit<ScoreState> {
  ScoreCubit() : super(ScoreInitial());
  
  ApiServices _api=ApiServices();

  List<UserWithScoresModel>scores=[];



  // Future<void> getScore({required String teacherId}) async {
  //   try {
  //     emit(GetScoreLoading());
  //     scores = [];
  //
  //     final response = await _api.getData(
  //       path: 'users?select=id,name,user_groups(groups(*)),score(*,quizzes!quiz_id(*))',
  //     );
  //
  //     for (var item in response.data) {
  //       try {
  //         // فلترة السكورات اللي تبع المدرس ده فقط
  //         item['score'] = (item['score'] as List).where((score) {
  //           final quiz = score['quizzes'];
  //           return quiz != null && quiz['teacher_id'] == teacherId;
  //         }).toList();
  //
  //         // لو فيه سكورات بعد الفلترة بس نضيفه
  //         if ((item['score'] as List).isNotEmpty) {
  //           scores.add(UserWithScoresModel.fromJson(item));
  //         }
  //       } catch (e) {
  //         log('[ERROR] Failed to parse user: $e');
  //       }
  //     }
  //
  //     emit(GetScoreSuccess());
  //   } catch (e, stack) {
  //     log('[EXCEPTION] getScore failed: $e');
  //     emit(GetScoreError());
  //   }
  // }

  Future<void> getScoreForTeacher({required String teacherId}) async {
    try {
      emit(GetScoreLoading());
      scores = [];

      final response = await _api.getData(
        path:
        '''
          users?select=
            id,
            name,
            user_groups!inner(groups!inner(id,name,stage_id,teacher_id)),
            score(*,
              quizzes!quiz_id(
                id,
                tittle,
                stage_id,
                time_limit,
                created_at,
                teacher_id,
                questions(count)
              )
            )
            &user_groups.groups.teacher_id=eq.$teacherId
          '''.replaceAll('\n', '').replaceAll(' ', ''),
      );

      for (var item in response.data) {
        try {
          // فلترة السكورات الخاصة بالمدرس فقط
          final originalScores = item['score'] as List;
          final filteredScores = originalScores.where((score) {
            final quiz = score['quizzes'];
            return quiz != null && quiz['teacher_id'] == teacherId;
          }).toList();

          // استبدال السكورات باللي تم تصفيتها
          item['score'] = filteredScores;

          // ضيف الطالب للموديل
          scores.add(UserWithScoresModel.fromJson(item));
        } catch (e) {
          log('[ERROR] Failed to parse user: $e');
        }
      }

      emit(GetScoreSuccess(scores));
    } catch (e, stack) {
      log('[EXCEPTION] getScore failed: $e');
      emit(GetScoreError());
    }
  }

  Future<void> getScoreForStudent({required String studentId}) async {
    try {
      emit(GetStudentScoreLoading());
      List<UserWithScoresModel>studentScores=[];


      final response = await _api.getData(
        path: 'users?select=id,name,user_groups(groups(*)),score(*,quizzes!quiz_id(*,questions(count)))&id=eq.$studentId',
      );

      for (var item in response.data) {
        try {
          // مش هنفلتر السكورات
          studentScores.add(UserWithScoresModel.fromJson(item));
        } catch (e) {
          log('[ERROR] Failed to parse user: $e');
        }
      }

      emit(GetStudentScoreSuccess(studentScores));
    } catch (e, stack) {
      log('[EXCEPTION] getScore failed: $e');
      emit(GetStudentScoreError());
    }
  }

  Future<void> addScore({required int score, required String quiz_id, required String teacherId}) async {
    try {
      emit(AddScoreLoading());

      final userId = Supabase.instance.client.auth.currentUser!.id;

      // تأكد إن البيانات محدثة
      await getScoreForTeacher(teacherId:teacherId );

      // تأكد إن المستخدم موجود في القائمة
      final currentUserScore = scores.firstWhere(
            (user) => user.id == userId,
        orElse: () => UserWithScoresModel(id: userId, name: '', score: [], groups: [], ),
      );

      // هل بالفعل فيه نتيجة للكويز دا؟
      final alreadySubmitted = currentUserScore.score.any(
            (s) => s.quizId == quiz_id,
      );

      if (alreadySubmitted) {
        print('⛔ النتيجة موجودة بالفعل لهذا الكويز والمستخدم، مش هضيفها تاني');

      }else{
        // مفيش نتيجة؟ يلا بينا نضيفها
        await _api.postData(path: 'score', data: {
          "quiz_id": quiz_id,
          "user_id": userId,
          "score": score,
        });
        await getScoreForTeacher(teacherId:teacherId); // عشان تحدث الليستة بعد الإضافة

      }



      emit(AddScoreSuccess());
    } on Exception catch (e) {
      log(e.toString());
      emit(AddScoreError());
    }
  }

  
}
