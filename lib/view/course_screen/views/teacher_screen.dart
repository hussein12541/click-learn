import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_learning/core/logic/get_user_data/get_user_data_cubit.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/post_model.dart';
import '../widgets/course_screen.dart';


class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});


  Widget build(BuildContext context) {

    List<GroupModel>groups  = context.read<GetUserDataCubit>().groups;


    return Scaffold(
        appBar: AppBar(title: Text("الكورسات"), centerTitle: true,),
        body: ListView.separated(
          itemCount: groups.length,
          separatorBuilder: (context, index) => const Divider(), // فاصل بسيط
          itemBuilder: (context, index) {
            final group = groups[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(group.teacher.imageUrl),
              ),
              title: Text(group.teacher.user.name),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {


                   return CourseListPage(stage_id: group.stageId,course_teacher_id: group.teacher_id,);
                      
                      },
                  ),
                );
              },
            );
          },
        )

    );
  }
}

