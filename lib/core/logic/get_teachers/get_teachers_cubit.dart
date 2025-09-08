import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/models/teacher_model.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:meta/meta.dart';

part 'get_teachers_state.dart';

class GetTeachersCubit extends Cubit<GetTeachersState> {
  GetTeachersCubit() : super(GetTeachersInitial());
  ApiServices _api = ApiServices();
  List<TeacherModel>teachers=[];

  Future<void>getTeachers({required String stage_id})async{
    try {

      emit(GetTeachersLoading());
      teachers=[];
    Response response =  await _api.getData(path: 'teachers?select=*,users(*),groups(*,schedules(*))&groups.stage_id=eq.$stage_id');
    for(var item in response.data){
      teachers.add(TeacherModel.fromJson(item));
    }
    emit(GetTeachersSuccess(teachers: teachers));
    } on Exception catch (e) {
      log(e.toString());
      emit(GetTeachersError());
    }

  }
}
