part of 'get_user_data_cubit.dart';


@immutable
sealed class GetUserDataState {}

final class GetUserDataInitial extends GetUserDataState {}

final class GetUserDataLoading extends GetUserDataState {}
class GetUserDataSuccess extends GetUserDataState {
  final UserModel? userModel;

  GetUserDataSuccess(this.userModel);
}

final class GetUserDataError extends GetUserDataState {
  String errorMessage;
  GetUserDataError(this.errorMessage);
}




