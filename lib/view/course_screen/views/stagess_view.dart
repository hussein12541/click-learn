import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/logic/get_courses/get_courses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/stage_group_schedule_model.dart';
import '../widgets/course_screen.dart';

class StageListPage extends StatelessWidget {
  const StageListPage({super.key});

  

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('الكورسات'),
        centerTitle: true,

      ),
      body: RefreshIndicator(
        onRefresh:() async =>      await context.read<GetCoursesCubit>().getAllCourses(isTeacher: true,teacher_id: Supabase.instance.client.auth.currentUser!.id, teacherIdsForStudent: []),

        child: BlocBuilder<GetCoursesCubit, GetCoursesState>(
          builder: (context, state) {
            if (state is GetStagesSuccess||state is GetCoursesSuccess) {
              List<DataList> courses = context.watch<GetCoursesCubit>().dataListDropdownItems;
              return ListView.builder(
                itemCount: courses.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Card(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: SvgPicture.asset(
                        'assets/images/images/videos.svg',
                        color: isDark ? Colors.white : kLightPrimaryColor,
                      ),
                      title: Text(
                        course.name??'', // هنا خليك دايمًا تستخدم الخاصية الصح
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CourseListPage(stage_id: courses[index].id??'', course_teacher_id: Supabase.instance.client.auth.currentUser!.id,),));

                      },
                    ),
                  );
                },
              );
            }  {
              return Skeletonizer(
                child: ListView.builder(
                  itemCount: 3,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) => Card(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: Icon(Icons.book),
                      title: Text(
                        'course.name??', // هنا خليك دايمًا تستخدم الخاصية الصح
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
