import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/payment_model.dart';

part 'get_payment_state.dart';

class GetPaymentCubit extends Cubit<GetPaymentState> {
  GetPaymentCubit() : super(GetPaymentInitial());
  ApiServices _api = ApiServices();
  Future<void>getAllPayment() async {
    try {

      emit(GetPaymentLoading());
      List<PaidModel>payments=[];

      Response response = await _api.getData(path: 'paid?user_id=eq.${Supabase.instance.client.auth.currentUser!.id}&order=created_at.desc',);
      for(var item in response.data){
        payments.add(PaidModel.fromJson(item));
      }
      emit(GetPaymentSuccess(payments: payments));
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(GetPaymentError());
    }
  }
}
