import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:e_learning/core/logic/get_quizzes/get_quizzes_cubit.dart';
import 'package:e_learning/core/logic/upload_quiz/upload_quiz_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/models/questions_for_upload.dart';
import '../../../core/models/stage_group_schedule_model.dart';
import '../../../core/widgets/compress_image.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/showMessage.dart';
import '../../nav_button/views/nav_button_screen.dart';

class QuizQuestionInput {
  final TextEditingController questionTextController = TextEditingController();
  final List<ChoiceInput> choices = [
    ChoiceInput(),
    ChoiceInput(),
  ];
  File? image;
}

class ChoiceInput {
  final TextEditingController textController = TextEditingController();
  bool isCorrect = false;
}

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quizTitleController = TextEditingController();
  DataList? selectedStage;

  List<QuizQuestionInput> questions = [QuizQuestionInput()];

  void _addQuestion() {
    setState(() {
      questions.add(QuizQuestionInput());
    });
  }

  void _removeQuestion(int index) {
    if (questions.length > 1) {
      setState(() {
        questions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب وجود سؤال واحد على الأقل')),
      );
    }
  }

  void _addChoice(QuizQuestionInput question) {
    setState(() {
      question.choices.add(ChoiceInput());
    });
  }

  void _removeChoice(QuizQuestionInput question, int index) {
    if (question.choices.length > 2) {
      setState(() {
        question.choices.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب وجود اختيارين على الأقل')),
      );
    }
  }

  Future<void> _pickImage(QuizQuestionInput question) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        question.image = File(picked.path);
      });
    }
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      for (var q in questions) {
        if (q.choices.length < 2 || !q.choices.any((c) => c.isCorrect)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('كل سؤال يجب أن يحتوي على اختيارين على الأقل وواحد صحيح')),
          );
          return;
        }
      }

      List<Question> QuestionsForUpload = [];
      for (var item in questions) {
        List<Choice> ChoicesForUpload = [];
        for (var choice in item.choices) {
          ChoicesForUpload.add(Choice(
            text: choice.textController.text,
            isCorrect: choice.isCorrect,
          ));
        }
        File? img = item.image;

        if (item.image != null) {
          try {
            final compressed = await compressImage(item.image!);
            if (compressed != null) {
              img = compressed;
            }
          } catch (e) {
            // الضغط فشل — استمر باستخدام الصورة الأصلية بدون تغيير
            debugPrint('Image compression failed: $e');
          }
        }

// تابع استخدام img سواء كانت مضغوطة أو الأصلية


        QuestionsForUpload.add(
          Question(
            text: item.questionTextController.text,
            choices: ChoicesForUpload,
            image:img ,
          ),
        );
      }

      /// ✅ نخرج النداء بره اللوب
      await context.read<UploadQuizCubit>().uploadQuiz(
        title: _quizTitleController.text,
        questions: QuestionsForUpload,
        timeLimit: _timeLimit ?? 10,
        stageId: selectedStage?.id ?? '',
        teacherName: context.read<GetUserDataCubit>().userModel?.name??"المدرس",

      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('املأ كل البيانات المطلوبة')),
      );
    }
  }


  @override
  void dispose() {
    _quizTitleController.dispose();
    for (var q in questions) {
      q.questionTextController.dispose();
      for (var c in q.choices) {
        c.textController.dispose();
      }
    }
    super.dispose();
  }
  int? _timeLimit;
  final TextEditingController _timeLimitController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة اختبار جديد'),

      ),

      body: BlocConsumer<UploadQuizCubit, UploadQuizState>(
        builder: (BuildContext context, state) {

          if (state is GetStageSuccess) {
            return Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomDropdown<DataList>(
                        hintText: 'اختر المرحلة',
                        items: context.read<UploadQuizCubit>().dataListDropdownItems,

                        onChanged: (value) => setState(() => selectedStage = value!),
                        decoration: _dropdownDecoration(context),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quizTitleController,
                        decoration: const InputDecoration(labelText: 'عنوان الاختبار'),
                        validator: (val) => val == null || val.isEmpty ? 'اكتب عنوان الاختبار' : null,
                      ),

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'مدة الاختبار بالدقائق'),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'اكتب مدة الاختبار';
                          if (int.tryParse(val) == null || int.parse(val) <= 0) return 'اكتب مدة صحيحة';
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            _timeLimit = int.tryParse(val);
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: questions.length,
                        itemBuilder: (context, qIndex) {
                          final q = questions[qIndex];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: q.questionTextController,
                                          decoration: InputDecoration(labelText: 'السؤال ${qIndex + 1}'),
                                          validator: (val) => val == null || val.isEmpty ? 'اكتب نص السؤال' : null,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeQuestion(qIndex),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (q.image != null)
                                    Center(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.file(
                                                q.image!,
                                                height: 120,
                                                width: 180,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: -8,
                                              right: -8,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    q.image = null;
                                                  });
                                                },
                                                borderRadius: BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.redAccent,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 4,
                                                        offset: Offset(1, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    )
                                  else
                                    Center(
                                      child: TextButton(
                                        onPressed: () => _pickImage(q),
                                        child: const Text('اختيار صورة'),
                                      ),
                                    ),
                                  const SizedBox(height: 8),

                                  const Text('الاختيارات:'),
                                  Column(
                                    children: List.generate(q.choices.length, (cIndex) {
                                      final c = q.choices[cIndex];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: c.textController,
                                              decoration: InputDecoration(labelText: 'اختيار ${cIndex + 1}'),
                                              validator: (val) => val == null || val.isEmpty ? 'اكتب الاختيار' : null,
                                            ),
                                          ),
                                          Checkbox(
                                            value: c.isCorrect,
                                            onChanged: (val) {
                                              setState(() {
                                                for (var other in q.choices) {
                                                  other.isCorrect = false;
                                                }
                                                c.isCorrect = val ?? false;
                                              });
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () => _removeChoice(q, cIndex),
                                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  TextButton.icon(
                                      onPressed: () => _addChoice(q),
                                      icon: const Icon(Icons.add),
                                      label: const Text('إضافة اختيار')
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة سؤال جديد'),
                      )
                    ],
                  ),
                ),
              ),
              bottomNavigationBar:
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                
                    onPressed: _saveQuiz,
                    child: const Text('حفظ'),
                  ),
                ),
              )
              ,
            );
          } else {
            return LoadingWidget();
          }
        },
        listener: (BuildContext context, UploadQuizState state) async {
          if (state is UploadQuizError) {
            ShowMessage.showToast('حدث خطأ غير متوقع');
          }
          if (state is UploadQuizSuccess) {
            await context.read<GetQuizzesCubit>().getAllQuizzes(isTeacher: true,teacherId: Supabase.instance.client.auth.currentUser!.id, teacherIdsForStudent: []);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavButton()),
            );
            ShowMessage.showToast(
              'تمت عملية النشر بنجاح',
              backgroundColor: Colors.green,
            );
          }
        },
      ),
    );
  }
  CustomDropdownDecoration _dropdownDecoration(BuildContext context) {
    return CustomDropdownDecoration(
      closedFillColor:
      Theme.of(context).inputDecorationTheme.fillColor ??
          Colors.transparent,
      expandedFillColor: Theme.of(context).cardColor,
      closedShadow: [
        BoxShadow(
          color:
          Theme.of(context).brightness == Brightness.dark
              ? Color(0xff424242)
              : Color(0xffF2F3F3),
        ),
      ],
      hintStyle:
      Theme.of(context).inputDecorationTheme.hintStyle ??
          TextStyle(color: Theme.of(context).hintColor),
      listItemStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
      ),
    );
  }

}



