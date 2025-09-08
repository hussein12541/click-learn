part of 'stories_cubit.dart';

@immutable
sealed class StoriesState {}

final class StoriesInitial extends StoriesState {}

final class AddStorySuccess extends StoriesState {}
final class AddStoryLoading extends StoriesState {}
final class AddStoryError extends StoriesState {}

final class DeleteStorySuccess extends StoriesState {}
final class DeleteStoryLoading extends StoriesState {}
final class DeleteStoryError extends StoriesState {}

final class GetStoriesSuccess extends StoriesState {}
final class GetStoriesLoading extends StoriesState {}
final class GetStoriesError extends StoriesState {}
