part of 'add_poll_cubit.dart';

@immutable
sealed class AddPollState {}

final class AddPollInitial extends AddPollState {}

final class AddPollLoading extends AddPollState {}
final class AddPollSuccess extends AddPollState {}
final class AddPollError extends AddPollState {}
