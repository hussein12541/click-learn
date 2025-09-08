import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../models/post_model.dart' show GroupModel;
import '../../widgets/get_token.dart';

part 'get_user_data_state.dart';

class GetUserDataCubit extends Cubit<GetUserDataState> {
  GetUserDataCubit() : super(GetUserDataInitial());

  final ApiServices _api = ApiServices();

  bool exists = false;
  bool samePhone = true;
  UserModel? userModel;
  List<GroupModel>groups =[];

  bool isTeacher = false;

  /// دالة موحدة بتجيب بيانات المستخدم وتشوف لو موجود وفحص الـ token كمان
  Future<void> fetchUserDataAndCheckExistence({required String id}) async {
    try {
      emit(GetUserDataLoading());
      groups = [];

      // Get user data
      final response = await _api.getData(
        path: "users?select=*&id=eq.$id&order=created_at.desc",
      );

      // Check if user is a teacher
      final teachersData = await _api.getData(
        path: "teachers?select=*&order=created_at.desc",
      );
      isTeacher = teachersData.data.any((item) => item['id'] == id);

      // Check if user exists
      if (response.data is List && response.data.isNotEmpty) {
        userModel = UserModel.fromJson(response.data[0]);
        exists = true;

        // Get groups
        final groupsData = await _api.getData(
          path:
          "user_groups?select=*,users(*),groups(*,stages(*),teachers(*,users(*)))&user_id=eq.${userModel?.id}&order=created_at.desc",
        );

        for (var group in groupsData.data) {
          if (group['groups'] != null) {
            final groupModel = GroupModel.fromJson(group['groups']);

            // ✅ تأكد إن الجروب مش مضاف قبل كده
            if (!groups.any((g) => g.id == groupModel.id)) {
              groups.add(groupModel);
            }

            print('+++++++++++');
            print(groupModel.toString());
          }
        }



        // Check device ID
        final deviceId = await DeviceTokenHelper.getDeviceId();
        final storedDeviceId = response.data[0]['device_id'];

        samePhone = storedDeviceId == deviceId;
        log('Device Match: $samePhone');

      } else {
        exists = false;
        samePhone = true;
        userModel = null;
      }

      emit(GetUserDataSuccess(userModel));
    } catch (e) {
      log("Error in fetchUserDataAndCheckExistence: $e");
      exists = false;
      samePhone = true;
      emit(GetUserDataError(e.toString()));
    }
  }

}



//
  //
  // final SupabaseClient _supabase = Supabase.instance.client;
  //
  // UserModel? userModel;
  // bool _isDataFetched = false;
  // bool _isLoading = false;
  //
  // Future<UserModel?> getUserData() async {
  //   if (_isDataFetched) {
  //     emit(GetUserDataSuccess(userModel!));
  //     return userModel;
  //   }
  //   if (_isLoading) return null;
  //
  //   _isLoading = true;
  //   emit(GetUserDataLoading());
  //
  //   try {
  //     final currentUser = _supabase.auth.currentUser;
  //     if (currentUser == null) {
  //       await clearUserData();
  //       emit(GetUserDataInitial());
  //       return null;
  //     }
  //
  //     final cachedUser = await _getCachedUserData();
  //     if (cachedUser != null && cachedUser.id == currentUser.id) {
  //       userModel = cachedUser;
  //       emit(GetUserDataSuccess(userModel!));
  //       return userModel;
  //     }
  //
  //     final response = await _api.getData(
  //       path: "users?select=*&id=eq.${currentUser.id}&order=created_at.desc",
  //     );
  //
  //     final userData = _validateResponse(response);
  //     userModel = UserModel.fromJson(userData);
  //
  //     await _cacheUserData(userModel!);
  //
  //     emit(GetUserDataSuccess(userModel!));
  //     return userModel;
  //   } catch (e) {
  //     final cachedUser = await _getCachedUserData();
  //     if (cachedUser != null) {
  //       userModel = cachedUser;
  //       emit(GetUserDataSuccess(userModel!));
  //       return userModel;
  //     }
  //
  //     emit(GetUserDataError(e.toString()));
  //     return null;
  //   } finally {
  //     _isLoading = false;
  //     _isDataFetched = true;
  //   }
  // }
  //
  //
  //
  // Map<String, dynamic> _validateResponse(dynamic response) {
  //   if (response.data == null || response.data.isEmpty) {
  //     throw Exception('No user data available');
  //   }
  //   return response.data[0];
  // }
  //
  // Future<void> _cacheUserData(UserModel user) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('user_data_id', user.id);
  //   await prefs.setString('user_data_name', user.name);
  //   await prefs.setString('user_data_phone', user.phone);
  //   await prefs.setString('user_data_groupId', user.groupId);
  //   await prefs.setString('user_data_email', user.email);
  // }
  //
  // Future<UserModel?> _getCachedUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final id = prefs.getString('user_data_id');
  //   final name = prefs.getString('user_data_name');
  //   final phone = prefs.getString('user_data_phone');
  //   final groupId = prefs.getString('user_data_groupId');
  //   final email = prefs.getString('user_data_email');
  //
  //   if (id == null || name == null || email == null|| phone == null|| groupId == null) return null;
  //
  //   return UserModel(
  //     id: id,
  //     name: name,
  //     email: email, phone:phone, groupId:groupId,
  //   );
  // }
  //
  // Future<void> clearUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('user_data_id');
  //   await prefs.remove('user_data_name');
  //   await prefs.remove('user_data_phone');
  //   await prefs.remove('user_data_groupId');
  //   await prefs.remove('user_data_email');
  //   userModel = null;
  //   _isDataFetched = false;
  //   emit(GetUserDataInitial());
  // }
