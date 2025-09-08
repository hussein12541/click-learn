part of 'get_group_details_cubit.dart';

@immutable
sealed class GetGroupDetailsState {}

final class GetGroupDetailsInitial extends GetGroupDetailsState {}

// final class GetGroupDetailsLoading extends GetGroupDetailsState {}
// final class GetGroupDetailsSuccess extends GetGroupDetailsState {
//   GroupModel group ;
//   GetGroupDetailsSuccess({required this.group});
// }
// final class GetGroupDetailsError extends GetGroupDetailsState {}
//

final class BookGroupDetailsLoading extends GetGroupDetailsState {}
final class BookGroupDetailsSuccess extends GetGroupDetailsState {
  final GroupModel group;
  BookGroupDetailsSuccess({required this.group});
}

final class BookGroupDetailsError extends GetGroupDetailsState {}
