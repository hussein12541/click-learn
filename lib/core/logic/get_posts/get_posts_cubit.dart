import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/models/post_model.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'get_posts_state.dart';

class GetPostsCubit extends Cubit<GetPostsState> {
  GetPostsCubit() : super(GetPostsInitial());
  final ApiServices _api =ApiServices();

  List<PostModel>posts=[];

  Future<void> getPosts({required List<GroupModel> groups, required bool isTeacher}) async {
    try {
      posts = [];
      emit(GetPostsLoading());

      final groupIds = groups.map((e) => e.id).whereType<String>().toList();

      if (groupIds.isEmpty && !isTeacher) {
        emit(GetPostsSuccess());
        return;
      }

      String filter;
      if (isTeacher) {
        final teacherId = Supabase.instance.client.auth.currentUser?.id;
        if (teacherId == null) {
          emit(GetPostsSuccess());
          return;
        }
        // فلترة بالجروبات اللي فيهم teacher_id = currentUserId
        filter = 'groups.teacher_id=eq.$teacherId';
      } else {
        final groupIdsString = groupIds.join(',');
        filter = 'group_id=in.($groupIdsString)';
      }

      final path = isTeacher
          ? 'posts?select=*,users(*,teachers(*)),groups:groups!inner(*,stages(*)),comments(*,replay(*,users(*)),users(*)),likes(*),polls!polls_post_id_fkey(*),poll_votes(*,users(*))&$filter&order=created_at.desc'
          : 'posts?select=*,users(*,teachers(*)),groups(*,stages(*)),comments(*,replay(*,users(*)),users(*)),likes(*),polls!polls_post_id_fkey(*),poll_votes(*,users(*))&$filter&order=created_at.desc';

      final response = await _api.getData(path: path);

      for (var post in response.data) {
        print("-----------");
        print(post.toString());
        posts.add(PostModel.fromJson(post));
      }

      emit(GetPostsSuccess());
    } catch (e) {
      log("getPosts error: $e");
      emit(GetPostsError());
    }
  }

  Future<void> addLike({required String post_id})async{
    try {
      emit(AddLikeLoading());
      await  _api.postData(path: 'likes', data: {
          "user_id":Supabase.instance.client.auth.currentUser!.id,
          "post_id":post_id
        });
      emit(AddLikeSuccess());
    } on Exception catch (e) {
      log(e.toString());
      emit(AddLikeError());
    }
  }

  Future<void> deleteLike({required String post_id})async{
    try {
      emit(DeleteLikeLoading());
      await  _api.deleteData(path: 'likes?post_id=eq.$post_id&user_id=eq.${Supabase.instance.client.auth.currentUser!.id}',);
      emit(DeleteLikeSuccess());
    } on Exception catch (e) {
      log(e.toString());
      emit(DeleteLikeError());
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

  void updatePost(PostModel updatedPost) {
    final index = posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      posts[index] = updatedPost;
      emit(GetPostsSuccess());
    }
  }





  Future<void> deletePost({required PostModel post}) async {
    try {
      emit(DeletePostLoading());
      if (post.deleteImageUrl != null) {
        if (!post.deleteImageUrl!.startsWith('http')) {
          await deleteImageFromSupabase(post.deleteImageUrl!);
        }
      }

      await _api.deleteData(path: 'posts?id=eq.${post.id}');
      posts.remove(post);
      emit(DeletePostSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(DeletePostError());
    }
  }

  Future<void> updateTextPost({required String id,required String name}) async {
    try {
      emit(UpdatePostLoading());


      await _api.patchData(path: 'posts?id=eq.$id', data: {
        "text":name
      });

      emit(UpdatePostSuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(UpdatePostError());
    }
  }
}
