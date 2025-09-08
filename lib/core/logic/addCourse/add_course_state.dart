part of 'add_course_cubit.dart';

@immutable
sealed class AddCourseState {}

final class AddCourseInitial extends AddCourseState {}

final class AddCourseSuccess extends AddCourseState {}
final class AddCourseLoading extends AddCourseState {}
final class AddCourseError extends AddCourseState {}

final class AddLessonSuccess extends AddCourseState {}
final class AddLessonLoading extends AddCourseState {}
final class AddLessonError extends AddCourseState {}

final class DeleteLessonSuccess extends AddCourseState {}
final class DeleteLessonLoading extends AddCourseState {}
final class DeleteLessonError extends AddCourseState {}

final class UpdateLessonSuccess extends AddCourseState {}
final class UpdateLessonLoading extends AddCourseState {}
final class UpdateLessonError extends AddCourseState {}




final class GetStagesLoading extends AddCourseState {}
final class GetStageSuccess extends AddCourseState {
  List<DataList> dataListDropdownItems = [];
  GetStageSuccess({required this.dataListDropdownItems});
}
final class GetStagesError extends AddCourseState {}
