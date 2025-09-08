part of 'add_vote_cubit.dart';

@immutable
sealed class AddVoteState {}

final class AddVoteInitial extends AddVoteState {}

final class AddVoteLoading extends AddVoteState {}
final class AddVoteError extends AddVoteState {}
final class AddVoteSuccess extends AddVoteState {}
