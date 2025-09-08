import 'package:e_learning/core/logic/get_teachers/get_teachers_cubit.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logic/get_group_details/get_group_details_cubit.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/models/stage_group_schedule_model.dart';
import '../../../core/models/teacher_model.dart';
import '../../../core/models/user_model.dart';
import '../../signup_screen/widgets/times_taple.dart';

class BookGroup extends StatelessWidget {
  final GroupModel group;

  const BookGroup({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    // 🔧 نحاول نجيب الجروب من الـ TeacherModel بأمان
    final teachers = context.watch<GetTeachersCubit>().teachers;

    final teacher = teachers.firstWhere(
          (t) => t.groups.any((g) => g.id == group.id),
      orElse: () => TeacherModel(
        id: '',
        imageUrl: '',
        users: UserModel(id: '', name: '', email: '', phone: '', stageId: '', user_groups: [], parent_phone: ''),
        groups: [],
      ),
    );

    final selectedGroup = teacher.groups.firstWhere(
          (g) => g.id == group.id,
      orElse: () => group,
    );

    return BlocProvider<GetGroupDetailsCubit>(
      create: (context) => GetGroupDetailsCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("حجز المجموعة"), centerTitle: true),
        body: BlocConsumer<GetGroupDetailsCubit, GetGroupDetailsState>(
          listener: (context, state) async {
            if (state is BookGroupDetailsSuccess) {
              await context.read<GetUserDataCubit>().fetchUserDataAndCheckExistence(id: Supabase.instance.client.auth.currentUser!.id);

              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is BookGroupDetailsLoading) {
              return const LoadingWidget();
            }

            final groupData = Groups(
              id: selectedGroup.id,
              createdAt: selectedGroup.createdAt?.toString() ?? '',
              name: selectedGroup.name,
              numberOfStudents: selectedGroup.numberOfStudents,
              stageId: selectedGroup.stageId,
              schedulesList: selectedGroup.schedules,
            );

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedGroup.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            buildGroupInfoTable(context, groupData),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (int.tryParse(selectedGroup.numberOfStudents) != null &&
                        int.parse(selectedGroup.numberOfStudents) > 0)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await context
                                .read<GetGroupDetailsCubit>()
                                .bookGroup(groupId: selectedGroup.id);
                            await context.read<GetTeachersCubit>().getTeachers(stage_id:context.read<GetUserDataCubit>().userModel!.stageId);
                         },
                          icon: const Icon(Icons.event_available),
                          label: const Text("احجز الآن"),
                        ),
                      )
                    else
                      Text(
                        "لا يوجد أماكن متاحة للحجز ❌",
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
