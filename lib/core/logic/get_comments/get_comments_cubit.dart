import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/models/comments_model.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'get_comments_state.dart';

class GetCommentsCubit extends Cubit<GetCommentsState> {
  GetCommentsCubit() : super(GetCommentsInitial());


  final ApiServices _api=ApiServices();


  List<CommentModel>comments=[];
  Future<void>getComments({required String post_id})async{

    try {
      emit(GetCommentsLoading());
      comments=[];
      Response response= await _api.getData(path: 'comments?select=*,replay(*,users(*)),users(*)&post_id=eq.$post_id&order=created_at.desc');

      for(var comment in response.data){
        comments.add(CommentModel.fromJson(comment));
      }

      emit(GetCommentsSuccess());
    } on Exception catch (e) {
      log(e.toString());
      emit(GetCommentsError());
    }

  }
  
  Future<void> addComment({required String post_id , required String comment, required String comment_id})async {
    try {
      // emit(AddReplaysLoading());
      await _api.postData(path: 'comments?post_id=eq.$post_id', data: {
        "user_id":Supabase.instance.client.auth.currentUser!.id,
        "post_id":post_id,
        "id":comment_id,
        "comment":comment
      });
      // emit(AddCommentsSuccess());
    } on Exception catch (e) {
      log(e.toString());
      // emit(AddCommentsError());
    }
  }

  Future<void> deleteComment({required String comment_id})async {
    try {
      // emit(AddReplaysLoading());
      await _api.deleteData(path: 'comments?id=eq.$comment_id', );
      // emit(AddCommentsSuccess());
    } on Exception catch (e) {
      log(e.toString());
      // emit(AddCommentsError());
    }
  }



  Future<void> addReplay({required String comment_id , required String replay})async {
    try {
      // emit(AddReplaysLoading());
      await _api.postData(path: 'replay?comment_id=eq.$comment_id', data: {
        "user_id":Supabase.instance.client.auth.currentUser!.id,
        "comment_id":comment_id,
        "replay":replay
      });
      // emit(AddCommentsSuccess());
    } on Exception catch (e) {
      log(e.toString());
      // emit(AddReplaysError());
    }
  }

  Future<void> deleteReplay({required String replay_id })async {
    try {
      // emit(AddReplaysLoading());
      await _api.deleteData(path: 'replay?id=eq.$replay_id',);
      // emit(AddCommentsSuccess());
    } on Exception catch (e) {
      log(e.toString());
      // emit(AddReplaysError());
    }
  }


}
