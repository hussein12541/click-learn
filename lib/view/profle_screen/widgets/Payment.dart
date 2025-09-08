import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/logic/get_payment/get_payment_cubit.dart';
import '../../../core/models/payment_model.dart';

class PaymentView extends StatelessWidget {
  final String teacherId;
  const PaymentView({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الدفع"),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) => GetPaymentCubit()..getAllPayment(),
        child: _PaymentBody(teacherId: teacherId,),
      ),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  final String teacherId;

  const _PaymentBody({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<GetPaymentCubit>().getAllPayment();
      },
      child: BlocBuilder<GetPaymentCubit, GetPaymentState>(
        builder: (context, state) {
          if (state is GetPaymentLoading) {
            return const LoadingWidget();
          } else if (state is GetPaymentSuccess) {
            List<PaidModel>  payments= state.payments.where((e) => e.teacher_id==teacherId,).toList();

            if (payments.isEmpty) {
              return const Center(child: Text("لا توجد دفعات حالياً"));
            }
           
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final PaidModel payment = payments[index];
                return ListTile(
                  leading: const Icon(Icons.payments_outlined, color: Colors.green),
                  title: Text(payment.message),
                  subtitle: Text(
                    _formatDate(payment.createdAt),

                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            );
          }  else {
            return const Center(child: Text("حدث خطأ غير متوقع"));
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    // تقدر تستخدم timeago أو تعمل فورمات حسب مزاجك
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day}";
  }
}
