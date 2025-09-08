part of 'score_cubit.dart';

@immutable
sealed class ScoreState {}

final class ScoreInitial extends ScoreState {}

final class AddScoreLoading extends ScoreState {}
final class AddScoreSuccess extends ScoreState {}
final class AddScoreError extends ScoreState {}

final class GetScoreLoading extends ScoreState {}
final class GetScoreSuccess extends ScoreState {
 final List<UserWithScoresModel>scores;
 GetScoreSuccess(this.scores);
}
final class GetScoreError extends ScoreState {}



final class GetStudentScoreLoading extends ScoreState {}
final class GetStudentScoreSuccess extends ScoreState {
 final List<UserWithScoresModel>studentScores;
 GetStudentScoreSuccess(this.studentScores);
}
final class GetStudentScoreError extends ScoreState {}


