part of 'get_payment_cubit.dart';

@immutable
sealed class GetPaymentState {}

final class GetPaymentInitial extends GetPaymentState {}

final class GetPaymentLoading extends GetPaymentState {}
final class GetPaymentSuccess extends GetPaymentState {
  final List<PaidModel>payments;
  GetPaymentSuccess({required this.payments});
}
final class GetPaymentError extends GetPaymentState {}
