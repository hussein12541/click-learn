part of 'get_comments_cubit.dart';

@immutable
sealed class GetCommentsState {}

final class GetCommentsInitial extends GetCommentsState {}

final class GetCommentsSuccess extends GetCommentsState {}
final class GetCommentsLoading extends GetCommentsState {}
final class GetCommentsError extends GetCommentsState {}

// final class AddCommentsSuccess extends GetCommentsState {}
// final class AddCommentsLoading extends GetCommentsState {}
// final class AddCommentsError extends GetCommentsState {}
//
// final class AddReplaysSuccess extends GetCommentsState {}
// final class AddReplaysLoading extends GetCommentsState {}
// final class AddReplaysError extends GetCommentsState {}
