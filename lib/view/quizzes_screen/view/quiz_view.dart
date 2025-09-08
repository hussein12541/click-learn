import 'package:e_learning/core/logic/get_quizzes/get_quizzes_cubit.dart';
import 'package:e_learning/core/logic/score/score_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constant/constant.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../widgets/Leaderboard.dart';
import '../widgets/quiz_details_screen.dart';

class QuizzesScreen extends StatefulWidget {
  final String stageId;
  final String teacherId;
  const QuizzesScreen({super.key, required this.stageId, required this.teacherId});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     context.read<ScoreCubit>().getScoreForTeacher(teacherId: widget.teacherId);
  }
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isTeacher = context.watch<GetUserDataCubit>().isTeacher;


    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الاختبارات'),actions: [IconButton(onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => LeaderboardScreen(stageId: widget.stageId, teacherId: widget.teacherId,),)), icon: SvgPicture.asset('assets/images/images/ranking.svg',color: kPrimaryColor,width: 35,height: 35,))],),
      body: RefreshIndicator(
        onRefresh: () async => await   context.read<GetQuizzesCubit>().getAllQuizzes(isTeacher: context.read<GetUserDataCubit>().isTeacher,teacherIdsForStudent: context
                  .read<GetUserDataCubit>()
                  .groups
                  .map((e) => e.teacher_id)
                  .whereType<String>()
                  .toList(), teacherId: Supabase.instance.client.auth.currentUser!.id,
              ),

        child: BlocBuilder<GetQuizzesCubit, GetQuizzesState>(
          builder: (context, state) {
            final cubit = context.watch<GetQuizzesCubit>();
            final quizzes = cubit.quizzes.where((element) => element.stageId==widget.stageId&&element.teacher_id==widget.teacherId,).toList();


            // حالة التحميل
            if (state is GetQuizzesLoading) {
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
            }

            // حالة الخطأ
            if (state is GetQuizzesError) {
              return const Center(
                child: Text(
                  "❌ حدث خطأ غير متوقع، حاول لاحقا.",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // حالة عدم وجود بيانات
            if (quizzes.isEmpty) {
              return const Center(
                child: Text(
                  "لا يوجد أي اختبارات حالياً.",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // العرض الأساسي
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10),
                    leading: SvgPicture.asset(
                      'assets/images/images/exam_icon.svg'

                      ,color: isDark ? Colors.white : kLightPrimaryColor,
                    ),
                    title: Text(
                      quiz.tittle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        '⏱ المدة: ${quiz.timeLimit} دقيقة',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    trailing:isTeacher? PopupMenuButton<String>(
                  tooltip: 'خيارات الاختبار',
                    onSelected: (value) async {
                      if (value == 'isShown') {
                        await cubit.showOrHideQuiz(quiz:quiz );
                      } else if (value == 'delete') {
                        await cubit.deleteQuiz(quiz:quiz );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'isShown',
                        child: Text(quiz.isShown == true ? '🔒 إخفاء الاختبار' : '🔓 إظهار الاختبار'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('🗑️ حذف', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ): Icon(Icons.arrow_forward_ios, size: 16),

                // trailing: isTeacher?IconButton(onPressed: () async => await cubit.deleteQuiz(quiz:quiz ), icon: Icon(CupertinoIcons.delete,color: Colors.red,)):const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                //

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizDetailsScreen(quiz: quiz),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
