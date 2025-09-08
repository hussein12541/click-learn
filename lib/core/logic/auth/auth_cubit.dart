import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/stage_group_schedule_model.dart';



part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  SupabaseClient client = Supabase.instance.client;
  final ApiServices _api=ApiServices();

  Future<void>login({required String email, required String fcm_token,required String device_id, required String password,required BuildContext context }) async{
   emit(LoginLoading());

    try {
      final AuthResponse res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      Response response = await _api.getData(path: 'users?id=eq.${Supabase.instance.client.auth.currentUser!.id}');

      if(response.data is List && response.data.isNotEmpty){

          await _api.patchData(
              path: 'users?id=eq.${Supabase.instance.client.auth.currentUser!
                  .id}', data: {
            "fcm_token": fcm_token
          });

        if (response.data[0]['device_id'] == null) {
          await _api.patchData(
              path: 'users?id=eq.${Supabase.instance.client.auth.currentUser!
                  .id}', data: {
            "device_id": device_id
          });
        }
      }

      emit(LoginSuccess());
    } on AuthException catch (e) {
      String errorMessage;
      if (e.message.contains("Invalid login credentials")) {
        errorMessage = "البريد الإلكتروني غير صحيح";
      } else {
        errorMessage = e.message;
      }
      print(" ++++++++ error signUp: $e");
      emit(LoginError(errorMessage));
    }
  }


  Future<void> signUp({
    required String name,
    required String phone,
    required String parent_phone,
    required String stageId,
    required String email,
    required String password,
    required String fcmToken,
    required String device_id,
  }) async {


    try {
      emit(SignupLoading());






        final AuthResponse res = await client.auth.signUp(
          email: email,
          password: password,
        );

        await addUserData(email: email, name: name, password: password, phone: phone, stageId: stageId, fcmToken: fcmToken, device_id: device_id, parent_phone: parent_phone);
        emit(SignupSuccess());


    } on AuthException catch (e) {
      print(" ++++++++ error signUp: $e");
      emit(SignupError(e.message));
      // TODO
    } on FormatException catch (e) {
      print(" ++++++++ error parsing number_of_students: $e");
      emit(SignupError('حدث خطأ غير متوقع'));
      // TODO
    }
  }
  // GoogleSignInAccount? googleUser;
  //
  // Future<AuthResponse> googleSignIn() async {
  //
  //   emit(GoogleLoginLoading());
  //   const webClientId = '645865194498-oqlcl6e5f5thsf8ep1p58aediqe0ph7u.apps.googleusercontent.com';
  //
  //
  //
  //   final GoogleSignIn googleSignIn = GoogleSignIn(
  //     serverClientId: webClientId,
  //   );
  //    googleUser = await googleSignIn.signIn();
  //    if(googleUser==null){
  //      return AuthResponse();
  //    }
  //
  //   final googleAuth = await googleUser!.authentication;
  //   final accessToken = googleAuth.accessToken;
  //   final idToken = googleAuth.idToken;
  //
  //   if (accessToken == null || idToken == null) {
  //     emit(GoogleLoginError());
  //     return AuthResponse();
  //   }
  //
  //
  //   AuthResponse response = await client.auth.signInWithIdToken(
  //     provider: OAuthProvider.google,
  //     idToken: idToken,
  //     accessToken: accessToken,
  //   );
  //   await addUserData(email: googleUser!.email, name: googleUser!.displayName!, password: 'google password');
  //   emit(GoogleLoginSuccess());
  //   return response;
  // }

  //
  // Future<AuthResponse> facebookSignIn() async {
  //   emit(FacebookLoginLoading());
  //
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login(
  //       permissions: ['email', 'public_profile'],
  //     );
  //
  //     if (result.status != LoginStatus.success || result.accessToken == null) {
  //       emit(FacebookLoginError());
  //       return AuthResponse();
  //     }
  //
  //     final accessToken = result.accessToken!.tokenString;
  //
  //     // Facebook authentication only provides access tokens, not ID tokens
  //     // We'll use the access token for both parameters since ID token is required
  //     AuthResponse response = await client.auth.signInWithIdToken(
  //       provider: OAuthProvider.facebook,
  //       idToken: accessToken,  // Using access token as ID token
  //       accessToken: accessToken,
  //     );
  //
  //     emit(FacebookLoginSuccess());
  //     return response;
  //   } catch (e) {
  //     emit(FacebookLoginError());
  //     return AuthResponse();
  //   }
  // }







  // Future<void>resetPassword({required email})async{
  //   emit(ResetPasswordLoading());
  //   try{
  //     await client.auth.resetPasswordForEmail(email);
  //     emit(ResetPasswordSuccess());
  //   }catch (e){
  //     log(e.toString());
  //     emit(ResetPasswordError());
  //   }
  // }

Future<void> addUserData({
    required String email,
    required String name,
    required String phone,
    required String parent_phone,
    required String stageId,
    required String password,
    required String fcmToken,
    required String device_id,

  })async {
    emit(UserDataAddedLoading());
    try {
      await client
          .from('users')
          .upsert({'email': email, 'name': name,"phone":phone,"parent_phone":parent_phone,"stageId":stageId,'password':password,'fcm_token':fcmToken,'device_id':device_id,'id':client.auth.currentUser!.id});
      emit(UserDataAddedSuccess());
    } on Exception catch (e) {
      log('UserDataAddedError$e');
      emit(UserDataAddedError(e.toString()));
    }
}



  List<StageGroupScheduleModel> StageGroupScheduleList = [];
  List<DataList> dataListDropdownItems = [];

  Future<void> getAllStages() async {
    try {
      emit(GetStagesLoading());
      Response response = await _api.getData(path: 'stages?select=*,groups(*,schedules(*))');
      StageGroupScheduleList.clear();
      StageGroupScheduleList.add(StageGroupScheduleModel.fromJson(response.data));

      // Flatten all DataList from the StageGroupScheduleModel list
      dataListDropdownItems.clear();
      for (var stage in StageGroupScheduleList) {
        if (stage.dataListList != null) {
          dataListDropdownItems.addAll(stage.dataListList!);
        }
      }

      print(response.data.toString());
      emit(GetStagesSuccess());
    } catch (e) {
      log("getAllStages error: $e");
      emit(GetStagesError());
    }
  }





}


