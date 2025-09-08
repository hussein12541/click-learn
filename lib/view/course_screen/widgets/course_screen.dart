import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/logic/get_courses/get_courses_cubit.dart';
import 'package:e_learning/core/models/course_model.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logic/addCourse/add_course_cubit.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import 'lessons_screen.dart';

class CourseListPage extends StatelessWidget {
  final String stage_id;
  final String course_teacher_id;

  const CourseListPage({super.key, required this.stage_id, required this.course_teacher_id});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<GetCoursesCubit>(); // نستخدمه بدل context بعدين

    return Scaffold(
      appBar: AppBar(title: const Text('الكورسات'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async =>
            await context.read<GetCoursesCubit>().getAllCourses(
              isTeacher: context.read<GetUserDataCubit>().isTeacher,
              teacherIdsForStudent: context
                  .read<GetUserDataCubit>()
                  .groups
                  .map((e) => e.teacher_id)
                  .whereType<String>()
                  .toList(),
              teacher_id: Supabase.instance.client.auth.currentUser!.id,
            ),
        child: BlocBuilder<GetCoursesCubit, GetCoursesState>(
          builder: (context, state) {
            if (state is GetCoursesLoading || state is UpdateCourseLoading) {
              return Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const ListTile(
                        leading: CircleAvatar(radius: 20),
                        title: Text('عنوان الاختبار'),
                        subtitle: Text('مدة الاختبار'),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is GetCoursesSuccess) {
              final courses = state.courses
                  .where((c) => c.stage_id == stage_id)
                  .toList();

              if (courses.isEmpty) {
                return const Center(child: Text("لا توجد كورسات متاحة"));
              }

              return _buildCoursesList(context, courses, isDark, cubit);
            } else {
              final courses = cubit.courses
                  .where((c) => c.stage_id == stage_id&&c.teacher_id==course_teacher_id)
                  .toList();

              if (courses.isEmpty) {
                return const Center(child: Text("لا توجد كورسات متاحة"));
              }

              return _buildCoursesList(context, courses, isDark, cubit);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCoursesList(
    BuildContext context,
    List<CourseModel> courses,
    bool isDark,
    GetCoursesCubit cubit,
  ) {
    final isTeacher = context.watch<GetUserDataCubit>().isTeacher;

    return ListView.builder(
      itemCount: courses.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          color: isDark ? Colors.grey[900] : Colors.white,
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: SvgPicture.asset(
              'assets/images/images/videos.svg',
              color: isDark ? Colors.white : kLightPrimaryColor,
            ),
            title: Text(
              course.name ?? '',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            trailing: isTeacher
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditCourseSheet(context, course);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('تأكيد الحذف'),
                            content: const Text(
                              'هل أنت متأكد من حذف هذا الكورس؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context); // اقفل الديالوج الأول
                                  await cubit.deleteCourse(id: course.id);
                                  await cubit.getAllCourses(
                                    isTeacher: true,
                                    teacher_id: Supabase
                                        .instance
                                        .client
                                        .auth
                                        .currentUser!
                                        .id,
                                    teacherIdsForStudent: [],
                                  );

                                  ShowMessage.showToast(
                                    backgroundColor: Colors.red,
                                    'تم حذف الكورس',
                                  );
                                },
                                child: const Text(
                                  'حذف',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                  )
                : Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => AddCourseCubit(),
                  child: LessonListPage(
                    initialLessons: course.lessons,
                    course_id: course.id,
                    course_index: index,
                    stage_id: course.stage_id,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditCourseSheet(BuildContext context, CourseModel course) {
    final nameController = TextEditingController(text: course.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تعديل الكورس',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'اسم الكورس',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ التعديلات'),
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      Navigator.pop(context);

                      final cubit = context.read<GetCoursesCubit>();
                      await cubit.updateCourse(id: course.id, name: newName);
                      await cubit.getAllCourses(
                        isTeacher: true,
                        teacher_id:
                            Supabase.instance.client.auth.currentUser!.id,
                        teacherIdsForStudent: [],
                      );

                      ShowMessage.showToast(
                        backgroundColor: Colors.green,
                        'تم تعديل الكورس',
                      );
                    } else {
                      ShowMessage.showToast('من فضلك اكتب اسم الكورس');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
