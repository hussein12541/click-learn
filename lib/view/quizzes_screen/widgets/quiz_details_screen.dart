import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/logic/score/score_cubit.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/models/quiz_model.dart';
import '../../../core/quiz_sql/quiz_db_helper.dart';


class QuizDetailsScreen extends StatefulWidget {
  final QuizModel quiz;
  const QuizDetailsScreen({super.key, required this.quiz});

  @override
  State<QuizDetailsScreen> createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> with WidgetsBindingObserver {
  late List<int?> selectedAnswers;

  bool isSubmitted = false;
  int correctCount = 0;
  late Timer _timer;
  int seconds = 0;
  List<int> wrongQuestionIndexes = [];

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addObserver(this); // 👈 كده بنرصد حالة التطبيق
    selectedAnswers = List.filled(widget.quiz.questions.length, null);
    seconds = widget.quiz.timeLimit * 60;
    _checkQuizStatus();
  }

  Future<void> _checkQuizStatus() async {
    final existingResult = await QuizDbHelper.getResult(widget.quiz.id);
    if (existingResult != null) {
      setState(() {
        isSubmitted = true;
        correctCount = existingResult['score'];
        wrongQuestionIndexes = existingResult['wrongQuestions']
            ?.toString()
            .split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e) ?? 0)
            .toList() ??
            [];

        selectedAnswers = existingResult['selectedAnswers']
            ?.toString()
            .split(',')
            .map((e) => e.isEmpty ? null : int.tryParse(e))
            .toList() ??
            List.filled(widget.quiz.questions.length, null);
      });
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        _submitAnswers();
      } else {
        setState(() => seconds--);
      }
    });
  }

  void _submitAnswers() async {
    _timer.cancel();
    correctCount = 0;
    wrongQuestionIndexes.clear();

    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final correctIndex = widget.quiz.questions[i].choices.indexWhere((c) => c.isCorrect);
      if (selectedAnswers[i] == correctIndex) {
        correctCount++;
      } else {
        wrongQuestionIndexes.add(i);
      }
    }

    await QuizDbHelper.saveResult(
      quizId: widget.quiz.id,
      score: correctCount,
      total: widget.quiz.questions.length,
      wrongIndexes: wrongQuestionIndexes,
      selectedAnswers: selectedAnswers,
    );

    await context.read<ScoreCubit>().addScore(score: correctCount, quiz_id:  widget.quiz.id, teacherId: widget.quiz.teacher_id);


    setState(() => isSubmitted = true);
    _showResultDialog();
  }








  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('النتيجة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            if (correctCount >= widget.quiz.questions.length / 2)
              Lottie.asset('assets/json/celebrate.json',width: 100.w,height: 100.h)
            else
              Lottie.asset('assets/json/bad.json',width: 100.w,height: 100.h),
            SizedBox(height: 20.h),
            Text(' أجبت على $correctCount من ${widget.quiz.questions.length}'),

          ],
        ),

      ),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.inactive || state == AppLifecycleState.paused) && !isSubmitted) {
      _submitAnswers(); // 👈 لو التطبيق خرج أو راح في الخلفية يبعت الإجابات
    }
  }
  @override
  void dispose() {
    if (!isSubmitted) _timer.cancel();
    WidgetsBinding.instance.removeObserver(this); // 👈 نلغي المراقبة
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
      if (!isSubmitted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تحذير 🛑'),
            content: const Text('إذا خرجت الأن سيتم إرسال الإجابات التي أخترتها. هل أنت متأكد من الخروج ؟'),
            actions: [
              TextButton(
                child: const Text('لا'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                child: const Text('نعم'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (confirm == true) {
          _submitAnswers(); // 👈 يسجل الإجابات
          return true;      // 👈 يخرج فعلاً
        } else {
          return false;     // 👈 يرجع للإمتحان
        }
      }
      return true; // لو الامتحان متسجّل بالفعل يسمح بالخروج عادي
    },
      child: BlocBuilder<ScoreCubit,ScoreState>(
        builder: (context, state) => (state is AddScoreLoading||state is AddScoreError||state is GetScoreLoading||state is GetScoreError)?Scaffold(body: LoadingWidget(),):Scaffold(
          appBar: AppBar(
            title: Text('الأسئلة'),
            actions: [
              if (!isSubmitted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      _formatTime(seconds),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.quiz.questions.length,
            itemBuilder: (context, index) {
              final question = widget.quiz.questions[index];
              final correctIndex = question.choices.indexWhere((c) => c.isCorrect);

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سؤال ${index + 1}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kLightPrimaryColor)),
                      const SizedBox(height: 8),
                      Text(question.text, style: const TextStyle(fontSize: 16)),
                      if (question.imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: GestureDetector(
                            onTap: () {
                              showImageViewer(
                                context,
                                CachedNetworkImageProvider(question.imageUrl),
                                swipeDismissible: true,
                                doubleTapZoomable: true,
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: question.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180.h,
                              placeholder: (context, url) => Skeletonizer(
                                enabled: true,
                                child: Container(width: double.infinity, height: 180.h, color: Colors.grey[300]),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Column(
                        children: List.generate(question.choices.length, (choiceIndex) {
                          final choice = question.choices[choiceIndex];
                          final isSelected = selectedAnswers[index] == choiceIndex;
                          final isCorrect = choice.isCorrect;
                          Color? backgroundColor;
                          Color borderColor = Colors.grey.shade300;
                          IconData iconData = Icons.circle_outlined;
                          Color iconColor = Colors.grey;

                          if (isSubmitted) {
                            if (isCorrect) {
                              backgroundColor = Colors.green.withOpacity(0.1);
                              borderColor = Colors.green;
                              iconData = Icons.check_circle;
                              iconColor = Colors.green;
                            } else if (isSelected && !isCorrect) {
                              backgroundColor = Colors.red.withOpacity(0.1);
                              borderColor = Colors.red;
                              iconData = Icons.cancel;
                              iconColor = Colors.red;
                            }
                          } else if (isSelected) {
                            backgroundColor = kLightPrimaryColor.withOpacity(0.1);
                            borderColor = kLightPrimaryColor;
                            iconData = Icons.radio_button_checked;
                            iconColor = kLightPrimaryColor;
                          }

                          return GestureDetector(
                            onTap: isSubmitted
                                ? null
                                : () {
                              setState(() {
                                selectedAnswers[index] = choiceIndex;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  Icon(iconData, color: iconColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      choice.text,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      if (isSubmitted && selectedAnswers[index] == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'لم يتم اختيار إجابة لهذا السؤال',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: isSubmitted
              ? null
              : SafeArea(
                child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                onPressed: () => _submitAnswers(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('إرسال الإجابات', style: TextStyle(fontSize: 16)),
                            ),
                          ),
              ),
        ),
      ),
    );
  }
}
