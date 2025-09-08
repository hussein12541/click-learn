part of 'get_posts_cubit.dart';

@immutable
sealed class GetPostsState {}

final class GetPostsInitial extends GetPostsState {}

final class GetPostsLoading extends GetPostsState {}
final class GetPostsSuccess extends GetPostsState {}
final class GetPostsError extends GetPostsState {}

final class AddLikeLoading extends GetPostsState {}
final class AddLikeSuccess extends GetPostsState {}
final class AddLikeError extends GetPostsState {}

final class DeleteLikeLoading extends GetPostsState {}
final class DeleteLikeSuccess extends GetPostsState {}
final class DeleteLikeError extends GetPostsState {}

final class DeletePostLoading extends GetPostsState{}
final class DeletePostSuccess extends GetPostsState{}
final class DeletePostError extends GetPostsState{}

final class UpdatePostLoading extends GetPostsState{}
final class UpdatePostSuccess extends GetPostsState{}
final class UpdatePostError extends GetPostsState{}

