part of 'upload_quiz_cubit.dart';

@immutable
sealed class UploadQuizState {}

final class UploadQuizInitial extends UploadQuizState {}


final class GetStagesLoading extends UploadQuizState {}
final class GetStageSuccess extends UploadQuizState {
  List<DataList> dataListDropdownItems = [];
  GetStageSuccess({required this.dataListDropdownItems});
}
final class GetStagesError extends UploadQuizState {}

final class UploadQuizLoading extends UploadQuizState{}
final class UploadQuizSuccess extends UploadQuizState{}
final class UploadQuizError extends UploadQuizState{}


