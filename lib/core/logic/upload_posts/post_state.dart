part of 'post_cubit.dart';

@immutable
sealed class PostState {}

final class PostInitial extends PostState {}

final class GetStagesLoading extends PostState{}
final class GetStagesSuccess extends PostState{}
final class GetStagesError extends PostState{}



final class UploadPostLoading extends PostState{}
final class UploadPostSuccess extends PostState{}
final class UploadPostError extends PostState{}

