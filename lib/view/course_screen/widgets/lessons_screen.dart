import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/logic/addCourse/add_course_cubit.dart';
import 'package:e_learning/core/logic/get_courses/get_courses_cubit.dart';
import 'package:e_learning/core/models/lesson_model.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:e_learning/view/course_screen/widgets/secure_youtube_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/widgets/showMessage.dart';
import 'lesson_screen.dart';

class LessonListPage extends StatefulWidget {
  final List<LessonModel> initialLessons;
  final String course_id;
  final String stage_id;
  final int course_index;

  const LessonListPage({
    super.key,
    required this.initialLessons,
    required this.course_id,
    required this.course_index,
    required this.stage_id,
  });

  @override
  State<LessonListPage> createState() => _LessonListPageState();
}

class _LessonListPageState extends State<LessonListPage> {
  late List<LessonModel> lessons;

  @override
  void initState() {
    super.initState();
    lessons = List.from(widget.initialLessons);
  }

  void _addNewLesson(LessonModel lesson) {
    setState(() {
      lessons.add(lesson);
    });
  }

  void _confirmDeleteLesson(LessonModel lesson) {
    final addCourseCubit = context.read<AddCourseCubit>();

    showDialog(
      context: context,
      builder: (_) {
        return Builder(
          builder: (dialogContext) {
            final getCoursesCubit = dialogContext.read<GetCoursesCubit>();

            return AlertDialog(
              title: const Text('تأكيد الحذف'),
              content: Text('هل أنت متأكد من حذف الدرس "${lesson.name}"؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    setState(() {
                      lessons.removeWhere((l) => l.id == lesson.id);
                    });
                    await addCourseCubit.deleteLesson(id: lesson.id);
                    await getCoursesCubit.getAllCourses(
                      isTeacher: true,
                      teacher_id: Supabase.instance.client.auth.currentUser!.id,
                      teacherIdsForStudent: [],
                    );

                    ShowMessage.showToast(
                      backgroundColor: Colors.green,
                      'تم حذف درس "${lesson.name}"',
                    );
                  },
                  child: const Text('حذف', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditLessonSheet(LessonModel lesson) {
    final nameController = TextEditingController(text: lesson.name);
    final videoUrlController = TextEditingController(text: lesson.vedioUrl);
    final pdfUrlController = TextEditingController(text: lesson.pdf_url);
    final addCourseCubit = context.read<AddCourseCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Builder(
          builder: (bottomContext) {
            final getCourseCubit = bottomContext.read<GetCoursesCubit>();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تعديل الدرس',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الفيديو',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الفيديو',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pdfUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الملف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ التعديلات'),
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final vedioUrl = videoUrlController.text.trim();
                      final pdfUrl = pdfUrlController.text.trim();

                      if (name.isEmpty ||
                          (vedioUrl.isEmpty && pdfUrl.isEmpty)) {
                        ShowMessage.showToast('املأ كل البيانات');
                        return;
                      }

                      await addCourseCubit.updateLesson(
                        id: lesson.id,
                        name: name,
                        vedio_url: vedioUrl,
                        pdfUrl: pdfUrl,
                      );

                      await getCourseCubit.getAllCourses(
                        isTeacher: true,
                        teacher_id:
                            Supabase.instance.client.auth.currentUser!.id,
                        teacherIdsForStudent: [],
                      );

                      setState(() {
                        final index = lessons.indexWhere(
                          (l) => l.id == lesson.id,
                        );
                        if (index != -1) {
                          lessons[index] = lessons[index].copyWith(
                            name: name,
                            vedioUrl: vedioUrl,
                            pdf_url: pdfUrl,
                          );
                        }
                      });

                      Navigator.pop(context);
                      ShowMessage.showToast(
                        backgroundColor: Colors.green,
                        'تم تعديل الدرس',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isTeacher = context.watch<GetUserDataCubit>().isTeacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدروس'),
        centerTitle: true,
        actions: [
          isTeacher
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'إضافة درس',
                  onPressed: () {
                    final addCourseCubit = context.read<AddCourseCubit>();

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        final nameController = TextEditingController();
                        final urlController = TextEditingController();

                        return Builder(
                          builder: (bottomContext) {
                            return BlocProvider.value(
                              value: addCourseCubit,
                              child: BlocBuilder<AddCourseCubit, AddCourseState>(
                                builder: (context, state) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom +
                                          20,
                                      left: 20,
                                      right: 20,
                                      top: 20,
                                    ),
                                    child: (state is AddLessonLoading)
                                        ? Container(
                                            height: 250,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'إضافة درس جديد',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              TextFormField(
                                                controller: nameController,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'اسم الفيديو',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              TextFormField(
                                                controller: urlController,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'رابط الفيديو',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.save),
                                                label: const Text(
                                                  'إضافة الدرس',
                                                ),
                                                onPressed: () async {
                                                  final name = nameController
                                                      .text
                                                      .trim();
                                                  final vedioUrl = urlController
                                                      .text
                                                      .trim();
                                                  final pdfUrl = urlController
                                                      .text
                                                      .trim();

                                                  if (name.isEmpty ||
                                                     ( vedioUrl.isEmpty&&pdfUrl.isEmpty)) {
                                                    ShowMessage.showToast(
                                                      'املأ كل البيانات',
                                                    );
                                                    return;
                                                  }

                                                  final lessonId = const Uuid()
                                                      .v4();

                                                  await addCourseCubit.addLesson(
                                                    teacher_name:
                                                        context
                                                            .read<
                                                              GetUserDataCubit
                                                            >()
                                                            .userModel
                                                            ?.name ??
                                                        "المدرس",

                                                    vedioUrl: vedioUrl,
                                                    pdfUrl: pdfUrl,
                                                    name: name,
                                                    course_id: widget.course_id,
                                                    id: lessonId,
                                                    stage_id: widget.stage_id,
                                                  );

                                                  final newLesson = LessonModel(
                                                    pdf_url: pdfUrl,
                                                    id: lessonId,
                                                    name: name,
                                                    courseId: widget.course_id,
                                                    vedioUrl: vedioUrl,
                                                    createdAt: DateTime.now(),
                                                    isShown: true,
                                                  );

                                                  final getCourseCubit = context
                                                      .read<GetCoursesCubit>();

                                                  await getCourseCubit
                                                      .getAllCourses(
                                                        isTeacher: true,
                                                        teacher_id: Supabase
                                                            .instance
                                                            .client
                                                            .auth
                                                            .currentUser!
                                                            .id,
                                                        teacherIdsForStudent:
                                                            [],
                                                      );

                                                  Navigator.pop(
                                                    context,
                                                    newLesson,
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ).then((newLesson) {
                      if (newLesson != null && newLesson is LessonModel) {
                        _addNewLesson(newLesson);
                        ShowMessage.showToast(
                          'تمت إضافة الدرس✅',
                          backgroundColor: Colors.green,
                        );
                      }
                    });
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
      body: BlocBuilder<AddCourseCubit, AddCourseState>(
        builder: (context, state) {
          if (state is AddCourseLoading ||
              state is AddLessonLoading ||
              state is DeleteLessonLoading ||
              state is UpdateLessonLoading) {
            return const LoadingWidget();
          }

          if (lessons.isEmpty) {
            return const Center(child: Text("لا توجد دروس متاحة"));
          }

          return ListView.builder(
            itemCount: lessons.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return Card(
                color: isDark ? Colors.grey[900] : Colors.white,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: SvgPicture.asset(
                    'assets/images/images/video.svg',
                    color: isDark ? Colors.white : kLightPrimaryColor,
                  ),
                  title: Text(
                    lesson.name,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: isTeacher
                      ? PopupMenuButton<String>(
                          tooltip: 'خيارات الدرس',
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _showEditLessonSheet(lesson);
                            }
                            if (value == 'isShown') {
                              final addCourseCubit = context
                                  .read<AddCourseCubit>();
                              final getCoursesCubit = context
                                  .read<GetCoursesCubit>();

                              await addCourseCubit.showOrHideLesson(
                                id: lesson.id,
                                isShown: lesson.isShown,
                              );

                              setState(() {
                                lessons[index] = lesson.copyWith(
                                  isShown: !lesson.isShown,
                                );
                              });
                            } else if (value == 'delete') {
                              _confirmDeleteLesson(lesson);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('✏️ تعديل'),
                            ),
                            PopupMenuItem(
                              value: 'isShown',
                              child: Text(
                                lesson.isShown == true
                                    ? '🔒 إخفاء الدرس'
                                    : '🔓 إظهار الدرس',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                '🗑️ حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        )
                      : Icon(Icons.arrow_forward_ios, size: 16),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonPage(lesson: lesson),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
