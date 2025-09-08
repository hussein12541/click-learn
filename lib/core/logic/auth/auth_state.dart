part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class LoginLoading extends AuthState{}
final class LoginSuccess extends AuthState{}
final class LoginError extends AuthState{
  String errorMessage;
  LoginError(this.errorMessage);
}


final class SignupLoading extends AuthState{}
final class SignupSuccess extends AuthState{}
final class SignupError extends AuthState{
  String errorMessage;
  SignupError(this.errorMessage);
}

// final class GoogleLoginLoading extends AuthState{}
// final class GoogleLoginSuccess extends AuthState{}
// final class GoogleLoginError extends AuthState{}

final class GetStagesLoading extends AuthState{}
final class GetStagesSuccess extends AuthState{}
final class GetStagesError extends AuthState{}

final class GetGroupsLoading extends AuthState{}
final class GetGroupsSuccess extends AuthState{}
final class GetGroupsError extends AuthState{}


final class UserDataAddedLoading extends AuthState{}
final class UserDataAddedSuccess extends AuthState{}
final class UserDataAddedError extends AuthState{
  String errorMessage;
  UserDataAddedError(this.errorMessage);
}





// final class FacebookLoginLoading extends AuthState{}
// final class FacebookLoginSuccess extends AuthState{}
// final class FacebookLoginError extends AuthState{}
