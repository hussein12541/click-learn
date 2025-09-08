import 'package:e_learning/core/logic/get_user_data/get_user_data_cubit.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logic/get_teachers/get_teachers_cubit.dart';
import '../widgets/booking_body.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  @override
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<GetTeachersCubit>().getTeachers(stage_id:context.read<GetUserDataCubit>().userModel!.stageId);
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الحجز"),centerTitle: true,),
      body: BlocBuilder<GetTeachersCubit,GetTeachersState>(
          builder:(context, state) =>  (state is GetTeachersSuccess)?BookingBody(teachers: context.watch<GetTeachersCubit>().teachers,):LoadingWidget()),
    );
  }
}
