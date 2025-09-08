part of 'get_teachers_cubit.dart';

@immutable
sealed class GetTeachersState {}

final class GetTeachersInitial extends GetTeachersState {}

final class GetTeachersLoading extends GetTeachersState {}
final class GetTeachersSuccess extends GetTeachersState {
  List<TeacherModel>teachers;
  GetTeachersSuccess({required this.teachers});
}
final class GetTeachersError extends GetTeachersState {}
