import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:meta/meta.dart';

part 'add_poll_state.dart';

class AddPollCubit extends Cubit<AddPollState> {
  AddPollCubit() : super(AddPollInitial());

  final ApiServices _api =ApiServices();

  Future<void> addPolls({required String post_id,required String option_text,})async{
    try {
      emit(AddPollLoading());
      await _api.postData(path: 'polls', data: {
        "post_id":post_id,
        "option_text":option_text

      });
    emit(AddPollSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(AddPollError());
    }
  }
}
