import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/teacher_model.dart';

part 'get_group_details_state.dart';

class GetGroupDetailsCubit extends Cubit<GetGroupDetailsState> {
  GetGroupDetailsCubit() : super(GetGroupDetailsInitial());
  
  ApiServices _api =ApiServices();


  //
  // Future<void>getGroupDetails({required String groupId})async{
  //   try {
  //     emit(GetGroupDetailsLoading());
  //     Response response = await _api.getData(path: 'groups?select=*,schedules(*)&id=eq.$groupId');
  //
  //     GroupModel group = GroupModel.fromJson(response.data[0]);
  //     emit(GetGroupDetailsSuccess(group: group));
  //   } on Exception catch (e) {
  //     log(e.toString());
  //     emit(GetGroupDetailsError());
  //     // TODO
  //   }
  //
  //
  // }
  //
  late GroupModel updatedGroup;
  Future<void> bookGroup({required String groupId}) async {
    try {
      emit(BookGroupDetailsLoading());

      // 1. جلب بيانات المجموعة علشان نعرف المدرس
      final responseGroup = await _api.getData(path: 'groups?select=*,schedules(*)&id=eq.$groupId');
      final GroupModel group = GroupModel.fromJson(responseGroup.data[0]);
      final String? teacherId = group.teacherId;

      // 2. جلب بيانات الطالب الحالي
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("لا يوجد مستخدم حالياً");

      // 3. التأكد إن الطالب مش حاجز مع نفس المدرس
      final responseUserGroups = await _api.getData(
        path: 'user_groups?select=*,groups(*)&user_id=eq.$userId',
      );
      final List<dynamic> userGroups = responseUserGroups.data;

      final bool alreadyBookedWithSameTeacher = userGroups.any((entry) {
        final groupData = entry['groups'];
        return groupData != null && groupData['teacher_id'] == teacherId;
      });

      if (alreadyBookedWithSameTeacher) {
        ShowMessage.showToast("أنت بالفعل مشترك مع هذا المدرس", backgroundColor: Colors.orange);
        emit(BookGroupDetailsError());
        return;
      }

      // 4. التأكد من توافر أماكن
      if (int.parse(group.numberOfStudents) > 0) {
        // تحديث عدد الطلاب
        await _api.patchData(path: 'groups?id=eq.$groupId', data: {
          "number_of_students": (int.parse(group.numberOfStudents) - 1).toString()
        });

        // إضافة الطالب للجروب
        await _api.postData(path: 'user_groups', data: {
          "user_id": userId,
          "group_id": groupId,
        });

        ShowMessage.showToast("تم الحجز بنجاح 🎉", backgroundColor: Colors.green);

        // 5. ✅ إعادة تحميل بيانات المجموعة المحدثة
        final updatedGroupRes = await _api.getData(path: 'groups?select=*,schedules(*)&id=eq.$groupId');
         updatedGroup = GroupModel.fromJson(updatedGroupRes.data[0]);

        emit(BookGroupDetailsSuccess(group: updatedGroup));
      } else {
        ShowMessage.showToast("المجموعة ممتلئة ❌", backgroundColor: Colors.red);
        emit(BookGroupDetailsError());
      }
    } catch (e) {
      log(e.toString());
      ShowMessage.showToast("حدث خطأ أثناء الحجز");
      emit(BookGroupDetailsError());
    }
  }

}
