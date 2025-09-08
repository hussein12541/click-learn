import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:e_learning/core/models/lesson_model.dart';
import 'package:e_learning/core/models/stage_group_schedule_model.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/logic/addCourse/add_course_cubit.dart';
import '../../../core/logic/get_courses/get_courses_cubit.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../nav_button/views/nav_button_screen.dart';

class LessonInput {
  final TextEditingController nameController;
  final TextEditingController vedioUrlController;
  final TextEditingController pdfUrlController;

  LessonInput({
    required this.nameController,
    required this.vedioUrlController,
    required this.pdfUrlController,
  });
}

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseNameController = TextEditingController();

  DataList? selectedStage;

  List<LessonInput> lessonInputs = [
    LessonInput(
      nameController: TextEditingController(),
      vedioUrlController: TextEditingController(),
      pdfUrlController: TextEditingController(),
    )
  ];

  @override
  void initState() {
    super.initState();
    context.read<AddCourseCubit>().getAllStages(teacherId: Supabase.instance.client.auth.currentUser!.id);
  }

  void _addLesson() {
    setState(() {
      lessonInputs.add(
        LessonInput(
          nameController: TextEditingController(),
          vedioUrlController: TextEditingController(),
          pdfUrlController: TextEditingController(),
        ),
      );
    });
  }

  void _removeLesson(int index) {
    if (lessonInputs.length > 1) {
      setState(() {
        lessonInputs.removeAt(index);
      });
    } else {
      ShowMessage.showToast('يجب أن يكون هناك درس على الأقل');
    }
  }

  Future<void> _saveCourse(BuildContext context) async {
    if (_formKey.currentState!.validate() && selectedStage != null) {
      final courseId = Uuid().v4();

      final lessons = lessonInputs.map((input) {
        return LessonModel(
          isShown: true,
          id: Uuid().v4(),
          name: input.nameController.text.trim(),
          courseId: courseId,
          vedioUrl: input.vedioUrlController.text.trim(),
          pdf_url: input.pdfUrlController.text.trim(),
          createdAt: DateTime.now(),
        );
      }).toList();

      if (lessons.any((l) => l.name.isEmpty || l.vedioUrl!.isEmpty)) {
        ShowMessage.showToast('تأكد إن كل الدروس مكتوبة صح');
        return;
      }

      print("تم حفظ الكورس: ${_courseNameController.text}");
      print("الدروس:");
      for (var lesson in lessons) {
        print(lesson.toJson());
      }

      await context.read<AddCourseCubit>().addCourse(stage_id:selectedStage!.id??'',course_name: _courseNameController.text,lessons: lessons, teacher_id: Supabase.instance.client.auth.currentUser!.id,
          teacher_name: context.read<GetUserDataCubit>().userModel?.name??"المدرس",

    );


      await context.read<GetCoursesCubit>().getAllCourses(isTeacher: true,teacher_id: Supabase.instance.client.auth.currentUser!.id, teacherIdsForStudent: []);



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavButton()),
      );
      ShowMessage.showToast('تم نشر الكورس بنجاح!', backgroundColor: Colors.green);

    } else {
      ShowMessage.showToast('املأ كل البيانات المطلوبة');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة كورس جديد'),
        centerTitle: true,

      ),
      body: BlocBuilder<AddCourseCubit, AddCourseState>(
        builder: (context, state) {
          if (state is GetStageSuccess) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomDropdown<DataList>(
                          hintText: 'اختر المرحلة',
                          items: context.read<AddCourseCubit>().dataListDropdownItems,
                          onChanged: (value) {
                            setState(() {
                              selectedStage = value!;
                            });
                          },
                          decoration: _dropdownDecoration(context),
                        ),
                        SizedBox(height: 16),
                        CustomTextFormField(
                          controller: _courseNameController,
                          hintText: 'اسم الكورس',
                          validator: (value) =>
                          value == null || value.isEmpty ? 'اكتب اسم الكورس' : null,
                        ),
                        SizedBox(height: 24),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: lessonInputs.length,
                          itemBuilder: (context, index) {
                            final input = lessonInputs[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextFormField(
                                        controller: input.nameController,
                                        hintText: 'عنوان الدرس رقم ${index + 1}',
                                        validator: (value) =>
                                        value == null || value.isEmpty ? 'اكتب العنوان' : null,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => _removeLesson(index),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h,),
                                CustomTextFormField(
                                  controller: input.vedioUrlController,
                                  hintText: 'رابط الدرس',
                                  validator: (value) {
                                    final pdf = lessonInputs[index].pdfUrlController.text.trim();
                                    if ((value == null || value.isEmpty) && pdf.isEmpty) {
                                      return 'اكتب رابط الفيديو أو الملف';
                                    }
                                    return null;
                                  },

                                ),
                                SizedBox(height: 10.h,),
                                CustomTextFormField(
                                  controller: input.pdfUrlController,
                                  hintText: 'رابط الملف',
                                  validator: (value) {
                                    final video = lessonInputs[index].vedioUrlController.text.trim();
                                    if ((value == null || value.isEmpty) && video.isEmpty) {
                                      return 'اكتب رابط الفيديو أو الملف';
                                    }
                                    return null;
                                  },

                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(height: 16),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _addLesson,
                          icon: Icon(Icons.add),
                          label: Text('إضافة درس جديد'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar:     SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async => await _saveCourse(context),
                    child: Text('حفظ'),
                  ),
                ),
              ),
            );
          }
          return LoadingWidget();
        },
      ),
    );
  }

  CustomDropdownDecoration _dropdownDecoration(BuildContext context) {
    return CustomDropdownDecoration(
      closedFillColor:
      Theme.of(context).inputDecorationTheme.fillColor ?? Colors.transparent,
      expandedFillColor: Theme.of(context).cardColor,
      closedShadow: [
        BoxShadow(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color(0xff424242)
              : Color(0xffF2F3F3),
        ),
      ],
      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle ??
          TextStyle(color: Theme.of(context).hintColor),
      listItemStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
      ),
    );
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    for (var input in lessonInputs) {
      input.nameController.dispose();
      input.vedioUrlController.dispose();
      input.pdfUrlController.dispose();
    }
    super.dispose();
  }
}
