import 'package:e_learning/view/booking_screen/widgets/select_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/logic/get_teachers/get_teachers_cubit.dart';
import '../../../core/models/teacher_model.dart';

class BookingBody extends StatelessWidget {
  final List<TeacherModel> teachers;

  const BookingBody({super.key, required this.teachers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: teachers.length,
      separatorBuilder: (context, index) => const Divider(), // فاصل بسيط
      itemBuilder: (context, index) {
        final teacher = teachers[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(teacher.imageUrl),
          ),
          title: Text(teacher.users.name),
          subtitle: Text(" عدد المجموعات: ${teacher.groups.length}"),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  final teachers = context.watch<GetTeachersCubit>().teachers.where((e) => e.id == teacher.id).toList();




                  return SelectGroup(groups: (teachers.isEmpty)?[
                    GroupModel(id: 'id', name: 'name', stageId: 'stageId', teacherId: 'teacherId', numberOfStudents: 'numberOfStudents')
                  ]:teachers.first.groups);
                },
              ),
            );

          },
        );
      },
    );
  }
}
