part of 'get_quizzes_cubit.dart';

@immutable
sealed class GetQuizzesState {}

final class GetQuizzesInitial extends GetQuizzesState {}

final class GetQuizzesLoading extends GetQuizzesState {}
final class GetQuizzesSuccess extends GetQuizzesState {
  List<QuizModel> quizzes=[];
  GetQuizzesSuccess({required this.quizzes});
}
final class GetQuizzesError extends GetQuizzesState {}


