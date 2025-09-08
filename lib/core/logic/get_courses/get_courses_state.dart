part of 'get_courses_cubit.dart';

@immutable
sealed class GetCoursesState {}

final class GetCoursesInitial extends GetCoursesState {}

final class GetStagesLoading extends GetCoursesState {}
final class GetStagesSuccess extends GetCoursesState {
  List<DataList> dataListDropdownItems = [];
  GetStagesSuccess({required this.dataListDropdownItems});
}

final class GetStagesError extends GetCoursesState {}
final class GetCoursesLoading extends GetCoursesState {}
final class GetCoursesSuccess extends GetCoursesState {
  List<CourseModel> courses = [];
  GetCoursesSuccess({required this.courses});
}
final class GetCoursesError extends GetCoursesState {}

final class UpdateCourseSuccess extends GetCoursesState {}
final class UpdateCourseLoading extends GetCoursesState {}
final class UpdateCourseError extends GetCoursesState {}


final class DeleteCourseSuccess extends GetCoursesState {}
final class DeleteCourseLoading extends GetCoursesState {}
final class DeleteCourseError extends GetCoursesState {}
